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
// Example: vps.sionzee.cz:45034

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/storage/secure_storage.dart';

import 'connection.dart';
import 'connection_error.dart';
import 'connection_status.dart';

class ConnectionManager extends ChangeNotifier {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final Logger _logger = Logger('ConnectionManager');
  Map<String, Connection> _connections = {};
  Iterable<Connection> get connections => _connections.values;

  /// The maximum number of backoff seconds for reconnection attempts.
  static const int maxBackoffSeconds = 300;

  Future<Connection> connect(String connectionUrl) async {
    final connection = _connections.putIfAbsent(connectionUrl, () => Connection(connectionUrl: connectionUrl));

    if(connection.status.value != ConnectionStatus.disconnected && connection.status.value != ConnectionStatus.error) {
      throw ConnectionError.fromException('Connection is not in disconnected state');
    }

    _connections[connectionUrl] = connection;
    await connection.connect();
    notifyListeners();
    return connection;
  }

  Future<void> remove(Connection connection) async {
    connection.isReconnectEnabled = false;
    await connection.disconnect();
    _connections.remove(connection.connectionUrl);
    notifyListeners();
  }

  Future<bool> save(Connection connection) async {
    if (connection.status.value != ConnectionStatus.authenticated) {
      throw ConnectionError.fromException('Connection is not in authenticated state');
    }

    await SecureStorage().write("${connection.connectionUrl + connection.mainServerId!}.token", connection.token!);
    await SecureStorage().write("${connection.connectionUrl + connection.mainServerId!}.serverId", connection.mainServerId!);
    final servers = await SecureStorage().readJSONArray("servers") as List<String> ?? [];
    if (!servers.contains(connection.connectionUrl + connection.mainServerId!)) {
      servers.add(connection.connectionUrl + connection.mainServerId!);
      await SecureStorage().writeJSONArray("servers", servers);
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
      connection.reconnectAttempts = 0;

      final token = await getToken(connection.connectionUrl, connection.mainServerId!);
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

      _logger.info('Connection(${connection.connectionUrl}) re-authenticated');
    } catch (e) {
      _logger.severe('Connection(${connection.connectionUrl}) reconnect failed: $e');
      connection.reconnectAttempts++;
      if(connection.isReconnectEnabled) {
        _scheduleReconnect(connection);
      }
    }
  }

  Future<String?> getToken(String connectionUrl, String serverId) async {
    return await SecureStorage().read("${connectionUrl + serverId}.token");
  }

  @override
  void dispose() {
    for (final connection in _connections.values) {
      connection.isReconnectEnabled = false;
      connection.reconnectTimer?.cancel();
      connection.disconnect();
    }
    _connections.clear();
    super.dispose();
  }

  Connection? getConnection(String connectionUrl) {
    return _connections[connectionUrl];
  }
}