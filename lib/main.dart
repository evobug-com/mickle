import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:talk/components/channel_list/core/models/channel_list_selected_room.dart';
import 'package:talk/components/voice_room/core/models/voice_room_current.dart';
import 'package:talk/core/managers/audio_manager.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart' hide WindowCaption, kWindowCaptionHeight;

import 'areas/security/security_provider.dart';
import 'components/console/widgets/console_errors_tab.dart';
import 'core/autoupdater/autoupdater.dart';
import 'core/autoupdater/version.dart';
import 'core/notifiers/theme_controller.dart';
import 'core/providers/global/update_provider.dart';
import 'core/storage/storage.dart';
import 'core/version.dart';
import 'layout/app_widget.dart';

final _logger = Logger('Main');

Future<void> main() async {
  // Configure logging
  _configureLogging();

  // Ensure necessary initializations
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  AudioManager.ensureInitialized();

  // Check for updates
  final updateInfo = await _checkForUpdates();

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
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize the system tray
  await _initSystemTray();

  // Initialize Notifications
  await _initializeLocalNotifier();

  // Initialize storage and load settings
  await _initializeStorage();

  // Handle Flutter errors
  _configureErrorHandling();

  // Initialize lunch at startup
  launchAtStartup.setup(
    appName: appName,
    packageName: 'SIOCOM',
    appPath: Platform.resolvedExecutable,
  );

  final theme = await _loadThemeFromStorage();

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [

        // Deprecated below
        ChangeNotifierProvider(create: (context) => ThemeController(theme: theme), lazy: false),
        ChangeNotifierProvider(create: (context) => VoiceRoomCurrent()),
        ChangeNotifierProvider(create: (context) => ChannelListSelectedChannel()),
        ChangeNotifierProvider(create: (context) => UpdateProvider(updateInfo: updateInfo)),

        // Global providers
        ChangeNotifierProvider(create: (context) => SelectedServerProvider()),
        ChangeNotifierProvider(create: (context) => SecurityWarningsProvider()),
      ],
      child: const AppWidget(),
    ),
  );
}

_configureLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });
}

Future<UpdateInfo> _checkForUpdates() async {
  _logger.fine("Checking for updates");
  final updater = AutoUpdater();

  // Set dry run with a fake version
  final currentVersion = SemVer.fromString(version);
  // final fakeVersion = SemVer(currentVersion.major, currentVersion.minor, currentVersion.patch + 1);
  const SemVer? fakeVersion = null;

  // Enable dry run mode
  const bool isDryRun = kDebugMode; // You can change this to false to disable dry run
  updater.setDryRun(isDryRun, fakeVersion: isDryRun ? fakeVersion : null);

  return await updater.checkForUpdates();
}

_initSystemTray() async {
  _logger.fine("Initializing system tray");
  String path =
  Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

  await trayManager.setIcon(path);
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'exit_app',
        label: 'Exit',
      ),
    ],
  );
  await trayManager.setContextMenu(menu);
}

_initializeLocalNotifier() async {
  _logger.fine("Initializing local notifier");
  await localNotifier.setup(
    appName: appName,
    // The parameter shortcutPolicy only works on Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
}

_initializeStorage() async {
  _logger.fine("Initializing storage");
  await SecureStorage.init();
  await Storage.init();

  final masterVolume = Storage().read('masterVolume');
  if(masterVolume != null) {
    AudioManager().masterVolume.value = double.parse(masterVolume);
  }
}

Future<ThemeData> _loadThemeFromStorage() async {
  // Load the theme from storage
  final scheme = Storage().read('theme');
  if(scheme != null) {
    return ThemeController.themes.firstWhere((element) => element.name == scheme).value;
  }

  return ThemeController.themes.firstWhere((theme) => theme.name == "Dark").value;
}

_configureErrorHandling() {
  _logger.fine("Configuring error handling");
  FlutterError.onError = (details) {
    if(details.exception.toString().contains("HTTP request failed, statusCode: 404,")) {
      return;
    }

    // if development mode, throw details.exception
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };

  Errors.initialize();
}

