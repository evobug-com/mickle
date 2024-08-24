import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/core/storage/preferences.dart';

import '../core/connection/client.dart';
import '../core/managers/client_manager.dart';

class AuthService with ChangeNotifier {
  final Logger _logger = Logger('AuthService');
  static AuthService? _instance;
  bool _isLoading = false;
  bool _isDone = false;
  String? _errorMessage;

  AuthService._();

  factory AuthService() {
    _instance ??= AuthService._();
    return _instance!;
  }

  bool get isLoading => _isLoading;
  bool get isDone => _isDone;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  get currentLoggingClient => _currentLoggingClient;

  Future<bool> autoLogin(BuildContext context, {required SelectedServerProvider selectedServerProvider}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool success = await _performAutologin(selectedServerProvider: selectedServerProvider);
      _isDone = true;
      if (success) {
        _navigateToChat(context);
      }
      return success;
    } catch (e) {
      _errorMessage = 'Autologin failed: ${e.toString()}';
      _logger.severe(_errorMessage);
      if(!kReleaseMode) {
        rethrow;
      }
    } finally {
      _isLoading = false;
      _isDone = true;
      notifyListeners();
    }
    return false;
  }

  Future<Client?> login(BuildContext context, {required ClientAddress address, required String username, required String password}) async {
    _errorMessage = null;
    _isLoading = true;
    _currentLoggingClient = null;
    notifyListeners();

    try {
      final Completer<String?> completer = Completer();
      _connectToServer(completer, address.host, username: username, password: password);
      await completer.future;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _logger.severe(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _currentLoggingClient;
  }

  Future<bool> _performAutologin({required SelectedServerProvider selectedServerProvider}) async {
    final servers = await Preferences.getServerList();
    if (servers.isEmpty) {
      _logger.fine("No servers to autologin to.");
      return false;
    }

    _logger.fine("Attempting to autologin to servers: $servers");
    final List<Completer<String?>> futures = [];

    for (var server in servers) {
      if (server == null || server.toString().isEmpty) {
        continue;
      }

      await _attemptServerLogin(server, futures);
    }

    return await _handleLoginResults(futures, selectedServerProvider: selectedServerProvider);
  }

  Future<void> _attemptServerLogin(dynamic server, List<Completer<String?>> futures) async {

    if (server['host'] == null || server['token'] == null) {
      return;
    }

    _logger.fine("Connecting to server $server");
    final completer = Completer<String?>();

    _connectToServer(completer, server['host'], token: server['token']);
    futures.add(completer);
  }

  Client? _currentLoggingClient;
  void _connectToServer(Completer<String?>? completer, String host,
      {String? token, String? username, String? password}) async {
    final client = Client(
      address: ClientAddress(host: host, port: 55000),
      onError: (error) {
        completer?.completeError(error);
      },
    );
    _currentLoggingClient = client;

    try {
      await client.connect();
      final loginResult = await client.login(token: token, username: username, password: password);

      if (loginResult.error != null) {
        throw loginResult.error!;
      }

      await Preferences.addServer(serverId: loginResult.serverId!, host: host, token: loginResult.token!, userId: loginResult.userId!, port: 55000);
      ClientManager().addClient(client);
      completer?.complete(null);
    } catch (e, stacktrace) {
      completer?.completeError(e, stacktrace);
      ClientManager().onConnectionLost(client);
    }
  }

  Future<bool> _handleLoginResults(List<Completer<String?>> futures,
      {required SelectedServerProvider selectedServerProvider}) async {
    final List<String?> results = await Future.wait(futures.map((e) => e.future));
    _logger.fine("Connection results: $results");

    if (results.any((element) => element == null)) {
      final successClient = ClientManager().clients.firstWhereOrNull(
            (client) => client.connection.state == ClientConnectionState.connected && client.userId != null,
      );

      if (successClient != null) {
        // Check for last logged server
        final lastVisitedServerId = Preferences.getLastVisitedServerId();

        // Check if the last visited server is still connected
        final lastVisitedServer = ClientManager().clients.firstWhereOrNull(
              (client) => client.serverId == lastVisitedServerId,
        );

        if (lastVisitedServer != null) {
          _logger.fine("Selecting last visited server: $lastVisitedServer");
          selectedServerProvider.selectServer(lastVisitedServer);
          return true;
        }

        // Server is not available, select the first available server
        _logger.fine("Selecting first available server: $successClient");
        selectedServerProvider.selectServer(successClient);
        return true;
      } else {
        _logger.warning("Autologin failed, no client connected.");
      }
    }
    return false;
  }

  void _navigateToChat(BuildContext context) {
    context.goNamed('chat');
  }

  abortLogin() {
    _currentLoggingClient?.disconnect();
    _currentLoggingClient = null;
  }
}