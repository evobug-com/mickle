import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:mickle/areas/security/security_provider.dart';
import 'package:mickle/components/channel_list/core/models/channel_list_selected_room.dart';
import 'package:mickle/components/voice_room/core/models/voice_room_current.dart';
import 'package:mickle/core/autoupdater/autoupdater.dart';
import 'package:mickle/core/managers/audio_manager.dart';
import 'package:mickle/core/providers/global/selected_server_provider.dart';
import 'package:mickle/core/providers/global/update_provider.dart';
import 'package:mickle/core/storage/secure_storage.dart';
import 'package:mickle/core/storage/storage.dart';
import 'package:mickle/core/theme/theme_controller.dart';
import 'package:mickle/core/version.dart';
import 'package:mickle/layout/app_widget.dart';
import 'package:mickle/main.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const KEY_PREFIX = '__TEST__';

Future<void> clearAllTestKeys() async {
  final storage = Storage();

  final removeKeysSet = <String>{};

  final storageKeys = await storage.getKeys();
  for (final key in storageKeys) {
    if (key.startsWith(KEY_PREFIX)) {
      removeKeysSet.add(key);
    }
  }

  print("Removing keys: $removeKeysSet");
  await storage.clear(allowList: removeKeysSet);
  removeKeysSet.clear();

  final secureStorage = SecureStorage();
  final secureStorageKeys = await secureStorage.getKeys();
  for (final key in secureStorageKeys) {
    if (key.startsWith(KEY_PREFIX)) {
      removeKeysSet.add(key);
    }
  }

  print("Removing secure keys: $removeKeysSet");
  await secureStorage.clear(allowList: removeKeysSet);
}

Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
      Duration timeout = const Duration(seconds: 1),
    }) async {
  bool timerDone = false;
  final timer = Timer(timeout, () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();

    final found = tester.any(finder);
    if (found) {
      timerDone = true;
    }
  }
  timer.cancel();
}

Future<MultiProvider Function()> initTestEnvironment() async {
  // Ensure necessary initializations
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app core before running tests.
  initializeStorage(prefix: KEY_PREFIX);

  await windowManager.ensureInitialized();
  AudioManager.ensureInitialized();

  // Initialize settings
  await initializeSettings();

  // Initialize window options
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: false,
    fullScreen: false,
    windowButtonVisibility: false,
  );

  // Wait until the window is ready to show
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await windowManager.setPreventClose(true);
  //   await windowManager.show();
  //   await windowManager.focus();
  });

  // Initialize lunch at startup
  launchAtStartup.setup(
    appName: appName,
    packageName: 'SIOCOM',
    appPath: Platform.resolvedExecutable,
  );

  createAppWidget() => MultiProvider(
    providers: [
      // Deprecated below
      ChangeNotifierProvider(create: (context) => ThemeController(), lazy: false),
      ChangeNotifierProvider(create: (context) => VoiceRoomCurrent()),
      ChangeNotifierProvider(create: (context) => ChannelListSelectedChannel()),
      ChangeNotifierProvider(create: (context) => UpdateProvider(updateInfo: UpdateInfo(updateAvailable: false))),

      // Global providers
      ChangeNotifierProvider(create: (context) => SelectedServerProvider()),
      ChangeNotifierProvider(create: (context) => SecurityWarningsProvider()),
    ],
    child: const AppWidget(),
  );

  // Reset testing state
  clearAllTestKeys();

  return createAppWidget;
}