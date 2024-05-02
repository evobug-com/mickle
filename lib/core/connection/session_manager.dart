import 'package:flutter/material.dart';
import 'package:talk/core/connection/reconnect_manager.dart';
import 'connection.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();
  Map<String, Connection> sessions = {};

  Connection addSession({required String serverAddress, String? username, String? password, String? token, required Function(dynamic) onError, required Function() onSuccess}) {
    if(sessions.containsKey(serverAddress)) {
      return sessions[serverAddress]!;
    }

    final connection = Connection(serverAddress: serverAddress, onError: onError, onLogin: onSuccess);
    sessions[serverAddress] = connection;
    connection.connect(username: username, password: password, token: token);

    notifyListeners();

    return connection;
  }

  Connection? removeSession(String serverAddress) {
    if(!sessions.containsKey(serverAddress)) {
      return null;
    }

    final connection = sessions.remove(serverAddress);
    if(connection != null) {
      ReconnectManager().removeConnection(connection);
      connection.disconnect();
    }

    notifyListeners();
    return connection;
  }

  Connection? getSession(String serverAddress) {
    return sessions[serverAddress];
  }
}