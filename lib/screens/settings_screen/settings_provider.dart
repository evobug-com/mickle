
import 'package:flutter/material.dart';

import '../../core/notifiers/theme_controller.dart';
import '../../core/storage/storage.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _singleton = SettingsProvider._internal();
  factory SettingsProvider() => _singleton;
  SettingsProvider._internal();

  bool get replaceTextEmoji => Storage().readBoolean('replaceTextEmoji', defaultValue: false);
  set replaceTextEmoji(bool value) {
    Storage().write('replaceTextEmoji', value.toString());
    notifyListeners();
  }

  bool get autostartup => Storage().readBoolean('autostartup', defaultValue: false);
  set autostartup(bool value) {
    Storage().write('autostartup', value.toString());
    notifyListeners();
  }

  bool get exitToTray => Storage().readBoolean('exitToTray', defaultValue: true);
  set exitToTray(bool value) {
    Storage().write('exitToTray', value.toString());
    notifyListeners();
  }

  String? get microphoneDevice => Storage().read('microphoneDevice');
  set microphoneDevice(value) {
    Storage().write('microphoneDevice', value);
    notifyListeners();
  }

  String get theme => Storage().readString('theme', defaultValue: ThemeController().currentThemeName);
  set theme(String value) {
    Storage().write('theme', value);
    notifyListeners();
  }

  String get language => Storage().readString('locale', defaultValue: 'en-us');
  set language(String value) {
    Storage().write('locale', value);
    notifyListeners();
  }
}