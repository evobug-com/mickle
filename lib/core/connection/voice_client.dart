import 'dart:io';
import 'dart:typed_data';

import 'package:talk/core/connection/message_stream_handler.dart';

class VoiceClientAddress {
  final InternetAddress host;
  final int port;

  VoiceClientAddress({required this.host, required this.port});

  @override
  String toString() {
    return '$host:$port';
  }
}

class VoiceClient {
  late RawDatagramSocket _socket;
  late VoiceClientAddress _address;
  late MessageStreamHandler _messageStreamHandler;

  static Future<VoiceClient> connect(VoiceClientAddress address, String token) async {
    final client = VoiceClient();

    client._address = address;
    client._socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    client._socket.listen((event) {
      switch(event) {
        case RawSocketEvent.closed:
        // TODO: Handle this case.
          break;
        case RawSocketEvent.read:
          final datagram = client._socket.receive();
          if(datagram == null) {
            return;
          }

          client._messageStreamHandler.onUDPData(datagram.data);
          break;
        case RawSocketEvent.readClosed:
        // Never happens, UDP Socket cannot be closed by a remote peer
          break;
        case RawSocketEvent.write:

          break;
      }
    }, onError: client.onError, onDone: client.onDone);

    client._messageStreamHandler = MessageStreamHandler(client.onData);

    return client;
  }

  void onError(Object error, StackTrace stackTrace) {
    print('Error: $error');
  }

  void onDone() {
    print('Done');
  }

  void sendData(Uint8List data) {
    _socket.send(data, _address.host, _address.port);
  }

  Future<void> onData(Uint8List data) async {

  }
}