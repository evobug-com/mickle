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
  @JsonKey(name: "parent")
  String? parent;

  Server({required this.id,
    required this.name,
    required this.main,
    required this.parent,});

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
  @JsonKey(name: "mentions")
  List<String>? mentions;

  Message({required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.mentions,});

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
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "archived")
  bool archived;

  Channel({required this.id,
    required this.name,
    required this.description,
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
  @JsonKey(name: "display_name")
  String? displayName;
  @JsonKey(name: "first_name")
  String? firstName;
  @JsonKey(name: "last_name")
  String? lastName;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "last_seen")
  DateTime? lastSeen;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "avatar")
  String? avatar;
  @JsonKey(name: "presence")
  String? presence;

  User({required this.id,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.lastSeen,
    required this.status,
    required this.avatar,
    required this.presence,});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  void notify() => notifyListeners();
  
  @override
  String toString() {
    return 'User{id: $id, displayName: $displayName, firstName: $firstName, lastName: $lastName, createdAt: $createdAt, lastSeen: $lastSeen, status: $status, avatar: $avatar, presence: $presence}';
  }
}

