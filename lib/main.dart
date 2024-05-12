// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:provider/provider.dart';
import 'package:talk/components/console/widgets/console_widget.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'package:talk/screens/home_screen.dart';
import 'package:talk/screens/login_screen.dart';
import 'package:talk/ui/lost_connection_bar.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart' hide WindowCaption, kWindowCaptionHeight;

import 'components/console/widgets/console_errors_tab.dart';
import 'core/notifiers/theme_controller.dart';
import 'core/storage/storage.dart';
import 'core/tray.dart';
import 'core/version.dart';
import 'screens/updater_screen.dart';
import 'ui/window_caption.dart';
import 'globals.dart' as globals;

void updateWindowStyle() async {
  if(globals.isUpdater) {
    windowManager.setMinimumSize(const Size(500, 500));
    windowManager.setSize(const Size(500, 500));
    windowManager.setTitle('Talk Updater [${version}]');
  } else {
    windowManager.setMinimumSize(const Size(1280, 720));
    windowManager.setSize(const Size(1280, 720));
    windowManager.setTitle('TALK [${version}]');
  }
  await windowManager.focus();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

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

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize the system tray
  await initSystemTray();

  // Initialize Notifications
  await localNotifier.setup(
    appName: appName,
    // The parameter shortcutPolicy only works on Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  // Initialize the storage
  await SecureStorage.init();
  await Storage.init();

  // Load the theme from storage
  final scheme = await Storage().read('theme');
  ThemeData? theme;
  if(scheme != null) {
    theme = ThemeController.themes.firstWhere((element) => element.name == scheme).value;
  }

  final masterVolume = await Storage().read('masterVolume');
  if(masterVolume != null) {
    AudioManager().masterVolume.value = double.parse(masterVolume);
  }

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

  launchAtStartup.setup(
    appName: appName,
    appPath: Platform.resolvedExecutable,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeController(theme: theme)),
      ],
      child: const AppWidget(),
    ),
  );
}

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  if(const String.fromEnvironment("UPDATER").isNotEmpty) {
    globals.isUpdater = true;
    updateWindowStyle();
    return '/updater';
  }

  final session = CurrentSession();
  if(session.connection == null) {
    return '/login';
  }
  return null;
}

class UpdaterScaffold extends StatelessWidget {
  final Widget body;
  const UpdaterScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kWindowCaptionHeight),
          child: WindowCaption(
            title: const Text('Talk Updater [${version}]'),
            disableExit: true,
            brightness: Theme
                .of(context)
                .brightness,
          ),
        ),
        backgroundColor: ThemeController
            .scheme(context)
            .surfaceContainer,
        body: body
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget body;

  const MyScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
        child: WindowCaption(
          title: const Text('TALK [${version}]'),
          brightness: Theme.of(context).brightness,
        ),
      ),
        backgroundColor: ThemeController.scheme(context).surfaceContainer,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            body,
            const LostConnectionBarWidget(),
            const ConsoleWidget(),
          ],
        )
    );
  }

}


/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      name: 'home',
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (ctx, state) => const LoginScreen(),
    ),
    GoRoute(
      name: 'updater',
      path: '/updater',
      builder: (ctx, state) => const UpdaterScreen(),
    )
  ],
  redirect: _redirect
);

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});
  @override
  State<StatefulWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with TrayListener, WindowListener {

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    super.initState();
    _init();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final botToastBuilder = BotToastInit();

    return MaterialApp.router(
      title: 'TALK 2024 Demo',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeController.of(context).currentTheme,
      builder: (context, child) {
        child = virtualWindowFrameBuilder(context, child);
        child = botToastBuilder(context, child);
        return child;
      },
    );
  }

  @override
  void onTrayIconMouseDown() {

  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {

  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'exit_app') {
      // do something
      windowManager.close();
    }
  }
}