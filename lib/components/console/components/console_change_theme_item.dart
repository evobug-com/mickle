import 'package:flutter/material.dart';

import '../../../core/notifiers/theme_controller.dart';
import '../../../core/storage/storage.dart';

class ConsoleChangeThemeItem extends StatelessWidget {
  const ConsoleChangeThemeItem({super.key});

  @override
  Widget build(BuildContext context) {
    // List tile to change theme
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Změnit vzhled'),
      onTap: () {
        // Show dialog with themes
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  title: const Text('Změna vzhledu'),
                  content: Column(
                    children: [
                      // List of themes
                      for (final theme in ThemeController.themes)
                        ListTile(
                          title: Text(theme.name),
                          onTap: () {
                            // Set theme
                            ThemeController.of(context, listen: false)
                                .setTheme(theme.value);
                            // Save theme to storage
                            Storage().write('theme', theme.name);
                            // Close dialog
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ));
            });
          },
        );
      },
    );
  }
}
