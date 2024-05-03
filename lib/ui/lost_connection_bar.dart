
import 'package:flutter/material.dart';
import 'package:talk/core/connection/connection.dart';
import 'package:talk/core/connection/reconnect_manager.dart';
import 'package:talk/core/notifiers/current_connection.dart';

class LostConnectionBarWidget extends StatelessWidget {
  const LostConnectionBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final session = CurrentSession();
    return ListenableBuilder(listenable: session, builder: (context, _) {
      if(session.connection == null) {
        return const SizedBox.shrink();
      }
      final connection = session.connection!;

      return ListenableBuilder(listenable: connection, builder: (context, child) {
        final connectionState = connection.state;
        if(connectionState == ConnState.connected) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: connectionState == ConnState.scheduledReconnect ? Colors.orange : Colors.red,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(getMessageFromState(connection), style: TextStyle(color: Colors.white))
          ),
        );
      });
    });
  }

  getMessageFromState(Connection connection) {
    switch(connection.state) {
      case ConnState.none:
        return "No connection to the server.";
      case ConnState.connecting:
        return "Connecting to the server...";
      case ConnState.connected:
        return "Connected to the server.";
      case ConnState.disconnected:
        return "Disconnected from the server.";
      case ConnState.scheduledReconnect:
        return "Reconnecting to the server... (attempt: ${ReconnectManager().getReconnectRetry(connection)!.attempts})";
    }
  }
}