import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:local_notifier/local_notifier.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/managers/audio_manager.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/packet_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../connection/client.dart';
import '../network/response.dart' as response;
import '../network/request.dart' as request;

final _logger = Logger('ResponseProcessor');

Future<void> processResponse(Client client, Uint8List data) async {
  try {
    final packetManager = PacketManager(client);
    final reference = flex_buffers.Reference.fromBuffer(data.buffer);
    final targetKey = "PacketResponse.${reference.mapKeyIterable.first}";
    final key = response.PacketResponse.values.firstWhereOrNull((value) => value.toString() == targetKey);
    final value = reference.mapValueIterable.first;

    if (key != response.PacketResponse.Ping) {
      _logger.info("Received packet: $key");
    }

    if (key != null) {
      await _handlePacket(key, value, client, packetManager);
    } else {
      _logger.warning("Unknown response type: $key");
      _logger.info("Response (json): ${reference.json}");
    }
  } catch (e) {
    _logger.severe("Error processing response: $e");
    _logger.severe("String data: ${String.fromCharCodes(data)}");
    _logger.severe("Buffer data: ${data}");
  }
}

Future<void> _handlePacket(response.PacketResponse key, flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  switch (key) {
    case response.Login.packetName:
      await _handleLoginResponse(value, client, packetManager);
      break;
    case response.Ping.packetName:
      await _handlePingResponse(client);
      break;
    case response.LoginWelcome.packetName:
      await _handleLoginWelcomeResponse(value, client);
      break;
    case response.UpdatePresence.packetName:
      _handleUpdatePresenceResponse(value, client);
      break;
    case response.ChannelMessageCreate.packetName:
      await _handleChannelMessageCreateResponse(value, client, packetManager);
      break;
    case response.UserChangeStatus.packetName:
      await _handleUserChangeStatusResponse(value, client, packetManager);
      break;
    case response.UserChangePresence.packetName:
      await _handleUserChangePresenceResponse(value, client, packetManager);
      break;
    case response.UserChangeAvatar.packetName:
      await _handleUserChangeAvatarResponse(value, client, packetManager);
      break;
    case response.UserChangeDisplayName.packetName:
      await _handleUserChangeDisplayNameResponse(value, client, packetManager);
      break;
    case response.UserChangePassword.packetName:
      await _handleUserChangePasswordResponse(value, client, packetManager);
      break;
    case response.ChannelMessageFetch.packetName:
      await _handleChannelMessageFetchResponse(value, client, packetManager);
      break;
    case response.ChannelCreate.packetName:
      await _handleChannelCreateResponse(value, client, packetManager);
      break;
    case response.ChannelDelete.packetName:
      await _handleChannelDeleteResponse(value, client, packetManager);
      break;
    case response.ChannelUpdate.packetName:
      await _handleChannelUpdateResponse(value, client, packetManager);
      break;
    case response.ChannelAddUser.packetName:
      await _handleChannelAddUser(value, client, packetManager);
      break;
    case response.ChannelRemoveUser.packetName:
      await _handleChannelRemoveUser(value, client, packetManager);
      break;
    case response.PacketResponse.JoinVoiceChannel:
      await _handleJoinVoiceChannelResponse(value, client, packetManager);
      break;
  }
}

Future<void> _handleLoginResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final login = response.Login.fromReference(value);
  packetManager.runResolve(login.requestId, login);
}

Future<void> _handlePingResponse(Client client) async {
  final duration = Duration(milliseconds: 100 + Random().nextInt(3000));
  await Future.delayed(duration);
  client.send(request.Pong().serialize());
}

Future<void> _handleLoginWelcomeResponse(flex_buffers.Reference value, Client client) async {
  final loginWelcome = response.LoginWelcome.fromReference(value);
  final db = Database(client.serverId!);
  db.users.addItems(loginWelcome.users);
  db.servers.addItems(loginWelcome.servers);
  db.channels.addItems(loginWelcome.channels);
  db.roles.addItems(loginWelcome.roles);
  db.serverUsers.addRelations(loginWelcome.serverUsers);
  db.roleUsers.addRelations(loginWelcome.roleUsers);
  db.channelUsers.addRelations(loginWelcome.channelUsers);
  db.permissions.addItems(loginWelcome.permissions);
  db.rolePermissions.addRelations(loginWelcome.rolePermissions);
  db.serverChannels.addRelations(loginWelcome.serverChannels);

  client.serverData.updateData(
    server: db.servers.firstWhereOrNull((element) => element.id == client.serverId),
    user: db.users.firstWhereOrNull((element) => element.id == client.userId),
  );
}

void _handleUpdatePresenceResponse(flex_buffers.Reference value, Client client) {
  final updatePresence = response.UpdatePresence.fromReference(value);
  final user = Database(client.serverId!).users.firstWhere((element) => element.id == updatePresence.userId);
  user.presence = updatePresence.presence;
  user.onUpdated();
  _logger.info("User presence updated: ${user.displayName} to ${user.presence}");
}

