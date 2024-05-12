import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/processor/request_processor.dart';

class ConsoleChangeAvatarItem extends StatefulWidget {
  const ConsoleChangeAvatarItem({super.key});

  @override
  ConsoleChangeAvatarItemState createState() => ConsoleChangeAvatarItemState();
}

class ConsoleChangeAvatarItemState extends State<ConsoleChangeAvatarItem> {

  final TextEditingController _newAvatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override void dispose() {
    _newAvatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      leading: const Icon(Icons.image),
      title: const Text("Změnit avatar"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
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

                      packetUserChangeAvatar(avatar: _newAvatarController.text);

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