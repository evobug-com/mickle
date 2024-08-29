import 'package:flutter/material.dart';
import 'package:talk/core/managers/client_manager.dart';
import '../components/server_list_navigator.dart';

class ServerListWidget extends StatelessWidget {
  final bool showAddServerButton;

  const ServerListWidget({super.key, required this.showAddServerButton});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: ClientManager.of(context, listen: false),
        builder: (context, _) {
          return ServerListNavigator(showAddServerButton: showAddServerButton);
        }
    );
  }
}