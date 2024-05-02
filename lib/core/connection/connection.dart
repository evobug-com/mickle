import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:talk/core/connection/reconnect_manager.dart';
import 'package:talk/core/connection/session_manager.dart';
import '../listener_list.dart';
import '../models/models.dart';
import "../network/request.dart" as request;
import "../network/response.dart" as response;
import '../processor/response_processor.dart';

enum ConnState {
  none,
  connecting,
  connected,
  disconnected,
  scheduledReconnect,
}

class Connection extends ChangeNotifier {
  final String serverAddress;
  SecureSocket? connection;
  Function(dynamic) onError;
  Function onLogin;
  ConnState _state = ConnState.none;
  bool _authenticated = false;
  StreamSubscription<Uint8List>? _subscription;
  ListenerList reconnectListeners = ListenerList();
  dynamic _server;
  dynamic _user;
  dynamic serverId;
  dynamic userId;
  bool loggedIn = false;
  List<Future<void> Function()> processingBuffer = [];
  Future<void>? processingFuture;

  Connection({required this.serverAddress, required this.onError, required this.onLogin});

  set server(Server? server) {
    _server = server;
    notifyListeners();
  }

  Server? get server => _server;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  User? get user => _user;

  void connect({String? username, String? password, String? token}) {
    print("Connecting to $serverAddress");
    state = ConnState.connecting;

    final log = File('keylog.txt');
    SecureSocket.connect(
      serverAddress,
      55000,
      context: SecurityContext.defaultContext, keyLog: (line) => log.writeAsStringSync(line, mode: FileMode.append),
      onBadCertificate: (certificate) {
        print("Bad certificate: $certificate");
        return true;
      },
    ).then((value) {
      connection = value;
      state = ConnState.connected;
      _onOpenConnection(username: username, password: password, token: token);
    }, onError: (error) {
      print("Error: $error");
      state = ConnState.disconnected;
      if(username != null || password != null) {
        // If we were trying to login, we don't want to reconnect
        // We cannot hold the credentials in memory
        onError(error.toString());
        SessionManager().removeSession(serverAddress);
        return;
      }
      ReconnectManager().onConnectionLost(this);
    });
  }

  void disconnect() {
    if(state == ConnState.disconnected) {
      return;
    }

    if(connection == null) {
      print("Called disconnect with null connection");
      return;
    }

    print("Connection closed.");
    state = ConnState.disconnected;
    connection!.close();
  }

  void send(Uint8List data) {
    if(connection == null) {
      print("Called send with null connection");
      return;
    }

    final socket = connection!;
    socket.add(data);
  }

  set state(ConnState state) {
    _state = state;
    notifyListeners();
  }

  ConnState get state => _state;

  set authenticated(bool authenticated) {
    _authenticated = authenticated;
    notifyListeners();
  }

  bool get authenticated => _authenticated;

  void _processNextInBuffer() {
    if(processingBuffer.isNotEmpty) {
      processingFuture = processingBuffer.removeAt(0)();
      processingFuture!.then((_) {
        processingFuture = null;
        _processNextInBuffer();
      });
    }
  }

  void _onOpenConnection({String? username, String? password, String? token}) {
    if(connection == null) {
      print("Called _onOpenConnection with null connection");
      return;
    }

    final socket = connection!;
    socket.setOption(SocketOption.tcpNoDelay, true);

    final bytesBuilder = BytesBuilder();
    int? expectedLength;

    _subscription = socket.listen((data) {
      // Add newly arrived data into the buffer
      bytesBuilder.add(data);

      if (expectedLength == null && bytesBuilder.length >= 4) {
        // Read the length prefix if it's not set and sufficient data is available
        var lengthBytes = bytesBuilder.toBytes().sublist(0, 4);
        expectedLength = ByteData.sublistView(lengthBytes).getUint32(0, Endian.big);
        bytesBuilder.clear();
        // Add remaining bytes back to the builder
        bytesBuilder.add(data.sublist(4));
      }

      if (expectedLength != null && bytesBuilder.length >= expectedLength!) {
        // If we have received enough bytes for the expected length, process the message
        var completeMessage = bytesBuilder.toBytes().sublist(0, expectedLength);

        if(processingFuture != null) {
          processingBuffer.add(() {
            return processResponse(this, Uint8List.fromList(completeMessage));
          });
        } else {
          processingFuture = processResponse(this, Uint8List.fromList(completeMessage));
          processingFuture!.then((_) {
            processingFuture = null;
            _processNextInBuffer();
          });
        }

        // Remove the processed message from the buffer and reset for the next message
        var remaining = bytesBuilder.toBytes().sublist(expectedLength!);
        bytesBuilder.clear();
        bytesBuilder.add(remaining);

        // Reset the length expectation
        expectedLength = null;
      }
    }, onError: (error) {
      print("Error: $error");
      SessionManager().removeSession(serverAddress);
      onError(error);
    }, cancelOnError: true, onDone: () {
      print("Connection done.");
      state = ConnState.disconnected;
      ReconnectManager().onConnectionLost(this);
    });

    _login(username: username, password: password, token: token);
  }

  void _login({String? username, String? password, String? token}) {

    final login = request.Login(
      username: username,
      password: password,
      token: token,
    );

    send(login.serialize());
  }

  // _tryFetchSessionToken() {
  //   try {
  //     final session = Database().store.box<models.ServerSession>().query(models.ServerSession_.address.equals(serverAddress)).build().findFirst();
  //     if(session != null) {
  //       return session.token;
  //     }
  //   } catch (e) {
  //     print("Error(_tryFetchSessionToken): $e");
  //   }
  //
  //   return null;
  // }

  void reconnect() {
    disconnect();
    connect();
    reconnectListeners.notify();
  }

  void onLoginWelcome() {
    notifyListeners();
  }
}