import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mickle/core/completer.dart';
import 'package:mickle/core/providers/scoped/connection_provider.dart';

class ConsoleChangePasswordItem extends StatefulWidget {
  const ConsoleChangePasswordItem({super.key});

  @override
  ConsoleChangePasswordItemState createState() => ConsoleChangePasswordItemState();
}

class ConsoleChangePasswordItemState extends State<ConsoleChangePasswordItem> {

  Completer? _futureResponse;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = ConnectionProvider.of(context);
    final packetManager = connectionProvider.packetManager;
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text("Změnit heslo"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Změna hesla"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Staré heslo",
                          ),
                          obscureText: true,
                          controller: _oldPasswordController,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Nové heslo",
                          ),
                          obscureText: true,
                          controller: _newPasswordController,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Potvrzení hesla",
                          ),
                          obscureText: true,
                          controller: _confirmPasswordController,
                        ),
                        if(_futureResponse != null)
                          FutureBuilder(
                            future: _futureResponse!.future,
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if(snapshot.hasError || (snapshot.hasData && snapshot.data != null && snapshot.data.error != null)) {
                                return Text("Chyba při změně hesla: ${snapshot.error != null ? snapshot.error.toString() : snapshot.data.error}");
                              }
                              return const Text("Heslo bylo změněno");
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

                          // Check if password is not empty, show toast if it is
                          if(_newPasswordController.text.isEmpty) {
                            setState(() {
                              _futureResponse = Completer();
                              _futureResponse!.completeError("Heslo nesmí být prázdné");
                            });
                            return;
                          }

                          // Check if password is valid, show toast if not
                          if(_newPasswordController.text != _confirmPasswordController.text) {
                            setState(() {
                              _futureResponse = Completer();
                              _futureResponse!.completeError("Hesla se neshodují");
                            });
                            return;
                          }

                          setState(() {
                            _futureResponse = packetManager.sendSetUserPassword(oldPassword: _oldPasswordController.text, newPassword: _newPasswordController.text).wrapInCompleter();
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