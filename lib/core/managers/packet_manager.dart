import 'dart:async';
import 'dart:convert';

import 'package:talk/areas/connection/connection.dart';
import 'package:talk/core/network/utils.dart';

import '../network/api_types.dart';

class PacketManager {
  // Each connection has own packet manager
  static final Map<Connection, PacketManager> _packetManagers = {};
  final Map<int, Completer<ApiResponse>> _requests = {};
  final Map<int, Type> _requestsTypes = {};
  int _requestId = 0;
  Connection _connection;

  int _getNewRequestId() {
    if(_requestId >= 65535) {
      _requestId = 0;
      return _requestId;
    }
    return _requestId++;
  }

  PacketManager._(this._connection);

  factory PacketManager(Connection connection) {
    return _packetManagers.putIfAbsent(connection, () => PacketManager._(connection));
  }

  void runResolve(int requestId, dynamic response) {
    if (_requests.containsKey(requestId)) {
      _requests.remove(requestId)!.complete(response);
    }
  }

  void runResolveError(int requestId, ApiResponse<dynamic> response) {
    if (_requests.containsKey(requestId)) {
      final typeString = _requestsTypes.remove(requestId)!.toString();
      final completer = _requests.remove(requestId)!;

      final type = PacketFactory.getTypeFromString(typeString);
      if (type != null) {
        final typedResponse = PacketFactory.createErrorResponse(
          type,
          response.requestId,
          response.type,
          response.error,
        );
        completer.complete(typedResponse);
      } else {
        completer.completeError(Exception('Unknown response type: $typeString'));
      }
    }
  }

  Future<ApiResponse<TRes>> sendRequest<TRes extends ResponseData, TReq extends RequestPacket>(
      TReq Function(int requestId) requestBuilder
      ) async {
    final requestId = _getNewRequestId();
    final completer = Completer<ApiResponse<TRes>>();
    _requests[requestId] = completer;
    _requestsTypes[requestId] = TRes;

    final TReq reqPacket = requestBuilder(requestId);

    // Create the correct JSON structure
    final Map<String, dynamic> reqPacketJson = {
      'type': reqPacket.packetType.substring(3, reqPacket.packetType.length - 6),
      'data': reqPacket.toJson()
    };

    // Remove the 'packetType' field from the 'data' object
    reqPacketJson['data'].remove('type');

    String json = jsonEncode(reqPacketJson);
    _connection.send(utf8.encode(json));

    return completer.future;
  }

  Future<ApiResponse<ResLoginPacket>> sendLogin({
    String? username,
    String? password,
    String? token
  }) {
    return sendRequest((requestId) => ReqLoginPacket(
      requestId: requestId,
      username: username,
      password: password,
      token: token,
    ));
  }

  Future<ApiResponse<ResSetUserPresencePacket>> sendUserChangePresence({
    required String presence
  }) {
    return sendRequest((requestId) => ReqSetUserPresencePacket(
      requestId: requestId,
      presence: presence,
    ));
  }

  Future<ApiResponse<ResSetUserStatusPacket>> sendUserChangeStatus({
    required String? status
  }) {
    return sendRequest((requestId) => ReqSetUserStatusPacket(
      requestId: requestId,
      status: status,
    ));
  }

  Future<ApiResponse<ResSetUserAvatarPacket>> sendUserChangeAvatar({
    required String? avatar
  }) {
    return sendRequest((requestId) => ReqSetUserAvatarPacket(
      requestId: requestId,
      avatar: avatar,
    ));
  }

  Future<ApiResponse<ResSetUserPasswordPacket>> sendUserChangePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return sendRequest((requestId) => ReqSetUserPasswordPacket(
      requestId: requestId,
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
  }

  Future<ApiResponse<ResSetUserDisplayNamePacket>> sendUserChangeDisplayName({
    required String displayName
  }) {
    return sendRequest((requestId) => ReqSetUserDisplayNamePacket(
      requestId: requestId,
      displayName: displayName,
    ));
  }

  Future<ApiResponse<ResCreateChannelMessagePacket>> sendChannelMessageCreate({
    required String value,
    required String channelId,
  }) {
    final mentions = parseMessageMentions(value, database: _connection.database);

    return sendRequest((requestId) => ReqCreateChannelMessagePacket(
      requestId: requestId,
      channelId: channelId,
      message: value,
      mentions: mentions,
    ));
  }

  Future<ApiResponse<ResFetchChannelMessagesPacket>> sendChannelMessageFetch({
    required String channelId,
    required String? lastMessageId,
  }) {
    return sendRequest((requestId) => ReqFetchChannelMessagesPacket(
      requestId: requestId,
      channelId: channelId,
      lastMessageId: lastMessageId,
    ));
  }

  Future<ApiResponse<ResCreateChannelPacket>> sendChannelCreate({
    required String serverId,
    required String name,
    required String? description,
  }) {
    return sendRequest((requestId) => ReqCreateChannelPacket(
        requestId: requestId,
        name: name,
        serverId: serverId,
        description: description
    ));
  }

  Future<ApiResponse<ResDeleteChannelPacket>> sendChannelDelete({
    required String channelId,
  }) {
    return sendRequest((requestId) => ReqDeleteChannelPacket(
      requestId: requestId,
      channelId: channelId,
    ));
  }

  Future<ApiResponse<ResModifyChannelPacket>> sendChannelUpdate({
    required String channelId,
    required String? name,
    required String? description,
  }) {
    return sendRequest((requestId) => ReqModifyChannelPacket(
      requestId: requestId,
      channelId: channelId,
      name: name,
      description: description,
    ));
  }

  Future<ApiResponse<ResAddUserToChannelPacket>> sendChannelAddUser({
    required String channelId,
    required String userId,
  }) {
    return sendRequest((requestId) => ReqAddUserToChannelPacket(
      requestId: requestId,
      channelId: channelId,
      userId: userId,
    ));
  }

  Future<ApiResponse<ResDeleteUserFromChannelPacket>> sendChannelRemoveUser({
    required String channelId,
    required String userId,
  }) {
    return sendRequest((requestId) => ReqDeleteUserFromChannelPacket(
        requestId: requestId,
        channelId: channelId,
        userId: userId
    ));
  }

  Future<ApiResponse<ResJoinVoiceChannelPacket>> sendJoinVoiceChannel({
    required String channelId,
  }) {
    return sendRequest((requestId) => ReqJoinVoiceChannelPacket(
      requestId: requestId,
      channelId: channelId,
    ));
  }

  Future<ApiResponse<ResPingPacket>> sendPing() {
    return sendRequest((requestId) => ReqPingPacket(
      requestId: requestId,
    ));
  }
}