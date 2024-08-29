import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/managers/audio_manager.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:talk/core/network/api_types.dart';
import 'package:talk/core/network/utils.dart';
import 'package:window_manager/window_manager.dart';
import '../connection/client.dart';

final _logger = Logger('ResponseProcessor');

Future<void> processResponse(Client client, Uint8List data) async {
  try {
    final packetManager = PacketManager(client);
    final stringJson = utf8.decode(data);
    final json = jsonDecode(stringJson);
    final packet = ApiResponse.fromJson(json);
    await _handlePacket(packet, client, packetManager);
  } catch (e) {
    _logger.severe("Error processing response: $e");
    if(e is Error) {
      _logger.severe("Error stack trace: ${e.stackTrace}");
    }
    _logger.severe("String data: ${String.fromCharCodes(data)}");
    _logger.severe("Buffer data: $data");
  }
}

Future<void> _handlePacket(ApiResponse packet, Client client, PacketManager packetManager) async {
  switch (packet.type) {
    case "ResLoginPacket":
      await handleResLoginPacket(packet.cast(ResLoginPacket.fromJson), client, packetManager);
      break;
    // case response.Ping.packetName:
    //   await _handlePingResponse(client);
    //   break;
    case "EvtWelcomePacket":
      await handleEvtWelcomePacket(packet.cast(EvtWelcomePacket.fromJson), client);
      break;
    case "EvtUpdatePresencePacket":
      await handleEvtUpdatePresencePacket(packet.cast(EvtUpdatePresencePacket.fromJson), client);
      break;
    case "ResCreateChannelMessagePacket":
      await handleResCreateChannelMessagePacket(packet.cast(ResCreateChannelMessagePacket.fromJson), client, packetManager);
      break;
    case "ResSetUserStatusPacket":
      await handleResSetUserStatusPacket(packet.cast(ResSetUserStatusPacket.fromJson), client, packetManager);
      break;
    case "ResSetUserPresencePacket":
      await handleResSetUserPresencePacket(packet.cast(ResSetUserPresencePacket.fromJson), client, packetManager);
      break;
    case "ResSetUserAvatarPacket":
      await handleResSetUserAvatarPacket(packet.cast(ResSetUserAvatarPacket.fromJson), client, packetManager);
      break;
    case "ResSetUserDisplayNamePacket":
      await handleResSetUserDisplayNamePacket(packet.cast(ResSetUserDisplayNamePacket.fromJson), client, packetManager);
      break;
    case "ResSetUserPasswordPacket":
      await handleResSetUserPasswordPacket(packet.cast(ResSetUserPasswordPacket.fromJson), client, packetManager);
      break;
    case "ResFetchChannelMessagesPacket":
      await handleResFetchChannelMessagesPacket(packet.cast(ResFetchChannelMessagesPacket.fromJson), client, packetManager);
      break;
    case "ResCreateChannelPacket":
      await handleResCreateChannelPacket(packet.cast(ResCreateChannelPacket.fromJson), client, packetManager);
      break;
    case "ResDeleteChannelPacket":
      await handleResDeleteChannelPacket(packet.cast(ResDeleteChannelPacket.fromJson), client, packetManager);
      break;
    case "ResModifyChannelPacket":
      await handleResModifyChannelPacket(packet.cast(ResModifyChannelPacket.fromJson), client, packetManager);
      break;
    case "ResAddUserToChannelPacket":
      await handleResAddUserToChannelPacket(packet.cast(ResAddUserToChannelPacket.fromJson), client, packetManager);
      break;
    case "ResRemoveUserFromChannelPacket":
      await handleResRemoveUserFromChannelPacket(packet.cast(ResRemoveUserFromChannelPacket.fromJson), client, packetManager);
      break;
    case "ResJoinVoiceChannelPacket":
      await handleResJoinVoiceChannelPacket(packet.cast(ResJoinVoiceChannelPacket.fromJson), client, packetManager);
      break;
  }
}

Future<void> handleResLoginPacket(ApiResponse<ResLoginPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);
}
//
// Future<void> _handlePingResponse(Client client) async {
//   final duration = Duration(milliseconds: 100 + Random().nextInt(3000));
//   await Future.delayed(duration);
//   client.send(request.Pong().serialize());
// }
//
Future<void> handleEvtWelcomePacket(ApiResponse<EvtWelcomePacket> packet, Client client) async {
  final db = Database(client.serverId!);
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

  client.serverData.updateData(
    server: db.servers.firstWhereOrNull((element) => element.id == client.serverId),
    user: db.users.firstWhereOrNull((element) => element.id == client.userId),
  );
}

Future<void> handleEvtUpdatePresencePacket(ApiResponse<EvtUpdatePresencePacket> packet, Client client) async {
  final user = Database(client.serverId!).users.firstWhere((element) {
    return element.id == packet.data!.userId;
  });
  user.presence = packet.data!.presence;
  user.notify();
  _logger.info("User presence updated: ${user.displayName} to ${user.presence}");
}

