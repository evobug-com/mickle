part of 'models.dart';

class Relation extends ChangeNotifier {
  String id;
  String input;
  String output;
  
  Relation({required this.id, required this.input, required this.output});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Relation.fromReference(flex_buffers.Reference data) {
    return Relation(
      id: data["id"].stringValue!,
      input: data["input"].stringValue!,
      output: data["output"].stringValue!
    );
  }
}
class Token extends ChangeNotifier {
  String id;
  String user;
  String token;
  dynamic createdAt;
  dynamic expiresAt;
  
  Token({required this.id, required this.user, required this.token, required this.createdAt, required this.expiresAt});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Token.fromReference(flex_buffers.Reference data) {
    return Token(
      id: data["id"].stringValue!,
      user: data["user"].stringValue!,
      token: data["token"].stringValue!,
      createdAt: data["createdAt"].stringValue!,
      expiresAt: data["expiresAt"].stringValue!
    );
  }
}
class Server extends ChangeNotifier {
  String id;
  String name;
  bool main;
  
  Server({required this.id, required this.name, required this.main});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Server.fromReference(flex_buffers.Reference data) {
    return Server(
      id: data["id"].stringValue!,
      name: data["name"].stringValue!,
      main: data["main"].boolValue!
    );
  }
}
class Permission extends ChangeNotifier {
  String id;
  String name;
  String category;
  dynamic createdAt;
  
  Permission({required this.id, required this.name, required this.category, required this.createdAt});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Permission.fromReference(flex_buffers.Reference data) {
    return Permission(
      id: data["id"].stringValue!,
      name: data["name"].stringValue!,
      category: data["category"].stringValue!,
      createdAt: data["createdAt"].stringValue!
    );
  }
}
class Role extends ChangeNotifier {
  String id;
  String name;
  int rank;
  dynamic createdAt;
  
  Role({required this.id, required this.name, required this.rank, required this.createdAt});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Role.fromReference(flex_buffers.Reference data) {
    return Role(
      id: data["id"].stringValue!,
      name: data["name"].stringValue!,
      rank: data["rank"].intValue!,
      createdAt: data["createdAt"].stringValue!
    );
  }
}
class Message extends ChangeNotifier {
  String id;
  String user;
  String content;
  dynamic createdAt;
  List<String>? mentions;
  
  Message({required this.id, required this.user, required this.content, required this.createdAt,  this.mentions});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Message.fromReference(flex_buffers.Reference data) {
    return Message(
      id: data["id"].stringValue!,
      user: data["user"].stringValue!,
      content: data["content"].stringValue!,
      createdAt: data["createdAt"].stringValue!,
      mentions: data["mentions"].isNull ? null : data["mentions"].vectorIterable.map((item) => item.stringValue!).toList()
    );
  }
}
class Channel extends ChangeNotifier {
  String id;
  String name;
  String? description;
  dynamic createdAt;
  bool archived;
  
  Channel({required this.id, required this.name,  this.description, required this.createdAt, required this.archived});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory Channel.fromReference(flex_buffers.Reference data) {
    return Channel(
      id: data["id"].stringValue!,
      name: data["name"].stringValue!,
      description: data["description"].stringValue,
      createdAt: data["createdAt"].stringValue!,
      archived: data["archived"].boolValue!
    );
  }
}
class User extends ChangeNotifier {
  String id;
  String? displayName;
  String? firstName;
  String? lastName;
  dynamic createdAt;
  dynamic? lastSeen;
  String? status;
  String? avatar;
  String? presence;
  
  User({required this.id,  this.displayName,  this.firstName,  this.lastName, required this.createdAt,  this.lastSeen,  this.status,  this.avatar,  this.presence});
    
  onUpdated() {
    notifyListeners();
  }
    
  factory User.fromReference(flex_buffers.Reference data) {
    return User(
      id: data["id"].stringValue!,
      displayName: data["displayName"].stringValue,
      firstName: data["firstName"].stringValue,
      lastName: data["lastName"].stringValue,
      createdAt: data["createdAt"].stringValue!,
      lastSeen: data["lastSeen"].stringValue,
      status: data["status"].stringValue,
      avatar: data["avatar"].stringValue,
      presence: data["presence"].stringValue
    );
  }
}
