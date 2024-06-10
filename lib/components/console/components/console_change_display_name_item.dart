import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talk/core/completer.dart';

import '../../../core/notifiers/current_client_provider.dart';

class ConsoleChangeDisplayNameItem extends StatefulWidget {
  const ConsoleChangeDisplayNameItem({super.key});

  @override
  ConsoleChangeDisplayNameItemState createState() => ConsoleChangeDisplayNameItemState();
}

class ConsoleChangeDisplayNameItemState extends State<ConsoleChangeDisplayNameItem> {

  final TextEditingController _newDisplayNameController = TextEditingController();
  Completer? _futureResponse;

  @override void dispose() {
    _newDisplayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    final packetManager = clientProvider.packetManager!;
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text("Změnit zobrazovací jméno"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Změna zobrazovacího jména"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Nové zobrazovací jméno",
                          ),
                          controller: _newDisplayNameController,
                        ),
                        if(_futureResponse != null)
                          FutureBuilder(
                            future: _futureResponse!.future,
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if(snapshot.hasError || (snapshot.hasData && snapshot.data != null && snapshot.data.error != null)) {
                                return Text("Chyba při změně zobrazovacího jména: ${snapshot.error != null ? snapshot.error.toString() : snapshot.data.error}");
                              }
                              return const Text("Zobrazovací jméno bylo změněno");
                            },
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Zavřit"),
                      ),
                      TextButton(
                        onPressed: !(_futureResponse?.isCompleted ?? true) ? null : () {

                          // Check if display name is not empty, show toast if it is
                          if(_newDisplayNameController.text.isEmpty) {
                            setState(() {
                              _futureResponse = Completer();
                              _futureResponse!.completeError("Zobrazovací jméno nesmí být prázdné");
                            });
                            return;
                          }

                          setState(() {
                            _futureResponse = packetManager.sendUserChangeDisplayName(displayName: _newDisplayNameController.text).wrapInCompleter();
                            _futureResponse!.future.whenComplete(() => setState(() {}));
                          });
                        },
                        child: const Text("Potvrdit"),
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