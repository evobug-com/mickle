import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../connection/connection.dart';
import '../database.dart';
import '../models/models.dart';

class RoomPermissions {
  bool canSendMessages = false;
  bool canReadMessages = false;
  bool canEditMessages = false;
  bool canDeleteMessages = false;
  bool canManageRoom = false;

  RoomPermissions({
    required this.canSendMessages,
    required this.canReadMessages,
    required this.canEditMessages,
    required this.canDeleteMessages,
    required this.canManageRoom,
  });
}

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

  RoomPermissions getPermissionsForChannel(String roomId) {
    final roles = user!.getRoles();
    final permissions = roles.map((role) => role.getPermissions()).toList().flattened;

    return RoomPermissions(
      canSendMessages: permissions.any((permission) => permission.id == 'channel_send_message'),
      canReadMessages: permissions.any((permission) => permission.id == 'channel_read_message'),
      canEditMessages: permissions.any((permission) => permission.id == 'channel_edit_message'),
      canDeleteMessages: permissions.any((permission) => permission.id == 'channel_delete_message'),
      canManageRoom: permissions.any((permission) => permission.id == 'channel_update'),
    );
  }
}