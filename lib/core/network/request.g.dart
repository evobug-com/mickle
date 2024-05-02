part of 'request.dart';

class Login extends Request {

  String? username;
  String? password;
  String? token;
  
  Login({ this.username,  this.password,  this.token});
  
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
class Message extends Request {

  String channelId;
  String message;
  
  Message({required this.channelId, required this.message});
  
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
