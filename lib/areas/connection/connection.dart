// # Connection
//
// The Connection class represents a TCP connection to a server.
// It provides an interface for sending and receiving messages, as well as handling connection events.
// Connections hold a state to main server identity and current user identity.
//
// Connection Status is controlled from this class, it cannot be changed from outside.

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mickle/areas/connection/connection_error.dart';
import 'package:mickle/areas/connection/connection_manager.dart';
import 'package:mickle/core/database.dart';
import 'package:mickle/core/managers/packet_manager.dart';
import 'package:mickle/core/models/models.dart';
import 'package:mickle/core/network/api_types.dart';
import 'package:mickle/core/storage/preferences.dart';
import '../../core/connection/message_stream_handler.dart';
import '../../core/processor/response_processor.dart';
import 'connection_status.dart';

class Connection {
  final String connectionUrl;
  final ValueNotifier<ConnectionStatus> _status = ValueNotifier(ConnectionStatus.disconnected);
  final Database database = Database();
  late PacketManager packetManager;
  String? currentUserId;
  User? currentUser;
  String? mainServerId;
  Server? mainServer;
  List<String>? serverIds;
  String? token;
  late Logger _logger;
  late final MessageStreamHandler _messageStreamHandler;

  // Reconnection
  int reconnectAttempts = 0;
  bool _reconnectEnabled = true;
  Timer? reconnectTimer;

  // Connection
  SecureSocket? _socket;

  // Error handling
  ConnectionError? error;

  Connection({required this.connectionUrl}) {
    _logger = Logger('Connection($connectionUrl)');
    packetManager = PacketManager(this);
    _messageStreamHandler = MessageStreamHandler((Uint8List data) async {
      return processResponse(this, data);
    });
  }
  bool get isReconnectEnabled => _reconnectEnabled;
  set isReconnectEnabled(bool value) {
    print('[Connection $connectionUrl] Setting reconnectEnabled to $value');
    _reconnectEnabled = value;
    if(!value) {
      reconnectAttempts = 0;
      reconnectTimer?.cancel();
    }
  }
  ValueListenable<ConnectionStatus> get status => _status;


  connect() async {
    if(_status.value != ConnectionStatus.disconnected) {
      throw ConnectionError.fromException('Connection is not in disconnected state (${_status.value})');
    }

    error = null;
    _status.value = ConnectionStatus.connecting;

    try {
      final [host, port] = connectionUrl.split(':');

      _socket = await SecureSocket.connect(
        host,
        int.parse(port),
        onBadCertificate: (certificate) {
          _logger.warning('Bad certificate: $certificate');
          return true;
        },
        context: SecurityContext.defaultContext,
        timeout: const Duration(seconds: 5),
      );

      _socket!.setOption(SocketOption.tcpNoDelay, true);

      _socket!.listen(
        _messageStreamHandler.onData,
        onDone: _handleDone,
        onError: _handleError,
        cancelOnError: true,
      );

      _status.value = ConnectionStatus.connected;
    } catch(e) {
      _handleError(e);
    }
  }

  /// If the socket closes and sends a done event, this handler is called.
  void _handleDone() {
    _status.value = ConnectionStatus.disconnected;
    ConnectionManager().onConnectionDone(this);
  }

  void _handleError(dynamic e) {
    ConnectionError connectionError;
    if (e is ConnectionError) {
      connectionError = e;
    } else {
      connectionError = ConnectionError.fromException(e);
    }
    _setError(connectionError);
  }

  void _setError(ConnectionError err) {
    _logger.severe('Socket error: $err');
    _status.value = ConnectionStatus.error;
    error = err;
    ConnectionManager().onConnectionError(this);
  }

  disconnect() async {
    _logger.info('Disconnecting...');
    if(_socket != null) {
      await _socket!.close();
      _socket = null;
    }

    _status.value = ConnectionStatus.disconnected;
  }

  Future<ApiResponse<ResLoginPacket>> authenticate({String? username, String? password, String? token}) async {
    error = null;
    _status.value = ConnectionStatus.authenticating;
    
    final authResult = await packetManager.sendLogin(
      username: username,
      password: password,
      token: token,
    );
    
    if(authResult.error == null) {
      currentUserId = authResult.data!.userId;
      mainServerId = authResult.data!.mainServerId;
      serverIds = authResult.data!.serverIds;
      this.token = authResult.data!.token;
    } else {
      _logger.warning('Authentication failed: ${authResult.error}');
      // Disable reconnect if authentication failed
      isReconnectEnabled = false;
      _handleError(ConnectionError.authenticationFailed(authResult.error?.message ?? "Unknown authentication error"));
    }
    
    return authResult;
  }

  onWelcome(EvtWelcomePacket packet) async {
    currentUser = database.users.firstWhereOrNull((element) => element.id == currentUserId!);
    mainServer = database.servers.firstWhereOrNull((element) => element.id == mainServerId!);
    _status.value = ConnectionStatus.authenticated;

    // Update entrypoint data with the new data
    var entrypointData = await Preferences.getEndpoint(connectionUrl)!;
    entrypointData = entrypointData!.copyWith(
      username: currentUser!.username,
      serverName: mainServer!.name,
    );
    await Preferences.setEndpoint(connectionUrl, entrypointData!);
  }

  void send(Uint8List data) {
    _socket?.add(data);
  }
}