// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, unused_field, unused_import, unnecessary_this, prefer_const_constructors


import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'package:collection/collection.dart';

part 'api_types.g.dart';


@JsonEnum()
enum PacketType {
  @JsonValue("ReqPingPacket")
  reqPingPacket,
  @JsonValue("ReqFetchPublicKeyPacket")
  reqFetchPublicKeyPacket,
  @JsonValue("ReqLoginPacket")
  reqLoginPacket,
  @JsonValue("ReqCreateChannelMessagePacket")
  reqCreateChannelMessagePacket,
  @JsonValue("ReqFetchChannelMessagesPacket")
  reqFetchChannelMessagesPacket,
  @JsonValue("ReqSetUserPasswordPacket")
  reqSetUserPasswordPacket,
  @JsonValue("ReqSetUserDisplayNamePacket")
  reqSetUserDisplayNamePacket,
  @JsonValue("ReqSetUserStatusPacket")
  reqSetUserStatusPacket,
  @JsonValue("ReqSetUserAvatarPacket")
  reqSetUserAvatarPacket,
  @JsonValue("ReqSetUserPresencePacket")
  reqSetUserPresencePacket,
  @JsonValue("ReqCreateChannelPacket")
  reqCreateChannelPacket,
  @JsonValue("ReqDeleteChannelPacket")
  reqDeleteChannelPacket,
  @JsonValue("ReqModifyChannelPacket")
  reqModifyChannelPacket,
  @JsonValue("ReqAddUserToChannelPacket")
  reqAddUserToChannelPacket,
  @JsonValue("ReqDeleteUserFromChannelPacket")
  reqDeleteUserFromChannelPacket,
  @JsonValue("ReqJoinVoiceChannelPacket")
  reqJoinVoiceChannelPacket,
  @JsonValue("ResPingPacket")
  resPingPacket,
  @JsonValue("ResFetchPublicKeyPacket")
  resFetchPublicKeyPacket,
  @JsonValue("ResLoginPacket")
  resLoginPacket,
  @JsonValue("ResCreateChannelMessagePacket")
  resCreateChannelMessagePacket,
  @JsonValue("ResFetchChannelMessagesPacket")
  resFetchChannelMessagesPacket,
  @JsonValue("ResSetUserPasswordPacket")
  resSetUserPasswordPacket,
  @JsonValue("ResSetUserDisplayNamePacket")
  resSetUserDisplayNamePacket,
  @JsonValue("ResSetUserStatusPacket")
  resSetUserStatusPacket,
  @JsonValue("ResSetUserAvatarPacket")
  resSetUserAvatarPacket,
  @JsonValue("ResSetUserPresencePacket")
  resSetUserPresencePacket,
  @JsonValue("ResCreateChannelPacket")
  resCreateChannelPacket,
  @JsonValue("ResDeleteChannelPacket")
  resDeleteChannelPacket,
  @JsonValue("ResModifyChannelPacket")
  resModifyChannelPacket,
  @JsonValue("ResAddUserToChannelPacket")
  resAddUserToChannelPacket,
  @JsonValue("ResDeleteUserFromChannelPacket")
  resDeleteUserFromChannelPacket,
  @JsonValue("ResJoinVoiceChannelPacket")
  resJoinVoiceChannelPacket,
  @JsonValue("EvtWelcomePacket")
  evtWelcomePacket,
  @JsonValue("EvtUpdatePresencePacket")
  evtUpdatePresencePacket,
}


@JsonSerializable()
class RequestPacket {
  @JsonKey(name: "type")
  final String packetType;

  RequestPacket({required this.packetType});

  factory RequestPacket.fromJson(Map<String, dynamic> json) => _$RequestPacketFromJson(json);
  Map<String, dynamic> toJson() => _$RequestPacketToJson(this);
}

@JsonSerializable()
class ResponseData {
  const ResponseData();

  factory ResponseData.fromJson(Map<String, dynamic> json) => _$ResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseDataToJson(this);
}

@JsonSerializable()
class EventData {
  const EventData();

  factory EventData.fromJson(Map<String, dynamic> json) => _$EventDataFromJson(json);
  Map<String, dynamic> toJson() => _$EventDataToJson(this);
}

class PacketError {
  final String message;

  PacketError(this.message);

  factory PacketError.fromJson(Map<String, dynamic> json) {
    return PacketError(json['message'] as String);
  }

  Map<String, dynamic> toJson() => {'message': message};
  
  @override
  String toString() {
    return 'PacketError{message: $message}';
  }
}

