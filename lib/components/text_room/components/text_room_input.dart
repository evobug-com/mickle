import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/connection/connection.dart';

import '../../../core/models/models.dart';
import '../../../core/processor/packet_manager.dart';
import '../core/models/text_room_scroll_controller.dart';

class TextRoomInput extends StatefulWidget {
  final Connection connection;
  final Channel channel;

  const TextRoomInput(
      {super.key, required this.connection, required this.channel});

  @override
  State<StatefulWidget> createState() => TextRoomInputState();
}

class TextRoomInputState extends State<TextRoomInput> {
  final TextEditingController _chatTextController = TextEditingController();
  final FocusNode _chatTextFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final packetManager = PacketManager(widget.connection);
    return TextField(
      focusNode: _chatTextFocus,
      controller: _chatTextController,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Message #${widget.channel.name}',
      ),
      onSubmitted: (value) {
        if (value.isEmpty) {
          return;
        }

        packetManager.sendChannelMessageCreate(value: value, channelId: widget.channel.id);

        Provider.of<TextRoomScrollController>(context, listen: false)
            .nextRenderScrollToBottom = true;

        // Clean the input for next message
        _chatTextController.clear();

        // Keep the chat input focused after sending message
        _chatTextFocus.requestFocus();
      },
    );
  }
}
