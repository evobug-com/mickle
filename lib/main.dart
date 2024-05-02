// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/notifiers/current_connection.dart';
import 'package:talk/core/storage/secure_storage.dart';
import 'package:talk/screens/home_screen.dart';
import 'package:talk/screens/login_screen.dart';
import 'package:talk/ui/lost_connection_bar.dart';

import 'core/connection/session_manager.dart';
import 'core/debug/console.dart';
import 'core/storage/storage.dart';
import 'core/theme.dart';

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the storage
  await SecureStorage.init();
  await Storage.init();

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

  return Scaffold(
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
    return MaterialApp.router(
      title: 'TALK 2024 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(extensions: <ThemeExtension<dynamic>>[
        const MyTheme(
          sidebarSurface: Color(0xFFE0E0E0),
        )
      ]),
      darkTheme: ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[
          const MyTheme(
            sidebarSurface: Color(0xFF303030),
          )
        ],
        listTileTheme: const ListTileThemeData(
          selectedColor: Colors.white,
          selectedTileColor: Color(0xFF424242),
        ),
      ),
      routerConfig: _router,
      themeMode: ThemeMode.dark,
    );
  }
}