class ApiResponse<T> {
  final int? requestId;
  final T? data;
  final PacketError? error;
  final String type;

  ApiResponse({required this.requestId, required this.type, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      requestId: json['request_id'] as int?,
      type: json['type'] as String,
      data: json['data'],
      error: json['error'] != null ? PacketError(json['error'] as String) : null,
    );
  }

  factory ApiResponse.success(T data, int? requestId, String type) =>
      ApiResponse(requestId: requestId, data: data, type: type);

  factory ApiResponse.error(String message, int? requestId, String type) =>
      ApiResponse(requestId: requestId, error: PacketError(message), type: type);

  bool get isSuccess => error == null;

  cast<TSub>(TSub Function(Map<String, dynamic> json) fromJson) {
    return ApiResponse<TSub>(
      requestId: requestId,
      type: type,
      data: data != null ? fromJson(data as Map<String, dynamic>) : null,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{requestId: $requestId, data: ${data?.toString()}, error: $error, type: $type}';
  }
}

@JsonSerializable()
class ReqPingPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;

  ReqPingPacket({required this.requestId,}) : super(packetType: "ReqPingPacket");

  factory ReqPingPacket.fromJson(Map<String, dynamic> json) => _$ReqPingPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqPingPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqPingPacket{requestId: $requestId}';
  }
}


@JsonSerializable()
class ReqFetchPublicKeyPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;

  ReqFetchPublicKeyPacket({required this.requestId,}) : super(packetType: "ReqFetchPublicKeyPacket");

  factory ReqFetchPublicKeyPacket.fromJson(Map<String, dynamic> json) => _$ReqFetchPublicKeyPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqFetchPublicKeyPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqFetchPublicKeyPacket{requestId: $requestId}';
  }
}


@JsonSerializable()
class ReqLoginPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "username", includeIfNull: false)
  final String? username;
  @JsonKey(name: "password", includeIfNull: false)
  final String? password;
  @JsonKey(name: "token", includeIfNull: false)
  final String? token;

  ReqLoginPacket({required this.requestId,
    required this.username,
    required this.password,
    required this.token,}) : super(packetType: "ReqLoginPacket");

  factory ReqLoginPacket.fromJson(Map<String, dynamic> json) => _$ReqLoginPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqLoginPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqLoginPacket{requestId: $requestId, username: $username, password: $password, token: $token}';
  }
}


@JsonSerializable()
class ReqCreateChannelMessagePacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "message")
  final String message;
  @JsonKey(name: "mentions", includeIfNull: false)
  final List<String>? mentions;

  ReqCreateChannelMessagePacket({required this.requestId,
    required this.channelId,
    required this.message,
    required this.mentions,}) : super(packetType: "ReqCreateChannelMessagePacket");

  factory ReqCreateChannelMessagePacket.fromJson(Map<String, dynamic> json) => _$ReqCreateChannelMessagePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqCreateChannelMessagePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqCreateChannelMessagePacket{requestId: $requestId, channelId: $channelId, message: $message, mentions: $mentions}';
  }
}


@JsonSerializable()
class ReqFetchChannelMessagesPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "last_message_id", includeIfNull: false)
  final String? lastMessageId;

  ReqFetchChannelMessagesPacket({required this.requestId,
    required this.channelId,
    required this.lastMessageId,}) : super(packetType: "ReqFetchChannelMessagesPacket");

  factory ReqFetchChannelMessagesPacket.fromJson(Map<String, dynamic> json) => _$ReqFetchChannelMessagesPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqFetchChannelMessagesPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqFetchChannelMessagesPacket{requestId: $requestId, channelId: $channelId, lastMessageId: $lastMessageId}';
  }
}


@JsonSerializable()
class ReqSetUserPasswordPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "old_password")
  final String oldPassword;
  @JsonKey(name: "new_password")
  final String newPassword;

  ReqSetUserPasswordPacket({required this.requestId,
    required this.oldPassword,
    required this.newPassword,}) : super(packetType: "ReqSetUserPasswordPacket");

  factory ReqSetUserPasswordPacket.fromJson(Map<String, dynamic> json) => _$ReqSetUserPasswordPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqSetUserPasswordPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqSetUserPasswordPacket{requestId: $requestId, oldPassword: $oldPassword, newPassword: $newPassword}';
  }
}


