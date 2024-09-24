// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, unused_field, unused_import, unnecessary_this, prefer_const_constructors


import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

part 'models.g.dart';


@JsonSerializable()
class Relation with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "input")
  String input;
  @JsonKey(name: "output")
  String output;

  Relation({required this.id,
    required this.input,
    required this.output,});

  factory Relation.fromJson(Map<String, dynamic> json) => _$RelationFromJson(json);
  Map<String, dynamic> toJson() => _$RelationToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Relation{id: $id, input: $input, output: $output}';
  }
}


@JsonSerializable()
class Token with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "user")
  String user;
  @JsonKey(name: "token")
  String token;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "expires_at")
  DateTime expiresAt;

  Token({required this.id,
    required this.user,
    required this.token,
    required this.createdAt,
    required this.expiresAt,});

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Token{id: $id, user: $user, token: $token, createdAt: $createdAt, expiresAt: $expiresAt}';
  }
}


@JsonSerializable()
class Server with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "main")
  bool main;
  @JsonKey(name: "parent", includeIfNull: false)
  String? parent;

  Server({required this.id,
    required this.name,
    required this.main,
    this.parent,});

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
  Map<String, dynamic> toJson() => _$ServerToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Server{id: $id, name: $name, main: $main, parent: $parent}';
  }
}


@JsonSerializable()
class Permission with ChangeNotifier {
  @JsonKey(name: "id")
  String id;

  Permission({required this.id,});

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Permission{id: $id}';
  }
}


@JsonSerializable()
class Role with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "rank")
  int rank;
  @JsonKey(name: "created_at")
  DateTime createdAt;

  Role({required this.id,
    required this.name,
    required this.rank,
    required this.createdAt,});

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Role{id: $id, name: $name, rank: $rank, createdAt: $createdAt}';
  }
}


@JsonSerializable()
class Message with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "user")
  String user;
  @JsonKey(name: "content")
  String content;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "mentions", includeIfNull: false)
  List<String>? mentions;

  Message({required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    this.mentions,});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Message{id: $id, user: $user, content: $content, createdAt: $createdAt, mentions: $mentions}';
  }
}


@JsonSerializable()
class Channel with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "description", includeIfNull: false)
  String? description;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "archived")
  bool archived;

  Channel({required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.archived,});

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'Channel{id: $id, name: $name, description: $description, createdAt: $createdAt, archived: $archived}';
  }
}


@JsonSerializable()
class User with ChangeNotifier {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "username", includeIfNull: false)
  String? username;
  @JsonKey(name: "display_name", includeIfNull: false)
  String? displayName;
  @JsonKey(name: "first_name", includeIfNull: false)
  String? firstName;
  @JsonKey(name: "last_name", includeIfNull: false)
  String? lastName;
  @JsonKey(name: "email", includeIfNull: false)
  String? email;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "last_seen", includeIfNull: false)
  DateTime? lastSeen;
  @JsonKey(name: "status", includeIfNull: false)
  String? status;
  @JsonKey(name: "avatar", includeIfNull: false)
  String? avatar;
  @JsonKey(name: "avatar_url", includeIfNull: false)
  String? avatarUrl;
  @JsonKey(name: "presence")
  String presence;

  User({required this.id,
    this.username,
    this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    required this.createdAt,
    this.lastSeen,
    this.status,
    this.avatar,
    this.avatarUrl,
    required this.presence,});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  void notify() => notifyListeners();

  @override
  String toString() {
    return 'User{id: $id, username: $username, displayName: $displayName, firstName: $firstName, lastName: $lastName, email: $email, createdAt: $createdAt, lastSeen: $lastSeen, status: $status, avatar: $avatar, avatarUrl: $avatarUrl, presence: $presence}';
  }
}


@JsonSerializable()
class UnreadMessageRelation extends Relation {
  @JsonKey(name: "last_read_message_id", includeIfNull: false)
  final String? lastReadMessageId;
  @JsonKey(name: "unread_count")
  final int unreadCount;
  @JsonKey(name: "last_update")
  final DateTime lastUpdate;

  UnreadMessageRelation({required this.lastReadMessageId,
    required this.unreadCount,
    required this.lastUpdate, required String input, required String output, required String id}) : super(input: input, output: output, id: id);

  factory UnreadMessageRelation.fromJson(Map<String, dynamic> json) => _$UnreadMessageRelationFromJson(json);
    @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$UnreadMessageRelationToJson(this);
    json.addAll(super.toJson());
    return json;
  }

  @override
  String toString() {
    return 'UnreadMessageRelation{id: $id, input: $input, output: $output, lastReadMessageId: $lastReadMessageId, unreadCount: $unreadCount, lastUpdate: $lastUpdate}';
  }
}

