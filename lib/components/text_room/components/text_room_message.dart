import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mickle/components/context_menu/core/utils/extensions.dart';
import 'package:mickle/core/models/models.dart' as models;
import 'package:mickle/core/providers/scoped/connection_provider.dart';
import 'package:mickle/ui/user_avatar.dart';

// This component will render a message in a room
// The message will have Avatar, name, time and message
// It will support editing and deleting messages
class TextRoomMessage extends StatefulWidget {
  final models.Message message;
  final models.User? user;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final bool isFirstMessage;
  final bool isMiddleMessage;
  final bool isLastMessage;

  const TextRoomMessage({
    super.key,
    required this.message,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.isFirstMessage,
    required this.isMiddleMessage,
    required this.isLastMessage,
  });

  @override
  TextRoomMessageState createState() => TextRoomMessageState();
}

class TextRoomMessageState extends State<TextRoomMessage> {

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: widget.isFirstMessage ? 8 : 0,
          bottom: widget.isFirstMessage || widget.isLastMessage ? 8 : 0,
        ),
        decoration: BoxDecoration(
          color: getMessageBgColor(),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.isFirstMessage ? 8 : 0),
            topRight: Radius.circular(widget.isFirstMessage ? 8 : 0),
            bottomLeft: Radius.circular(widget.isLastMessage ? 8 : 0),
            bottomRight: Radius.circular(widget.isLastMessage ? 8 : 0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildInfo(theme),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Color getMessageBgColor() {
    final isCurrentUser = widget.user?.id == ConnectionProvider.of(context).user.id;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if(isHovered) {
      return colorScheme.surfaceContainerHighest;
    }

    return isCurrentUser
    ? colorScheme.surfaceContainerLow
    : Colors.transparent;
  }

  Column _buildContent(ThemeData theme) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.isFirstMessage)
                    Text(
                        widget.user?.displayName ?? '<user not found>',
                        style: theme.textTheme.titleMedium),
                  const Expanded(child: SizedBox()),
                  if (widget.isFirstMessage)
                    Text(widget.message.createdAt.toLocal().formatted,
                        style: theme.textTheme.bodySmall),
                ],
              ),

              MarkdownBody(
                data: widget.message.content ?? '<No message>',
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyMedium,
                ),
              )
            ],
          );
  }

  SizedBox _buildInfo(ThemeData theme) {
    return SizedBox(
          width: 40,
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 50),
            child: widget.isFirstMessage ?
            UserAvatar(imageUrl: widget.user?.avatarUrl) :
            isHovered ? Text(widget.message.createdAt.toLocal().formatted, style: theme.textTheme.bodySmall) : null
          ),
        );
  }
}
