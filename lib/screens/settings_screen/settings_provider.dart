
import 'package:flutter/material.dart';

import '../../core/storage/secure_storage.dart';
import '../../core/storage/storage.dart';
import 'settings_models.dart';

enum SettingsKeys {
  replaceTextEmoji,
  autostartup,
  exitToTray,
  microphonePreferredDevice,
  speakerPreferredDevice,
  cameraPreferredDevice,
  theme,
  locale,
  playSoundOnIncomingMessage,
  playSoundOnOutgoingMessage,
  playSoundOnMention,
  playSoundOnError,
  showDesktopNotifications,
  sendMessageOnEnter,
  messageDateFormat,
  masterVolume,
}

const defaultValues = {
  SettingsKeys.replaceTextEmoji: false,
  SettingsKeys.autostartup: false,
  SettingsKeys.exitToTray: true,
  SettingsKeys.microphonePreferredDevice: '',
  SettingsKeys.speakerPreferredDevice: '',
  SettingsKeys.cameraPreferredDevice: '',
  SettingsKeys.theme: 'Dark',
  SettingsKeys.locale: 'en-us',
  SettingsKeys.playSoundOnIncomingMessage: true,
  SettingsKeys.playSoundOnOutgoingMessage: true,
  SettingsKeys.playSoundOnMention: true,
  SettingsKeys.playSoundOnError: false,
  SettingsKeys.showDesktopNotifications: true,
  SettingsKeys.sendMessageOnEnter: true,
  SettingsKeys.messageDateFormat: 'HH:mm',
  SettingsKeys.masterVolume: 1.0,
};

class SettingsPreferencesProvider extends ChangeNotifier {
  static final SettingsPreferencesProvider _singleton = SettingsPreferencesProvider._internal();
  factory SettingsPreferencesProvider() => _singleton;
  SettingsPreferencesProvider._internal();

  static final Storage _storage = Storage();
  static final SecureStorage _secureStorage = SecureStorage();
  static final Map<SettingsKeys, List<Function>> _notifiers = {};

  void addPropertyListener(SettingsKeys key, Function listener) {
    if(!_notifiers.containsKey(key)) {
      _notifiers[key] = [];
    }
    if(!_notifiers[key]!.contains(listener)) {
      _notifiers[key]!.add(listener);
    }
  }

  void removePropertyListener(SettingsKeys key, Function listener) {
    if(_notifiers.containsKey(key)) {
      _notifiers[key]!.remove(listener);
    }
  }

  void notify(SettingsKeys key) {
    super.notifyListeners();
    if(_notifiers.containsKey(key)) {
      for(final listener in _notifiers[key]!) {
        listener();
      }
    }
  }

  Future<bool> getReplaceTextSymbolsWithEmoji() async {
    return (await _storage.getBool(SettingsKeys.replaceTextEmoji.name)) ?? defaultValues[SettingsKeys.replaceTextEmoji] as bool;
  }

  Future<void> setReplaceTextSymbolsWithEmoji(bool value) async {
    final result = _storage.setBool(SettingsKeys.replaceTextEmoji.name, value);
    await result;
    notify(SettingsKeys.replaceTextEmoji);
    return result;
  }

  Future<bool> getLaunchAtStartup() async {
    return (await _storage.getBool(SettingsKeys.autostartup.name)) ?? defaultValues[SettingsKeys.autostartup] as bool;
  }

  Future<void> setLaunchAtStartup(bool value) async {
    final result = _storage.setBool(SettingsKeys.autostartup.name, value);
    await result;
    notify(SettingsKeys.autostartup);
    return result;
  }

  Future<bool> getExitToTray() async {
    return (await _storage.getBool(SettingsKeys.exitToTray.name)) ?? defaultValues[SettingsKeys.exitToTray] as bool;
  }

  Future<void> setExitToTray(bool value) async {
    final result = _storage.setBool(SettingsKeys.exitToTray.name, value);
    await result;
    notify(SettingsKeys.exitToTray);
    return result;
  }

  Future<String> getTheme() async {
    return (await _storage.getString(SettingsKeys.theme.name)) ?? defaultValues[SettingsKeys.theme] as String;
  }

  Future<void> setTheme(String value) async {
    final result = _storage.setString(SettingsKeys.theme.name, value);
    await result;
    notify(SettingsKeys.theme);
    return result;
  }

  Future<String> getLanguage() async {
    return (await _storage.getString(SettingsKeys.locale.name)) ?? defaultValues[SettingsKeys.locale] as String;
  }

  Future<void> setLanguage(String value) async {
    final result = _storage.setString(SettingsKeys.locale.name, value);
    await result;
    notify(SettingsKeys.locale);
    return result;
  }

  // Audio

  Future<String> getMicrophonePreferredDevice() async {
    return (await _storage.getString(SettingsKeys.microphonePreferredDevice.name)) ?? defaultValues[SettingsKeys.microphonePreferredDevice] as String;
  }

  Future<void> setMicrophonePreferredDevice(String value) async {
    final result = _storage.setString(SettingsKeys.microphonePreferredDevice.name, value);
    await result;
    notify(SettingsKeys.microphonePreferredDevice);
    return result;
  }

  Future<String> getSpeakerPreferredDevice() async {
    return (await _storage.getString(SettingsKeys.speakerPreferredDevice.name)) ?? defaultValues[SettingsKeys.speakerPreferredDevice] as String;
  }

  Future<void> setSpeakerPreferredDevice(String value) async {
    final result = _storage.setString(SettingsKeys.speakerPreferredDevice.name, value);
    await result;
    notify(SettingsKeys.speakerPreferredDevice);
    return result;
  }

