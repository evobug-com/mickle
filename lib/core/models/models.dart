import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:flutter/foundation.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';

import '../database.dart';
part 'models.g.dart';

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


extension UserExtension on User {
  List<Role> getRoles() {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    Database database = Database(clientProvider.selectedClient!.serverId!);

    final roles = database.roleUsers.outputs(id);
    return roles.map((relation) => database.roles.get("Role:${relation.input}")!).toList();
  }

  getPermissionsForChannel(String roomId) {
    final roles = getRoles();
    final permissions = roles.map((role) => role.getPermissions()).expand((element) => element).toList();

    return RoomPermissions(
      canSendMessages: permissions.any((permission) => permission.id == 'channel_send_message'),
      canReadMessages: permissions.any((permission) => permission.id == 'channel_read_message'),
      canEditMessages: permissions.any((permission) => permission.id == 'channel_edit_message'),
      canDeleteMessages: permissions.any((permission) => permission.id == 'channel_delete_message'),
      canManageRoom: permissions.any((permission) => permission.id == 'channel_update'),
    );
  }
}

extension RoleExtension on Role {
  List<Permission> getPermissions() {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    Database database = Database(clientProvider.selectedClient!.serverId!);

    final permissions = database.rolePermissions.inputs(id);
    return permissions.map((relation) => database.permissions.get("Permission:${relation.output}")!).toList();
  }

  List<User> getUsers() {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    Database database = Database(clientProvider.selectedClient!.serverId!);

    final users = database.roleUsers.inputs(id);
    return users.map((relation) => database.users.get("User:${relation.output}")!).toList();
  }
}

extension ChannelExtension on Channel {
  List<Message> getMessages() {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    Database database = Database(clientProvider.selectedClient!.serverId!);

    final channelMessagesRelations = database.channelMessages.inputs(id);

    // Get all messages for channelMessagesRelations by id
    final channelMessages = channelMessagesRelations.map((relation) => database.messages.get("Message:${relation.output}")!).toList();
    channelMessages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    return channelMessages;
  }

  containsMessage(Message message) {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    Database database = Database(clientProvider.selectedClient!.serverId!);

    final channelMessagesRelations = database.channelMessages.outputs(message.id);
    return channelMessagesRelations.any((relation) => relation.input == id);
  }
}

extension ServerExtension on Server {
  List<Channel> getChannels() {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    final database = clientProvider.database!;

    final serverChannelsRelations = database.serverChannels.inputs(id);

    // Get all channels for serverChannelsRelations by id
    final serverChannels = serverChannelsRelations.map((relation) => database.channels.get("Channel:${relation.output}")!).toList();
    return serverChannels;
  }

  containsChannel(Channel channel) {
    CurrentClientProvider clientProvider = CurrentClientProvider();
    assert(clientProvider.selectedClient != null);
    Database database = Database(clientProvider.selectedClient!.serverId!);

    final serverChannelsRelations = database.serverChannels.outputs(channel.id);
    return serverChannelsRelations.any((relation) => relation.input == id);
  }
}