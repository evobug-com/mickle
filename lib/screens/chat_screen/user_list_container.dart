import 'package:flutter/material.dart';
import 'package:talk/components/channel_list/core/models/channel_list_selected_room.dart';
import 'package:talk/core/models/utils.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

import '../../core/database.dart';
import '../../core/models/models.dart';
import '../../ui/user_avatar.dart';
import 'sidebar_box.dart';

class UserListContainer extends StatelessWidget {
  final ConnectionProvider connection;
  const UserListContainer({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    return SidebarBox(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8.0),
          Expanded(
            child: StreamBuilder(
                stream: connection.database.users.stream,
                initialData:
                connection.database.users.items,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final Channel? selectedChannel =
                      ChannelListSelectedChannel.of(context).getChannel(connection.server);

                  List<User> users = selectedChannel == null ? connection.database.users.items : selectedChannel.getUsers(database: connection.database);

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListenableBuilder(
                          listenable: users[index],
                          builder: (context, widget) {
                            return ListTile(
                              // Avatar leading
                              leading: UserAvatar(
                                presence: UserPresence
                                    .fromString(
                                    users[index]
                                        .presence),
                                imageUrl:
                                users[index].avatar,
                              ),
                              // User with status
                              title: Text(users[index]
                                  .displayName ??
                                  "<No name>"),
                              subtitle:
                              users[index].status !=
                                  null
                                  ? Text(users[index]
                                  .status!)
                                  : null,
                              // trailing message icon
                              trailing: const IconButton(
                                icon: Icon(Icons.message),
                                onPressed: null,
                              ),
                              onTap: () {
                                // Cycle all enum status
                                // final UserPresence newStatus = UserPresence.values[(users[index].presence.index + 1) % UserPresence.values.length];
                                // users[index].presence = newStatus;
                                // Database().store.box<User>().put(users[index]);
                              },
                            );
                          });
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}