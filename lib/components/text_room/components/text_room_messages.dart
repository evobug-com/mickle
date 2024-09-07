import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/models/utils.dart';
import 'package:talk/core/network/api_types.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

import '../../../core/models/models.dart';
import '../../ui/date_separator.dart';
import 'text_room_message.dart';
import '../core/models/text_room_scroll_controller.dart';

/// A widget that displays messages in a text room channel.
///
/// This widget handles fetching messages, displaying them in a scrollable list,
/// and managing scroll behavior.
class TextRoomMessages extends StatefulWidget {
  final Channel channel;
  final ConnectionProvider connection;
  const TextRoomMessages({super.key, required this.channel, required this.connection});

  @override
  State<TextRoomMessages> createState() => TextRoomMessagesState();
}

class TextRoomMessagesState extends State<TextRoomMessages> {
  Future<ApiResponse<ResFetchChannelMessagesPacket>>? fetchingMessages;

  @override
  void initState() {
    print('[TextRoomMessages] Init State');
    super.initState();
    _initializeMessages();
    _restoreScrollPosition();
  }

  /// Initializes messages for the channel.
  ///
  /// If there are no messages, it triggers a fetch from the backend.
  void _initializeMessages() {
    // Ask backend for messages if we don't have any
    final messages = widget.channel.getMessages(database: widget.connection.database);
    if(messages.isEmpty) {
      _fetchMessages();
    } else {
      // Set fetching messages to completed future because we have messages already
      fetchingMessages = Future.value(ApiResponse.success(const ResFetchChannelMessagesPacket(messages: [], relations: []), 0, "ResFetchChannelMessagesPacket"));
    }
  }

  /// Fetches messages from the backend for the current channel.
  void _fetchMessages() {
    fetchingMessages = widget.connection.packetManager.sendChannelMessageFetch(
        channelId: widget.channel.id,
        lastMessageId: widget.channel.getMessages(database: widget.connection.database).firstOrNull?.id
    );
    fetchingMessages!.then((response) {
     print('[TextRoomMessages] Fetched messages: $response');
    });
  }

  /// Restores the scroll position for the current channel.
  void _restoreScrollPosition() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    // Restore the scroll controller for the selected channel
    if(scrollController.controllers.containsKey(widget.channel.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.controllers[widget.channel.id]!.jumpToCached();
        print('[TextRoomMessages] Restored scroll position for channel ${widget.channel.name}');
      });
    }
  }

  /// Determines if more messages should be fetched based on scroll position.
  bool _shouldFetchMessages() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    return _isScrollAvailable() && scrollController.controllers[widget.channel.id]!.controller.position.pixels == 0;
  }

  /// Checks if scrolling is available for the current channel.
  bool _isScrollAvailable() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    final chatScrollController = scrollController.controllers[widget.channel.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      return chatScrollController.controller.position.maxScrollExtent > 0;
    }
    return false;
  }

  /// Determines if the chat should scroll to the bottom.
  bool _shouldScrollToBottom() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    final chatScrollController = scrollController.controllers[widget.channel.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      return chatScrollController.position == chatScrollController.controller.position.maxScrollExtent;
    }
    return true;
  }

  /// Scrolls the chat to the bottom.
  void _scrollToBottom() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    final chatScrollController = scrollController.controllers[widget.channel.id];
    if(chatScrollController != null && chatScrollController.hasClients) {
      chatScrollController.scrollToBottom();
      print("[TextRoomMessages] Scrolling to bottom");
    }
  }

  /// Determines if a date separator should be shown between messages.
  bool _shouldShowDateSeparator(DateTime currentDate, DateTime? previousDate) {
    if (previousDate == null) return true;
    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  @override
  void didUpdateWidget(covariant TextRoomMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[TextRoomMessages] Did Update');

    if(oldWidget.channel != widget.channel) {
      _restoreScrollPosition();

      // Fetch messages
      _fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchingMessages,
        builder: (context, messagesFetchSnapshot) {
          return StreamBuilder(
            stream: widget.connection.database.messages.stream.where(
                    (message) => widget.channel.containsMessage(message, database: widget.connection.database)
            ),
            initialData: widget.channel.getMessages(database: widget.connection.database),
            builder: (context, snapshot) {
              print('[TextRoomMessages] Building messages');
              print('[TextRoomMessages] snapshot.hasData: ${snapshot.hasData}');
              print('[TextRoomMessages] messagesFetchSnapshot.hasData: ${messagesFetchSnapshot.hasData}');
              if (!snapshot.hasData || !messagesFetchSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildMessageList(widget.channel.getMessages(database: widget.connection.database));
            },
          );
        }
    );
  }

  /// Builds the list of messages.
  Widget _buildMessageList(List<Message> messages) {
    final textRoomScrollController = Provider.of<TextRoomScrollController>(context);
    textRoomScrollController.nextRenderScrollToBottom = _shouldScrollToBottom();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (textRoomScrollController.nextRenderScrollToBottom) {
        _scrollToBottom();
        textRoomScrollController.nextRenderScrollToBottom = false;
      }
    });

    return ListView.builder(
      controller: _getScrollController(),
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageItem(messages, index),
    );
  }

  /// Builds an individual message item, including date separators when necessary.
  Widget _buildMessageItem(List<Message> messages, int index) {
    final message = messages[index];
    final user = widget.connection.database.users.get(message.user);
    final currentMessageDate =message.createdAt;
    final previousMessageDate = index > 0 ? messages[index - 1].createdAt : null;

    return Column(
      children: [
        if (_shouldShowDateSeparator(currentMessageDate, previousMessageDate))
          DateSeparator(date: currentMessageDate),
        TextRoomMessage(
          message: message,
          user: user,
          onEdit: null,
          onDelete: null,
        ),
      ],
    );
  }

  /// Gets or creates a scroll controller for the current channel.
  ScrollController _getScrollController() {
    final scrollController = Provider.of<TextRoomScrollController>(context, listen: false);
    return scrollController.controllers.putIfAbsent(widget.channel.id, () {
      final controller = CachedScrollController();
      controller.controller.addListener(() {
        scrollController.nextRenderScrollToBottom = _shouldScrollToBottom();
        if (_shouldFetchMessages()) {
          _fetchMessages();
        }
      });
      return controller;
    }).controller;
  }
}