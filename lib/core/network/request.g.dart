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
class Message extends Request {

  int requestId;
  String channelId;
  String message;
  
  Message({required this.requestId, required this.channelId, required this.message});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("Message", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("channelId", channelId);
      builder.addStringWKey("message", message);
    });
    
    return builder.finish(); 
  } 

}
class ChangePassword extends Request {

  int requestId;
  String oldPassword;
  String newPassword;
  
  ChangePassword({required this.requestId, required this.oldPassword, required this.newPassword});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChangePassword", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("oldPassword", oldPassword);
      builder.addStringWKey("newPassword", newPassword);
    });
    
    return builder.finish(); 
  } 

}
class ChangeDisplayName extends Request {

  int requestId;
  String displayName;
  
  ChangeDisplayName({required this.requestId, required this.displayName});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChangeDisplayName", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("displayName", displayName);
    });
    
    return builder.finish(); 
  } 

}
class ChangeStatus extends Request {

  int requestId;
  String status;
  
  ChangeStatus({required this.requestId, required this.status});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChangeStatus", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("status", status);
    });
    
    return builder.finish(); 
  } 

}
class ChangeAvatar extends Request {

  int requestId;
  String avatar;
  
  ChangeAvatar({required this.requestId, required this.avatar});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChangeAvatar", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("avatar", avatar);
    });
    
    return builder.finish(); 
  } 

}
class ChangePresence extends Request {

  int requestId;
  String presence;
  
  ChangePresence({required this.requestId, required this.presence});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("ChangePresence", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("presence", presence);
    });
    
    return builder.finish(); 
  } 

}
