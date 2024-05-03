// ignore_for_file: sized_box_for_whitespace

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'package:talk/screens/home_screen.dart';
import 'package:talk/screens/login_screen.dart';
import 'package:talk/ui/lost_connection_bar.dart';

import 'core/debug/console.dart';
import 'core/notifiers/theme_controller.dart';
import 'core/storage/storage.dart';

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeController(theme: theme),
      child: const MyApp()
    )
  );
}

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  final session = CurrentSession();
  if(session.connection == null) {
    return '/login';
  }
  return null;
}

class MyScaffold extends StatelessWidget {
  final Widget body;

  const MyScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeController.scheme(context).surfaceContainer,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            body,
            const LostConnectionBarWidget(),
            const Console(),
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
  ],
  redirect: _redirect
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TALK 2024 Demo',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeController.of(context).currentTheme,
    );
  }
}