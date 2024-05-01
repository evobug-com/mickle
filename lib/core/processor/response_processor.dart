import 'package:audioplayers/audioplayers.dart';
import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/database.dart';
import 'dart:typed_data';
import "../network/response.dart" as response;

import 'package:talk/core/connection/connection.dart';

processResponse(Connection connection, Uint8List data) async {
  try {
    final reference = flex_buffers.Reference.fromBuffer(data.buffer);
    final key = reference.mapKeyIterable.first;
    final value = reference.mapValueIterable.first;
    print("[ResponseProcessor] Processing response (json): ${reference.json}");

    switch (key) {
      case "Login":
        print("[ResponseProcessor] $key response: $value");
        final login = response.Login.fromReference(value);
        if(login.error != null) {
          connection.onError(login.error);
          connection.disconnect();
          print("Error: ${login.error}");
        } else {
          connection.userId = login.userId;
          connection.serverId = login.serverId;
          connection.onLogin();
          print("Logged in as ${login.userId} on server ${login.serverId}");
        }
        break;
      case "LoginWelcome":
        print("[ResponseProcessor] $key response: $value");
        final loginWelcome = response.LoginWelcome.fromReference(value);
        final db = Database(connection.serverId);
        db.users.addItems(loginWelcome.users);
        db.servers.addItems(loginWelcome.servers);
        db.channels.addItems(loginWelcome.channels);
        db.roles.addItems(loginWelcome.roles);
        db.serverUsers.addItems(loginWelcome.serverUsers);
        db.roleUsers.addItems(loginWelcome.roleUsers);
        db.channelUsers.addItems(loginWelcome.channelUsers);
        db.permissions.addItems(loginWelcome.permissions);
        db.messages.addItems(loginWelcome.messages);
        db.channelMessages.addItems(loginWelcome.channelMessages);

        connection.server = db.servers.firstWhere((element) => element.id == connection.serverId);
        connection.user = db.users.firstWhere((element) => element.id == connection.userId);
        connection.onLoginWelcome();
        break;
      case "UpdatePresence":
        print("[ResponseProcessor] $key response: $value");
        final updatePresence = response.UpdatePresence.fromReference(value);
        final user = Database(connection.serverId).users.firstWhere((element) => element.id == updatePresence.userId);
        if(user != null) {
          user.presence = updatePresence.presence;
          user.onUpdated();
          print("[ResponseProcessor] User presence updated: ${user.displayName} to ${user.status}");
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
          db.channelMessages.addItem(message.relation!);
          print("[ResponseProcessor] Message added: ${message.message!.content}");
          AudioManager.playSingleShot("Message", AssetSource("audio/new_message_received.wav"));
        }
        break;
      default:
        print("[ResponseProcessor] Unknown response type: $key");
    }
  } catch (e) {
    print("[ResponseProcessor] Error processing response: $e");
    print("String data: ${String.fromCharCodes(data)}");
    return;
  }
}