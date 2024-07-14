import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import 'package:talk/screens/settings_screen.dart';

import '../../../core/models/models.dart';
import '../../../core/managers/packet_manager.dart';
import '../core/models/text_room_scroll_controller.dart';

class TextRoomInput extends StatefulWidget {
  final ConnectionProvider connection;
  final Channel channel;

  const TextRoomInput(
      {super.key, required this.connection, required this.channel});

  @override
  State<StatefulWidget> createState() => TextRoomInputState();
}

class TextRoomInputState extends State<TextRoomInput> {
  final TextEditingController _chatTextController = TextEditingController();
  final FocusNode _chatTextFocus = FocusNode();

  String replaceEmojis(String value) {
    final emojiMap = {
      ':D': '😀',
      ':)': '🙂',
      ':(': '😞',
      ':P': '😛',
      ':O': '😲',
      ':|': '😐',
      ':*': '😘',
      ':@': '😠',
      ':S': '😖',
      ':\$': '🤑',
      ':!': '😱',
      ':L': '😍',
      ':X': '😵',
      ':Y': '😋',
      ':Z': '😴',
      ':W': '😷',
      ':T': '😆',
      ':B': '😎',
    };

    final emojiNameMap = {
      ':grinning_face:': '😀',
      ':beaming_face_with_smiling_eyes:': '😁',
      ':grinning_squinting_face:': '😆',
      ':grinning_face_with_sweat:': '😅',
      ':rolling_on_the_floor_laughing:': '🤣',
      ':face_with_tears_of_joy:': '😂',
      ':slightly_smiling_face:': '🙂',
      ':upside_down_face:': '🙃',
      ':winking_face:': '😉',
      ':smiling_face_with_smiling_eyes:': '😊',
      ':smiling_face_with_halo:': '😇',
      ':smiling_face_with_hearts:': '🥰',
      ':smiling_face_with_heart_eyes:': '😍',
      ':star_struck:': '🤩',
      ':face_blowing_a_kiss:': '😘',
      ':kissing_face:': '😗',
      ':smiling_face:': '☺️',
      ':kissing_face_with_closed_eyes:': '😚',
      ':kissing_face_with_smiling_eyes:': '😙',
      ':smiling_face_with_tear:': '🥲',
      ':face_savoring_food:': '😋',
      ':relieved_face:': '😌',
      ':smiling_face_with_sunglasses:': '😎',
      ':smirking_face:': '😏',
      ':neutral_face:': '😐',
      ':expressionless_face:': '😑',
      ':unamused_face:': '😒',
      ':face_with_rolling_eyes:': '🙄',
      ':grimacing_face:': '😬',
      ':lying_face:': '🤥',
      ':pensive_face:': '😔',
      ':confused_face:': '😕',
      ':money_mouth_face:': '🤑',
      ':astonished_face:': '😲',
      ':flushed_face:': '😳',
      ':disappointed_face:': '😞',
      ':worried_face:': '😟',
      ':angry_face:': '😠',
      ':pouting_face:': '😡',
    };

    var result = value;
    emojiNameMap.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    escape(String s) {
      return s.replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\]'), (x) {return "\\${x[0]}";});
    }

    emojiMap.forEach((key, value) {
      // We need to match \s:D\s, \s:D$, ^:D\s, ^:D$
      final regex = RegExp(r'(^|\s)' + escape(key) + r'($|\s)');
      result = result.replaceAllMapped(regex, (match) {
        return match.group(1)! + value + match.group(2)!;
      });
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _chatTextFocus,
      controller: _chatTextController,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: 'Message #${widget.channel.name}',
      ),
      onChanged: (value) {
        if(Settings().replaceTextEmoji) {
          // Replace emojis
          final replacedValue = replaceEmojis(value);
          if (value != replacedValue) {
            _chatTextController.value = TextEditingValue(
              text: replacedValue,
              selection: _chatTextController.selection,
            );
          }
        }
      },
      onSubmitted: (value) {
        if (value.isEmpty) {
          return;
        }

        widget.connection.packetManager.sendChannelMessageCreate(value: value, channelId: widget.channel.id);

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
