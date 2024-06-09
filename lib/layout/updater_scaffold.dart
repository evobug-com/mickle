import 'package:flutter/material.dart';

import '../core/notifiers/theme_controller.dart';
import '../core/version.dart';
import '../ui/window_caption.dart';

class UpdaterScaffold extends StatelessWidget {
  final Widget body;
  const UpdaterScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kWindowCaptionHeight),
          child: WindowCaption(
            title: const Text('Talk Updater [$version]'),
            disableExit: true,
            brightness: Theme
                .of(context)
                .brightness,
          ),
        ),
        backgroundColor: ThemeController
            .scheme(context)
            .surfaceContainer,
        body: body
    );
  }
}
