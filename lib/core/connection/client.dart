import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/managers/audio_manager.dart';
import 'package:talk/core/managers/client_manager.dart';
import 'package:talk/core/connection/message_stream_handler.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/network/api_types.dart';
import 'package:talk/core/processor/response_processor.dart';

import '../models/models.dart';
import '../network/utils.dart';

enum ClientConnectionState {
  none,
  connecting,
  connected,
  disconnected,
}

class ConnectionNotifier extends ChangeNotifier {
  ClientConnectionState _state = ClientConnectionState.none;
  ClientConnectionState get state => _state;

  void updateState(ClientConnectionState state) {
    if(state == ClientConnectionState.connected) {
      AudioManager.playSingleShot("Music", AssetSource("audio/connection_success.wav"));
    } else if(_state != ClientConnectionState.none && state == ClientConnectionState.disconnected) {
      AudioManager.playSingleShot("Music", AssetSource("audio/connection_lost.wav"));
    }
    _state = state;
    notifyListeners();
  }
}

class ClientAddress {
  final String host;
  final int port;

  ClientAddress({required this.host, required this.port});

  @override
  String toString() {
    return '$host:$port';
  }
}

class ServerData extends ChangeNotifier {
  String? serverId;
  String? userId;
  Server? server;
  User? user;

  ServerData({
    this.serverId,
    this.userId,
    this.server,
    this.user,
  });

  void updateData({
    String? serverId,
    String? userId,
    Server? server,
    User? user,
  }) {
    if(serverId != null) {
      this.serverId = serverId;
    }
    if(userId != null) {
      this.userId = userId;
    }
    if(server != null) {
      this.server = server;
    }
    if(user != null) {
      this.user = user;
    }
    notifyListeners();
  }
}

final _logger = Logger('Client');

class Client {
  SecureSocket? _socket;
  final ClientAddress _address;
  final ConnectionNotifier _connectionNotifier;
  late final MessageStreamHandler _messageStreamHandler;
  final Function(String) onError;
  final ServerData _serverData = ServerData();

  Client({
    required ClientAddress address,
    required this.onError,
  }) : _address = address,
        _connectionNotifier = ConnectionNotifier() {
    _messageStreamHandler = MessageStreamHandler((Uint8List data) async {
      return processResponse(this, data);
    });
  }

  Future<void> connect() async {
    _logger.info('Connecting to $_address...');
    _connectionNotifier.updateState(ClientConnectionState.connecting);

    final log = File('keylog.txt');
    _socket = await SecureSocket.connect(
        _address.host,
        _address.port,
        onBadCertificate: (cert) {
          _logger.warning('Bad certificate: $cert (address: $_address)');
          return true;
        },
      context: SecurityContext.defaultContext,
      keyLog: (line) => log.writeAsStringSync(line, mode: FileMode.append),
      timeout: const Duration(seconds: 5),
    );

    if(_socket != null) {
      _socket!.setOption(SocketOption.tcpNoDelay, true);

      _socket!.listen((data) {
        _messageStreamHandler.onData(data);
      }, onDone: () {
        _logger.info('onDone: Connection closed (address: $_address)');
        _connectionNotifier.updateState(ClientConnectionState.disconnected);
        ClientManager().onConnectionLost(this);
      }, onError: (e) {
        _logger.severe('Connection error: $e (address: $_address)');
        onError(e);
        _connectionNotifier.updateState(ClientConnectionState.disconnected);
      }, cancelOnError: true);

      _logger.info('Connected to $_address');
      _connectionNotifier.updateState(ClientConnectionState.connected);
    }
  }

  Future disconnect() async {
    _logger.info('Disconnected from $_address');
    _connectionNotifier.updateState(ClientConnectionState.disconnected);
    await _socket?.close();
  }

  void send(Uint8List data) {
    try {
      _socket?.add(data);
    } catch (e) {
      _logger.severe('Failed to send data: $e');
    }
  }

  Future<ApiResponse<ResLoginPacket>> login({
    String? username, String? password, String? token
  }) async {
    final result = await PacketManager(this).sendLogin(username: username, password: password, token: token);
    if(result.error != null) {
      _connectionNotifier.updateState(ClientConnectionState.disconnected); // Server rejected the login
    } else {
      _serverData.updateData(serverId: result.data!.serverIds.first, userId: result.data!.userId);
    }
    return result;
  }

  ConnectionNotifier get connection => _connectionNotifier;
  ClientAddress get address => _address;
  String? get serverId => _serverData.serverId;
  String? get userId => _serverData.userId;
  Server? get server => _serverData.server;
  User? get user => _serverData.user;
  ServerData get serverData => _serverData;
}