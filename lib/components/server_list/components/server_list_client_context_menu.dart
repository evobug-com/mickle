import 'package:flutter/material.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/areas/connection/connection_manager.dart';
import 'package:talk/areas/connection/connection_status.dart';
import '../../context_menu/context_menu.dart' as context_menu;

class ServerListClientContextMenu extends StatelessWidget {
  final Widget child;
  final Connection connection;
  const ServerListClientContextMenu({super.key, required this.child, required this.connection});

  @override
  Widget build(BuildContext context) {
    return context_menu.ContextMenuRegion(
      contextMenu: context_menu.ContextMenu(
          entries: <context_menu.ContextMenuEntry> [
            context_menu.MenuItem(
                label: 'Disconnect',
                value: 'disconnect',
                icon: Icons.power_settings_new,
                isDisabled: connection.status.value == ConnectionStatus.disconnected || connection.status.value == ConnectionStatus.error
            ),
            // Drop server
            const context_menu.MenuItem(
                label: 'Remove Server',
                value: 'remove',
                icon: Icons.delete,
                isDisabled: false
            ),
          ]
      ),
      onItemSelected: (value) async {
        if(value == 'remove') {
          ConnectionManager().remove(connection);
        } else if(value == 'disconnect') {
          connection.isReconnectEnabled = false;
          connection.disconnect();
        }
      },
      child: child,
    );
  }

}