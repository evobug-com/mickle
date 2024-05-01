import 'package:flutter/material.dart';
import 'connection.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();
  Map<String, Connection> sessions = {};

  Connection addSession(String serverAddress, String username, String password, Function(dynamic) onError, Function() onLogin) {
    if(sessions.containsKey(serverAddress)) {
      return sessions[serverAddress]!;
    }

    final connection = Connection(serverAddress: serverAddress, onError: onError, onLogin: onLogin);
    sessions[serverAddress] = connection;
    connection.connect(username: username, password: password);

    notifyListeners();

    return connection;
  }

  Connection? removeSession(String serverAddress) {
    if(!sessions.containsKey(serverAddress)) {
      return null;
    }

    final connection = sessions.remove(serverAddress);
    connection!.disconnect();

    notifyListeners();
    return connection;
  }

  Connection? getSession(String serverAddress) {
    return sessions[serverAddress];
  }
}