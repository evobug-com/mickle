import 'package:flutter/material.dart';
import 'package:talk/components/context_menu/context_menu.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'disposable.dart';
import 'notifiers/selected_channel_controller.dart';

class GenericRoomList extends StatefulWidget {
  final int itemCount;
  final String Function(int index) titleBuilder;
  final SelectedChannelController controller;
  final void Function(int index) onRoomSelected;
  final String Function(int index) getRoomUid;

  const GenericRoomList({
    super.key,
    required this.itemCount,
    required this.titleBuilder,
    required this.controller,
    required this.onRoomSelected,
    required this.getRoomUid,
  });

  @override
  GenericChannelListState createState() => GenericChannelListState();
}

class GenericChannelListState extends State<GenericRoomList> {
  final Map<String, Function> _setStates = {};

  @override
  void initState() {

    widget.controller.addListener(() {
      if (widget.controller.previousChannel != null && _setStates.containsKey(widget.controller.previousChannel!.id)) {
        _setStates[widget.controller.previousChannel!.id]!(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (BuildContext context, int index) {
        final roomId = widget.getRoomUid(index);

        return Disposable(
          onDispose: () {
            _setStates.remove(roomId);
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              _setStates[roomId] = setState;
              final permissions = CurrentSession().getPermissionsForChannel(roomId);

              return ContextMenuRegion(
                onItemSelected: (value) {

                },
                contextMenu: ContextMenu(
                  entries: <ContextMenuEntry> [
                    const MenuHeader(text: "Možnosti kanálu"),
                    // Menu items for: Copy, Mark as read, Mute, Notifications, Rename, Editor, Archive, Leave
                    const MenuItem(
                      label: "Kopírovat",
                      value: 'copy',
                      icon: Icons.copy,
                      isDisabled: true
                    ),
                    const MenuItem(
                      label: "Označit jako přečtené",
                      value: 'mark_as_read',
                      icon: Icons.mark_chat_read,
                        isDisabled: true
                    ),
                    const MenuItem(
                      label: "Ztlumit",
                      value: 'mute',
                      icon: Icons.volume_off,
                      isDisabled: true
                    ),
                    const MenuItem(
                      label: "Notifikace",
                      value: 'notifications',
                      icon: Icons.notifications,
                      isDisabled: true
                    ),
                    MenuItem(
                      label: "Přejmenovat",
                      value: 'rename',
                      icon: Icons.edit,
                      isDisabled: !permissions.canManageRoom
                    ),
                    MenuItem(
                      label: "Upravit",
                      value: 'edit',
                      icon: Icons.edit,
                      isDisabled: !permissions.canManageRoom
                    ),
                    MenuItem(
                      label: "Archivovat",
                      value: 'archive',
                      icon: Icons.archive,
                      isDisabled: !permissions.canManageRoom
                    ),
                    const MenuItem(
                      label: "Opustit",
                      value: 'leave',
                      icon: Icons.exit_to_app,
                      isDisabled: true
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(widget.titleBuilder(index)),
                  leading: const Icon(Icons.tag),
                  selected: roomId == widget.controller.currentChannel?.id,
                  // Show badge in trailing
                  // trailing: roomId == widget.controller.selectedRoomId
                  //     ? const CircleAvatar(
                  //         backgroundColor: Colors.red,
                  //         radius: 4,
                  //       )
                  //     : null,
                  onTap: () {
                    setState(() {
                      widget.onRoomSelected(index);
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}