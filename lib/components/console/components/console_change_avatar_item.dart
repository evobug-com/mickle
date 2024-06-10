import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';
import 'package:talk/core/completer.dart';

class ConsoleChangeAvatarItem extends StatefulWidget {
  const ConsoleChangeAvatarItem({super.key});

  @override
  ConsoleChangeAvatarItemState createState() => ConsoleChangeAvatarItemState();
}

class ConsoleChangeAvatarItemState extends State<ConsoleChangeAvatarItem> {

  final TextEditingController _newAvatarController = TextEditingController();
  Completer? _futureResponse;

  @override
  void dispose() {
    _newAvatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    final packetManager = clientProvider.packetManager!;
    return ListTile(
      leading: const Icon(Icons.image),
      title: const Text("Změnit avatar"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Změna avataru"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Adresa obrázku",
                          ),
                          controller: _newAvatarController,
                        ),
                        if(_futureResponse != null)
                          FutureBuilder(
                            future: _futureResponse!.future,
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if(snapshot.hasError || (snapshot.hasData && snapshot.data != null && snapshot.data.error != null)) {
                                return Text("Chyba při změně avataru: ${snapshot.error != null ? snapshot.error.toString() : snapshot.data.error}");
                              }
                              return const Text("Avatar byl změněn");
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
                          setState(() {
                            _futureResponse = packetManager.sendUserChangeAvatar(avatar: _newAvatarController.text).wrapInCompleter();
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