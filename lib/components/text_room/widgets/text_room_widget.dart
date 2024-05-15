import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/components/text_room/components/text_room_header.dart';
import 'package:talk/components/text_room/core/models/text_room_scroll_controller.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/models/models.dart';

import '../../../core/surfaces.dart';
import '../components/text_room_input.dart';
import '../components/text_room_messages.dart';

// A widget that displays list of messages, and allows user to send a message

class TextRoomWidget extends StatefulWidget {
  final Client client;
  final Channel channel;

  const TextRoomWidget(
      {super.key, required this.channel, required this.client});

  @override
  State<StatefulWidget> createState() => TextRoomWidgetState();
}

class TextRoomWidgetState extends State<TextRoomWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TextRoomScrollController>(
      create: (_) => TextRoomScrollController(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Surface.surfaceContainer(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextRoomHeader(
                channel: widget.channel,
              )
            ),
            Expanded(
              child: TextRoomMessages(
                channel: widget.channel,
                client: widget.client,
              ),
            ),
            const Divider(height: 1),
            TextRoomInput(
              client: widget.client,
              channel: widget.channel,
            ),
          ],
        ),
      ),
    );
  }
}
