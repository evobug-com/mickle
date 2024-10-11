import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:mickle/core/app_state.dart';
import 'package:mickle/core/providers/global/selected_server_provider.dart';
import 'package:mickle/layout/my_scaffold.dart';

import '../areas/connection/connection_manager.dart';
import '../areas/connection/connection_status.dart';
import '../core/storage/preferences.dart';

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
      _connectToAllEndpoints();
    });
  }

  Future<void> _connectToAllEndpoints() async {
    final endpoints = await Preferences.getEndpoints();
    _logger.info('Connecting to ${endpoints.join(', ')} endpoints');

    final connectionManager = ConnectionManager();
    await Future.wait(endpoints.map((endpoint) => _connectToEndpoint(connectionManager, endpoint)));

    await _navigateBasedOnConnections(connectionManager);
    AppState.overSplash = true;
  }

  Future<void> _connectToEndpoint(ConnectionManager connectionManager, String endpoint) async {
    final endpointData = await Preferences.getEndpoint(endpoint);
    if (endpointData == null) return;

    final connection = await connectionManager.connect(endpointData.connectionUrl, disconnectOnError: true);
    if (connection.error != null) return;

    await connection.authenticate(token: endpointData.token);
    if(connection.error != null) {
      connection.isReconnectEnabled = false;
      await connection.disconnect();
    }
  }

  Future<void> _navigateBasedOnConnections(ConnectionManager connectionManager) async {
    if (!mounted) return;

    final lastOpenedServer = await Preferences.getLastVisitedServerId();
    final connection = connectionManager.connections.firstWhereOrNull(
            (connection) => connection.mainServerId == lastOpenedServer && _isConnectedOrAuthenticated(connection)
    ) ?? connectionManager.connections.firstWhereOrNull(
            (connection) => _isConnectedOrAuthenticated(connection)
    );

    if(await Preferences.getIsFirstTime()) {
      GoRouter.of(context).goNamed('first-time');
    } else if (connection != null) {
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