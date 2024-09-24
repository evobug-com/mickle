import 'dart:ui';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mickle/areas/utilities/elevation.dart';
import 'package:mickle/core/providers/scoped/connection_provider.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';

import '../../../core/models/models.dart';
import '../core/models/text_room_scroll_controller.dart';

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

class TextRoomInput extends StatefulWidget {
  final ConnectionProvider connection;
  final Channel channel;

  const TextRoomInput(
      {super.key, required this.connection, required this.channel});

  @override
  State<StatefulWidget> createState() => TextRoomInputState();
}

class TextRoomInputState extends State<TextRoomInput> with SingleTickerProviderStateMixin {
  final TextEditingController _chatTextController = TextEditingController();
  final _emojiScrollController = ScrollController();
  late final FocusNode _chatTextFocus;
  bool _emojiShowing = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatTextFocus = FocusNode(
      onKeyEvent: (node, event) {
        // sendMessageOnEnter

        if(event.deviceType == KeyEventDeviceType.keyboard) {

          if(SettingsProvider().sendMessageOnEnter && event.logicalKey == LogicalKeyboardKey.enter && !HardwareKeyboard.instance.isShiftPressed) {
            _sendMessage(_chatTextController.text);
            return KeyEventResult.handled;
          } else if(!SettingsProvider().sendMessageOnEnter && event.logicalKey == LogicalKeyboardKey.enter && HardwareKeyboard.instance.isShiftPressed) {
            _sendMessage(_chatTextController.text);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _chatTextController.dispose();
    _chatTextFocus.dispose();
    _emojiScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker(value) {
    setState(() {
      _emojiShowing = value;
      if (_emojiShowing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Elevation(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
                bottom: Radius.circular(_emojiShowing ? 0 : 30),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.add_circle_outline_rounded),
                        iconSize: 20,
                        onPressed: () {
                          // TODO: Implement add attachment functionality
                        }
                    ),
                    Expanded(
                      child: TextField(
                          focusNode: _chatTextFocus,
                          controller: _chatTextController,
                          decoration: InputDecoration(
                            hintText: 'Message #${widget.channel.name}',
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) {
                            if(SettingsProvider().replaceTextEmoji) {
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
                          onSubmitted: _sendMessage
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.sentiment_satisfied_alt, color: colorScheme.onSurfaceVariant, size: 20),
                      onPressed: () {
                        _toggleEmojiPicker(!_emojiShowing);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _animation,
              child: Container(
                height: 256,
                child: _buildEmojiPicker(colorScheme),
              ),
            ),
          ],
        );
      },
    );
  }

  EmojiPicker _buildEmojiPicker(ColorScheme colorScheme) {
    return EmojiPicker(
          textEditingController: _chatTextController,
          scrollController: _emojiScrollController,
          config: Config(
            height: 256,
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
              backgroundColor: colorScheme.surfaceContainerHigh,
              // Issue: https://github.com/flutter/flutter/issues/28894
              emojiSizeMax: 28 *
                  (defaultTargetPlatform ==
                      TargetPlatform.iOS
                      ? 1.2
                      : 1.0),
            ),
            swapCategoryAndBottomBar: false,
            skinToneConfig: const SkinToneConfig(),
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: colorScheme.surfaceContainerHigh,
              indicatorColor: colorScheme.primary,
              iconColorSelected: colorScheme.primary,
            ),
            bottomActionBarConfig: BottomActionBarConfig(
              enabled: false,
              backgroundColor: colorScheme.surfaceContainerHigh,
              buttonColor: colorScheme.primary,
              buttonIconColor: colorScheme.onPrimary,
            ),
            searchViewConfig: SearchViewConfig(
              backgroundColor: colorScheme.surfaceContainerHigh,
            ),
          ),
        );
  }

  void _sendMessage(String value) {
    if (value.isEmpty) {
      return;
    }

    widget.connection.packetManager.sendCreateChannelMessage(value: value, channelId: widget.channel.id);

    Provider.of<TextRoomScrollController>(context, listen: false)
        .nextRenderScrollToBottom = true;

    // Clean the input for next message
    _chatTextController.clear();

    // Keep the chat input focused after sending message
    _chatTextFocus.requestFocus();

    _toggleEmojiPicker(false);
  }
}
