import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';

import '../components/console/widgets/console_widget.dart';
import '../components/server_list/widgets/server_list_widget.dart';
import '../core/version.dart';
import '../ui/window_caption.dart';

class MyScaffold extends StatefulWidget {
  final Widget body;
  final bool showSidebar;

  const MyScaffold({super.key, required this.body, this.showSidebar = true});

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
          create: (context) => ConnectionProvider(selectedServerProvider.connection),
          update: (context, selectedServerProvider, connectionProvider) {
            if(connectionProvider == null) return ConnectionProvider(selectedServerProvider.connection!);
            connectionProvider.update(selectedServerProvider.connection);
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
                if(widget.showSidebar) ServerListWidget(showAddServerButton: !isLoginScreen, showMainServersOnly: isLoginScreen),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      widget.body,
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