Future<void> _handleChannelMessageCreateResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final message = response.ChannelMessageCreate.fromReference(value);
  packetManager.runResolve(message.requestId, message);

  if (message.error != null) {
    _logger.severe("Message error: ${message.error}");
  } else {
    final db = Database(client.serverId!);
    db.messages.addItem(message.message!);
    db.channelMessages.addRelation(message.relation!);
    _logger.info("Message added: ${message.message!.content}");

    if (message.mentions != null && message.mentions!.contains(client.userId!)) {
      AudioManager.playSingleShot("Message", AssetSource("audio/mention.wav"));

      final user = db.users.firstWhereOrNull((element) => element.id == message.message!.user);
      if (user != null && !await windowManager.isFocused()) {
        LocalNotification notification = LocalNotification(
          title: "Mention from ${user.displayName}",
          body: message.message!.content,
        );
        notification.show();
      }
    } else {
      AudioManager.playSingleShot("Message", AssetSource("audio/new_message_received.wav"));
    }

    if (message.message!.content.contains("porno")) {
      AudioManager.playSingleShot("EasterEgg", AssetSource("audio/easter_egg.wav"));
    }
  }
}

Future<void> _handleUserChangeStatusResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.UserChangeStatus.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.userId}");
    if (user != null) {
      user.status = packet.status;
      user.onUpdated();
      _logger.info("User ${user.displayName} has changed status to '${user.status}'");
    }
  }
}

Future<void> _handleUserChangePresenceResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.UserChangePresence.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.userId}");
    if (user != null) {
      user.presence = packet.presence;
      user.onUpdated();
      _logger.info("User ${user.displayName} has changed presence to '${user.presence}'");
    }
  }
}

Future<void> _handleUserChangeAvatarResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.UserChangeAvatar.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.userId}");
    if (user != null) {
      user.avatar = packet.avatar;
      user.onUpdated();
      _logger.info("User ${user.displayName} has changed avatar to '${user.avatar}'");
    }
  }
}

Future<void> _handleUserChangeDisplayNameResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.UserChangeDisplayName.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final user = db.users.get("User:${packet.userId}");
    if (user != null) {
      final displayName = user.displayName;
      user.displayName = packet.displayName;
      user.onUpdated();
      _logger.info("User $displayName has changed display name to '${user.displayName}'");
    }
  }
}

Future<void> _handleUserChangePasswordResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.UserChangePassword.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    _logger.info("UserChangePassword success");
  } else {
    _logger.severe("UserChangePassword error: ${packet.error}");
  }
}

Future<void> _handleChannelMessageFetchResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.ChannelMessageFetch.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.messages.addItems(packet.messages);
    db.channelMessages.addRelations(packet.relations);
    _logger.info("Fetched [${packet.messages.length}, ${packet.relations.length}] messages");
  } else {
    _logger.severe("FetchMessages error: ${packet.error}");
  }
}

Future<void> _handleChannelCreateResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.ChannelCreate.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.channels.addItem(packet.channel!);
    db.channelUsers.addRelation(packet.channelUserRelation!);
    db.serverChannels.addRelation(packet.serverChannelRelation!);
    _logger.info("Channel created: ${packet.channel!.name}");
  } else {
    _logger.severe("ChannelCreate error: ${packet.error}");
  }
}

Future<void> _handleChannelDeleteResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.ChannelDelete.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final channel = db.channels.get("Channel:${packet.channelId}");
    if (channel != null) {
      db.channels.removeItem(channel);
    }
    db.channelUsers.removeRelationInput(packet.channelId);
    db.serverChannels.removeRelationOutput(packet.channelId);
    _logger.info("Channel deleted: ${packet.channelId}");
  } else {
    _logger.severe("ChannelDelete error: ${packet.error}");
  }
}

Future<void> _handleChannelUpdateResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) async {
  final packet = response.ChannelUpdate.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    final packetChannel = packet.channel!;
    final channel = db.channels.get("Channel:${packetChannel.id}");
    if (channel != null) {
      channel.name = packetChannel.name;
      channel.description = packetChannel.description;
      channel.onUpdated();
      _logger.info("Channel updated: ${packetChannel.name}");
    } else {
      db.channels.addItem(packetChannel);
      _logger.info("Tried to update channel but instead was added: ${packetChannel.name}");
    }
  } else {
    _logger.severe("ChannelUpdate error: ${packet.error}");
  }
}

_handleChannelAddUser(flex_buffers.Reference value, Client client, PacketManager packetManager) {
  final packet = response.ChannelAddUser.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.channelUsers.addRelation(packet.relation!);
    _logger.info("ChannelAddUser success");
  } else {
    _logger.severe("ChannelAddUser error: ${packet.error}");
  }
}

_handleChannelRemoveUser(flex_buffers.Reference value, Client client, PacketManager packetManager) {
  final packet = response.ChannelRemoveUser.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    final db = Database(client.serverId!);
    db.channelUsers.removeRelation(packet.relation!);

    // IF we are the user being removed, remove the channel from our list
    if (packet.relation!.output == client.userId) {
      final channel = db.channels.get("Channel:${packet.relation!.input}");
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

_handleJoinVoiceChannelResponse(flex_buffers.Reference value, Client client, PacketManager packetManager) {
  final packet = response.JoinVoiceChannel.fromReference(value);
  packetManager.runResolve(packet.requestId, packet);

  if (packet.error == null) {
    _logger.info("JoinVoiceChannel success");
  } else {
    _logger.severe("JoinVoiceChannel error: ${packet.error}");
  }
}