import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talk/core/completer.dart';

import '../../../core/notifiers/current_client_provider.dart';
import '../../../core/processor/packet_manager.dart';

class ConsoleChangePresenceItem extends StatefulWidget {
  const ConsoleChangePresenceItem({super.key});

  @override
  State<ConsoleChangePresenceItem> createState() => _ConsoleChangePresenceItemState();
}

class _ConsoleChangePresenceItemState extends State<ConsoleChangePresenceItem> {
  Completer? _futureResponse;

  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    final packetManager = clientProvider.packetManager!;

    return ListTile(
      leading: const Icon(Icons.circle),
      title: const Text("Změnit přítomnost"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Změna přítomnosti'),
                    content: Column(
                      children: [
                        // List of themes
                        for (final presence in ["online", "offline", "away", "busy", "invisible"])
                          ListTile(
                            title: Text(presence),
                            onTap: !(_futureResponse?.isCompleted ?? true) ? null : () {
                              setState(() {
                                _futureResponse = packetManager.sendUserChangePresence(presence: presence).wrapInCompleter();
                                _futureResponse!.future.whenComplete(() => setState(() {}));
                              });
                            },
                          ),
                        if(_futureResponse != null)
                          FutureBuilder(
                            future: _futureResponse!.future,
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if(snapshot.hasError || (snapshot.hasData && snapshot.data != null && snapshot.data.error != null)) {
                                return Text("Chyba při změně přítomnosti: ${snapshot.error != null ? snapshot.error.toString() : snapshot.data.error}");
                              }
                              return const Text("Přítomnost byla změněna");
                            },
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Zavřít"),
                      ),
                    ],
                  );
                }
              );
            }
        );
      },
    );
  }
}