Future<void> handleResCreateChannelMessagePacket(ApiResponse<ResCreateChannelMessagePacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error != null) {
    _logger.severe("Message error: ${packet.error}");
  } else {
    final db = Database(client.serverId!);
    db.messages.addItem(packet.data!.message!);
    db.channelMessages.addRelation(packet.data!.relation!);
    _logger.info("Message added: ${packet.data!.message!.content}");

    if (packet.data!.mentions != null && packet.data!.mentions!.contains(client.userId!)) {
      AudioManager.playSingleShot("Message", AssetSource("audio/mention.wav"));

      final user = db.users.firstWhereOrNull((element) => element.id == packet.data!.message!.user);
      if (user != null && !await windowManager.isFocused()) {
        LocalNotification notification = LocalNotification(
          title: "Mention from ${user.displayName}",
          body: packet.data!.message!.content,
        );
        notification.show();
      }
    } else {
      AudioManager.playSingleShot("Message", AssetSource("audio/new_message_received.wav"));
    }

    if (packet.data!.message!.content.contains("porno")) {
      AudioManager.playSingleShot("EasterEgg", AssetSource("audio/easter_egg.wav"));
    }
  }
}

Future<void> handleResSetUserStatusPacket(ApiResponse<ResSetUserStatusPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      user.status = packet.data!.status;
      user.notify();
      _logger.info("User ${user.displayName} has changed status to '${user.status}'");
    }
  }
}

Future<void> handleResSetUserPresencePacket(ApiResponse<ResSetUserPresencePacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      user.presence = packet.data!.presence;
      user.notify();
      _logger.info("User ${user.displayName} has changed presence to '${user.presence}'");
    }
  }
}

Future<void> handleResSetUserAvatarPacket(ApiResponse<ResSetUserAvatarPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      user.avatar = packet.data!.avatar;
      user.notify();
      _logger.info("User ${user.displayName} has changed avatar to '${user.avatar}'");
    }
  }
}

Future<void> handleResSetUserDisplayNamePacket(ApiResponse<ResSetUserDisplayNamePacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.data!.userId}");
    if (user != null) {
      final displayName = user.displayName;
      user.displayName = packet.data!.displayName;
      user.notify();
      _logger.info("User $displayName has changed display name to '${user.displayName}'");
    }
  }
}

Future<void> handleResSetUserPasswordPacket(ApiResponse<ResSetUserPasswordPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    _logger.info("UserChangePassword success");
  } else {
    _logger.severe("UserChangePassword error: ${packet.error}");
  }
}

Future<void> handleResFetchChannelMessagesPacket(ApiResponse<ResFetchChannelMessagesPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.messages.addItems(packet.data!.messages);
    db.channelMessages.addRelations(packet.data!.relations);
    _logger.info("Fetched [${packet.data!.messages.length}, ${packet.data!.relations.length}] messages");
  } else {
    _logger.severe("FetchMessages error: ${packet.error}");
  }
}

Future<void> handleResCreateChannelPacket(ApiResponse<ResCreateChannelPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.channels.addItem(packet.data!.channel!);
    db.channelUsers.addRelation(packet.data!.channelUserRelation!);
    db.serverChannels.addRelation(packet.data!.serverChannelRelation!);
    _logger.info("Channel created: ${packet.data!.channel!.name}");
  } else {
    _logger.severe("ChannelCreate error: ${packet.error}");
  }
}

Future<void> handleResDeleteChannelPacket(ApiResponse<ResDeleteChannelPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
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

Future<void> handleResModifyChannelPacket(ApiResponse<ResModifyChannelPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final packetChannel = packet.data!.channel!;
    final channel = db.channels.get("Channel:${packetChannel.id}");
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

Future<void> handleResAddUserToChannelPacket(ApiResponse<ResAddUserToChannelPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.channelUsers.addRelation(packet.data!.relation!);
    _logger.info("ChannelAddUser success");
  } else {
    _logger.severe("ChannelAddUser error: ${packet.error}");
  }
}

Future<void> handleResRemoveUserFromChannelPacket(ApiResponse<ResRemoveUserFromChannelPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.channelUsers.removeRelation(packet.data!.relation!);

    // IF we are the user being removed, remove the channel from our list
    if (packet.data!.relation!.output == client.userId) {
      final channel = db.channels.get("Channel:${packet.data!.relation!.input}");
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

Future<void> handleResJoinVoiceChannelPacket(ApiResponse<ResJoinVoiceChannelPacket> packet, Client client, PacketManager packetManager) async {
  packetManager.runResolve(packet.requestId!, packet);

  if (packet.error == null) {
    _logger.info("JoinVoiceChannel success");
  } else {
    _logger.severe("JoinVoiceChannel error: ${packet.error}");
  }
}