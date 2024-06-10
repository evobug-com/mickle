import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/models/models.dart';

import '../../../../core/audio/audio_manager.dart';

class VoiceRoomCurrent extends ChangeNotifier {
  Channel? _currentChannel;
  Channel? get currentChannel => _currentChannel;

  void joinVoice(Channel channel) {
    AudioManager.playSingleShot("SFX", AssetSource("audio/enter_voice.wav"));
    _currentChannel = channel;
    notifyListeners();
  }

  void leaveVoice() {
    AudioManager.playSingleShot("SFX", AssetSource("audio/leave_voice.wav"));
    _currentChannel = null;
    notifyListeners();
  }

  static of(BuildContext context, {bool listen = true}) {
    return Provider.of<VoiceRoomCurrent>(context, listen: listen);
  }
}