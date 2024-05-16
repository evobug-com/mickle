import 'dart:async';

import 'package:talk/core/connection/client.dart';
import 'package:talk/core/network/utils.dart';

import '../network/request.dart' as request;
import '../network/response.dart' as response;

class PacketManager {
  // Each connection has own packet manager
  static final Map<Client, PacketManager> _packetManagers = {};
  final Map<int, Completer> _requests = {};
  int _requestId = 0;
  Client _client;

  int _getNewRequestId() {
    if(_requestId >= 65535) {
      _requestId = 0;
      return _requestId;
    }
    return _requestId++;
  }

  PacketManager._(Client connection) : _client = connection;

  factory PacketManager(Client connection) {
    if (_packetManagers.containsKey(connection)) {
      return _packetManagers[connection]!;
    } else {
      final packetManager = PacketManager._(connection);
      _packetManagers[connection] = packetManager;
      return packetManager;
    }
  }

  Future<TRes> runRequest<TRes, TReq extends Request>(TReq Function(int requestId) requestBuilder) {
    final req = _request();
    final completer = Completer<TRes>();
    _requests[req] = completer;
    final TReq reqPacket = requestBuilder(req);
    _client.send(reqPacket.serialize());
    return completer.future;
  }

  int _request() {
    final requestId = _getNewRequestId();
    // Create future for the request
    final completer = Completer();
    _requests[requestId] = completer;
    return requestId;
  }

  void runResolve(int requestId, dynamic response) {
    if (_requests.containsKey(requestId)) {
      _requests.remove(requestId)!.complete(response);
    }
  }

  Future<response.Login> sendLogin({
    String? username,
    String? password,
    String? token
  }) {
    return runRequest((requestId) {
      return request.Login(
        requestId: requestId,
        username: username,
        password: password,
        token: token,
      );
    });
  }

  Future<response.UserChangePresence> sendUserChangePresence({
    required String presence
  }) {
    return runRequest((requestId) {
      return request.UserChangePresence(
        requestId: requestId,
        presence: presence,
      );
    });
  }

  Future<response.UserChangeStatus> sendUserChangeStatus({
    required String status
  }) {
    return runRequest((requestId) {
      return request.UserChangeStatus(
        requestId: requestId,
        status: status,
      );
    });
  }

  Future<response.UserChangeAvatar> sendUserChangeAvatar({
    required String avatar
  }) {
    return runRequest((requestId) {
      return request.UserChangeAvatar(
        requestId: requestId,
        avatar: avatar,
      );
    });
  }

  Future<response.UserChangePassword> sendUserChangePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return runRequest((requestId) {
      return request.UserChangePassword(
        requestId: requestId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    });
  }

  Future<response.UserChangeDisplayName> sendUserChangeDisplayName({
    required String displayName
  }) {
    return runRequest((requestId) {
      return request.UserChangeDisplayName(
        requestId: requestId,
        displayName: displayName,
      );
    });
  }

  Future<response.ChannelMessageCreate> sendChannelMessageCreate({
    required String value,
    required String channelId,
  }) {
    return runRequest((requestId) {

      final mentions = request.parseMessageMentions(value);

      return request.ChannelMessageCreate(
        requestId: requestId,
        channelId: channelId,
        message: value,
        mentions: mentions,
      );
    });
  }

  Future<response.ChannelMessageFetch> sendChannelMessageFetch({
    required String channelId,
    required String? lastMessageId,
  }) {
    return runRequest((requestId) {
      return request.ChannelMessageFetch(
        requestId: requestId,
        channelId: channelId,
        lastMessageId: lastMessageId,
      );
    });
  }

  Future<response.ChannelCreate> sendChannelCreate({
    required String serverId,
    required String name,
    required String? description,
  }) {
    return runRequest((requestId) {
      return request.ChannelCreate(
        requestId: requestId,
        name: name,
        serverId: serverId,
        description: description
      );
    });
  }

  Future<response.ChannelDelete> sendChannelDelete({
    required String channelId,
  }) {
    return runRequest((requestId) {
      return request.ChannelDelete(
        requestId: requestId,
        channelId: channelId,
      );
    });
  }

  Future<response.ChannelUpdate> sendChannelUpdate({
    required String channelId,
    required String? name,
    required String? description,
  }) {
    return runRequest((requestId) {
      return request.ChannelUpdate(
        requestId: requestId,
        channelId: channelId,
        name: name,
        description: description,
      );
    });
  }

  Future<response.ChannelAddUser> sendChannelAddUser({
    required String channelId,
    required String userId,
  }) {
    return runRequest((requestId) {
      return request.ChannelAddUser(
        requestId: requestId,
        channelId: channelId,
        userId: userId,
      );
    });
  }

  Future<response.ChannelRemoveUser> sendChannelRemoveUser({
    required String channelId,
    required String userId,
  }) {
    return runRequest((requestId) {
      return request.ChannelRemoveUser(
        requestId: requestId,
        channelId: channelId,
        userId: userId
      );
    });
  }
}