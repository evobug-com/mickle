import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class Device {
  final String id;
  final String name;
  final bool isDefault;
  Device(this.id, this.name, this.isDefault);

  @override
  String toString() {
    return 'Device{id: $id, name: $name, isDefault: $isDefault}';
  }
}

class _AudioPlatform {
  static late MethodChannel audioManagerPlatform;

  void ensureInitialized() {
    audioManagerPlatform = const MethodChannel('evobug.mickle/audio_manager');
  }

  static Future<List<Device>> getInputDevices() async {
    try {
      final devices = await audioManagerPlatform.invokeMethod<List<dynamic>>('getInputDevices');
      return (devices??[]).map((device) {
        return Device(device['id'], device['name'], device['isDefault']);
      }).toList();
    } on PlatformException catch (e) {
      print('Failed to get input devices: ${e.message}');
      return [];
    }
  }

  static Future<List<Device>> getOutputDevices() async {
    try {
      final devices = await audioManagerPlatform.invokeMethod<List<dynamic>>('getOutputDevices');
      return (devices??[]).map((device) {
        return Device(device['id'], device['name'], device['isDefault']);
      }).toList();
    } on PlatformException catch (e) {
      print('Failed to get input devices: ${e.message}');
      return [];
    }
  }

  static Future<bool> startCaptureStream(String deviceId) async {
    try {
      return await audioManagerPlatform.invokeMethod('startCaptureStream', {'deviceId': deviceId});
    } on PlatformException catch (e) {
      print('Failed to start capture stream: $e');
    }
    return false;
  }

  static Future<void> stopCaptureStream(String deviceId) async {
    try {
      await audioManagerPlatform.invokeMethod('stopCaptureStream', {'deviceId': deviceId});
    } on PlatformException catch (e) {
      print('Failed to stop capture stream: $e');
    }
  }

  static Future<void> stopAllCaptureStreams() async {
    try {
      await audioManagerPlatform.invokeMethod('stopAllCaptureStreams');
    } on PlatformException catch (e) {
      print('Failed to stop all capture streams: $e');
    }
  }

  static void setAudioDataHandler(Function(String deviceId, Uint8List audioData) handler) {
    audioManagerPlatform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onAudioData') {
        final args = call.arguments as Map;
        final deviceId = args['deviceId'] as String;
        final audioData = args['data'] as Uint8List;
        handler(deviceId, audioData);
      }
    });
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
    await player.setVolume(audioManager._masterVolume.value);
    await player.setReleaseMode(ReleaseMode.release);
    audioManager._players.add(player);
    player.onPlayerComplete.listen((_) {
      player.dispose();
      audioManager._players.remove(player);
    });
    return player.play(source);
  }

  get masterVolume => _masterVolume;

  // Get a list of input devices
  static Future<List<Device>> getInputDevices() async {
    return _AudioPlatform.getInputDevices();
  }

  // Get a list of output devices
  static Future<List<Device>> getOutputDevices() async {
    return _AudioPlatform.getOutputDevices();
  }

  // Start recording audio from a specific device
  static Future<bool> startCaptureStream(String deviceId) async {
    return _AudioPlatform.startCaptureStream(deviceId);
  }

  // Stop recording audio from a specific device
  static Future<void> stopCaptureStream(String deviceId) async {
    return _AudioPlatform.stopCaptureStream(deviceId);
  }

  // Stop recording audio from all devices
  static Future<void> stopAllCaptureStreams() async {
    return _AudioPlatform.stopAllCaptureStreams();
  }

  // Set a callback to receive audio data from the platform
  static void setAudioDataHandler(Function(String deviceId, Uint8List audioData) handler) {
    _AudioPlatform.setAudioDataHandler(handler);
  }

  static void ensureInitialized() {
    _AudioPlatform().ensureInitialized();
  }
}