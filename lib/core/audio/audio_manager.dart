import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// Audio manager is shared across the app and is responsible for playing audio.
// It holds a list of audio players and provides methods to play, pause, and stop audio.
// Each audio player can play a single audio file at a time.
// Audio Player is abstraction over the platform specific audio player. Each platform has its own implementation.
// Each action on the audio player is asynchronous and returns a Future.

class CategorizedAudioPlayer extends AudioPlayer {
  final String category;
  CategorizedAudioPlayer(this.category);
}

class Volume extends ChangeNotifier {
  double _volume = 1.0;

  double get value => _volume;

  set value(double volume) {
    _volume = volume;
    notifyListeners();
  }
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  // Master volume for all audio (voice, app sounds, etc.)
  final Volume _masterVolume = Volume();

  // List of audio players
  final List<CategorizedAudioPlayer> _players = [];

  // Play an audio file
  static void playSingleShot(String category, Source source) async {
    AudioManager audioManager = AudioManager();
    final player = CategorizedAudioPlayer(category);
    await player.setReleaseMode(ReleaseMode.release);
    audioManager._players.add(player);
    player.onPlayerComplete.listen((_) {
      player.dispose();
      audioManager._players.remove(player);
    });
    return player.play(source);
  }

  get masterVolume => _masterVolume;

}