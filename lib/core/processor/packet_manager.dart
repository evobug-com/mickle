import 'dart:async';

import 'package:talk/core/connection/connection.dart';
import 'package:talk/core/network/utils.dart';

import '../network/request.dart' as request;
import '../network/response.dart' as response;

class PacketManager {
  // Each connection has own packet manager
  static final Map<Connection, PacketManager> _packetManagers = {};
  final Map<int, Completer> _requests = {};
  int _requestId = 0;
  Connection _connection;

  int _getNewRequestId() {
    if(_requestId >= 65535) {
      _requestId = 0;
      return _requestId;
    }
    return _requestId++;
  }

  PacketManager._(Connection connection) : _connection = connection;

  factory PacketManager(Connection connection) {
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
    _connection.send(reqPacket.serialize());
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
      return request.ChannelMessageCreate(
        requestId: requestId,
        channelId: channelId,
        message: value,
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
    required String name,
    required String? description,
  }) {
    return runRequest((requestId) {
      return request.ChannelCreate(
        requestId: requestId,
        name: name,
        serverId: _connection.serverId,
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
}