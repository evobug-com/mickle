import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:flutter/material.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/connection/reconnect_manager.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'dart:typed_data';
import "../network/response.dart" as response;
import "../network/request.dart" as request;

import 'package:talk/core/connection/connection.dart';

import '../storage/storage.dart';

processResponse(Connection connection, Uint8List data) async {
  try {
    final reference = flex_buffers.Reference.fromBuffer(data.buffer);
    final key = reference.mapKeyIterable.first;
    final value = reference.mapValueIterable.first;

    switch (key) {
      case "Login":
        print("[ResponseProcessor] $key response: $value");
        final login = response.Login.fromReference(value);
        if(login.error != null) {
          connection.onError(login.error);
          connection.disconnect();
          print("Error: ${login.error}");
        } else {
          // Write json data to storage of current servers
          String? jsonServers = await SecureStorage().read("servers");
          if(jsonServers == null) {
            jsonServers = "[]";
          }

          // Parse json data
          final servers = jsonDecode(jsonServers);

          // Add server to list if not already present
          if(!servers.contains(login.serverId)) {
            servers.add(login.serverId);
            await SecureStorage().write("servers", jsonEncode(servers));
          }

          // Save servers
          await Storage().write("servers", jsonEncode(servers));


          await SecureStorage().write("${login.serverId}.token", login.token!);
          await SecureStorage().write("${login.serverId}.userId", login.userId!);
          await SecureStorage().write("${login.serverId}.host", connection.serverAddress);

          connection.userId = login.userId;
          connection.serverId = login.serverId;
          connection.loggedIn = true;
          ReconnectManager().removeConnection(connection);
          connection.onLogin();
          print("Logged in as ${login.userId} on server ${login.serverId}");
        }
        break;
      case "Ping":
        // print("[ResponseProcessor] $key response: $value");
        // Add jitter and reply with pong
        final duration = Duration(milliseconds: 100 + Random().nextInt(3000));
        Future.delayed(duration).then((value) {
          connection.send(request.Pong().serialize());
        });
        break;
      case "LoginWelcome":
        print("[ResponseProcessor] $key response: $value");
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
        // db.messages.addItems(loginWelcome.messages);
        // db.channelMessages.addRelations(loginWelcome.channelMessages);

        connection.server = db.servers.firstWhereOrNull((element) => element.id == connection.serverId);
        if(connection.server == null) {
          print("[ResponseProcessor] Server not found: ${connection.serverId}");
        }
        connection.user = db.users.firstWhereOrNull((element) => element.id == connection.userId);
        if(connection.user == null) {
          print("[ResponseProcessor] User not found: ${connection.userId}");
        }
        connection.onLoginWelcome();
        break;
      case "UpdatePresence":
        print("[ResponseProcessor] $key response: $value");
        final updatePresence = response.UpdatePresence.fromReference(value);
        final user = Database(connection.serverId).users.firstWhere((element) => element.id == updatePresence.userId);
        if(user != null) {
          user.presence = updatePresence.presence;
          user.onUpdated();
          print("[ResponseProcessor] User presence updated: ${user.displayName} to ${user.presence}");
        }
        break;
      case "Message":
        print("[ResponseProcessor] $key response: $value");
        final message = response.Message.fromReference(value);
        if(message.error != null) {
          print("[ResponseProcessor] Message error: ${message.error}");
        } else {
          final db = Database(connection.serverId);
          db.messages.addItem(message.message!);
          db.channelMessages.addRelation(message.relation!);
          print("[ResponseProcessor] Message added: ${message.message!.content}");
          AudioManager.playSingleShot("Message", AssetSource("audio/new_message_received.wav"));

          if(message.message!.content!.contains("porno")) {
            AudioManager.playSingleShot("EasterEgg", AssetSource("audio/easter_egg.wav"));
          }
        }
        break;
      case "ChangeStatus":
        print("[ResponseProcessor] $key response: $value");
        final packet = response.ChangeStatus.fromReference(value);
        if(packet.error == null) {
          final db = Database(connection.serverId);
          final user = db.users.get("User:${packet.userId}");
          if(user != null) {
            user.status = packet.status;
            user.onUpdated();
            print("User ${user.displayName} has changed status to '${user.status}'");
          }
        }
        break;
      case "ChangePresence":
        print("[ResponseProcessor] $key response: $value");
        final packet = response.ChangePresence.fromReference(value);
        if(packet.error == null) {
          final db = Database(connection.serverId);
          final user = db.users.get("User:${packet.userId}");
          if(user != null) {
            user.presence = packet.presence;
            user.onUpdated();
            print("User ${user.displayName} has changed presence to '${user.presence}'");
          }
        }
        break;
      case "ChangeAvatar":
        print("[ResponseProcessor] $key response: $value");
        final packet = response.ChangeAvatar.fromReference(value);
        if(packet.error == null) {
          final db = Database(connection.serverId);
          final user = db.users.get("User:${packet.userId}");
          if(user != null) {
            user.avatar = packet.avatar;
            user.onUpdated();
            print("User ${user.displayName} has changed avatar to '${user.avatar}'");
          }
        }
        break;
      case "ChangeDisplayName":
        print("[ResponseProcessor] $key response: $value");
        final packet = response.ChangeDisplayName.fromReference(value);
        if(packet.error == null) {
          final db = Database(connection.serverId);
          final user = db.users.get("User:${packet.userId}");
          if(user != null) {
            final displayName = user.displayName;
            user.displayName = packet.displayName;
            user.onUpdated();
            print("User ${displayName} has changed status to '${user.displayName}'");
          }
        }
        break;
      case "ChangePassword":
        print("[ResponseProcessor] $key response: $value");
        final packet = response.ChangePassword.fromReference(value);
        if(packet.error == null) {
          // Display toast with success
          print("[ResponseProcessor] ChangePassword success");
        } else {
          // Display toast with error
          print("[ResponseProcessor] ChangePassword error: ${packet.error}");
        }
        break;
      case "FetchMessages":
        print("[ResponseProcessor] $key response: $value");
        final packet = response.FetchMessages.fromReference(value);
        if(packet.error == null) {
          final db = Database(connection.serverId);
          db.messages.addItems(packet.messages);
          db.channelMessages.addRelations(packet.relations);
          print("[ResponseProcessor] Fetched [${packet.messages.length}, ${packet.relations.length}] messages");
        } else {
          print("[ResponseProcessor] FetchMessages error: ${packet.error}");
        }
        break;
      default:
        print("[ResponseProcessor] Unknown response type: $key");
        print("[ResponseProcessor] response (json): ${reference.json}");
    }
  } catch (e) {
    print("[ResponseProcessor] Error processing response: $e");
    print("String data: ${String.fromCharCodes(data)}");
    return;
  }
}