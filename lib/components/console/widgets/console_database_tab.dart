import 'package:flutter/material.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';

import '../../../core/database.dart';

class ConsoleDatabaseTab extends StatefulWidget {
  const ConsoleDatabaseTab({super.key});

  @override
  ConsoleDatabaseTabState createState() => ConsoleDatabaseTabState();
}

class ConsoleDatabaseTabState extends State<ConsoleDatabaseTab> {
  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    final database = clientProvider.database!;
    // Display all data in the database
    // There will be many data, so it is necessary to use ListView to scroll
    // Heading for each table, then list of data using ExpansionTile

    final relations = {
      "serverUsers": database.serverUsers,
      "serverChannels": database.serverChannels,
      "channelUsers": database.channelUsers,
      "channelMessages": database.channelMessages,
      "roleUsers": database.roleUsers,
      "rolePermissions": database.rolePermissions,
    };

    final tables = {
      "servers": database.servers,
      "users": database.users,
      "channels": database.channels,
      "messages": database.messages,
      "roles": database.roles,
      "permissions": database.permissions,
    };

    return ListView(
      children: [
        ...tables.entries.map((entry) {
          return ExpansionTile(
            title: Text("${entry.key} (${entry.value.items.length})"),
            children: [
              ...entry.value.items.map((item) {
                return ListenableBuilder(
                  listenable: item,
                  builder: (context, _) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  }
                );
              }),
            ],
          );
        }),
        ...relations.entries.map((entry) {
          return ExpansionTile(
            title: Text("${entry.key} (${entry.value.items.length})"),
            children: [
              ...entry.value.items.map((item) {
                return ListenableBuilder(
                  listenable: item,
                  builder: (context, _) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  }
                );
              }),
            ],
          );
        }),
      ]
    );
  }
}