  Future<String> getCameraPreferredDevice() async {
    return (await _storage.getString(SettingsKeys.cameraPreferredDevice.name)) ?? defaultValues[SettingsKeys.cameraPreferredDevice] as String;
  }

  Future<void> setCameraPreferredDevice(String value) async {
    final result = _storage.setString(SettingsKeys.cameraPreferredDevice.name, value);
    await result;
    notify(SettingsKeys.cameraPreferredDevice);
    return result;
  }

  Future<double> getMasterVolume() async {
    return (await _storage.getDouble(SettingsKeys.masterVolume.name)) ?? defaultValues[SettingsKeys.masterVolume] as double;
  }

  Future<void> setMasterVolume(double value) async {
    final result = _storage.setDouble(SettingsKeys.masterVolume.name, value);
    await result;
    notify(SettingsKeys.masterVolume);
    return result;
  }

  // Notification settings

  Future<bool> getPlaySoundOnIncomingMessage() async {
    return (await _storage.getBool(SettingsKeys.playSoundOnIncomingMessage.name)) ?? defaultValues[SettingsKeys.playSoundOnIncomingMessage] as bool;
  }

  Future<void> setPlaySoundOnIncomingMessage(bool value) async {
    final result = _storage.setBool(SettingsKeys.playSoundOnIncomingMessage.name, value);
    await result;
    notify(SettingsKeys.playSoundOnIncomingMessage);
    return result;
  }

  Future<bool> getPlaySoundOnOutgoingMessage() async {
    return (await _storage.getBool(SettingsKeys.playSoundOnOutgoingMessage.name)) ?? defaultValues[SettingsKeys.playSoundOnOutgoingMessage] as bool;
  }

  Future<void> setPlaySoundOnOutgoingMessage(bool value) async {
    final result = _storage.setBool(SettingsKeys.playSoundOnOutgoingMessage.name, value);
    await result;
    notify(SettingsKeys.playSoundOnOutgoingMessage);
    return result;
  }

  Future<bool> getPlaySoundOnMention() async {
    return (await _storage.getBool(SettingsKeys.playSoundOnMention.name)) ?? defaultValues[SettingsKeys.playSoundOnMention] as bool;
  }

  Future<void> setPlaySoundOnMention(bool value) async {
    final result = _storage.setBool(SettingsKeys.playSoundOnMention.name, value);
    await result;
    notify(SettingsKeys.playSoundOnMention);
    return result;
  }

  Future<bool> getPlaySoundOnError() async {
    return (await _storage.getBool(SettingsKeys.playSoundOnError.name)) ?? defaultValues[SettingsKeys.playSoundOnError] as bool;
  }

  Future<void> setPlaySoundOnError(bool value) async {
    final result = _storage.setBool(SettingsKeys.playSoundOnError.name, value);
    await result;
    notify(SettingsKeys.playSoundOnError);
    return result;
  }

  Future<bool> getShowDesktopNotifications() async {
    return (await _storage.getBool(SettingsKeys.showDesktopNotifications.name)) ?? defaultValues[SettingsKeys.showDesktopNotifications] as bool;
  }

  Future<void> setShowDesktopNotifications(bool value) async {
    final result = _storage.setBool(SettingsKeys.showDesktopNotifications.name, value);
    await result;
    notify(SettingsKeys.showDesktopNotifications);
    return result;
  }

  // Behaviour settings
  Future<bool> getSendMessageOnEnter() async {
    return (await _storage.getBool(SettingsKeys.sendMessageOnEnter.name)) ?? defaultValues[SettingsKeys.sendMessageOnEnter] as bool;
  }

  Future<void> setSendMessageOnEnter(bool value) async {
    final result = _storage.setBool(SettingsKeys.sendMessageOnEnter.name, value);
    await result;
    notify(SettingsKeys.sendMessageOnEnter);
    return result;
  }

  Future<String> getMessageDateFormat() async {
    return (await _storage.getString(SettingsKeys.messageDateFormat.name)) ?? defaultValues[SettingsKeys.messageDateFormat] as String;
  }

  Future<void> setMessageDateFormat(String value) async {
    final result = _storage.setString(SettingsKeys.messageDateFormat.name, value);
    await result;
    notify(SettingsKeys.messageDateFormat);
    return result;
  }
}

class CachedPreference<TGet> extends ChangeNotifier {
  final Future<TGet> Function() get;
  CachedPreference({required SettingsKeys settingKey, required this.get}) {
    SettingsPreferencesProvider().addPropertyListener(settingKey, notifyListeners);
    notifyListeners();
  }

  TGet? _value;
  TGet? get value => _value;

  @override
  void dispose() {
    SettingsPreferencesProvider().removePropertyListener(SettingsKeys.replaceTextEmoji, notifyListeners);
    super.dispose();
  }

  @override
  void notifyListeners() {
    get().then((value) {
      _value = value;
      super.notifyListeners();
    });
  }
}

class SettingsTabController extends TabController {
  String _tab;
  String? _item;
  final List<SettingMetadata> categories;

  SettingsTabController({String tab = 'server', String? item, required this.categories, required super.vsync}) : _tab = tab, _item = item, super(length: categories.length) {
    print('SettingsTabController: tab=$_tab, item=$_item');
  }

  String get tab => _tab;
  String? get item => _item;

  void setCurrent({required String tab, String? item}) {
    _tab = tab;
    _item = item;
    index = categories.indexWhere((element) => element.tab == tab);
    print('SettingsTabController: setCurrent tab=$tab, item=$item, index=$index');
    notifyListeners();
  }

  void reset() {
    _tab = "servers";
    _item = null;
    notifyListeners();
  }
}