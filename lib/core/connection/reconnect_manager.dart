// This class will try to reconnect to the server every x seconds if the connection is lost.

import 'dart:math';

import 'package:talk/core/connection/connection.dart';
import 'package:collection/collection.dart';

import '../storage/secure_storage.dart';

const int maxBackoff = 300;

class ConnectionRetry {
  int attempts = 0;
  final Connection connection;
  Future<void> reconnectFuture = Future.value();
  bool stopped = false;

  ConnectionRetry(this.connection);

  void reconnect() async {

    if(stopped) {
      return;
    }

    if(connection.serverId == null) {
      // No token, no server id, no connection
      return;
    }

    final token = await SecureStorage().read("${connection.serverId}.token");
    if(token == null) {
      // No token, no connection
      return;
    }

    if(attempts == 0) {
      attempts++;
      print("Reconnecting immediately. Attempt: $attempts");
      // Try immediately
      connection.connect(token: token);
    } else {
      num delay = pow(2, attempts);
      // jitter
      delay += Random().nextInt(2);
      connection.state = ConnState.scheduledReconnect;
      delay = min(delay, maxBackoff);
      print("Scheduled reconnect. Attempt: $attempts. Delay: $delay");
      reconnectFuture = Future.delayed(Duration(seconds: delay as int), () {
        attempts++;
        connection.connect(token: token);
      });
    }
  }

  void stop() {
    // abort future
    stopped = true;
  }

}

class ReconnectManager {
  static final ReconnectManager _instance = ReconnectManager._internal();
  List<ConnectionRetry> _connections = [];

  factory ReconnectManager() {
    return _instance;
  }

  ReconnectManager._internal();

  void onConnectionLost(Connection connection) {
    // Add to the list of connections to reconnect
    // If the connection is already in the list, schedule a reconnect
    // Otherwise, create a new ConnectionRetry object and add it to the list
    final existing = _connections.firstWhereOrNull((element) => element.connection == connection);
    if(existing != null) {
      if(existing.stopped) {
        // Remove the stopped connection
        _connections.remove(existing);
        return;
      }

      existing.reconnect();
    } else {
      final retry = ConnectionRetry(connection);
      _connections.add(retry);
      retry.reconnect();
    }
  }

  getReconnectRetry(Connection connection) {
    return _connections.firstWhereOrNull((element) => element.connection == connection);
  }

  void removeConnection(Connection connection) {
    _connections.removeWhere((element) => element.connection == connection);
  }

  void removeAll() {
    for (var element in _connections) {
      element.stop();
    }
  }
}