import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:local_notifier/local_notifier.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/connection/reconnect_manager.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/processor/packet_manager.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:typed_data';
import "../network/response.dart" as response;
import "../network/request.dart" as request;

import 'package:talk/core/connection/connection.dart';

import '../storage/storage.dart';

processResponse(Connection connection, Uint8List data) async {
  try {
    final packetManager = PacketManager(connection);
    final reference = flex_buffers.Reference.fromBuffer(data.buffer);
    final targetKey = "PacketResponse.${reference.mapKeyIterable.first}";
    final key = response.PacketResponse.values.firstWhereOrNull((value) => value.toString() == targetKey);
    final value = reference.mapValueIterable.first;

    if(key != response.PacketResponse.Ping) {
      print("[ResponseProcessor] Received packet: $key");
    }

    if(key != null) {
      switch (key) {
        case response.Login.packetName:
          final login = response.Login.fromReference(value);
          packetManager.runResolve(login.requestId, login);
          if (login.error != null) {
            connection.onError(login.error);
            connection.disconnect();
            print("Error: ${login.error}");
          } else {
            // Write json data to storage of current servers
            String? jsonServers = await SecureStorage().read("servers");
            if (jsonServers == null) {
              jsonServers = "[]";
            }

            // Parse json data
            final servers = jsonDecode(jsonServers);

            // Add server to list if not already present
            if (!servers.contains(login.serverId)) {
              servers.add(login.serverId);
              await SecureStorage().write("servers", jsonEncode(servers));
            }

            // Save servers
            await Storage().write("servers", jsonEncode(servers));


            await SecureStorage().write(
                "${login.serverId}.token", login.token!);
            await SecureStorage().write(
                "${login.serverId}.userId", login.userId!);
            await SecureStorage().write(
                "${login.serverId}.host", connection.serverAddress);

            connection.userId = login.userId;
            connection.serverId = login.serverId;
            connection.loggedIn = true;
            ReconnectManager().removeConnection(connection);
            connection.onLogin();
            print("Logged in as ${login.userId} on server ${login.serverId}");
          }
          return;
        case response.Ping.packetName:
        // print("[ResponseProcessor] $key response: $value");
        // Add jitter and reply with pong
          final duration = Duration(milliseconds: 100 + Random().nextInt(3000));
          Future.delayed(duration).then((value) {
            connection.send(request.Pong().serialize());
          });
          return;
        case response.LoginWelcome.packetName:
          final loginWelcome = response.LoginWelcome.fromReference(value);
          final db = Database(connection.serverId);
          db.users.addItems(loginWelcome.users);
          db.servers.addItems(loginWelcome.servers);
          db.channels.addItems(loginWelcome.channels);
          db.roles.addItems(loginWelcome.roles);
          db.serverUsers.addRelations(loginWelcome.serverUsers);
          db.roleUsers.addRelations(loginWelcome.roleUsers);
          db.channelUsers.addRelations(loginWelcome.channelUsers);
          db.permissions.addItems(loginWelcome.permissions);
          db.rolePermissions.addRelations(loginWelcome.rolePermissions);
          // db.messages.addItems(loginWelcome.messages);
          // db.channelMessages.addRelations(loginWelcome.channelMessages);

          connection.server =
              db.servers.firstWhereOrNull((element) => element.id ==
                  connection.serverId);
          if (connection.server == null) {
            print(
                "[ResponseProcessor] Server not found: ${connection.serverId}");
          }
          connection.user = db.users.firstWhereOrNull((element) => element.id ==
              connection.userId);
          if (connection.user == null) {
            print("[ResponseProcessor] User not found: ${connection.userId}");
          }
          connection.onLoginWelcome();
          return;
        case response.UpdatePresence.packetName:
          final updatePresence = response.UpdatePresence.fromReference(value);
          final user = Database(connection.serverId).users.firstWhere((
              element) => element.id == updatePresence.userId);
          if (user != null) {
            user.presence = updatePresence.presence;
            user.onUpdated();
            print("[ResponseProcessor] User presence updated: ${user
                .displayName} to ${user.presence}");
          }
          return;
        case response.ChannelMessageCreate.packetName:
          final message = response.ChannelMessageCreate.fromReference(value);
          packetManager.runResolve(message.requestId, message);
          if (message.error != null) {
            print("[ResponseProcessor] Message error: ${message.error}");
          } else {
            final db = Database(connection.serverId);
            db.messages.addItem(message.message!);
            db.channelMessages.addRelation(message.relation!);
            print("[ResponseProcessor] Message added: ${message.message!
                .content}");
            if (message.mentions != null &&
                message.mentions!.contains(connection.userId!)) {
              AudioManager.playSingleShot(
                  "Message", AssetSource("audio/mention.wav"));

              final user = db.users.firstWhereOrNull((element) =>
              element.id == message.message!.user);
              if (user != null) {
                if (!await windowManager.isFocused()) {
                  LocalNotification notification = LocalNotification(
                    title: "Mention from ${user.displayName}",
                    body: message.message!.content,
                  );

                  notification.show();
                }
              }
            } else {
              AudioManager.playSingleShot(
                  "Message", AssetSource("audio/new_message_received.wav"));
            }

            if (message.message!.content!.contains("porno")) {
              AudioManager.playSingleShot(
                  "EasterEgg", AssetSource("audio/easter_egg.wav"));
            }
          }
          return;
        case response.UserChangeStatus.packetName:
          final packet = response.UserChangeStatus.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            final user = db.users.get("User:${packet.userId}");
            if (user != null) {
              user.status = packet.status;
              user.onUpdated();
              print("User ${user.displayName} has changed status to '${user
                  .status}'");
            }
          }
          return;
        case response.UserChangePresence.packetName:
          final packet = response.UserChangePresence.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            final user = db.users.get("User:${packet.userId}");
            if (user != null) {
              user.presence = packet.presence;
              user.onUpdated();
              print("User ${user.displayName} has changed presence to '${user
                  .presence}'");
            }
          }
          return;
        case response.UserChangeAvatar.packetName:
          final packet = response.UserChangeAvatar.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            final user = db.users.get("User:${packet.userId}");
            if (user != null) {
              user.avatar = packet.avatar;
              user.onUpdated();
              print("User ${user.displayName} has changed avatar to '${user
                  .avatar}'");
            }
          }
          return;
        case response.UserChangeDisplayName.packetName:
          final packet = response.UserChangeDisplayName.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            final user = db.users.get("User:${packet.userId}");
            if (user != null) {
              final displayName = user.displayName;
              user.displayName = packet.displayName;
              user.onUpdated();
              print("User ${displayName} has changed status to '${user
                  .displayName}'");
            }
          }
          return;
        case response.UserChangePassword.packetName:
          final packet = response.UserChangePassword.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            // Display toast with success
            print("[ResponseProcessor] UserChangePassword success");
          } else {
            // Display toast with error
            print("[ResponseProcessor] UserChangePassword error: ${packet
                .error}");
          }
          return;
        case response.ChannelMessageFetch.packetName:
          final packet = response.ChannelMessageFetch.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            db.messages.addItems(packet.messages);
            db.channelMessages.addRelations(packet.relations);
            print("[ResponseProcessor] Fetched [${packet.messages
                .length}, ${packet.relations.length}] messages");
          } else {
            print("[ResponseProcessor] FetchMessages error: ${packet.error}");
          }
          return;
        case response.PacketResponse.ChannelCreate:
          final packet = response.ChannelCreate.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            db.channels.addItem(packet.channel!);
            db.channelUsers.addRelation(packet.channelUserRelation!);
            db.serverChannels.addRelation(packet.serverChannelRelation!);
            print(
                "[ResponseProcessor] Channel created: ${packet.channel!.name}");
          } else {
            print("[ResponseProcessor] ChannelCreate error: ${packet.error}");
          }
          return;
        case response.PacketResponse.ChannelDelete:
          final packet = response.ChannelDelete.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            final channel = db.channels.get("Channel:${packet.channelId}");
            if (channel != null) {
              db.channels.removeItem(channel);
            }
            db.channelUsers.removeRelationInput(packet.channelId);
            db.serverChannels.removeRelationOutput(packet.channelId);
            print("[ResponseProcessor] Channel deleted: ${packet.channelId}");
          } else {
            print("[ResponseProcessor] ChannelDelete error: ${packet.error}");
          }
          return;
        case response.PacketResponse.ChannelUpdate:
          final packet = response.ChannelUpdate.fromReference(value);
          packetManager.runResolve(packet.requestId, packet);
          if (packet.error == null) {
            final db = Database(connection.serverId);
            final packetChannel = packet.channel!;
            final channel = db.channels.get("Channel:${packetChannel.id}");
            if (channel != null) {
              channel.name = packetChannel.name;
              channel.description = packetChannel.description;
              channel.onUpdated();
              print("[ResponseProcessor] Channel updated: ${packetChannel.name}");
            } else {
              db.channels.addItem(packetChannel);
              print("[ResponseProcessor] Tried to update channel but instead was added: ${packetChannel.name}");
            }
          } else {
            print("[ResponseProcessor] ChannelUpdate error: ${packet.error}");
          }
          return;
      }
    }

    print("[ResponseProcessor] Unknown response type: $key");
    print("[ResponseProcessor] response (json): ${reference.json}");
  } catch (e) {
    print("[ResponseProcessor] Error processing response: $e");
    print("String data: ${String.fromCharCodes(data)}");
    return;
  }
}