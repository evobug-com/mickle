import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/connection/client_manager.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart' hide WindowCaption, kWindowCaptionHeight;

import 'components/console/widgets/console_errors_tab.dart';
import 'core/notifiers/current_client_provider.dart';
import 'core/notifiers/theme_controller.dart';
import 'core/storage/storage.dart';
import 'core/version.dart';
import 'layout/app_widget.dart';
import 'utils.dart';

final _logger = Logger('Main');

Future<void> main() async {
  // Configure logging
  _configureLogging();

  // Ensure necessary initializations
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  AudioManager.ensureInitialized();

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

  updateWindowStyle();

  // Wait until the window is ready to show
  windowManager.waitUntilReadyToShow(windowOptions, () async {
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
    appPath: Platform.resolvedExecutable,
  );

  final theme = await _loadThemeFromStorage();

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeController(theme: theme), lazy: false),
        ChangeNotifierProvider(create: (context) => ClientManager(), lazy: false),
        ChangeNotifierProvider(create: (context) => CurrentClientProvider(), lazy: false),
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

  final masterVolume = await Storage().read('masterVolume');
  if(masterVolume != null) {
    AudioManager().masterVolume.value = double.parse(masterVolume);
  }
}

Future<ThemeData> _loadThemeFromStorage() async {
  // Load the theme from storage
  final scheme = await Storage().read('theme');
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

// _autologin() async {
//   List<dynamic> servers = await SecureStorage().readJSONArray("servers");
//   if(servers.isEmpty) {
//     _logger.fine("No servers to autologin");
//     return;
//   }
//
//   _logger.fine("Autologin to servers: $servers");
//   final futures = <Completer<String?>>[];
//
//   for (var server in servers) {
//
//     if(server == null || server.toString().isEmpty) {
//       continue;
//     }
//
//     final [host, token] = await Future.wait([
//       SecureStorage().read("$server.host"),
//       SecureStorage().read("$server.token"),
//     ], eagerError: true);
//
//     if(host == null || token == null) {
//       continue;
//     }
//
//     _logger.fine("Connecting to server $server");
//     final completer = Completer<String?>();
//
//     ((Completer<String?> completer) async {
//       final client = Client(
//           address: ClientAddress(
//               host: host,
//               port: 55000
//           ),
//           onError: (error) {
//             completer.completeError(error);
//           }
//       );
//
//       SecureStorage storage = SecureStorage();
//
//       try {
//         // Throws an error if connection fails
//         await client.connect();
//
//         final loginResult = await client.login(token: token);
//
//         // Throws an error if login fails
//         if(loginResult.error != null) {
//           throw loginResult.error!;
//         }
//
//         await storage.write("${loginResult.serverId}.token", loginResult.token!);
//         await storage.write("${loginResult.serverId}.userId", loginResult.userId!);
//         await storage.write("${loginResult.serverId}.host", client.address.host);
//         await storage.write("${loginResult.serverId}.port", client.address.port.toString());
//
//         ClientManager().addClient(client);
//         completer.complete(null);
//       } catch (e, stacktrace) {
//         completer.completeError(e, stacktrace);
//         ClientManager().onConnectionLost(client);
//       }
//     })(completer);
//     futures.add(completer);
//   }
//
//   // Wait for all connections to be established
//   List<String?> results = await Future.wait(futures.map((e) => e.future));
//   _logger.fine("Connection results: $results");
//   if(results.any((element) => element == null)) {
//     final successClient = ClientManager().clients.firstWhereOrNull((element) => element.connection.state == ClientConnectionState.connected && element.userId != null);
//     if(successClient != null) {
//       CurrentClientProvider().selectClient(successClient);
//     } else {
//       _logger.warning("No client was successfully connected.");
//     }
//   }
// }

// // RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
// // Isolate.spawn((rootIsolateToken) async {
// //   BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
// //
//   AudioManager.setAudioDataHandler((deviceId, data) {
//     print('AudioData: $deviceId, $data');
//   });
//   final deviceId = (await AudioManager.getInputDevices()).firstWhere((item) => item.isDefault).id;
//   print('Default Device: $deviceId');
//   dynamic result = await AudioManager.startCaptureStream(deviceId);
//   print('StartCaptureStream: $result');
// // }, rootIsolateToken);