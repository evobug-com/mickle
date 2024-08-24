import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

import '../components/console/widgets/console_widget.dart';
import '../components/server_list/widgets/server_list_widget.dart';
import '../core/version.dart';
import '../ui/lost_connection_bar.dart';
import '../ui/window_caption.dart';

class MyScaffold extends StatefulWidget {
  final Widget body;

  const MyScaffold({super.key, required this.body});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final router = GoRouter.of(context);
    final isLoginScreen = router.routeInformationProvider.value.uri.path == '/login';

    return Consumer<SelectedServerProvider>(
      builder: (context, selectedServerProvider, child) {
        return ChangeNotifierProxyProvider<SelectedServerProvider, ConnectionProvider>(
          create: (context) => ConnectionProvider(selectedServerProvider.client!),
          update: (context, selectedServerProvider, connectionProvider) {
            if(connectionProvider == null) return ConnectionProvider(selectedServerProvider.client!);
            connectionProvider.update(selectedServerProvider.client!);
            return connectionProvider;
          },
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kWindowCaptionHeight),
              child: WindowCaption(
                title: const Text('TALK [$version]'),
                brightness: colorScheme.brightness,
              ),
            ),
            backgroundColor: colorScheme.surfaceContainerLow,
            body: Row(
              children: [
                ServerListWidget(showAddServerButton: !isLoginScreen),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      widget.body,
                      if (!kDebugMode) const LostConnectionBarWidget(),
                      const ConsoleWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}