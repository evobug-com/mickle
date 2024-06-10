import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:talk/components/voice_room/core/models/voice_room_current.dart';

import '../../../core/audio/audio_manager.dart';

class VoiceRoomControlPanel extends StatefulWidget {
  const VoiceRoomControlPanel({super.key});

  @override
  State<StatefulWidget> createState() => VoiceRoomControlPanelState();
}

class VoiceRoomControlPanelState extends State<VoiceRoomControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.headphones),
          tooltip: 'Mute audio',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.mic),
          tooltip: 'Mute microphone',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.screen_share),
          tooltip: 'Share screen',
          onPressed: null,
        ),
        IconButton(
          icon: Icon(Icons.videocam),
          tooltip: 'Toggle webcam',
          onPressed: null,
        ),
        IconButton(
          icon: Icon(Icons.call_end),
          tooltip: 'Leave voice chat',
          onPressed: () {
            VoiceRoomCurrent.of(context, listen: false).leaveVoice();
          },
        ),
      ]
    );
  }
}