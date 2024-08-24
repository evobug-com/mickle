import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import '../../../core/network/response.dart' as response;

import '../../../core/models/models.dart';
import 'text_room_message.dart';
import '../core/models/text_room_scroll_controller.dart';

class TextRoomMessages extends StatefulWidget {
  final Channel channel;
  final ConnectionProvider connection;
  const TextRoomMessages({super.key, required this.channel, required this.connection});

  @override
  State<TextRoomMessages> createState() => TextRoomMessagesState();
}

class TextRoomMessagesState extends State<TextRoomMessages> {
  Future<response.ChannelMessageFetch>? fetchingMessages;

  @override
  void initState() {
    super.initState();
    // Ask backend for messages if we don't have any
    final messages = widget.channel.getMessages(database: widget.connection.database);
    if(messages.isEmpty) {
      fetchMessages();
    } else {
      // Set fetching messages to completed future because we have messages already
      fetchingMessages = Future.value(response.ChannelMessageFetch());
    }

    restoreScrollPosition();
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

  fetchMessages() {
    fetchingMessages = widget.connection.packetManager.sendChannelMessageFetch(channelId: widget.channel.id, lastMessageId: widget.channel.getMessages(database: widget.connection.database).firstOrNull?.id);
  }

  restoreScrollPosition() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    // Restore the scroll controller for the selected channel
    if(scrollController.controllers.containsKey(widget.channel.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.controllers[widget.channel.id]!.jumpToCached();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TextRoomMessages oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.channel != widget.channel) {
      restoreScrollPosition();

      // Fetch messages
      fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.channel.getMessages(database: widget.connection.database);
    final textRoomScrollController = Provider.of<TextRoomScrollController>(context);
    var previousDate = DateTime.now();
    return FutureBuilder(
      future: fetchingMessages,
      builder: (context, messagesFetchSnapshot) {
        return StreamBuilder(
          stream: widget.connection.database.messages.stream.where((message) => widget.channel.containsMessage(message, database: widget.connection.database)),
          initialData: messages,
          builder: (context, snapshot) {

            if(!snapshot.hasData || !messagesFetchSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Get fresh messages
            final messages = widget.channel.getMessages(database: widget.connection.database);

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
                    fetchingMessages = widget.connection.packetManager.sendChannelMessageFetch(channelId: widget.channel.id, lastMessageId: widget.channel.getMessages(database: widget.connection.database).first.id);
                  }
                });
                return controller;
              }).controller,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final user = widget.connection.database.users.get("User:${message.user}");

                final currentMessage = messages[index];

                // Date is: 2024-05-10T22:41:50.173955362Z
                final currentMessageDate = DateTime.parse(currentMessage.createdAt);
                final todayDate = DateTime.now();
                final diffToToday = todayDate.difference(currentMessageDate);
                String text;

                if(diffToToday.inDays <= 6) {
                  if(diffToToday.inDays == 0) {
                    text = "Today";
                  } else if(diffToToday.inDays == 1) {
                    text = "Yesterday";
                  } else {
                    // Show the week day name
                    text = currentMessageDate.toLocal().weekday == 1 ? "Monday" : currentMessageDate.toLocal().weekday == 2 ? "Tuesday" : currentMessageDate.toLocal().weekday == 3 ? "Wednesday" : currentMessageDate.toLocal().weekday == 4 ? "Thursday" : currentMessageDate.toLocal().weekday == 5 ? "Friday" : currentMessageDate.toLocal().weekday == 6 ? "Saturday" : "Sunday";
                  }
                } else {
                  text = currentMessageDate.toLocal().toIso8601String().substring(0, 10);
                }

                Widget? daySeparatorWidget;
                if(currentMessageDate.day != previousDate.day || currentMessageDate.month != previousDate.month || currentMessageDate.year != previousDate.year) {
                  previousDate = currentMessageDate;
                  final decoration = BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  );
                  daySeparatorWidget = Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Container(decoration: decoration, height: 2,)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Container(decoration: decoration, height: 2,)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if(daySeparatorWidget != null) daySeparatorWidget,
                    TextRoomMessage(
                      message: message,
                      user: user,
                      onEdit: null,
                      onDelete: null,
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    );

  }

}