@JsonSerializable()
class ReqSetUserDisplayNamePacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "display_name")
  final String displayName;

  ReqSetUserDisplayNamePacket({required this.requestId,
    required this.displayName,}) : super(packetType: "ReqSetUserDisplayNamePacket");

  factory ReqSetUserDisplayNamePacket.fromJson(Map<String, dynamic> json) => _$ReqSetUserDisplayNamePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqSetUserDisplayNamePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqSetUserDisplayNamePacket{requestId: $requestId, displayName: $displayName}';
  }
}


@JsonSerializable()
class ReqSetUserStatusPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "status", includeIfNull: false)
  final String? status;

  ReqSetUserStatusPacket({required this.requestId,
    required this.status,}) : super(packetType: "ReqSetUserStatusPacket");

  factory ReqSetUserStatusPacket.fromJson(Map<String, dynamic> json) => _$ReqSetUserStatusPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqSetUserStatusPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqSetUserStatusPacket{requestId: $requestId, status: $status}';
  }
}


@JsonSerializable()
class ReqSetUserAvatarPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "avatar", includeIfNull: false)
  final String? avatar;
  @JsonKey(name: "avatar_blob", includeIfNull: false)
  final String? avatarBlob;

  ReqSetUserAvatarPacket({required this.requestId,
    required this.avatar,
    required this.avatarBlob,}) : super(packetType: "ReqSetUserAvatarPacket");

  factory ReqSetUserAvatarPacket.fromJson(Map<String, dynamic> json) => _$ReqSetUserAvatarPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqSetUserAvatarPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqSetUserAvatarPacket{requestId: $requestId, avatar: $avatar, avatarBlob: $avatarBlob}';
  }
}


@JsonSerializable()
class ReqSetUserPresencePacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "presence")
  final String presence;

  ReqSetUserPresencePacket({required this.requestId,
    required this.presence,}) : super(packetType: "ReqSetUserPresencePacket");

  factory ReqSetUserPresencePacket.fromJson(Map<String, dynamic> json) => _$ReqSetUserPresencePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqSetUserPresencePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqSetUserPresencePacket{requestId: $requestId, presence: $presence}';
  }
}


@JsonSerializable()
class ReqCreateChannelPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "server_id")
  final String serverId;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "description", includeIfNull: false)
  final String? description;
  @JsonKey(name: "private")
  final bool private;

  ReqCreateChannelPacket({required this.requestId,
    required this.serverId,
    required this.name,
    required this.description,
    required this.private,}) : super(packetType: "ReqCreateChannelPacket");

  factory ReqCreateChannelPacket.fromJson(Map<String, dynamic> json) => _$ReqCreateChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqCreateChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqCreateChannelPacket{requestId: $requestId, serverId: $serverId, name: $name, description: $description, private: $private}';
  }
}


@JsonSerializable()
class ReqDeleteChannelPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "server_id")
  final String serverId;

  ReqDeleteChannelPacket({required this.requestId,
    required this.channelId,
    required this.serverId,}) : super(packetType: "ReqDeleteChannelPacket");

  factory ReqDeleteChannelPacket.fromJson(Map<String, dynamic> json) => _$ReqDeleteChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqDeleteChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqDeleteChannelPacket{requestId: $requestId, channelId: $channelId, serverId: $serverId}';
  }
}


@JsonSerializable()
class ReqModifyChannelPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "name", includeIfNull: false)
  final String? name;
  @JsonKey(name: "description", includeIfNull: false)
  final String? description;

  ReqModifyChannelPacket({required this.requestId,
    required this.channelId,
    required this.name,
    required this.description,}) : super(packetType: "ReqModifyChannelPacket");

  factory ReqModifyChannelPacket.fromJson(Map<String, dynamic> json) => _$ReqModifyChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqModifyChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqModifyChannelPacket{requestId: $requestId, channelId: $channelId, name: $name, description: $description}';
  }
}


@JsonSerializable()
class ReqAddUserToChannelPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "user_id")
  final String userId;

  ReqAddUserToChannelPacket({required this.requestId,
    required this.channelId,
    required this.userId,}) : super(packetType: "ReqAddUserToChannelPacket");

  factory ReqAddUserToChannelPacket.fromJson(Map<String, dynamic> json) => _$ReqAddUserToChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqAddUserToChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqAddUserToChannelPacket{requestId: $requestId, channelId: $channelId, userId: $userId}';
  }
}


@JsonSerializable()
class ReqDeleteUserFromChannelPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "server_id")
  final String serverId;

  ReqDeleteUserFromChannelPacket({required this.requestId,
    required this.channelId,
    required this.userId,
    required this.serverId,}) : super(packetType: "ReqDeleteUserFromChannelPacket");

  factory ReqDeleteUserFromChannelPacket.fromJson(Map<String, dynamic> json) => _$ReqDeleteUserFromChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqDeleteUserFromChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqDeleteUserFromChannelPacket{requestId: $requestId, channelId: $channelId, userId: $userId, serverId: $serverId}';
  }
}


