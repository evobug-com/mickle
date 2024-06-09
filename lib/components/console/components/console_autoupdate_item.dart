import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/globals.dart' as globals;
import '../../../utils.dart';

class ConsoleAutoUpdateItem extends StatelessWidget {
  const ConsoleAutoUpdateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.update),
      title: const Text("Spustit vyhledávání aktualizací"),
      onTap: () {
        globals.isUpdater = true;
        context.go("/updater");
        updateWindowStyle();
      },
    );
  }
}