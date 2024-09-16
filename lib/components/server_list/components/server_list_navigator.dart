import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/areas/connection/connection_manager.dart';
import 'package:talk/areas/utilities/elevation.dart';
import 'package:talk/components/context_menu/core/utils/extensions.dart';
import 'package:talk/components/server_list/components/server_list_client_context_menu.dart';
import 'package:talk/core/models/models.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';

import '../../../areas/connection/connection_status.dart';

class ServerListNavigator extends StatefulWidget {
  final bool showAddServerButton;
  final bool showMainServersOnly;
  const ServerListNavigator({super.key, required this.showAddServerButton, required this.showMainServersOnly});

  @override
  State<ServerListNavigator> createState() => _ServerListNavigatorState();
}

class _ServerListNavigatorState extends State<ServerListNavigator> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ).toReversed();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ConnectionManager connectionManager = ConnectionManager();

    // Listen to added new connections or deleted connections
    return ListenableBuilder(
        listenable: connectionManager,
        builder: (context, _) {
          if (_isDisposed) return Container();
          return SizedBox(
            width: 72,
            child: Elevation(
              child: Column(
                children: [
                  Expanded(child: ListView.builder(
                    itemCount: connectionManager.connections.length,
                    itemBuilder: (context, index) {
                      final connection = connectionManager.connections.elementAt(index);
                      return _buildClientServerList(context, connection);
                    },
                  ),),
                  if(widget.showAddServerButton) Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        context.goNamed('login');
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildClientServerList(BuildContext context, Connection connection) {
    return ValueListenableBuilder(
      valueListenable: connection.status,
      builder: (context, status, _) {
        if (_isDisposed) return Container();
        return _buildClientIcon(context, connection);

        // if (status != ConnectionStatus.authenticated) {
        //   return _buildClientIcon(context, connectionManager, client, null);
        // }
        //
        // return StreamBuilder(
        //   stream: Database(client.serverId!).servers.stream,
        //   initialData: Database(client.serverId!).servers.items,
        //   builder: (context, snapshot) {
        //     final servers = Database(client.serverId!).servers.items;
        //     if (!snapshot.hasData || servers.isEmpty) {
        //       return _buildClientIcon(context, connectionManager, client, null);
        //     }
        //
        //     final mainServer = servers.firstWhere((server) => server.main, orElse: () => servers.first);
        //
        //     return Column(
        //       children: [
        //         _buildClientIcon(context, connectionManager, client, mainServer),
        //         ...servers
        //             .where((server) => !server.main && server.parent == mainServer.id)
        //             .map((subServer) => _buildSubServerIcon(context, client, subServer)),
        //       ],
        //     );
        //   },
        // );
      },
    );
  }

  Widget _buildClientIcon(BuildContext context, Connection connection) {
    final colorScheme = Theme.of(context).colorScheme;

    String serverName = connection.status.value == ConnectionStatus.authenticated ? connection.mainServer!.name : connection.connectionUrl;
    String initials = _getServerInitials(serverName);

    return ServerListClientContextMenu(
      connection: connection,
      child: GestureDetector(
        onTap: () {
          if(connection.error != null) {
            return;
          } else {
            SelectedServerProvider.of(context, listen: false).selectServer(connection);
            context.goNamed('chat');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Tooltip(
            message: _getTooltipMessage(connection, serverName),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                if(connection.status.value == ConnectionStatus.error || connection.status.value == ConnectionStatus.connecting)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildConnectionStatusIndicator(context, connection) ?? Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildConnectionStatusIndicator(BuildContext context, Connection connection) {
    if (_isDisposed) return null;

    final colorScheme = Theme.of(context).colorScheme;
    return _getConnectionStatusIcon(connection.status.value, colorScheme);
  }

  String _getTooltipMessage(Connection connection, String serverName) {
    String message = '$serverName\nStatus: ${connection.status.value}';

    if (connection.status.value != ConnectionStatus.authenticated && connection.isReconnectEnabled) {
      message += '\nReconnecting... Attempt: ${connection.reconnectAttempts + 1}';
    }

    if (connection.error != null) {
      message += '\nLast Error: ${connection.error}';
    }

    return message;
  }

  Widget _buildSubServerIcon(BuildContext context, Connection connection, Server server) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
      child: Tooltip(
        message: server.name,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _getServerInitials(server.name),
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getServerInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length == 1) {
      if (name.contains(':')) {
        return 'S';
      }
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  Widget? _getConnectionStatusIcon(ConnectionStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ConnectionStatus.authenticated:
      case ConnectionStatus.connected:
        return null;
      case ConnectionStatus.authenticating:
      case ConnectionStatus.connecting:
        return RotationTransition(turns: _animation, child: Icon(Icons.sync, size: 20, color: colorScheme.onTertiaryContainer));
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return Icon(Icons.error_outline, size: 20, color: colorScheme.onTertiaryContainer);
      default:
        return null;
    }
  }
}