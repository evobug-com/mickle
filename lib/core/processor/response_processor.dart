import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logging/logging.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/core/managers/audio_manager.dart';
import 'package:talk/core/network/api_types.dart';
import 'package:window_manager/window_manager.dart';

import '../../screens/settings_screen/settings_provider.dart';

final _logger = Logger('ResponseProcessor');

Future<void> processResponse(Connection connection, Uint8List data) async {
  try {
    final stringJson = utf8.decode(data);
    final json = jsonDecode(stringJson);
    final packet = ApiResponse.fromJson(json);
    await _handlePacket(packet, connection);
  } catch (e) {
    _logger.severe("Error processing response: $e");
    if(e is Error) {
      _logger.severe("Error stack trace: ${e.stackTrace}");
    }
    _logger.severe("String data: ${String.fromCharCodes(data)}");
    _logger.severe("Buffer data: $data");
  }
}

Future<void> _handlePacket(ApiResponse packet, Connection connection) async {
  switch (packet.type) {
    case "ResLoginPacket":
      await handleResLoginPacket(packet.cast(ResLoginPacket.fromJson), connection);
      break;
    case "ResLoginPingPacket":
      await handleResPingPacket(packet.cast(ResLoginPacket.fromJson), connection);
      break;
    case "EvtWelcomePacket":
      await handleEvtWelcomePacket(packet.cast(EvtWelcomePacket.fromJson), connection);
      break;
    case "EvtUpdatePresencePacket":
      await handleEvtUpdatePresencePacket(packet.cast(EvtUpdatePresencePacket.fromJson), connection);
      break;
    case "ResCreateChannelMessagePacket":
      await handleResCreateChannelMessagePacket(packet.cast(ResCreateChannelMessagePacket.fromJson), connection);
      break;
    case "ResSetUserStatusPacket":
      await handleResSetUserStatusPacket(packet.cast(ResSetUserStatusPacket.fromJson), connection);
      break;
    case "ResSetUserPresencePacket":
      await handleResSetUserPresencePacket(packet.cast(ResSetUserPresencePacket.fromJson), connection);
      break;
    case "ResSetUserAvatarPacket":
      await handleResSetUserAvatarPacket(packet.cast(ResSetUserAvatarPacket.fromJson), connection);
      break;
    case "ResSetUserDisplayNamePacket":
      await handleResSetUserDisplayNamePacket(packet.cast(ResSetUserDisplayNamePacket.fromJson), connection);
      break;
    case "ResSetUserPasswordPacket":
      await handleResSetUserPasswordPacket(packet.cast(ResSetUserPasswordPacket.fromJson), connection);
      break;
    case "ResFetchChannelMessagesPacket":
      await handleResFetchChannelMessagesPacket(packet.cast(ResFetchChannelMessagesPacket.fromJson), connection);
      break;
    case "ResCreateChannelPacket":
      await handleResCreateChannelPacket(packet.cast(ResCreateChannelPacket.fromJson), connection);
      break;
    case "ResDeleteChannelPacket":
      await handleResDeleteChannelPacket(packet.cast(ResDeleteChannelPacket.fromJson), connection);
      break;
    case "ResModifyChannelPacket":
      await handleResModifyChannelPacket(packet.cast(ResModifyChannelPacket.fromJson), connection);
      break;
    case "ResAddUserToChannelPacket":
      await handleResAddUserToChannelPacket(packet.cast(ResAddUserToChannelPacket.fromJson), connection);
      break;
    case "ResRemoveUserFromChannelPacket":
      await handleResRemoveUserFromChannelPacket(packet.cast(ResDeleteUserFromChannelPacket.fromJson), connection);
      break;
    case "ResJoinVoiceChannelPacket":
      await handleResJoinVoiceChannelPacket(packet.cast(ResJoinVoiceChannelPacket.fromJson), connection);
      break;
    case "ErrorPacket":
      await handleErrorPacket(packet, connection);
      break;
  }
}

Future<void> handleErrorPacket(ApiResponse packet, Connection connection) async {
  _logger.severe("ErrorPacket: ${packet.error}");
  if(packet.requestId != null) {
    connection.packetManager.runResolveError(packet.requestId!, packet);
  }
}

Future<void> handleResLoginPacket(ApiResponse<ResLoginPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);
}

Future<void> handleResPingPacket(ApiResponse<ResLoginPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);
}

Future<void> handleEvtWelcomePacket(ApiResponse<EvtWelcomePacket> packet, Connection connection) async {
  final db = connection.database;
  db.users.addItems(packet.data!.users);
  db.servers.addItems(packet.data!.servers);
  db.channels.addItems(packet.data!.channels);
  db.roles.addItems(packet.data!.roles);
  db.serverUsers.addRelations(packet.data!.serverUsers);
  db.roleUsers.addRelations(packet.data!.roleUsers);
  db.channelUsers.addRelations(packet.data!.channelUsers);
  db.permissions.addItems(packet.data!.permissions);
  db.rolePermissions.addRelations(packet.data!.rolePermissions);
  db.serverChannels.addRelations(packet.data!.serverChannels);
  db.unreadMessages.addRelations(packet.data!.unreadMessages);
  connection.onWelcome(packet.data!);
}

Future<void> handleEvtUpdatePresencePacket(ApiResponse<EvtUpdatePresencePacket> packet, Connection connection) async {
  final user = connection.database.users.firstWhere((element) {
    return element.id == packet.data!.userId;
  });
  user.presence = packet.data!.presence;
  user.notify();
  _logger.info("User presence updated: ${user.displayName} to ${user.presence}");
}

