import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/connection/connection.dart';
import 'package:talk/core/database.dart';
import 'package:talk/core/processor/packet_manager.dart';

import '../../../core/models/models.dart';
import '../../../ui/channel_message.dart';
import '../core/models/text_room_scroll_controller.dart';

class TextRoomMessages extends StatefulWidget {
  final Channel channel;
  final Connection connection;
  const TextRoomMessages({super.key, required this.channel, required this.connection});

  @override
  State<TextRoomMessages> createState() => TextRoomMessagesState();
}

class TextRoomMessagesState extends State<TextRoomMessages> {
  @override
  void initState() {
    super.initState();

    // Ask backend for messages if we don't have any
    final messages = widget.channel.getMessages();
    if(messages.isEmpty) {
      PacketManager(widget.connection).sendChannelMessageFetch(channelId: widget.channel.id, lastMessageId: null);
    }

    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    // Restore the scroll controller for the selected channel
    if(scrollController.controllers.containsKey(widget.channel.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.controllers[widget.channel.id]!.jumpToCached();
      });
    }
  }

  @override
  void dispose() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    for (var element in scrollController.controllers.values) {
      element.dispose();
    }

    super.dispose();
  }

  shouldFetchMessages() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    return isScrollAvailable() && scrollController.controllers[widget.channel.id]!.controller.position.pixels == 0;
  }

  isScrollAvailable() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    final chatScrollController = scrollController.controllers[widget.channel.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      return chatScrollController.controller.position.maxScrollExtent > 0;
    }
    return false;
  }

  // Returns true if the chat is scrolled to the bottom
  shouldScrollToBottom() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    final chatScrollController = scrollController.controllers[widget.channel.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      return chatScrollController.position == chatScrollController.controller.position.maxScrollExtent;
    }
    return true;
  }

  scrollToBottom() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    final chatScrollController = scrollController.controllers[widget.channel.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      chatScrollController.scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final packetManager = PacketManager(widget.connection);
    final database = Database(widget.connection.serverId);
    final messages = widget.channel.getMessages();
    final textRoomScrollController = Provider.of<TextRoomScrollController>(context);
    return StreamBuilder(
      stream: database.messages.stream.where((message) => widget.channel.containsMessage(message)),
      initialData: messages,
      builder: (context, snapshot) {
        // Get fresh messages
        final messages = widget.channel.getMessages();

        if (snapshot.hasData) {

          // If we are at bottom, scroll to bottom on new message
          textRoomScrollController.nextRenderScrollToBottom = shouldScrollToBottom();

          // Post frame callback to scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(textRoomScrollController.nextRenderScrollToBottom) {
              scrollToBottom();
              textRoomScrollController.nextRenderScrollToBottom = false;
            }
          });

          return ListView.builder(
            controller: Provider.of<TextRoomScrollController>(context, listen: false).controllers.putIfAbsent(widget.channel.id, () {
              final controller = CachedScrollController();
              controller.controller.addListener(() {
                // If user scrolls up, disable auto scroll to bottom
                textRoomScrollController.nextRenderScrollToBottom = shouldScrollToBottom();

                if(shouldFetchMessages()) {
                  packetManager.sendChannelMessageFetch(channelId: widget.channel.id, lastMessageId: widget.channel.getMessages().first.id);
                }
              });
              return controller;
            }).controller,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final user = database.users.get("User:${message.user}");

              return ChannelMessage(
                message: message,
                user: user,
                onEdit: null,
                onDelete: null,
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );

  }

}