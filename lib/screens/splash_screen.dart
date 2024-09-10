import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/layout/my_scaffold.dart';

import '../areas/connection/connection_manager.dart';
import '../areas/connection/connection_status.dart';
import '../core/storage/preferences.dart';
import '../core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _logger = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToAllServers();
    });
  }

  Future<void> _connectToAllServers() async {
    final servers = await SecureStorage().readJSONArray("endpoints") ?? [];
    _logger.info('Connecting to ${servers.length} endpoints');

    final connectionManager = ConnectionManager();
    await Future.wait(servers.map((server) => _connectToServer(connectionManager, server)));

    _navigateBasedOnConnections(connectionManager);
  }

  Future<void> _connectToServer(ConnectionManager connectionManager, String server) async {
    final connectionUrl = await SecureStorage().read("$server.connectionUrl");
    if (connectionUrl == null) return;

    final connection = await connectionManager.connect(connectionUrl, disconnectOnError: true);
    if (connection.error != null) return;

    final token = await SecureStorage().read("$server.token");
    await connection.authenticate(token: token);
    if(connection.error != null) {
      connection.isReconnectEnabled = false;
      await connection.disconnect();
    }
  }

  void _navigateBasedOnConnections(ConnectionManager connectionManager) {
    if (!mounted) return;

    final lastOpenedServer = Preferences.getLastVisitedServerId();
    final connection = connectionManager.connections.firstWhereOrNull(
            (connection) => connection.mainServerId == lastOpenedServer && _isConnectedOrAuthenticated(connection)
    ) ?? connectionManager.connections.firstWhereOrNull(
            (connection) => _isConnectedOrAuthenticated(connection)
    );

    if (connection != null) {
      Provider.of<SelectedServerProvider>(context, listen: false).selectServer(connection);
      GoRouter.of(context).goNamed('chat');
    } else {
      GoRouter.of(context).goNamed('login');
    }
  }


  bool _isConnectedOrAuthenticated(dynamic connection) {
    return connection.status.value == ConnectionStatus.connected ||
        connection.status.value == ConnectionStatus.authenticating ||
        connection.status.value == ConnectionStatus.authenticated;
  }

  @override
  Widget build(BuildContext context) {
    return const MyScaffold(body: Center(child: CircularProgressIndicator()));
  }
}