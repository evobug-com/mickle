import 'package:flutter/material.dart';
import 'package:talk/core/managers/client_manager.dart';
import 'package:talk/core/notifiers/theme_controller.dart';

import '../components/server_list_navigator.dart';

class ServerListWidget extends StatefulWidget {
  final bool showAddServerButton;

  const ServerListWidget({super.key, required this.showAddServerButton})
      : super();

  @override
  State<ServerListWidget> createState() => _ServerListWidgetState();
}

class _ServerListWidgetState extends State<ServerListWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = ThemeController.scheme(context);

    return ListenableBuilder(
      listenable: ClientManager.of(context, listen: false),
      builder: (context, _) {
        return ServerListNavigator(showAddServerButton: widget.showAddServerButton);
      }
    );
  }
}
