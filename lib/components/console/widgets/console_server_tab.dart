import 'package:flutter/material.dart';
import 'package:talk/core/notifiers/current_client_provider.dart';

class ConsoleServerTab extends StatefulWidget {
  const ConsoleServerTab({Key? key}) : super(key: key);

  @override
  ConsoleServerTabState createState() => ConsoleServerTabState();
}

class ConsoleServerTabState extends State<ConsoleServerTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Button to logout
        ListTile(
          title: const Text("Odhlásit se"),
          onTap: () {
            // CurrentSession()
          },
        ),
      ],
    );
  }
}