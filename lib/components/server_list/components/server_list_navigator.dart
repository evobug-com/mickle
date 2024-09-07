import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talk/areas/connection/connection.dart';
import 'package:talk/areas/connection/connection_manager.dart';
import 'package:talk/core/models/models.dart';

import '../../../areas/connection/connection_status.dart';

class ServerListNavigator extends StatelessWidget {
  const ServerListNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConnectionManager connectionManager = ConnectionManager();

    // Listen to added new connections or deleted connections
    return ListenableBuilder(
        listenable: connectionManager,
        builder: (context, _) {
          return SizedBox(
            width: 72,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: ListView.builder(
                itemCount: connectionManager.connections.length,
                itemBuilder: (context, index) {
                  final connection = connectionManager.connections.elementAt(index);
                  return _buildClientServerList(context, connection);
                },
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
        print('Connection status: $status');
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

    return Padding(
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
                color: colorScheme.primaryContainer,
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
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildConnectionStatusIndicator(context, connection),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusIndicator(BuildContext context, Connection connection) {
    final colorScheme = Theme.of(context).colorScheme;
    final connectionColor = _getConnectionColor(connection.status.value, colorScheme);

    if (connection.status.value == ConnectionStatus.disconnected && connection.isReconnectEnabled) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(connectionColor),
        ),
      );
    } else {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: connectionColor,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 2),
        ),
      );
    }
  }

  String _getTooltipMessage(Connection connection, String serverName) {
    String message = '$serverName\nStatus: ${connection.status.value}';

    if (connection.isReconnectEnabled) {
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

  Color _getConnectionColor(ConnectionStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ConnectionStatus.authenticated:
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.authenticating:
      case ConnectionStatus.connecting:
        return Colors.yellow;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return colorScheme.error;
      default:
        return colorScheme.surfaceVariant;
    }
  }
}