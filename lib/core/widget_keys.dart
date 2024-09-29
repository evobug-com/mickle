import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@Immutable()
class WidgetKeys {
  // First Time Screen
  static const Key firstTimeScreen = Key('firstTimeScreen');
  static const Key firstTimeScreenFreshStartButton = Key('firstTimeScreenFreshStartButton');
  static const Key firstTimeScreenImportButton = Key('firstTimeScreenImportButton');
  static const Key firstTimeScreenNextButton = Key('firstTimeScreenNextButton');
  static const Key firstTimeScreenLaunchAtStartupSwitch = Key('firstTimeScreenLaunchAtStartupSwitch');
  static const Key firstTimeScreenExitToTraySwitch = Key('firstTimeScreenExitToTraySwitch');
  static const Key firstTimeScreenLaunchMickleButton = Key('firstTimeScreenLaunchMickleButton');
  static Key firstTimeScreenThemeDynamicButton(String theme) => Key('theme_${theme}_button');

  // Login Screen
  static const Key loginScreen = Key('loginScreen');
}