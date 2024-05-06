import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talk/core/models/models.dart' as models;
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/notifiers/theme_controller.dart';
import 'package:talk/ui/user_avatar.dart';

// This component will render a message in a room
// The message will have Avatar, name, time and message
// It will support editing and deleting messages
class ChannelMessage extends StatefulWidget {
  final models.Message message;
  final models.User? user;
  final void Function()? onEdit;
  final void Function()? onDelete;

  const ChannelMessage({
    super.key,
    required this.message,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ChannelMessageState createState() => ChannelMessageState();
}

class ChannelMessageState extends State<ChannelMessage> {
  bool _isHovered = false;

  getBackgroundColor() {
    // if is current user
    if (widget.user?.id == CurrentSession().user?.id) {
      if (_isHovered) {
        return ThemeController
            .scheme(context)
            .surfaceContainerLowest;
      } else {
        return ThemeController.scheme(context).surfaceContainerLow;
      }
    }

    if(_isHovered) {
      return ThemeController.scheme(context).surfaceContainerLowest;
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ThemeController.scheme(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.fromLTRB(0, 1, 0, 1),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: colorScheme.onSurface,
              displayColor: colorScheme.onSurface,
            ),
          ),
          child: Stack(
            children: [
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(imageUrl: widget.user?.avatar),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.user?.displayName ?? '<user not found>', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),),
                          const SizedBox(width: 8),
                          if(widget.message.createdAt != null) Text(DateFormat('HH:mm:ss').format(DateTime.parse(widget.message.createdAt)), style: TextStyle(color: colorScheme.onSurface, fontStyle: FontStyle.italic)),
                          if (widget.message.createdAt == null) Text(widget.message.createdAt ?? '<No time>', style: TextStyle(color: colorScheme.onSurface, fontStyle: FontStyle.italic)),
                        ],
                      ),
                      Text(widget.message.content ?? '<No message>', style: TextStyle(color: colorScheme.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
            if (_isHovered)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ),
            ]
          ),
        ),
      ),
    );
  }
}