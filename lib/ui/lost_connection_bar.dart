
import 'package:flutter/material.dart';
import 'package:talk/core/connection/connection.dart';
import 'package:talk/core/notifiers/current_connection.dart';

class LostConnectionBarWidget extends StatelessWidget {
  const LostConnectionBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final session = CurrentSession();
    return ListenableBuilder(listenable: session, builder: (context, _) {
      if(session.connection == null || session.connection!.state != ConnState.connected) {
        return const ColoredBox(
          color: Colors.red,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No connection to the server."),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}