@JsonSerializable()
class ReqJoinVoiceChannelPacket extends RequestPacket {
  @JsonKey(name: "request_id")
  final int requestId;
  @JsonKey(name: "channel_id")
  final String channelId;

  ReqJoinVoiceChannelPacket({required this.requestId,
    required this.channelId,}) : super(packetType: "ReqJoinVoiceChannelPacket");

  factory ReqJoinVoiceChannelPacket.fromJson(Map<String, dynamic> json) => _$ReqJoinVoiceChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ReqJoinVoiceChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ReqJoinVoiceChannelPacket{requestId: $requestId, channelId: $channelId}';
  }
}


@JsonSerializable()
class ResPingPacket extends ResponseData {
  

  const ResPingPacket() : super();

  factory ResPingPacket.fromJson(Map<String, dynamic> json) => _$ResPingPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResPingPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResPingPacket{}';
  }
}


@JsonSerializable()
class ResFetchPublicKeyPacket extends ResponseData {
  @JsonKey(name: "public_key")
  final String publicKey;
  @JsonKey(name: "data")
  final String data;
  @JsonKey(name: "signature")
  final String signature;

  const ResFetchPublicKeyPacket({required this.publicKey,
    required this.data,
    required this.signature,}) : super();

  factory ResFetchPublicKeyPacket.fromJson(Map<String, dynamic> json) => _$ResFetchPublicKeyPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResFetchPublicKeyPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResFetchPublicKeyPacket{publicKey: $publicKey, data: $data, signature: $signature}';
  }
}


@JsonSerializable()
class ResLoginPacket extends ResponseData {
  @JsonKey(name: "token")
  final String token;
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "server_ids")
  final List<String> serverIds;
  @JsonKey(name: "main_server_id")
  final String mainServerId;

  const ResLoginPacket({required this.token,
    required this.userId,
    required this.serverIds,
    required this.mainServerId,}) : super();

  factory ResLoginPacket.fromJson(Map<String, dynamic> json) => _$ResLoginPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResLoginPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResLoginPacket{token: $token, userId: $userId, serverIds: $serverIds, mainServerId: $mainServerId}';
  }
}


@JsonSerializable()
class ResCreateChannelMessagePacket extends ResponseData {
  @JsonKey(name: "message")
  final Message message;
  @JsonKey(name: "relation")
  final Relation relation;
  @JsonKey(name: "mentions", includeIfNull: false)
  final List<String>? mentions;

  const ResCreateChannelMessagePacket({required this.message,
    required this.relation,
    required this.mentions,}) : super();

  factory ResCreateChannelMessagePacket.fromJson(Map<String, dynamic> json) => _$ResCreateChannelMessagePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResCreateChannelMessagePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResCreateChannelMessagePacket{message: $message, relation: $relation, mentions: $mentions}';
  }
}


@JsonSerializable()
class ResFetchChannelMessagesPacket extends ResponseData {
  @JsonKey(name: "messages")
  final List<Message> messages;
  @JsonKey(name: "relations")
  final List<Relation> relations;

  const ResFetchChannelMessagesPacket({required this.messages,
    required this.relations,}) : super();

  factory ResFetchChannelMessagesPacket.fromJson(Map<String, dynamic> json) => _$ResFetchChannelMessagesPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResFetchChannelMessagesPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResFetchChannelMessagesPacket{messages: $messages, relations: $relations}';
  }
}


@JsonSerializable()
class ResSetUserPasswordPacket extends ResponseData {
  

  const ResSetUserPasswordPacket() : super();

  factory ResSetUserPasswordPacket.fromJson(Map<String, dynamic> json) => _$ResSetUserPasswordPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResSetUserPasswordPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResSetUserPasswordPacket{}';
  }
}


@JsonSerializable()
class ResSetUserDisplayNamePacket extends ResponseData {
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "display_name")
  final String displayName;

  const ResSetUserDisplayNamePacket({required this.userId,
    required this.displayName,}) : super();

  factory ResSetUserDisplayNamePacket.fromJson(Map<String, dynamic> json) => _$ResSetUserDisplayNamePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResSetUserDisplayNamePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResSetUserDisplayNamePacket{userId: $userId, displayName: $displayName}';
  }
}


