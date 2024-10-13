import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mickle/areas/security/security.dart';
import 'package:mickle/core/providers/global/selected_server_provider.dart';
import 'package:mickle/core/providers/scoped/connection_provider.dart';

import '../areas/utilities/elevation.dart';
import '../components/console/widgets/console_widget.dart';
import '../components/server_list/widgets/server_list_widget.dart';
import '../core/version.dart';
import '../ui/window_caption.dart';

class MyScaffold extends StatefulWidget {
  final Widget body;
  final bool showSidebar;
  final bool showSearchBar;

  const MyScaffold({super.key, required this.body, this.showSidebar = true, this.showSearchBar = true});

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
              child: Elevation(
                offset: 1,
                child: WindowCaption(
                  showSearchBar: widget.showSearchBar,
                  title: Text(
                      'Mickle [$version]',
                    style: Theme.of(context).textTheme.titleSmall
                  ),
                  brightness: colorScheme.brightness,
                ),
              ),
            ),
            backgroundColor: colorScheme.surface,
            body: Row(
              children: [
                if(widget.showSidebar) ServerListWidget(showAddServerButton: !isLoginScreen, showMainServersOnly: isLoginScreen),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      widget.body,
                      const ConsoleWidget(),
                      const SecurityWidget(),
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