import 'package:flutter/material.dart';
import '../components/server_list_navigator.dart';

class ServerListWidget extends StatelessWidget {
  final bool showAddServerButton;
  final bool showMainServersOnly;

  const ServerListWidget({super.key, required this.showAddServerButton, required this.showMainServersOnly});

  @override
  Widget build(BuildContext context) {
    return const ServerListNavigator();
  }
}