import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/screens/splash_screen.dart';
import 'package:talk/screens/update_screen.dart';
import 'package:talk/services/auth_service.dart';
import 'core/providers/global/update_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';

final _logger = Logger('Router');

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {

  final authService = AuthService();

  if(!authService.isDone) {
    _logger.fine("Auto-login in progress, redirecting to splash screen");
    return '/splash';
  }

  final updateProvider = UpdateProvider.of(context, listen: false);
  // Check if update is available and not skipped
  if (updateProvider.updateAvailable) {
    _logger.fine("Update available and not skipped, redirecting to update screen");
    return '/update';
  }

  final selectedServerProvider = SelectedServerProvider.of(context, listen: false);
  if(selectedServerProvider.client == null) {
    _logger.fine("No server selected, redirecting to login screen");
    return '/login';
  }

  return null;
}

/// The route configuration.
final GoRouter router = GoRouter(
    observers: [
      BotToastNavigatorObserver(),
    ],
    routes: <RouteBase>[
      GoRoute(
        name: 'update',
        path: '/update',
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const UpdateScreen()),
      ),
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