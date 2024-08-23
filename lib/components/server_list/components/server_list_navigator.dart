import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/components/server_list/components/server_list_client_context_menu.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/storage/preferences.dart';

import '../../../core/managers/client_manager.dart';
import '../../../core/providers/global/selected_server_provider.dart';

class ServerListNavigator extends StatefulWidget {
  final bool showAddServerButton;
  const ServerListNavigator({super.key, required this.showAddServerButton});

  @override
  State<ServerListNavigator> createState() => _ServerListNavigatorState();
}

class _ServerListNavigatorState extends State<ServerListNavigator> {
  int _selectedServerIndex = -1;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = Preferences.getIsServerListExpanded();
  }

  void setCurrentClient(Client client) {
    SelectedServerProvider.of(context, listen: false).selectServer(client);
    context.goNamed("chat");
  }

  Color _getColorForConnectionState(ClientConnectionState state) {
    switch (state) {
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

  List<Widget> _getDestinations() {
    final clients = ClientManager.of(context, listen: false).clients;
    return clients.mapIndexed((index, client) {
      return ListenableBuilder(
        listenable: client.connection,
        builder: (context, _) {
          return ServerListClientContextMenu(
            client: client,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: TooltipVisibility(
                visible: !_isExpanded,
                child: Tooltip(
                  message: client.address.toString(),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: EdgeInsets.zero,
                    selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
                    title: Icon(
                      Icons.computer,
                      color: _getColorForConnectionState(client.connection.state),
                    ),
                    subtitle: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: _isExpanded ? Center(
                        child: Text(
                          client.address.toString(),
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: _getColorForConnectionState(client.connection.state)),
                        ),
                      ) : null,
                    ),
                    selected: index == _selectedServerIndex,
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
              ),
            ),
          );
        }
      );
    }).toList();
  }

  void onDestinationSelected(int index) {
    setState(() {
      _selectedServerIndex = index;
    });
    setCurrentClient(
        ClientManager.of(context, listen: false).clients.elementAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: _isExpanded ? 100 : 40,
      duration: const Duration(milliseconds: 150),
      child: ListenableBuilder(
        listenable: ClientManager.of(context, listen: false),
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon button for adding a new server
              if (widget.showAddServerButton)
                Tooltip(
                    message: "Add server",
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () {
                        context.goNamed("login");
                      },
                    ),
                  ),
              ..._getDestinations(),
              const Expanded(child: SizedBox()),
              // Toggle visibility of server list
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: AnimatedSwitcher(duration:
                    const Duration(milliseconds: 150), child: Icon(_isExpanded ? Icons.arrow_left : Icons.arrow_right)),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                        Preferences.setIsServerListExpanded(_isExpanded);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        }
      )
    );
  }
}