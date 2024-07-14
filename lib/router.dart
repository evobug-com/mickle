import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/screens/splash_screen.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/utils.dart';
import 'core/notifiers/current_client_provider.dart';
import 'globals.dart' as globals;
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/updater_screen.dart';

final _logger = Logger('Router');

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  final authService = AuthService();

  if(!authService.isDone) {
    _logger.fine("Redirecting to splash screen");
    return '/splash';
  }

  if(const String.fromEnvironment("UPDATER").isNotEmpty) {
    _logger.fine("Redirecting to updater screen");
    globals.isUpdater = true;
    updateWindowStyle();
    return '/updater';
  }

  final client = CurrentClientProvider.of(context, listen: false);
  if(client.selectedClient == null) {
    _logger.fine("Redirecting to login screen");
    return '/login';
  }

  _logger.fine("Redirecting to ${state.fullPath}");
  return null;
}

/// The route configuration.
final GoRouter router = GoRouter(
    observers: [
      BotToastNavigatorObserver(),
    ],
    routes: <RouteBase>[
      GoRoute(
        name: 'splash',
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        name: 'chat',
        path: '/chat',
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const ChatScreen()),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        name: 'updater',
        path: '/updater',
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const UpdaterScreen()),
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: SettingsScreen(
          tab: state.uri.queryParameters['tab'],
          item: state.uri.queryParameters['item'],
        )),
      )
    ],
    initialLocation: '/splash',
    redirect: _redirect,
);