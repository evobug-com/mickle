import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/managers/client_manager.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/layout/my_scaffold.dart';

class ServerListNavigator extends StatefulWidget {
  final bool showAddServerButton;
  const ServerListNavigator({Key? key, required this.showAddServerButton}) : super(key: key);

  @override
  _ServerListNavigatorState createState() => _ServerListNavigatorState();
}

class _ServerListNavigatorState extends State<ServerListNavigator> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientManager>(
      builder: (context, clientManager, child) {
        final selectedClient = SelectedServerProvider.of(context).client;
        final allClients = clientManager.clients;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 72 + (_animation.value * 72),
              child: Row(
                children: [
                  // Left column (expanded view) - All Clients
                  SizeTransition(
                    sizeFactor: _animation,
                    axis: Axis.horizontal,
                    child: Container(
                      width: 72,
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      child: Column(
                        children: [
                          if (widget.showAddServerButton) _buildAddServerButton(context),
                          Expanded(child: _buildClientList(allClients.toList(), selectedClient)),
                          _buildQuickListButton(context, allClients.toList()),
                        ],
                      ),
                    ),
                  ),
                  // Right column (always visible) - Selected Client and its Subservers
                  Container(
                    width: 72,
                    child: Column(
                      children: [
                        Expanded(child: _buildSelectedClientView(selectedClient)),
                        _buildFoldingButton()
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddServerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () {
          context.goNamed('login');
        },
        tooltip: 'Add Server',
      ),
    );
  }

  Widget _buildClientList(List<Client> clients, Client? selectedClient) {
    return ListView(
      children: clients.map((client) => _buildClientIcon(context, client, isSelected: client == selectedClient)).toList(),
    );
  }

  Widget _buildSelectedClientView(Client? selectedClient) {
    if (selectedClient == null) {
      return Center(child: Text('No server selected', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
    }
    return Column(
      children: [
        _buildClientIcon(context, selectedClient, isSelected: true),
        const SizedBox(height: 8),
        Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), height: 1),
        const SizedBox(height: 8),
        Expanded(child: _buildSubServerList(context, selectedClient)),
      ],
    );
  }

  Widget _buildClientIcon(BuildContext context, Client client, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Tooltip(
        message: client.server?.name ?? 'Unknown Server',
        child: InkWell(
          onTap: () {
            SelectedServerProvider.of(context, listen: false).selectServer(client);
            context.goNamed("chat");
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getServerAlias(client.server?.name ?? ''),
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubServerList(BuildContext context, Client selectedClient) {
    if (selectedClient.serverId == null) {
      return Center(child: Text('No sub servers available', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
    }

    final database = Database(selectedClient.serverId!);
    return StreamBuilder(
      stream: database.servers.stream,
      initialData: database.servers.items,
      builder: (context, snapshot) {
        final subservers = database.servers.items.where((server) => server.parent == selectedClient.serverId && !server.main).toList();
        if (!snapshot.hasData || subservers.isEmpty) {
          return Center(child: Text('No sub servers', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
        }
        return ListView.builder(
          itemCount: subservers.length,
          itemBuilder: (context, index) {
            final subserver = subservers[index];
            return _buildSubServerIcon(context, subserver, selectedClient);
          },
        );
      },
    );
  }

  Widget _buildSubServerIcon(BuildContext context, Server subserver, Client parentClient) {
    final isSelected = SelectedServerProvider.of(context).client?.serverId == subserver.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Tooltip(
        message: subserver.name,
        child: InkWell(
          onTap: () {
            // Implement subserver selection logic
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getServerAlias(subserver.name),
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoldingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IconButton(
        icon: Icon(_isExpanded ? Icons.chevron_left : Icons.chevron_right),
        onPressed: _toggleExpanded,
      ),
    );
  }

  Widget _buildQuickListButton(BuildContext context, List<Client> allClients) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IconButton(
        icon: Icon(Icons.list, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => _showQuickListDialog(context, allClients),
        tooltip: 'Quick Server List',
      ),
    );
  }

  void _showQuickListDialog(BuildContext context, List<Client> allClients) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quick Server List'),
          content: Container(
            width: 300,
            height: 400,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search servers...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allClients.length,
                    itemBuilder: (context, index) {
                      final client = allClients[index];
                      return ListTile(
                        title: Text(client.server?.name ?? 'Unknown Server'),
                        leading: CircleAvatar(
                          child: Text(_getServerAlias(client.server?.name ?? '')),
                        ),
                        onTap: () {
                          SelectedServerProvider.of(context, listen: false).selectServer(client);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getServerAlias(String serverName) {
    final words = serverName.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, min(2, words[0].length)).toUpperCase();
    } else {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }
}