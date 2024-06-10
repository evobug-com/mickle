import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talk/core/completer.dart';

import '../../../core/notifiers/current_client_provider.dart';

class ConsoleChangeStatusItem extends StatefulWidget {
  const ConsoleChangeStatusItem({super.key});

  @override
  ConsoleChangeStatusItemState createState() => ConsoleChangeStatusItemState();
}

class ConsoleChangeStatusItemState extends State<ConsoleChangeStatusItem> {

  final TextEditingController _newStatusController = TextEditingController();
  Completer? _futureResponse;

  @override
  void initState() {
    super.initState();
  }

  @override void dispose() {
    _newStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = CurrentClientProvider.of(context);
    final packetManager = clientProvider.packetManager!;
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text("Změnit status"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Změna statusu"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Nový status",
                          ),
                          controller: _newStatusController,
                        ),
                        if(_futureResponse != null)
                          FutureBuilder(
                            future: _futureResponse!.future,
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if(snapshot.hasError || (snapshot.hasData && snapshot.data != null && snapshot.data.error != null)) {
                                return Text("Chyba při změně statusu: ${snapshot.error != null ? snapshot.error.toString() : snapshot.data.error}");
                              }
                              return const Text("Status byl změněn");
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
                      TextButton(
                        onPressed: !(_futureResponse?.isCompleted ?? true) ? null : () {
                          setState(() {
                            _futureResponse = packetManager.sendUserChangeStatus(status: _newStatusController.text).wrapInCompleter();
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