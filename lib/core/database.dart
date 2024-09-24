import 'package:mickle/core/list_stream.dart';

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
  final ListStream<Server> servers = ListStream<Server>();
  final ListStream<User> users = ListStream<User>();
  final ListStream<Channel> channels = ListStream<Channel>();
  final ListStream<Message> messages = ListStream<Message>();
  final ListStream<Role> roles = ListStream<Role>();
  final ListStream<Permission> permissions = ListStream<Permission>();
  final RelationListStream<Relation> serverUsers = RelationListStream();
  final RelationListStream<Relation> serverChannels = RelationListStream();
  final RelationListStream<Relation> channelUsers = RelationListStream();
  final RelationListStream<Relation> channelMessages = RelationListStream();
  final RelationListStream<Relation> roleUsers = RelationListStream();
  final RelationListStream<Relation> rolePermissions = RelationListStream();
  final RelationListStream<UnreadMessageRelation> unreadMessages = RelationListStream();
}