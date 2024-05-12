import 'package:flutter/material.dart';

import '../../../core/notifiers/current_connection.dart';
import '../../../core/processor/request_processor.dart';

class ConsoleChangePresenceItem extends StatelessWidget {
  const ConsoleChangePresenceItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.circle),
      title: const Text("Změnit přítomnost"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Změna přítomnosti"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListenableBuilder(
                        listenable: CurrentSession().connection!.user!,
                        builder: (context, child) {
                          return DropdownButton<String>(
                            value: CurrentSession().connection!.user!.presence!,
                            items: ["online", "offline", "away", "busy", "invisible"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (value) {
                              // Change presence
                              packetUserChangePresence(presence: value!);
                            },
                          );
                        }
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Change"),
                  ),
                ],
              );
            }
        );
      },
    );
  }
}