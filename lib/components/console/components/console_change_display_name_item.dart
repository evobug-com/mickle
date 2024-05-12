import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/processor/request_processor.dart';

class ConsoleChangeDisplayNameItem extends StatefulWidget {
  const ConsoleChangeDisplayNameItem({super.key});

  @override
  ConsoleChangeDisplayNameItemState createState() => ConsoleChangeDisplayNameItemState();
}

class ConsoleChangeDisplayNameItemState extends State<ConsoleChangeDisplayNameItem> {

  final TextEditingController _newDisplayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override void dispose() {
    _newDisplayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text("Změnit zobrazovací jméno"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
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

                      // Check if display name is not empty, show toast if it is
                      if(_newDisplayNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Display name cannot be empty")));
                        return;
                      }

                      packetUserChangeDisplayName(displayName: _newDisplayNameController.text);

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