// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestPacket _$RequestPacketFromJson(Map<String, dynamic> json) =>
    RequestPacket(
      packetType: json['type'] as String,
    );

Map<String, dynamic> _$RequestPacketToJson(RequestPacket instance) =>
    <String, dynamic>{
      'type': instance.packetType,
    };

ResponseData _$ResponseDataFromJson(Map<String, dynamic> json) =>
    ResponseData();

Map<String, dynamic> _$ResponseDataToJson(ResponseData instance) =>
    <String, dynamic>{};

EventData _$EventDataFromJson(Map<String, dynamic> json) => EventData();

Map<String, dynamic> _$EventDataToJson(EventData instance) =>
    <String, dynamic>{};

ReqPingPacket _$ReqPingPacketFromJson(Map<String, dynamic> json) =>
    ReqPingPacket(
      requestId: (json['request_id'] as num).toInt(),
    );

Map<String, dynamic> _$ReqPingPacketToJson(ReqPingPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
    };

ReqLoginPacket _$ReqLoginPacketFromJson(Map<String, dynamic> json) =>
    ReqLoginPacket(
      requestId: (json['request_id'] as num).toInt(),
      username: json['username'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$ReqLoginPacketToJson(ReqLoginPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'username': instance.username,
      'password': instance.password,
      'token': instance.token,
    };

ReqCreateChannelMessagePacket _$ReqCreateChannelMessagePacketFromJson(
        Map<String, dynamic> json) =>
    ReqCreateChannelMessagePacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
      message: json['message'] as String,
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ReqCreateChannelMessagePacketToJson(
        ReqCreateChannelMessagePacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
      'message': instance.message,
      'mentions': instance.mentions,
    };

ReqFetchChannelMessagesPacket _$ReqFetchChannelMessagesPacketFromJson(
        Map<String, dynamic> json) =>
    ReqFetchChannelMessagesPacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
      lastMessageId: json['last_message_id'] as String?,
    );

Map<String, dynamic> _$ReqFetchChannelMessagesPacketToJson(
        ReqFetchChannelMessagesPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
      'last_message_id': instance.lastMessageId,
    };

ReqSetUserPasswordPacket _$ReqSetUserPasswordPacketFromJson(
        Map<String, dynamic> json) =>
    ReqSetUserPasswordPacket(
      requestId: (json['request_id'] as num).toInt(),
      oldPassword: json['old_password'] as String,
      newPassword: json['new_password'] as String,
    );

Map<String, dynamic> _$ReqSetUserPasswordPacketToJson(
        ReqSetUserPasswordPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'old_password': instance.oldPassword,
      'new_password': instance.newPassword,
    };

ReqSetUserDisplayNamePacket _$ReqSetUserDisplayNamePacketFromJson(
        Map<String, dynamic> json) =>
    ReqSetUserDisplayNamePacket(
      requestId: (json['request_id'] as num).toInt(),
      displayName: json['display_name'] as String,
    );

Map<String, dynamic> _$ReqSetUserDisplayNamePacketToJson(
        ReqSetUserDisplayNamePacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'display_name': instance.displayName,
    };

ReqSetUserStatusPacket _$ReqSetUserStatusPacketFromJson(
        Map<String, dynamic> json) =>
    ReqSetUserStatusPacket(
      requestId: (json['request_id'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ReqSetUserStatusPacketToJson(
        ReqSetUserStatusPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'status': instance.status,
    };

ReqSetUserAvatarPacket _$ReqSetUserAvatarPacketFromJson(
        Map<String, dynamic> json) =>
    ReqSetUserAvatarPacket(
      requestId: (json['request_id'] as num).toInt(),
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$ReqSetUserAvatarPacketToJson(
        ReqSetUserAvatarPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'avatar': instance.avatar,
    };

ReqSetUserPresencePacket _$ReqSetUserPresencePacketFromJson(
        Map<String, dynamic> json) =>
    ReqSetUserPresencePacket(
      requestId: (json['request_id'] as num).toInt(),
      presence: json['presence'] as String,
    );

Map<String, dynamic> _$ReqSetUserPresencePacketToJson(
        ReqSetUserPresencePacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'presence': instance.presence,
    };

ReqCreateChannelPacket _$ReqCreateChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ReqCreateChannelPacket(
      requestId: (json['request_id'] as num).toInt(),
      serverId: json['server_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ReqCreateChannelPacketToJson(
        ReqCreateChannelPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'server_id': instance.serverId,
      'name': instance.name,
      'description': instance.description,
    };

ReqDeleteChannelPacket _$ReqDeleteChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ReqDeleteChannelPacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
    );

Map<String, dynamic> _$ReqDeleteChannelPacketToJson(
        ReqDeleteChannelPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
    };

ReqModifyChannelPacket _$ReqModifyChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ReqModifyChannelPacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ReqModifyChannelPacketToJson(
        ReqModifyChannelPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
      'name': instance.name,
      'description': instance.description,
    };

ReqAddUserToChannelPacket _$ReqAddUserToChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ReqAddUserToChannelPacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$ReqAddUserToChannelPacketToJson(
        ReqAddUserToChannelPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
      'user_id': instance.userId,
    };

ReqDeleteUserFromChannelPacket _$ReqDeleteUserFromChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ReqDeleteUserFromChannelPacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$ReqDeleteUserFromChannelPacketToJson(
        ReqDeleteUserFromChannelPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
      'user_id': instance.userId,
    };

ReqJoinVoiceChannelPacket _$ReqJoinVoiceChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ReqJoinVoiceChannelPacket(
      requestId: (json['request_id'] as num).toInt(),
      channelId: json['channel_id'] as String,
    );

Map<String, dynamic> _$ReqJoinVoiceChannelPacketToJson(
        ReqJoinVoiceChannelPacket instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'channel_id': instance.channelId,
    };

ResPingPacket _$ResPingPacketFromJson(Map<String, dynamic> json) =>
    ResPingPacket();

Map<String, dynamic> _$ResPingPacketToJson(ResPingPacket instance) =>
    <String, dynamic>{};

ResLoginPacket _$ResLoginPacketFromJson(Map<String, dynamic> json) =>
    ResLoginPacket(
      token: json['token'] as String,
      userId: json['user_id'] as String,
      serverIds: (json['server_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mainServerId: json['main_server_id'] as String,
    );

Map<String, dynamic> _$ResLoginPacketToJson(ResLoginPacket instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user_id': instance.userId,
      'server_ids': instance.serverIds,
      'main_server_id': instance.mainServerId,
    };

ResCreateChannelMessagePacket _$ResCreateChannelMessagePacketFromJson(
        Map<String, dynamic> json) =>
    ResCreateChannelMessagePacket(
      message: Message.fromJson(json['message'] as Map<String, dynamic>),
      relation: Relation.fromJson(json['relation'] as Map<String, dynamic>),
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ResCreateChannelMessagePacketToJson(
        ResCreateChannelMessagePacket instance) =>
    <String, dynamic>{
      'message': instance.message,
      'relation': instance.relation,
      'mentions': instance.mentions,
    };

ResFetchChannelMessagesPacket _$ResFetchChannelMessagesPacketFromJson(
        Map<String, dynamic> json) =>
    ResFetchChannelMessagesPacket(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      relations: (json['relations'] as List<dynamic>)
          .map((e) => Relation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResFetchChannelMessagesPacketToJson(
        ResFetchChannelMessagesPacket instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'relations': instance.relations,
    };

ResSetUserPasswordPacket _$ResSetUserPasswordPacketFromJson(
        Map<String, dynamic> json) =>
    ResSetUserPasswordPacket();

Map<String, dynamic> _$ResSetUserPasswordPacketToJson(
        ResSetUserPasswordPacket instance) =>
    <String, dynamic>{};

ResSetUserDisplayNamePacket _$ResSetUserDisplayNamePacketFromJson(
        Map<String, dynamic> json) =>
    ResSetUserDisplayNamePacket(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
    );

Map<String, dynamic> _$ResSetUserDisplayNamePacketToJson(
        ResSetUserDisplayNamePacket instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'display_name': instance.displayName,
    };

ResSetUserStatusPacket _$ResSetUserStatusPacketFromJson(
        Map<String, dynamic> json) =>
    ResSetUserStatusPacket(
      userId: json['user_id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ResSetUserStatusPacketToJson(
        ResSetUserStatusPacket instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'status': instance.status,
    };

ResSetUserAvatarPacket _$ResSetUserAvatarPacketFromJson(
        Map<String, dynamic> json) =>
    ResSetUserAvatarPacket(
      userId: json['user_id'] as String,
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$ResSetUserAvatarPacketToJson(
        ResSetUserAvatarPacket instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'avatar': instance.avatar,
    };

ResSetUserPresencePacket _$ResSetUserPresencePacketFromJson(
        Map<String, dynamic> json) =>
    ResSetUserPresencePacket(
      userId: json['user_id'] as String,
      presence: json['presence'] as String,
    );

Map<String, dynamic> _$ResSetUserPresencePacketToJson(
        ResSetUserPresencePacket instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'presence': instance.presence,
    };

ResCreateChannelPacket _$ResCreateChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ResCreateChannelPacket(
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
      channelUserRelation: Relation.fromJson(
          json['channel_user_relation'] as Map<String, dynamic>),
      serverChannelRelation: Relation.fromJson(
          json['server_channel_relation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResCreateChannelPacketToJson(
        ResCreateChannelPacket instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'channel_user_relation': instance.channelUserRelation,
      'server_channel_relation': instance.serverChannelRelation,
    };

ResDeleteChannelPacket _$ResDeleteChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ResDeleteChannelPacket(
      channelId: json['channel_id'] as String,
    );

Map<String, dynamic> _$ResDeleteChannelPacketToJson(
        ResDeleteChannelPacket instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
    };

ResModifyChannelPacket _$ResModifyChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ResModifyChannelPacket(
      channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResModifyChannelPacketToJson(
        ResModifyChannelPacket instance) =>
    <String, dynamic>{
      'channel': instance.channel,
    };

ResAddUserToChannelPacket _$ResAddUserToChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ResAddUserToChannelPacket(
      relation: Relation.fromJson(json['relation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResAddUserToChannelPacketToJson(
        ResAddUserToChannelPacket instance) =>
    <String, dynamic>{
      'relation': instance.relation,
    };

ResDeleteUserFromChannelPacket _$ResDeleteUserFromChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ResDeleteUserFromChannelPacket(
      relation: Relation.fromJson(json['relation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResDeleteUserFromChannelPacketToJson(
        ResDeleteUserFromChannelPacket instance) =>
    <String, dynamic>{
      'relation': instance.relation,
    };

ResJoinVoiceChannelPacket _$ResJoinVoiceChannelPacketFromJson(
        Map<String, dynamic> json) =>
    ResJoinVoiceChannelPacket(
      userId: json['user_id'] as String,
      channelId: json['channel_id'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$ResJoinVoiceChannelPacketToJson(
        ResJoinVoiceChannelPacket instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'channel_id': instance.channelId,
      'token': instance.token,
    };

EvtWelcomePacket _$EvtWelcomePacketFromJson(Map<String, dynamic> json) =>
    EvtWelcomePacket(
      servers: (json['servers'] as List<dynamic>)
          .map((e) => Server.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverUsers: (json['server_users'] as List<dynamic>)
          .map((e) => Relation.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverChannels: (json['server_channels'] as List<dynamic>)
          .map((e) => Relation.fromJson(e as Map<String, dynamic>))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => Permission.fromJson(e as Map<String, dynamic>))
          .toList(),
      roles: (json['roles'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      roleUsers: (json['role_users'] as List<dynamic>)
          .map((e) => Relation.fromJson(e as Map<String, dynamic>))
          .toList(),
      rolePermissions: (json['role_permissions'] as List<dynamic>)
          .map((e) => Relation.fromJson(e as Map<String, dynamic>))
          .toList(),
      channels: (json['channels'] as List<dynamic>)
          .map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
      channelUsers: (json['channel_users'] as List<dynamic>)
          .map((e) => Relation.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EvtWelcomePacketToJson(EvtWelcomePacket instance) =>
    <String, dynamic>{
      'servers': instance.servers,
      'server_users': instance.serverUsers,
      'server_channels': instance.serverChannels,
      'permissions': instance.permissions,
      'roles': instance.roles,
      'role_users': instance.roleUsers,
      'role_permissions': instance.rolePermissions,
      'channels': instance.channels,
      'channel_users': instance.channelUsers,
      'users': instance.users,
    };

EvtUpdatePresencePacket _$EvtUpdatePresencePacketFromJson(
        Map<String, dynamic> json) =>
    EvtUpdatePresencePacket(
      userId: json['user_id'] as String,
      presence: json['presence'] as String,
    );

Map<String, dynamic> _$EvtUpdatePresencePacketToJson(
        EvtUpdatePresencePacket instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'presence': instance.presence,
    };