@JsonSerializable()
class ResSetUserStatusPacket extends ResponseData {
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "status", includeIfNull: false)
  final String? status;

  const ResSetUserStatusPacket({required this.userId,
    required this.status,}) : super();

  factory ResSetUserStatusPacket.fromJson(Map<String, dynamic> json) => _$ResSetUserStatusPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResSetUserStatusPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResSetUserStatusPacket{userId: $userId, status: $status}';
  }
}


@JsonSerializable()
class ResSetUserAvatarPacket extends ResponseData {
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "avatar_url", includeIfNull: false)
  final String? avatarUrl;

  const ResSetUserAvatarPacket({required this.userId,
    required this.avatarUrl,}) : super();

  factory ResSetUserAvatarPacket.fromJson(Map<String, dynamic> json) => _$ResSetUserAvatarPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResSetUserAvatarPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResSetUserAvatarPacket{userId: $userId, avatarUrl: $avatarUrl}';
  }
}


@JsonSerializable()
class ResSetUserPresencePacket extends ResponseData {
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "presence")
  final String presence;

  const ResSetUserPresencePacket({required this.userId,
    required this.presence,}) : super();

  factory ResSetUserPresencePacket.fromJson(Map<String, dynamic> json) => _$ResSetUserPresencePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResSetUserPresencePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResSetUserPresencePacket{userId: $userId, presence: $presence}';
  }
}


@JsonSerializable()
class ResCreateChannelPacket extends ResponseData {
  @JsonKey(name: "channel")
  final Channel channel;
  @JsonKey(name: "channel_users_relation")
  final List<Relation> channelUsersRelation;
  @JsonKey(name: "server_channel_relation")
  final Relation serverChannelRelation;

  const ResCreateChannelPacket({required this.channel,
    required this.channelUsersRelation,
    required this.serverChannelRelation,}) : super();

  factory ResCreateChannelPacket.fromJson(Map<String, dynamic> json) => _$ResCreateChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResCreateChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResCreateChannelPacket{channel: $channel, channelUsersRelation: $channelUsersRelation, serverChannelRelation: $serverChannelRelation}';
  }
}


@JsonSerializable()
class ResDeleteChannelPacket extends ResponseData {
  @JsonKey(name: "channel_id")
  final String channelId;

  const ResDeleteChannelPacket({required this.channelId,}) : super();

  factory ResDeleteChannelPacket.fromJson(Map<String, dynamic> json) => _$ResDeleteChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResDeleteChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResDeleteChannelPacket{channelId: $channelId}';
  }
}


@JsonSerializable()
class ResModifyChannelPacket extends ResponseData {
  @JsonKey(name: "channel")
  final Channel channel;

  const ResModifyChannelPacket({required this.channel,}) : super();

  factory ResModifyChannelPacket.fromJson(Map<String, dynamic> json) => _$ResModifyChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResModifyChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResModifyChannelPacket{channel: $channel}';
  }
}


@JsonSerializable()
class ResAddUserToChannelPacket extends ResponseData {
  @JsonKey(name: "relation")
  final Relation relation;

  const ResAddUserToChannelPacket({required this.relation,}) : super();

  factory ResAddUserToChannelPacket.fromJson(Map<String, dynamic> json) => _$ResAddUserToChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResAddUserToChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResAddUserToChannelPacket{relation: $relation}';
  }
}


@JsonSerializable()
class ResDeleteUserFromChannelPacket extends ResponseData {
  @JsonKey(name: "relation")
  final Relation relation;

  const ResDeleteUserFromChannelPacket({required this.relation,}) : super();

  factory ResDeleteUserFromChannelPacket.fromJson(Map<String, dynamic> json) => _$ResDeleteUserFromChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResDeleteUserFromChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResDeleteUserFromChannelPacket{relation: $relation}';
  }
}


@JsonSerializable()
class ResJoinVoiceChannelPacket extends ResponseData {
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "channel_id")
  final String channelId;
  @JsonKey(name: "token")
  final String token;

  const ResJoinVoiceChannelPacket({required this.userId,
    required this.channelId,
    required this.token,}) : super();

  factory ResJoinVoiceChannelPacket.fromJson(Map<String, dynamic> json) => _$ResJoinVoiceChannelPacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$ResJoinVoiceChannelPacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'ResJoinVoiceChannelPacket{userId: $userId, channelId: $channelId, token: $token}';
  }
}


