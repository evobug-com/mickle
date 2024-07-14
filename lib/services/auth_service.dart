import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../core/connection/client.dart';
import '../core/managers/client_manager.dart';
import '../core/network/response.dart';
import '../core/notifiers/current_client_provider.dart';
import '../core/storage/secure_storage.dart';

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

  Future<bool> autoLogin(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool success = await _performAutologin();
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
      final result = await completer.future;
      if (result == null || result.isEmpty) {
        _navigateToChat(context);
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _logger.severe(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _currentLoggingClient;
  }

  Future<bool> _performAutologin() async {
    final List<dynamic> servers = await SecureStorage().readJSONArray("servers");
    if (servers.isEmpty) {
      _logger.fine("No servers to autologin");
      return false;
    }

    _logger.fine("Autologin to servers: $servers");

    final List<Completer<String?>> futures = [];

    for (var server in servers) {
      if (server == null || server.toString().isEmpty) {
        continue;
      }

      await _attemptServerLogin(server, futures);
    }

    return await _handleLoginResults(futures);
  }

  Future<void> _attemptServerLogin(dynamic server, List<Completer<String?>> futures) async {
    final String? host = await SecureStorage().read("$server.host");
    final String? token = await SecureStorage().read("$server.token");

    if (host == null || token == null) {
      return;
    }

    _logger.fine("Connecting to server $server");
    final completer = Completer<String?>();

    _connectToServer(completer, host, token: token);
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

      await _storeLoginData(loginResult, client);
      ClientManager().addClient(client);
      completer?.complete(null);
    } catch (e, stacktrace) {
      completer?.completeError(e, stacktrace);
      ClientManager().onConnectionLost(client);
    }
  }

  Future<void> _storeLoginData(Login loginResult, Client client) async {
    final SecureStorage storage = SecureStorage();
    await storage.write("${loginResult.serverId}.token", loginResult.token!);
    await storage.write("${loginResult.serverId}.userId", loginResult.userId!);
    await storage.write("${loginResult.serverId}.host", client.address.host);
    await storage.write("${loginResult.serverId}.port", client.address.port.toString());
  }

  Future<bool> _handleLoginResults(List<Completer<String?>> futures) async {
    final List<String?> results = await Future.wait(futures.map((e) => e.future));
    _logger.fine("Connection results: $results");

    if (results.any((element) => element == null)) {
      final successClient = ClientManager().clients.firstWhereOrNull(
            (client) => client.connection.state == ClientConnectionState.connected && client.userId != null,
      );

      if (successClient != null) {
        CurrentClientProvider().selectClient(successClient);
        return true;
      } else {
        _logger.warning("No client was successfully connected.");
      }
    }
    return false;
  }

  void _navigateToChat(BuildContext context) {
    context.go('/chat');
  }

  abortLogin() {
    _currentLoggingClient?.disconnect();
    _currentLoggingClient = null;
  }
}