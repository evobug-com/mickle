import 'package:talk/core/list_stream.dart';

import 'models/models.dart';

enum UserPresence {
  online,
  away,
  busy,
  offline;

  static fromString(String? status) {
    switch (status) {
      case 'online':
        return UserPresence.online;
      case 'away':
        return UserPresence.away;
      case 'busy':
        return UserPresence.busy;
      case 'offline':
        return UserPresence.offline;
    }
    return UserPresence.offline;
  }
}

extension UserPresenceExtension on UserPresence {
  UserPresence fromString(String status) {
    switch (status) {
      case 'online':
        return UserPresence.online;
      case 'away':
        return UserPresence.away;
      case 'busy':
        return UserPresence.busy;
      case 'offline':
        return UserPresence.offline;
    }
    return UserPresence.offline;
  }
}

class Database {
  // Map of server id to Databases
  static final Map<String, Database> _servers = {};

  factory Database(String serverId) {
    if (!_servers.containsKey(serverId)) {
      _servers[serverId] = Database._internal();
    }

    return _servers[serverId]!;
  }

  Database._internal() {}

  final ListStream<Server> servers = ListStream<Server>();
  final ListStream<User> users = ListStream<User>();
  final ListStream<Channel> channels = ListStream<Channel>();
  final ListStream<Message> messages = ListStream<Message>();
  final ListStream<Role> roles = ListStream<Role>();
  final ListStream<Permission> permissions = ListStream<Permission>();
  final RelationListStream serverUsers = RelationListStream();
  final RelationListStream serverChannels = RelationListStream();
  final RelationListStream channelUsers = RelationListStream();
  final RelationListStream channelMessages = RelationListStream();
  final RelationListStream roleUsers = RelationListStream();
}