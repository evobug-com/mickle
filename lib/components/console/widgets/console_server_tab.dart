import 'package:flutter/material.dart';

class ConsoleServerTab extends StatefulWidget {
  const ConsoleServerTab({super.key});

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