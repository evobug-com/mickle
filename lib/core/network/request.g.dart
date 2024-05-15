part of 'request.dart';

class Login extends Request {

  int requestId;
  String? username;
  String? password;
  String? token;
  
  Login({required this.requestId,  this.username,  this.password,  this.token});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("Login", () {
      builder.addIntWKey("requestId", requestId);
      if(username != null) { builder.addStringWKey("username", username!); } else { builder.addNullWKey("username"); }
      if(password != null) { builder.addStringWKey("password", password!); } else { builder.addNullWKey("password"); }
      if(token != null) { builder.addStringWKey("token", token!); } else { builder.addNullWKey("token"); }
    });
    
    return builder.finish(); 
  } 

}
class Pong extends Request {

  
  
  Pong();
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("Pong", () {
      
    });
    
    return builder.finish(); 
  } 

}
class ChannelMessageCreate extends Request {

  int requestId;
  String channelId;
  String message;
  List<String>? mentions;
  
  ChannelMessageCreate({required this.requestId, required this.channelId, required this.message,  this.mentions});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChannelMessageCreate", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("channelId", channelId);
      builder.addStringWKey("message", message);
      builder.addArrayWKey("mentions", () { mentions?.forEach((item) { builder.addString(item); }); });
    });
    
    return builder.finish(); 
  } 

}
class ChannelMessageFetch extends Request {

  int requestId;
  String channelId;
  String? lastMessageId;
  
  ChannelMessageFetch({required this.requestId, required this.channelId,  this.lastMessageId});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChannelMessageFetch", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("channelId", channelId);
      if(lastMessageId != null) { builder.addStringWKey("lastMessageId", lastMessageId!); } else { builder.addNullWKey("lastMessageId"); }
    });
    
    return builder.finish(); 
  } 

}
class UserChangePassword extends Request {

  int requestId;
  String oldPassword;
  String newPassword;
  
  UserChangePassword({required this.requestId, required this.oldPassword, required this.newPassword});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("UserChangePassword", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("oldPassword", oldPassword);
      builder.addStringWKey("newPassword", newPassword);
    });
    
    return builder.finish(); 
  } 

}
class UserChangeDisplayName extends Request {

  int requestId;
  String displayName;
  
  UserChangeDisplayName({required this.requestId, required this.displayName});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("UserChangeDisplayName", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("displayName", displayName);
    });
    
    return builder.finish(); 
  } 

}
class UserChangeStatus extends Request {

  int requestId;
  String status;
  
  UserChangeStatus({required this.requestId, required this.status});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("UserChangeStatus", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("status", status);
    });
    
    return builder.finish(); 
  } 

}
class UserChangeAvatar extends Request {

  int requestId;
  String avatar;
  
  UserChangeAvatar({required this.requestId, required this.avatar});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("UserChangeAvatar", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("avatar", avatar);
    });
    
    return builder.finish(); 
  } 

}
class UserChangePresence extends Request {

  int requestId;
  String presence;
  
  UserChangePresence({required this.requestId, required this.presence});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("UserChangePresence", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("presence", presence);
    });
    
    return builder.finish(); 
  } 

}
class ChannelCreate extends Request {

  int requestId;
  String serverId;
  String name;
  String? description;
  
  ChannelCreate({required this.requestId, required this.serverId, required this.name,  this.description});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChannelCreate", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("serverId", serverId);
      builder.addStringWKey("name", name);
      if(description != null) { builder.addStringWKey("description", description!); } else { builder.addNullWKey("description"); }
    });
    
    return builder.finish(); 
  } 

}
class ChannelDelete extends Request {

  int requestId;
  String channelId;
  
  ChannelDelete({required this.requestId, required this.channelId});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChannelDelete", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("channelId", channelId);
    });
    
    return builder.finish(); 
  } 

}
class ChannelUpdate extends Request {

  int requestId;
  String channelId;
  String? name;
  String? description;
  
  ChannelUpdate({required this.requestId, required this.channelId,  this.name,  this.description});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChannelUpdate", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("channelId", channelId);
      if(name != null) { builder.addStringWKey("name", name!); } else { builder.addNullWKey("name"); }
      if(description != null) { builder.addStringWKey("description", description!); } else { builder.addNullWKey("description"); }
    });
    
    return builder.finish(); 
  } 

}
class ChannelAddUser extends Request {

  int requestId;
  String channelId;
  String userId;
  
  ChannelAddUser({required this.requestId, required this.channelId, required this.userId});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChannelAddUser", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("channelId", channelId);
      builder.addStringWKey("userId", userId);
    });
    
    return builder.finish(); 
  } 

}
