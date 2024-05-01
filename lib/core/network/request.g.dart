part of 'request.dart';

class Login extends Request {

  String username;
  String password;
  
  Login({required this.username, required this.password});
  
    serialize() {
    final builder = flex_buffers.Builder();
   
    builder.addMapWKey("Login", () {
      builder.addIntWKey("requestId", requestId);
      builder.addStringWKey("username", username);
      builder.addStringWKey("password", password);
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
