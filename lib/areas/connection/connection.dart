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
import 'package:talk/areas/connection/connection_error.dart';
import 'package:talk/areas/connection/connection_manager.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/network/api_types.dart';
import 'package:talk/core/network/utils.dart';
import '../../core/connection/message_stream_handler.dart';
import '../../core/processor/response_processor.dart';
import 'connection_status.dart';

class Connection {
  final String connectionUrl;
  final ValueNotifier<ConnectionStatus> _status = ValueNotifier(ConnectionStatus.disconnected);
  Database? database;
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
  int _reconnectAttempts = 0;
  bool _reconnectEnabled = true;
  Timer? _reconnectTimer;

  // Connection
  SecureSocket? _socket;

  // Error handling
  ConnectionError? error;

  Connection({required this.connectionUrl}) {
    _logger = Logger('Connection($connectionUrl)');
    _messageStreamHandler = MessageStreamHandler((Uint8List data) async {
      return processResponse(this, data);
    });
    packetManager = PacketManager(this);
  }

  Timer? get reconnectTimer => _reconnectTimer;
  set reconnectTimer(Timer? value) => _reconnectTimer = value;
  bool get isReconnectEnabled => _reconnectEnabled;
  set isReconnectEnabled(bool value) => _reconnectEnabled = value;
  int get reconnectAttempts => _reconnectAttempts;
  set reconnectAttempts(int value) => _reconnectAttempts = value;
  ValueListenable<ConnectionStatus> get status => _status;


  connect() async {
    _status.value = ConnectionStatus.connecting;

    try {
      _socket = await SecureSocket.connect(
        connectionUrl,
        int.parse(connectionUrl.split(':')[1]),
        onBadCertificate: (certificate) {
          _logger.warning('Bad certificate: $certificate');
          return true;
        },
        context: SecurityContext.defaultContext,
        timeout: Duration(seconds: 5),
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
      database = Database(mainServerId!);
      _status.value = ConnectionStatus.authenticated;
    } else {
      _logger.warning('Authentication failed: ${authResult.error}');
      _handleError(ConnectionError.authenticationFailed(authResult.error?.message ?? "Unknown authentication error"));
    }
    
    return authResult;
  }

  void send(Uint8List data) {
    _socket?.add(data);
  }
}