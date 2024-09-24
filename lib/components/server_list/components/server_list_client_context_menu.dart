import 'package:flutter/material.dart';
import 'package:mickle/areas/connection/connection.dart';
import 'package:mickle/areas/connection/connection_manager.dart';
import 'package:mickle/areas/connection/connection_status.dart';
import '../../../core/providers/global/selected_server_provider.dart';
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
            // Reconnect
            context_menu.MenuItem(
                label: 'Reconnect',
                value: 'reconnect',
                icon: Icons.refresh,
                isDisabled: connection.status.value != ConnectionStatus.error && connection.status.value != ConnectionStatus.disconnected
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

        if(value == 'remove' || value == 'disconnect') {
          // If the connection is the selected server, clear the selected server
          if(connection == SelectedServerProvider.of(context, listen: false).connection) {
            SelectedServerProvider.of(context, listen: false).selectServer(null);
          }
        }

        if(value == 'reconnect') {
          connection.isReconnectEnabled = true;
          ConnectionManager().onConnectionDone(connection);
        }
      },
      child: child,
    );
  }

}