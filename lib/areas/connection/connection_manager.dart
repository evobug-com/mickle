// # Connection Manager
//
// The Connection Manager is responsible for handling multiple WebSocket connections
// in the Talk application. It provides an interface for creating, managing, and
// closing connections, as well as reconnecting. Each server is identified by hostname or IP address and port.
//
// On successful connection, the connection status is set to connected and
// the server is saved in Secure Storage.
//
// The Connection Manager is notified only when we are connecting to a new server or removing a server.
// It is not notified when the connection status changes. In this case, the Connection class is responsible for notifying the listeners.
//
// Example: localhost:55000

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:talk/areas/connection/connection_tofu.dart';
import 'package:talk/core/storage/secure_storage.dart';

import '../security/security_provider.dart';
import 'connection.dart';
import 'connection_error.dart';
import 'connection_status.dart';

class ConnectionManager extends ChangeNotifier {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final Logger _logger = Logger('ConnectionManager');
  final Map<String, Connection> _connections = {};
  Iterable<Connection> get connections => _connections.values;

  /// The maximum number of backoff seconds for reconnection attempts.
  static const int maxBackoffSeconds = 300;

  // ignore: unused_field
  final Timer _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    print("Pinging connections... (${_instance._connections.length})");
    for (final connection in _instance._connections.values) {
      if(connection.status.value == ConnectionStatus.authenticated) {
        connection.packetManager.sendPing();
        print("Sending ping to ${connection.connectionUrl}");
      }
    }
  });

  Future<Connection> connect(String connectionUrl, {bool? disconnectOnError, bool? doNotStoreInConnections, bool? disableAutoReconnect}) async {
    final connection = doNotStoreInConnections == true ? Connection(connectionUrl: connectionUrl) : _connections.putIfAbsent(connectionUrl, () => Connection(connectionUrl: connectionUrl));
    if(disableAutoReconnect == true) {
      connection.isReconnectEnabled = false;
    }

    if(connection.status.value != ConnectionStatus.disconnected && connection.status.value != ConnectionStatus.error) {
      throw ConnectionError.fromException('Connection is not in disconnected state (${connection.status.value})');
    }

    await connection.connect();

    final completion = Completer<Connection>();
    var scheduledCompletion = false;

    if(connection.error == null) {
      final serverPublicKey = await connection.packetManager.sendFetchPublicKey();
      if(serverPublicKey.error != null) {
        connection.error = ConnectionError.tofuError('Failed to fetch public key: ${serverPublicKey.error}');
      } else {
        bool isVerified = await TOFUService.verifyServerIdentity(connectionUrl, serverPublicKey.data!.publicKey, serverPublicKey.data!.signature);
        if(!isVerified) {
          connection.error = ConnectionError.tofuError('Server identity verification failed');
          SecurityWarningsProvider().addWarning(
              SecurityWarning(
                  connectionUrl,
                  "The ${connectionUrl}'s identity has changed. This could indicate a security risk.\n\nExpected:\n${await TOFUService.getServerPublicKey(connectionUrl)}\nActual:\n${serverPublicKey.data!.publicKey}\n\nPlease verify the server's identity and contact the server administrator if necessary. If you are sure this is the correct server, you can proceed.\nIf you are not sure, this means that there is a security risk and you are probably connecting to a different server than you think.",
                  onProceed: (warning) async {
                    await TOFUService.resetStoredKey(warning.connectionUrl);
                    SecurityWarningsProvider().removeWarning(warning.connectionUrl);
                    await connection.connect();
                    completion.complete(connection);
                  },
                  onDismiss: (warning) {
                    SecurityWarningsProvider().removeWarning(warning.connectionUrl);
                  }
              )
          );
          scheduledCompletion = true;
        }
      }
    }

    if(connection.error != null && disconnectOnError == true) {
      connection.isReconnectEnabled = false;
      connection.disconnect();
    }

    notifyListeners();

    if(scheduledCompletion) {
      await completion.future;
    }

    notifyListeners();
    return connection;
  }

  Future<void> remove(Connection connection) async {
    connection.isReconnectEnabled = false;
    await connection.disconnect();
    _connections.remove(connection.connectionUrl);
    await SecureStorage().delete("${connection.connectionUrl}.token");
    await SecureStorage().delete("${connection.connectionUrl}.serverId");
    await SecureStorage().delete("${connection.connectionUrl}.connectionUrl");
    final endpoints = await SecureStorage().readJSONArray("endpoints");
    endpoints.remove(connection.connectionUrl);
    await SecureStorage().writeJSONArray("endpoints", endpoints);
    notifyListeners();
  }

  Future<bool> save(Connection connection) async {
    if (connection.token == null || connection.mainServerId == null) {
      throw ConnectionError.fromException('Connection token or main server ID is null');
    }

    await SecureStorage().write("${connection.connectionUrl}.token", connection.token!);
    await SecureStorage().write("${connection.connectionUrl}.serverId", connection.mainServerId!);
    await SecureStorage().write("${connection.connectionUrl}.connectionUrl", connection.connectionUrl);
    final endpoints = await SecureStorage().readJSONArray("endpoints");
    if (!endpoints.contains(connection.connectionUrl)) {
      endpoints.add(connection.connectionUrl);
      await SecureStorage().writeJSONArray("endpoints", endpoints);
    }

    return true;
  }

  void onConnectionDone(Connection connection) {
    if(connection.isReconnectEnabled) {
      _scheduleReconnect(connection);
    }
  }

  void onConnectionError(Connection connection) {
    if(connection.isReconnectEnabled) {
      _scheduleReconnect(connection);
    }
  }

  void _scheduleReconnect(Connection connection) {
    final delay = min(pow(2, connection.reconnectAttempts) + Random().nextInt(2), maxBackoffSeconds).toInt();
    _logger.info('Connection(${connection.connectionUrl}) reconnecting in $delay seconds. Attempt ${connection.reconnectAttempts + 1}');
    connection.reconnectTimer?.cancel();
    connection.reconnectTimer = Timer(Duration(seconds: delay), () => _attemptReconnect(connection));
  }

  Future<void> _attemptReconnect(Connection connection) async {
    _logger.info('Connection(${connection.connectionUrl}) reconnecting...');
    try {
      await connect(connection.connectionUrl);
      if(connection.error != null) {
        throw connection.error!;
      }

      _logger.info('Connection(${connection.connectionUrl}) reconnected');
      connection.isReconnectEnabled = false;

      final token = await getToken(connection.connectionUrl);
      if(token == null) {
        _logger.warning('Connection(${connection.connectionUrl}) token not found');
        // TODO: Require re-authentication, notify user somehow
        return;
      }

      await connection.authenticate(username: null, password: null, token: token);
      if(connection.error != null) {
        _logger.warning('Connection(${connection
            .connectionUrl}) re-authentication failed: ${connection.error}');
        // TODO: Authenticate failed, notify user somehow
        return;
      }

      connection.isReconnectEnabled = true;
      _logger.info('Connection(${connection.connectionUrl}) re-authenticated');
    } catch (e) {
      _logger.severe('Connection(${connection.connectionUrl}) reconnect failed: $e');
      if(e is Error) {
        print(e.stackTrace);
      }

      connection.reconnectAttempts++;
      if(connection.isReconnectEnabled) {
        _scheduleReconnect(connection);
      }
    }
  }

  Future<String?> getToken(String connectionUrl) async {
    return await SecureStorage().read("${connectionUrl}.token");
  }

  @override
  void dispose() {
    for (final connection in _connections.values) {
      connection.isReconnectEnabled = false;
      connection.disconnect();
    }
    _connections.clear();
    super.dispose();
  }

  Connection? getConnection(String connectionUrl) {
    return _connections[connectionUrl];
  }
}