@JsonSerializable()
class EvtWelcomePacket extends EventData {
  @JsonKey(name: "servers")
  final List<Server> servers;
  @JsonKey(name: "server_users")
  final List<Relation> serverUsers;
  @JsonKey(name: "server_channels")
  final List<Relation> serverChannels;
  @JsonKey(name: "permissions")
  final List<Permission> permissions;
  @JsonKey(name: "roles")
  final List<Role> roles;
  @JsonKey(name: "role_users")
  final List<Relation> roleUsers;
  @JsonKey(name: "role_permissions")
  final List<Relation> rolePermissions;
  @JsonKey(name: "channels")
  final List<Channel> channels;
  @JsonKey(name: "channel_users")
  final List<Relation> channelUsers;
  @JsonKey(name: "users")
  final List<User> users;
  @JsonKey(name: "unread_messages")
  final List<UnreadMessageRelation> unreadMessages;

  const EvtWelcomePacket({required this.servers,
    required this.serverUsers,
    required this.serverChannels,
    required this.permissions,
    required this.roles,
    required this.roleUsers,
    required this.rolePermissions,
    required this.channels,
    required this.channelUsers,
    required this.users,
    required this.unreadMessages,}) : super();

  factory EvtWelcomePacket.fromJson(Map<String, dynamic> json) => _$EvtWelcomePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$EvtWelcomePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'EvtWelcomePacket{servers: $servers, serverUsers: $serverUsers, serverChannels: $serverChannels, permissions: $permissions, roles: $roles, roleUsers: $roleUsers, rolePermissions: $rolePermissions, channels: $channels, channelUsers: $channelUsers, users: $users, unreadMessages: $unreadMessages}';
  }
}


@JsonSerializable()
class EvtUpdatePresencePacket extends EventData {
  @JsonKey(name: "user_id")
  final String userId;
  @JsonKey(name: "presence")
  final String presence;

  const EvtUpdatePresencePacket({required this.userId,
    required this.presence,}) : super();

  factory EvtUpdatePresencePacket.fromJson(Map<String, dynamic> json) => _$EvtUpdatePresencePacketFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$EvtUpdatePresencePacketToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'EvtUpdatePresencePacket{userId: $userId, presence: $presence}';
  }
}

class PacketFactory {
  static final Map<Type, ApiResponse<ResponseData> Function(int?, String, PacketError?)> _creators = {
        ResPingPacket: (requestId, type, error) => ApiResponse<ResPingPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResFetchPublicKeyPacket: (requestId, type, error) => ApiResponse<ResFetchPublicKeyPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResLoginPacket: (requestId, type, error) => ApiResponse<ResLoginPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResCreateChannelMessagePacket: (requestId, type, error) => ApiResponse<ResCreateChannelMessagePacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResFetchChannelMessagesPacket: (requestId, type, error) => ApiResponse<ResFetchChannelMessagesPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResSetUserPasswordPacket: (requestId, type, error) => ApiResponse<ResSetUserPasswordPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResSetUserDisplayNamePacket: (requestId, type, error) => ApiResponse<ResSetUserDisplayNamePacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResSetUserStatusPacket: (requestId, type, error) => ApiResponse<ResSetUserStatusPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResSetUserAvatarPacket: (requestId, type, error) => ApiResponse<ResSetUserAvatarPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResSetUserPresencePacket: (requestId, type, error) => ApiResponse<ResSetUserPresencePacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResCreateChannelPacket: (requestId, type, error) => ApiResponse<ResCreateChannelPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResDeleteChannelPacket: (requestId, type, error) => ApiResponse<ResDeleteChannelPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResModifyChannelPacket: (requestId, type, error) => ApiResponse<ResModifyChannelPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResAddUserToChannelPacket: (requestId, type, error) => ApiResponse<ResAddUserToChannelPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResDeleteUserFromChannelPacket: (requestId, type, error) => ApiResponse<ResDeleteUserFromChannelPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
        ResJoinVoiceChannelPacket: (requestId, type, error) => ApiResponse<ResJoinVoiceChannelPacket>(
      requestId: requestId,
      type: type,
      data: null,
      error: error,
    ),
  };
  
  static ApiResponse<ResponseData> createErrorResponse(Type type, int? requestId, String responseType, PacketError? error) {
    final creator = _creators[type];
    if (creator == null) {
      throw Exception('Unknown packet type: $type');
    }
    return creator(requestId, responseType, error);
  }

  static Type? getTypeFromString(String typeString) {
    return _creators.keys.firstWhereOrNull(
      (type) => type.toString() == typeString,
    );
  }
}
