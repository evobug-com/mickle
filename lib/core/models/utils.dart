
import 'package:collection/collection.dart';
import '../database.dart';
import 'models.dart';

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
  List<Role> getRoles({required Database database}) {

    final roles = database.roleUsers.outputs(id);
    return roles.map((relation) => database.roles.get(relation.input)!).toList();
  }

  getPermissionsForChannel(String roomId, {required Database database}) {
    final roles = getRoles(database: database);
    final permissions = roles.map((role) => role.getPermissions(database: database)).expand((element) => element).toList();

    return RoomPermissions(
      canSendMessages: permissions.any((permission) => permission.id == 'channel_send_message'),
      canReadMessages: permissions.any((permission) => permission.id == 'channel_read_message'),
      canEditMessages: permissions.any((permission) => permission.id == 'channel_edit_message'),
      canDeleteMessages: permissions.any((permission) => permission.id == 'channel_delete_message'),
      canManageRoom: permissions.any((permission) => permission.id == 'channel_update'),
    );
  }

  UnreadMessageRelation? getUnreadMessagesForChannel(Channel channel, {required Database database}) {
    final unreadMessages = database.unreadMessages.inputs(id);
    return unreadMessages.firstWhereOrNull((relation) => relation.output == channel.id);
  }
}

extension RoleExtension on Role {
  List<Permission> getPermissions({required Database database}) {
    final permissions = database.rolePermissions.inputs(id);
    return permissions.map((relation) => database.permissions.get(relation.output)!).toList();
  }

  List<User> getUsers({required Database database}) {
    final users = database.roleUsers.inputs(id);
    return users.map((relation) => database.users.get(relation.output)!).toList();
  }
}

extension ChannelExtension on Channel {
  List<Message> getMessages({required Database database}) {
    final channelMessagesRelations = database.channelMessages.inputs(id);

    // Get all messages for channelMessagesRelations by id
    final channelMessages = channelMessagesRelations.map((relation) => database.messages.get(relation.output)!).toList();
    channelMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return channelMessages;
  }

  List<User> getUsers({required Database database}) {
    final channelUsersRelations = database.channelUsers.inputs(id);

    // Get all users for channelUsersRelations by id
    final channelUsers = channelUsersRelations.map((relation) => database.users.get(relation.output)!).toList();
    return channelUsers;
  }

  String getServerId({required Database database}) {
    final serverChannelsRelations = database.serverChannels.inputs(id);
    return serverChannelsRelations.firstWhere((relation) => relation.output == id).input;
  }

  containsMessage(Message message, {required Database database}) {
    final channelMessagesRelations = database.channelMessages.outputs(message.id);
    return channelMessagesRelations.any((relation) => relation.input == id);
  }
}

extension ServerExtension on Server {
  List<Channel> getChannels({required Database database}) {
    final serverChannelsRelations = database.serverChannels.inputs(id);

    // Get all channels for serverChannelsRelations by id
    final serverChannels = serverChannelsRelations.map((relation) => database.channels.get(relation.output)).toList();
    return serverChannels.where((channel) => channel != null).map((channel) => channel!).toList();
  }

  /// Get all channels that the user is a member of
  List<Channel> getChannelsForUser(User user, {required Database database}) {
    final serverChannelsRelations = database.serverChannels.inputs(id);

    // Get all channels for serverChannelsRelations by id
    final channels = serverChannelsRelations.map((relation) => database.channels.get(relation.output)).toList();

    return channels.where((channel) {
      if(channel == null) {
        return false;
      }
      // Filter channels with channelUsers relation

      // Get relations for channel;
      final channelUsersRelations = database.channelUsers.inputs(channel.id);

      // return true if user is a member of the channel
      return channelUsersRelations.any((relation) => relation.output == user.id);
    }).map((channel) => channel!).toList();
  }

  containsChannel(Channel channel, {required Database database}) {
    final serverChannelsRelations = database.serverChannels.outputs(channel.id);
    return serverChannelsRelations.any((relation) => relation.input == id);
  }
}