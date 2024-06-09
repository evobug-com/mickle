import 'dart:ui';

import 'package:window_manager/window_manager.dart';

import '../globals.dart' as globals;
import 'core/version.dart';

void updateWindowStyle() async {
  if(globals.isUpdater) {
    windowManager.setMinimumSize(const Size(500, 500));
    windowManager.setSize(const Size(500, 500));
    windowManager.setTitle('Talk Updater [$version]');
  } else {
    windowManager.setMinimumSize(const Size(1280, 720));
    windowManager.setSize(const Size(1280, 720));
    windowManager.setTitle('TALK [$version]');
  }
  await windowManager.focus();
}