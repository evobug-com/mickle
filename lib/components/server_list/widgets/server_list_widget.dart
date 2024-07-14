import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/managers/client_manager.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';
import 'package:talk/core/notifiers/theme_controller.dart';

import '../../../core/connection/client.dart';
import '../components/server_list_client_context_menu.dart';
import '../components/server_list_clients_listener.dart';

class ServerListWidget extends StatefulWidget {
  const ServerListWidget({super.key});

  @override
  State<ServerListWidget> createState() => _ServerListWidgetState();
}

class _ServerListWidgetState extends State<ServerListWidget> {
  int _selectedServerIndex = -1;

  void setCurrentClient(Client client) {
    CurrentClientProvider.of(context, listen: false).selectClient(client);
    context.go("/chat");
  }

  Color _getColorForConnectionState(ClientConnectionState state) {
    switch(state) {
      case ClientConnectionState.connected:
        return Colors.green;
      case ClientConnectionState.connecting:
        return Colors.orange;
      case ClientConnectionState.disconnected:
        return Colors.red;
      case ClientConnectionState.none:
        return Colors.transparent;
    }
  }

  List<NavigationRailDestination> _getDestinations() {
    final clients = ClientManager.of(context, listen: false).clients;
    final list = clients.map((client) {
      return NavigationRailDestination(
        icon: ServerListClientContextMenu(client: client, child: Icon(Icons.computer, color: _getColorForConnectionState(client.connection.state),)),
        selectedIcon: ServerListClientContextMenu(client: client, child: Icon(Icons.computer, color: _getColorForConnectionState(client.connection.state))),
        label: ServerListClientContextMenu(client: client, child: Text(client.address.toString(), style: TextStyle(color: _getColorForConnectionState(client.connection.state)),)),
      );
    }).toList();

    if (list.length < 2) {
      for (int i = list.length; i < 2; i++) {
        list.add(const NavigationRailDestination(
          icon: Icon(
            Icons.not_interested,
            color: Colors.transparent,
          ),
          disabled: true,
          label: Text(''),
        ));
      }
    }
    return list;
  }

  void onDestinationSelected(int index) {
    setState(() {
      _selectedServerIndex = index;
    });
    setCurrentClient(ClientManager.of(context, listen: false).clients.elementAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ThemeController.scheme(context);

    return ListenableBuilder(
      listenable: ClientManager.of(context, listen: false),
      builder: (context, _) {
        return ServerListClientsListener(
          builder: (context) {
            return NavigationRail(
              indicatorShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              indicatorColor: colorScheme.surfaceContainerHigh,
              selectedIndex: _selectedServerIndex <= 0 ? null : _selectedServerIndex,
              backgroundColor: colorScheme.surfaceContainerLow,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: onDestinationSelected,
              leading: Tooltip(
                message: "Add server",
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {
                    context.go("/login");
                  },
                ),
              ),
              destinations: _getDestinations(),
            );
          }
        );
      }
    );
  }
}
