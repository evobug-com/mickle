// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relation _$RelationFromJson(Map<String, dynamic> json) => Relation(
      id: json['id'] as String,
      input: json['input'] as String,
      output: json['output'] as String,
    );

Map<String, dynamic> _$RelationToJson(Relation instance) => <String, dynamic>{
      'id': instance.id,
      'input': instance.input,
      'output': instance.output,
    };

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      id: json['id'] as String,
      user: json['user'] as String,
      token: json['token'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'token': instance.token,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
    };

Server _$ServerFromJson(Map<String, dynamic> json) => Server(
      id: json['id'] as String,
      name: json['name'] as String,
      main: json['main'] as bool,
      parent: json['parent'] as String?,
    );

Map<String, dynamic> _$ServerToJson(Server instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'main': instance.main,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('parent', instance.parent);
  return val;
}

Permission _$PermissionFromJson(Map<String, dynamic> json) => Permission(
      id: json['id'] as String,
    );

Map<String, dynamic> _$PermissionToJson(Permission instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      id: json['id'] as String,
      name: json['name'] as String,
      rank: (json['rank'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'rank': instance.rank,
      'created_at': instance.createdAt.toIso8601String(),
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      user: json['user'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MessageToJson(Message instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'user': instance.user,
    'content': instance.content,
    'created_at': instance.createdAt.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('mentions', instance.mentions);
  return val;
}

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      archived: json['archived'] as bool,
    );

Map<String, dynamic> _$ChannelToJson(Channel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  val['created_at'] = instance.createdAt.toIso8601String();
  val['archived'] = instance.archived;
  return val;
}

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] == null
          ? null
          : DateTime.parse(json['last_seen'] as String),
      status: json['status'] as String?,
      avatar: json['avatar'] as String?,
      presence: json['presence'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('display_name', instance.displayName);
  writeNotNull('first_name', instance.firstName);
  writeNotNull('last_name', instance.lastName);
  val['created_at'] = instance.createdAt.toIso8601String();
  writeNotNull('last_seen', instance.lastSeen?.toIso8601String());
  writeNotNull('status', instance.status);
  writeNotNull('avatar', instance.avatar);
  val['presence'] = instance.presence;
  return val;
}

UnreadMessageRelation _$UnreadMessageRelationFromJson(
        Map<String, dynamic> json) =>
    UnreadMessageRelation(
      lastReadMessageId: json['last_read_message_id'] as String?,
      unreadCount: (json['unread_count'] as num).toInt(),
      lastUpdate: DateTime.parse(json['last_update'] as String),
      input: json['input'] as String,
      output: json['output'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$UnreadMessageRelationToJson(
    UnreadMessageRelation instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'input': instance.input,
    'output': instance.output,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('last_read_message_id', instance.lastReadMessageId);
  val['unread_count'] = instance.unreadCount;
  val['last_update'] = instance.lastUpdate.toIso8601String();
  return val;
}
