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
                initialData: connection.database.users.items,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final Channel? selectedChannel =
                      ChannelListSelectedChannel.of(context)
                          .getChannel(connection.server);

                  List<User> users = selectedChannel == null
                      ? connection.database.users.items
                      : selectedChannel.getUsers(database: connection.database);

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListenableBuilder(
                          listenable: users[index],
                          builder: (context, widget) {
                            return _buildUserItem(users, index, context);
                          });
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  bool _shouldShowRoleSeparator(User user, User? previousUser) {
    if (previousUser == null) {
      return true;
    }

    final roles = user.getRoles(database: connection.database);
    final previousRoles = previousUser.getRoles(database: connection.database);

    // Find role with highest priority
    roles.sort((a, b) => a.rank.compareTo(b.rank));
    previousRoles.sort((a, b) => a.rank.compareTo(b.rank));

    final highestRole = roles.last;
    final previousHighestRole = previousRoles.last;

    return highestRole.rank != previousHighestRole.rank;
  }

  Widget _buildUserItem(List<User> users, int index, BuildContext context) {
    final user = users[index];
    final previousUser = index > 0 ? users[index - 1] : null;
    final theme = Theme.of(context);
    print('Building user item for ${user.displayName}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(_shouldShowRoleSeparator(user, previousUser))
          Padding(
            padding: EdgeInsets.fromLTRB(12, previousUser != null ? 12 : 0, 12, 12),
            child: Text(
              user.getRoles(database: connection.database).last.name,
              style: theme.textTheme.titleSmall,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            // Avatar leading
            leading: UserAvatar(
              presence: UserPresence.fromString(users[index].presence),
              imageUrl: user.avatar,
            ),
            // User with status
            title: Text(user.displayName ?? "<No name>"),
            subtitle: user.status != null
                ? Text(user.status!, overflow: TextOverflow.ellipsis)
                : null,
            // trailing message icon
            // trailing:  IconButton(
            //   icon: Icon(Icons.chat_bubble_outline),
            //   onPressed: null,
            // ),
            onTap: () {
              // Cycle all enum status
              // final UserPresence newStatus = UserPresence.values[(users[index].presence.index + 1) % UserPresence.values.length];
              // users[index].presence = newStatus;
              // Database().store.box<User>().put(users[index]);
            },
          ),
        ),
      ],
    );
  }
}
