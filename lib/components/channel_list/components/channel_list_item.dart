import 'package:flutter/material.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/models/utils.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

import '../../context_menu/components/menu_header.dart';
import '../../context_menu/components/menu_item.dart';
import '../../context_menu/core/models/context_menu.dart';
import '../../context_menu/core/models/context_menu_entry.dart';
import '../../context_menu/widgets/context_menu_region.dart';
import '../core/models/channel_list_selected_room.dart';

class ChannelListItem extends StatelessWidget {
  final User user;
  final Channel channel;
  final ConnectionProvider connection;
  final Function(Channel channel, String action) contextMenuHandler;

  const ChannelListItem(
      {super.key,
      required this.contextMenuHandler,
      required this.channel,
      required this.user,
      required this.connection});

  @override
  Widget build(BuildContext context) {
    final permissions = user.getPermissionsForChannel(channel.id,
        database: connection.database);
    final channelListSelectedRoom = ChannelListSelectedChannel.of(context);
    final scheme = Theme.of(context).colorScheme;
    final unreadMessages = user.getUnreadMessagesForChannel(channel,
        database: connection.database);
    bool isUnread = (unreadMessages?.unreadCount ?? 0) > 0;

    return ContextMenuRegion(
      onItemSelected: (value) {
        if (value != null) {
          contextMenuHandler(channel, value);
        }
      },
      contextMenu: ContextMenu(
        entries: <ContextMenuEntry>[
          const MenuHeader(text: "Možnosti kanálu"),
          // Menu items for: Copy, Mark as read, Mute, Notifications, Rename, Editor, Archive, Leave
          const MenuItem(
              label: "Kopírovat",
              value: 'copy',
              icon: Icons.copy,
              isDisabled: true),
          const MenuItem(
              label: "Označit jako přečtené",
              value: 'mark_as_read',
              icon: Icons.mark_chat_read,
              isDisabled: true),
          const MenuItem(
              label: "Ztlumit",
              value: 'mute',
              icon: Icons.volume_off,
              isDisabled: true),
          const MenuItem(
              label: "Notifikace",
              value: 'notifications',
              icon: Icons.notifications,
              isDisabled: true),
          MenuItem(
              label: "Upravit",
              value: 'edit',
              icon: Icons.edit,
              isDisabled: !permissions.canManageRoom),
          MenuItem(
              label: "Archivovat",
              value: 'archive',
              icon: Icons.archive,
              isDisabled: !permissions.canManageRoom),
          const MenuItem(
              label: "Opustit",
              value: 'leave',
              icon: Icons.exit_to_app,
              isDisabled: false),
        ],
      ),
      child: ListTile(
        title: Text(
          channel.name,
          style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              // color: isUnread ? scheme.onSurface : scheme.onSurfaceVariant
            ),
        ),
        leading: Icon(Icons.tag,
            // color: isUnread ? scheme.onSurface : scheme.onSurfaceVariant
        ),
        selected: channel.id ==
            channelListSelectedRoom.getChannel(connection.server)?.id,
        // selectedTileColor: scheme.surfaceContainerHigh,
        // Show badge in trailing
        // trailing: channel.id == channelListSelectedRoom.getChannel(connection.server)?.id
        //     ? const CircleAvatar(
        //         backgroundColor: Colors.red,
        //         radius: 4,
        //       )
        //     : null,
        onTap: () {
          ChannelListSelectedChannel.of(context, listen: false)
              .setChannel(connection.server, channel);
        },
      ),
    );
  }
}
