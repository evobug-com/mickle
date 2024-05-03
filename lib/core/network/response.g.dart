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
  late List<models.Message> messages;
  late List<models.Relation> channelMessages;
  
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
      ..users = data["users"].vectorIterable.map((item) => models.User.fromReference(item)).toList()
      ..messages = data["messages"].vectorIterable.map((item) => models.Message.fromReference(item)).toList()
      ..channelMessages = data["channelMessages"].vectorIterable.map((item) => models.Relation.fromReference(item)).toList();
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
