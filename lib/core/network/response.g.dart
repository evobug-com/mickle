part of 'response.dart';

class Login {

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

  
  
  Ping();
  
  factory Ping.fromReference(flex_buffers.Reference data) {
    return Ping()
      ;
  }
}
class LoginWelcome {

  late List<models.Server> servers;
  late List<models.Relation> serverUsers;
  late List<models.Permission> permissions;
  late List<models.Role> roles;
  late List<models.Relation> roleUsers;
  late List<models.Channel> channels;
  late List<models.Relation> channelUsers;
  late List<models.User> users;
  
  LoginWelcome();
  
  factory LoginWelcome.fromReference(flex_buffers.Reference data) {
    return LoginWelcome()
      ..servers = data["servers"].vectorIterable.map((item) => models.Server.fromReference(item)).toList()
      ..serverUsers = data["serverUsers"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..permissions = data["permissions"].vectorIterable.map((item) => models.Permission.fromReference(item)).toList()
      ..roles = data["roles"].vectorIterable.map((item) => models.Role.fromReference(item)).toList()
      ..roleUsers = data["roleUsers"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..channels = data["channels"].vectorIterable.map((item) => models.Channel.fromReference(item)).toList()
      ..channelUsers = data["channelUsers"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList()
      ..users = data["users"].vectorIterable.map((item) => models.User.fromReference(item)).toList();
  }
}
class UpdatePresence {

  late String userId;
  late String presence;
  
  UpdatePresence();
  
  factory UpdatePresence.fromReference(flex_buffers.Reference data) {
    return UpdatePresence()
      ..userId = data["userId"].stringValue!
      ..presence = data["presence"].stringValue!;
  }
}
class Message {

  late int requestId;
  String? error;
  models.Message? message;
  models.Relation? relation;
  
  Message();
  
  factory Message.fromReference(flex_buffers.Reference data) {
    return Message()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..message = data["message"].isNull ? null : models.Message.fromReference(data["message"])
      ..relation = data["relation"].isNull ? null : models.Relation.fromReference(data["relation"]);
  }
}
class ChangePassword {

  late int requestId;
  String? error;
  
  ChangePassword();
  
  factory ChangePassword.fromReference(flex_buffers.Reference data) {
    return ChangePassword()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue;
  }
}
class ChangeDisplayName {

  late int requestId;
  late String userId;
  late String displayName;
  String? error;
  
  ChangeDisplayName();
  
  factory ChangeDisplayName.fromReference(flex_buffers.Reference data) {
    return ChangeDisplayName()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..displayName = data["displayName"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class ChangeStatus {

  late int requestId;
  late String userId;
  late String status;
  String? error;
  
  ChangeStatus();
  
  factory ChangeStatus.fromReference(flex_buffers.Reference data) {
    return ChangeStatus()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..status = data["status"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class ChangeAvatar {

  late int requestId;
  late String userId;
  late String avatar;
  String? error;
  
  ChangeAvatar();
  
  factory ChangeAvatar.fromReference(flex_buffers.Reference data) {
    return ChangeAvatar()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..avatar = data["avatar"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class ChangePresence {

  late int requestId;
  late String userId;
  late String presence;
  String? error;
  
  ChangePresence();
  
  factory ChangePresence.fromReference(flex_buffers.Reference data) {
    return ChangePresence()
      ..requestId = data["requestId"].intValue!
      ..userId = data["userId"].stringValue!
      ..presence = data["presence"].stringValue!
      ..error = data["error"].stringValue;
  }
}
class FetchMessages {

  late int requestId;
  String? error;
  late List<models.Message> messages;
  late List<models.Relation> relations;
  
  FetchMessages();
  
  factory FetchMessages.fromReference(flex_buffers.Reference data) {
    return FetchMessages()
      ..requestId = data["requestId"].intValue!
      ..error = data["error"].stringValue
      ..messages = data["messages"].vectorIterable.map((item) => models.Message.fromReference(item)).toList()
      ..relations = data["relations"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList();
  }
}