Future<void> handleResCreateChannelMessagePacket(ApiResponse<ResCreateChannelMessagePacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error != null) {
    _logger.severe("Message error: ${packet.error}");
  } else {
    final db = connection.database;
    db.messages.addItem(packet.data!.message);
    db.channelMessages.addRelation(packet.data!.relation);
    _logger.info("Message added: ${packet.data!.message.content}");

    if (packet.data!.mentions != null && packet.data!.mentions!.contains(connection.currentUserId!)) {
      if(SettingsProvider().playSoundOnMention) {
        AudioManager.playSingleShot("Message", AssetSource("audio/mention.wav"));
      }

      final user = db.users.firstWhereOrNull((element) => element.id == packet.data!.message.user);
      if (user != null && !await windowManager.isFocused() && SettingsProvider().showDesktopNotifications) {
        LocalNotification notification = LocalNotification(
          title: "Mention from ${user.displayName}",
          body: packet.data!.message.content,
        );
        notification.show();
      }
    } else {
      if(SettingsProvider().playSoundOnAnyMessage) {
        AudioManager.playSingleShot("Message", AssetSource("audio/new_message_received.wav"));
      }
    }

    if (packet.data!.message.content.contains("porno")) {
      AudioManager.playSingleShot("EasterEgg", AssetSource("audio/easter_egg.wav"));
    }
  }
}

Future<void> handleResSetUserStatusPacket(ApiResponse<ResSetUserStatusPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      user.status = packet.data!.status;
      user.notify();
      _logger.info("User ${user.displayName} has changed status to '${user.status}'");
    }
  }
}

Future<void> handleResSetUserPresencePacket(ApiResponse<ResSetUserPresencePacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      user.presence = packet.data!.presence;
      user.notify();
      _logger.info("User ${user.displayName} has changed presence to '${user.presence}'");
    }
  }
}

Future<void> handleResSetUserAvatarPacket(ApiResponse<ResSetUserAvatarPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      user.avatar = packet.data!.avatar;
      user.notify();
      _logger.info("User ${user.displayName} has changed avatar to '${user.avatar}'");
    }
  }
}

Future<void> handleResSetUserDisplayNamePacket(ApiResponse<ResSetUserDisplayNamePacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      final displayName = user.displayName;
      user.displayName = packet.data!.displayName;
      user.notify();
      _logger.info("User $displayName has changed display name to '${user.displayName}'");
    }
  }
}

Future<void> handleResSetUserPasswordPacket(ApiResponse<ResSetUserPasswordPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    _logger.info("UserChangePassword success");
  } else {
    _logger.severe("UserChangePassword error: ${packet.error}");
  }
}

Future<void> handleResFetchChannelMessagesPacket(ApiResponse<ResFetchChannelMessagesPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    db.messages.addItems(packet.data!.messages);
    db.channelMessages.addRelations(packet.data!.relations);
    _logger.info("Fetched [${packet.data!.messages.length}, ${packet.data!.relations.length}] messages");
  } else {
    _logger.severe("FetchMessages error: ${packet.error}");
  }
}

Future<void> handleResCreateChannelPacket(ApiResponse<ResCreateChannelPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    db.channels.addItem(packet.data!.channel);
    db.channelUsers.addRelation(packet.data!.channelUserRelation);
    db.serverChannels.addRelation(packet.data!.serverChannelRelation);
    _logger.info("Channel created: ${packet.data!.channel.name}");
  } else {
    _logger.severe("ChannelCreate error: ${packet.error}");
  }
}

Future<void> handleResDeleteChannelPacket(ApiResponse<ResDeleteChannelPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    final channel = db.channels.get("Channel:${packet.data!.channelId}");
    if (channel != null) {
      db.channels.removeItem(channel);
    }
    db.channelUsers.removeRelationInput(packet.data!.channelId);
    db.serverChannels.removeRelationOutput(packet.data!.channelId);
    _logger.info("Channel deleted: ${packet.data!.channelId}");
  } else {
    _logger.severe("ChannelDelete error: ${packet.error}");
  }
}

Future<void> handleResModifyChannelPacket(ApiResponse<ResModifyChannelPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    final packetChannel = packet.data!.channel;
    final channel = db.channels.get(packetChannel.id);
    if (channel != null) {
      channel.name = packetChannel.name;
      channel.description = packetChannel.description;
      channel.notify();
      _logger.info("Channel updated: ${packetChannel.name}");
    } else {
      db.channels.addItem(packetChannel);
      _logger.info("Tried to update channel but instead was added: ${packetChannel.name}");
    }
  } else {
    _logger.severe("ChannelUpdate error: ${packet.error}");
  }
}

Future<void> handleResAddUserToChannelPacket(ApiResponse<ResAddUserToChannelPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    db.channelUsers.addRelation(packet.data!.relation);
    _logger.info("ChannelAddUser success");
  } else {
    _logger.severe("ChannelAddUser error: ${packet.error}");
  }
}

Future<void> handleResRemoveUserFromChannelPacket(ApiResponse<ResDeleteUserFromChannelPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = connection.database;
    db.channelUsers.removeRelation(packet.data!.relation);

    // IF we are the user being removed, remove the channel from our list
    if (packet.data!.relation.output == connection.currentUserId) {
      final channel = db.channels.get("Channel:${packet.data!.relation.input}");
      if (channel != null) {
        db.channels.removeItem(channel);
        db.channelUsers.removeRelationInput(channel.id);
        db.serverChannels.removeRelationOutput(channel.id);
      }
    }

    _logger.info("ChannelRemoveUser success");
  } else {
    _logger.severe("ChannelRemoveUser error: ${packet.error}");
  }
}

Future<void> handleResJoinVoiceChannelPacket(ApiResponse<ResJoinVoiceChannelPacket> packet, Connection connection) async {
  connection.packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    _logger.info("JoinVoiceChannel success");
  } else {
    _logger.severe("JoinVoiceChannel error: ${packet.error}");
  }
}