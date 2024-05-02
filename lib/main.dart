// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final theme = await Storage().read('theme');
  if(theme != null) {
    ThemeController().setTheme(ThemeController().themes.firstWhere((element) => element.name == theme).theme);
  }

  final masterVolume = await Storage().read('masterVolume');
  if(masterVolume != null) {
    AudioManager().masterVolume.value = double.parse(masterVolume);
  }

  runApp(const MyApp());
}

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  final session = CurrentSession();
  if(session.connection == null) {
    return '/login';
  }
  return null;
}

// Wrapper around the app to provide different widgets
Widget _wrapApp(BuildContext context, Widget child) {
  // Overlay with Console must be topmost
  // Add connection status bar (overlay second)
  // Add the child

  return ListenableBuilder(
    listenable: ThemeController(),
    builder: (context, c) {
      return Scaffold(
        backgroundColor: ThemeController().theme.colorScheme.surface,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            child,
            const LostConnectionBarWidget(),
            const Console(),
          ],
        )
      );
    }
  );
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return _wrapApp(context, const HomeScreen());
      }
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return _wrapApp(context, const LoginScreen());
      },
    ),
  ],
  redirect: _redirect
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController(),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'TALK 2024 Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeController().theme,
          routerConfig: _router
        );
      }
    );
  }
}