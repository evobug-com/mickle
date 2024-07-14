
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../components/console/widgets/console_widget.dart';
import '../components/server_list/widgets/server_list_widget.dart';
import '../core/notifiers/theme_controller.dart';
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
    final colorScheme = ThemeController.scheme(context);

    return Scaffold(
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
          const ServerListWidget(),

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
    );
  }
}