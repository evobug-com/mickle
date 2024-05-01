import 'package:flutter/material.dart';

import '../connection/connection.dart';
import '../models/models.dart';

class CurrentSession extends ChangeNotifier {
  static final CurrentSession _instance = CurrentSession._internal();
  factory CurrentSession() => _instance;
  CurrentSession._internal();

  Connection? _connection;

  Connection? get connection => _connection;
  set connection(Connection? connection) {
    _connection = connection;
    notifyListeners();
  }

  User? get user => _connection?.user;
  Server? get server => _connection?.server;
}