import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:flutter/foundation.dart';
import 'package:talk/core/notifiers/current_connection.dart';

import '../database.dart';
part 'models.g.dart';

extension UserExtension on User {
  List<Role> getRoles() {
    CurrentSession session = CurrentSession();
    Database database = Database(session.server!.id);
    final roles = database.roleUsers.outputs(id);
    return roles.map((relation) => database.roles.get("Role:${relation.input}")!).toList();
  }
}

extension RoleExtension on Role {
  List<Permission> getPermissions() {
    CurrentSession session = CurrentSession();
    Database database = Database(session.server!.id);
    final permissions = database.rolePermissions.inputs(id);
    return permissions.map((relation) => database.permissions.get("Permission:${relation.output}")!).toList();
  }

  List<User> getUsers() {
    CurrentSession session = CurrentSession();
    Database database = Database(session.server!.id);
    final users = database.roleUsers.inputs(id);
    return users.map((relation) => database.users.get("User:${relation.output}")!).toList();
  }
}

extension ChannelExtension on Channel {
  List<Message> getMessages() {
    final database = Database(CurrentSession().connection!.serverId!);
    final channelMessagesRelations = database.channelMessages.inputs(id);

    // Get all messages for channelMessagesRelations by id
    final channelMessages = channelMessagesRelations.map((relation) => database.messages.get("Message:${relation.output}")!).toList();
    channelMessages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    return channelMessages;
  }

  containsMessage(Message message) {
    final database = Database(CurrentSession().connection!.serverId!);
    final channelMessagesRelations = database.channelMessages.outputs(message.id);
    return channelMessagesRelations.any((relation) => relation.input == id);
  }
}