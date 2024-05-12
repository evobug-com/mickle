import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../../core/processor/request_processor.dart';

class ConsoleChangePasswordItem extends StatefulWidget {
  const ConsoleChangePasswordItem({super.key});

  @override
  ConsoleChangePasswordItemState createState() => ConsoleChangePasswordItemState();
}

class ConsoleChangePasswordItemState extends State<ConsoleChangePasswordItem> {

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
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text("Změnit heslo"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
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
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Zrušit"),
                  ),
                  TextButton(
                    onPressed: () {

                      // Check if password is not empty, show toast if it is
                      if(_newPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password cannot be empty")));
                        return;
                      }

                      // Check if password is valid, show toast if not
                      if(_newPasswordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                        return;
                      }

                      packetUserChangePassword(oldPassword: _oldPasswordController.text, newPassword: _newPasswordController.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Potvrdit"),
                  ),
                ],
              );
            }
        );
      },
    );
  }
}