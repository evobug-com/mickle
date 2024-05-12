import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/processor/request_processor.dart';

class ConsoleChangeStatusItem extends StatefulWidget {
  const ConsoleChangeStatusItem({super.key});

  @override
  ConsoleChangeStatusItemState createState() => ConsoleChangeStatusItemState();
}

class ConsoleChangeStatusItemState extends State<ConsoleChangeStatusItem> {

  final TextEditingController _newStatusController = TextEditingController();

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
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text("Změnit status"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
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

                      packetUserChangeStatus(status: _newStatusController.text);

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