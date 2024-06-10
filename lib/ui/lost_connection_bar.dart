
import 'package:flutter/material.dart';
import 'package:talk/core/connection/client.dart';

import '../core/notifiers/current_client_provider.dart';

class LostConnectionBarWidget extends StatelessWidget {
  const LostConnectionBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    return ListenableBuilder(listenable: clientProvider, builder: (context, _) {
      if(clientProvider.selectedClient == null) {
        return const SizedBox.shrink();
      }

      return ListenableBuilder(listenable: clientProvider.selectedClient!.connection, builder: (context, child) {
        final connectionState = clientProvider.selectedClient!.connection.state;
        if(connectionState == ClientConnectionState.connected) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: connectionState == ClientConnectionState.connecting ? Colors.orange : Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(getMessageFromState(connectionState), style: const TextStyle(color: Colors.white))
          ),
        );
      });
    });
  }

  getMessageFromState(ClientConnectionState state) {
    switch(state) {
      case ClientConnectionState.none:
        return "No connection to the server.";
      case ClientConnectionState.connecting:
        return "Connecting to the server...";
      case ClientConnectionState.connected:
        return "Connected to the server.";
      case ClientConnectionState.disconnected:
        return "Disconnected from the server.";
    }
  }
}