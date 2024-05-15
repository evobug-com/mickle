
import 'package:flutter/widgets.dart';

import '../../../core/connection/client_manager.dart';

class ServerListClientsListener extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  const ServerListClientsListener({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final clients = ClientManager.of(context, listen: true).clients;
    return ListenableBuilder(
      listenable: Listenable.merge(clients.map((client) => client.connection)),
      builder: (context, _) {
        return builder(context);
      }
    );
  }

}