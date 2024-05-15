part of 'response.dart';

class Login {

  static const PacketResponse packetName = PacketResponse.Login;

  late int requestId;
  String? error;
  String? token;
  String? userId;
  String? serverId;
  
  Login();
  
  factory Login.fromReference(flex_buffers.Reference data) {
    return Login()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..token = data["token"].stringValue
      ..userId = data["userId"].stringValue
      ..serverId = data["serverId"].stringValue;
  }
}
class Ping {

  static const PacketResponse packetName = PacketResponse.Ping;

  
  
  Ping();
  
  factory Ping.fromReference(flex_buffers.Reference data) {
    return Ping()
      ;
  }
}
class LoginWelcome {

  static const PacketResponse packetName = PacketResponse.LoginWelcome;

  late List<models.Server> servers;
  late List<models.Relation> serverUsers;
  late List<models.Relation> serverChannels;
  late List<models.Permission> permissions;
  late List<models.Role> roles;
  late List<models.Relation> roleUsers;
  late List<models.Relation> rolePermissions;
  late List<models.Channel> channels;
  late List<models.Relation> channelUsers;
  late List<models.User> users;
  
  LoginWelcome();
  
  factory LoginWelcome.fromReference(flex_buffers.Reference data) {
    return LoginWelcome()
      ..servers = data["servers"].vectorIterable.map((item) => models.Server.fromReference(item)).toList()
      ..serverUsers = data["serverUsers"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..serverChannels = data["serverChannels"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..permissions = data["permissions"].vectorIterable.map((item) => models.Permission.fromReference(item)).toList()
      ..roles = data["roles"].vectorIterable.map((item) => models.Role.fromReference(item)).toList()
      ..roleUsers = data["roleUsers"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..rolePermissions = data["rolePermissions"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..channels = data["channels"].vectorIterable.map((item) => models.Channel.fromReference(item)).toList()
      ..channelUsers = data["channelUsers"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..users = data["users"].vectorIterable.map((item) => models.User.fromReference(item)).toList();
  }
}
class UpdatePresence {

  static const PacketResponse packetName = PacketResponse.UpdatePresence;

  late String userId;
  late String presence;
  
  UpdatePresence();
  
  factory UpdatePresence.fromReference(flex_buffers.Reference data) {
    return UpdatePresence()
      ..userId = data["userId"].stringValue!
      ..presence = data["presence"].stringValue!;
  }
}
class ChannelMessageCreate {

  static const PacketResponse packetName = PacketResponse.ChannelMessageCreate;

  late int requestId;
  String? error;
  models.Message? message;
  models.Relation? relation;
  List<String>? mentions;
  
  ChannelMessageCreate();
  
  factory ChannelMessageCreate.fromReference(flex_buffers.Reference data) {
    return ChannelMessageCreate()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..message = data["message"].isNull ? null : models.Message.fromReference(data["message"])
      ..relation = data["relation"].isNull ? null : models.Relation.fromReference(data["relation"])
      ..mentions = data["mentions"].isNull ? null : data["mentions"].vectorIterable.map((item) => item.stringValue!).toList();
  }
}
class UserChangePassword {

  static const PacketResponse packetName = PacketResponse.UserChangePassword;

  late int requestId;
  String? error;
  
  UserChangePassword();
  
  factory UserChangePassword.fromReference(flex_buffers.Reference data) {
    return UserChangePassword()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue;
  }
}
class UserChangeDisplayName {

  static const PacketResponse packetName = PacketResponse.UserChangeDisplayName;

  late int requestId;
  late String userId;
  late String displayName;
  String? error;
  
  UserChangeDisplayName();
  
  factory UserChangeDisplayName.fromReference(flex_buffers.Reference data) {
    return UserChangeDisplayName()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..displayName = data["displayName"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class UserChangeStatus {

  static const PacketResponse packetName = PacketResponse.UserChangeStatus;

  late int requestId;
  late String userId;
  late String status;
  String? error;
  
  UserChangeStatus();
  
  factory UserChangeStatus.fromReference(flex_buffers.Reference data) {
    return UserChangeStatus()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..status = data["status"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class UserChangeAvatar {

  static const PacketResponse packetName = PacketResponse.UserChangeAvatar;

  late int requestId;
  late String userId;
  late String avatar;
  String? error;
  
  UserChangeAvatar();
  
  factory UserChangeAvatar.fromReference(flex_buffers.Reference data) {
    return UserChangeAvatar()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..avatar = data["avatar"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class UserChangePresence {

  static const PacketResponse packetName = PacketResponse.UserChangePresence;

  late int requestId;
  late String userId;
  late String presence;
  String? error;
  
  UserChangePresence();
  
  factory UserChangePresence.fromReference(flex_buffers.Reference data) {
    return UserChangePresence()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..presence = data["presence"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class ChannelMessageFetch {

  static const PacketResponse packetName = PacketResponse.ChannelMessageFetch;

  late int requestId;
  String? error;
  late List<models.Message> messages;
  late List<models.Relation> relations;
  
  ChannelMessageFetch();
  
  factory ChannelMessageFetch.fromReference(flex_buffers.Reference data) {
    return ChannelMessageFetch()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..messages = data["messages"].vectorIterable.map((item) => models.Message.fromReference(item)).toList()
      ..relations = data["relations"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList();
  }
}
class ChannelCreate {

  static const PacketResponse packetName = PacketResponse.ChannelCreate;

  late int requestId;
  String? error;
  models.Channel? channel;
  models.Relation? channelUserRelation;
  models.Relation? serverChannelRelation;
  
  ChannelCreate();
  
  factory ChannelCreate.fromReference(flex_buffers.Reference data) {
    return ChannelCreate()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..channel = data["channel"].isNull ? null : models.Channel.fromReference(data["channel"])
      ..channelUserRelation = data["channelUserRelation"].isNull ? null : models.Relation.fromReference(data["channelUserRelation"])
      ..serverChannelRelation = data["serverChannelRelation"].isNull ? null : models.Relation.fromReference(data["serverChannelRelation"]);
  }
}
class ChannelDelete {

  static const PacketResponse packetName = PacketResponse.ChannelDelete;

  late int requestId;
  late String channelId;
  String? error;
  
  ChannelDelete();
  
  factory ChannelDelete.fromReference(flex_buffers.Reference data) {
    return ChannelDelete()
      ..requestId = data["requestId"].intValue!
      ..channelId = data["channelId"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class ChannelUpdate {

  static const PacketResponse packetName = PacketResponse.ChannelUpdate;

  late int requestId;
  String? error;
  models.Channel? channel;
  
  ChannelUpdate();
  
  factory ChannelUpdate.fromReference(flex_buffers.Reference data) {
    return ChannelUpdate()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..channel = data["channel"].isNull ? null : models.Channel.fromReference(data["channel"]);
  }
}
enum PacketResponse {
  Login,
  Ping,
  LoginWelcome,
  UpdatePresence,
  ChannelMessageCreate,
  UserChangePassword,
  UserChangeDisplayName,
  UserChangeStatus,
  UserChangeAvatar,
  UserChangePresence,
  ChannelMessageFetch,
  ChannelCreate,
  ChannelDelete,
  ChannelUpdate
}
  