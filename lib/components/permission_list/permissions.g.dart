import 'core/models/permission_model.dart';

// This file is generated by prebuild.dart
// Do not modify this file manually!!!

final Map<String, Permission> permissions = {
  'server_create': const Permission("Server", "server_create", "Server Create", "Allows the user to create servers"),
  'server_update': const Permission("Server", "server_update", "Server Update", "Allows the user to edit the server"),
  'server_delete': const Permission("Server", "server_delete", "Server Delete", "Allows the user to delete the server"),
  'server_add_users': const Permission("Server", "server_add_users", "Server Add Users", "Allows the user to add users to the server"),
  'server_remove_users': const Permission("Server", "server_remove_users", "Server Remove Users", "Allows the user to remove users from the server"),
  'role_create': const Permission("Role", "role_create", "Role Create", "Allows the user to create new roles"),
  'role_delete': const Permission("Role", "role_delete", "Role Delete", "Allows the user to delete roles"),
  'role_update': const Permission("Role", "role_update", "Role Update", "Allows the user to update roles"),
  'user_update': const Permission("User", "user_update", "User Update", "Allows the user to edit other users"),
  'channel_update': const Permission("Channel", "channel_update", "Channel Update", "Allows the user to edit channels"),
  'channel_create': const Permission("Channel", "channel_create", "Channel Create", "Allows the user to create channels"),
  'channel_delete': const Permission("Channel", "channel_delete", "Channel Delete", "Allows the user to delete channels"),
  'channel_add_users': const Permission("Channel", "channel_add_users", "Channel Add Users", "Allows the user to add users to channels"),
  'channel_remove_users': const Permission("Channel", "channel_remove_users", "Channel Remove Users", "Allows the user to remove users from channels"),
  'channel_join_voice': const Permission("Channel", "channel_join_voice", "Channel Join Voice", "Allows the user to join voice in channels"),
  'channel_send_messages': const Permission("Chat", "channel_send_messages", "Channel Send Messages", "Allows the user to send messages"),
  'channel_read_messages': const Permission("Chat", "channel_read_messages", "Channel Read Messages", "Allows the user to read messages"),
  'channel_upload_media': const Permission("Chat", "channel_upload_media", "Channel Upload Media", "Allows the user to upload images and videos to chat messages"),
  'channel_delete_messages': const Permission("Chat", "channel_delete_messages", "Channel Delete Messages", "Allows the user to delete chat messages by other members"),
  'channel_pin_messages': const Permission("Chat", "channel_pin_messages", "Channel Pin Messages", "Allows the user to pin chat messages"),
    
};

  