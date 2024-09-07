import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:talk/generated/l10n.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/notifiers/theme_controller.dart';
import '../core/storage/storage.dart';
import '../router.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});
  @override
  State<StatefulWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with TrayListener, WindowListener {

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final botToastBuilder = BotToastInit();

    return MaterialApp.router(
      title: 'TALK',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeController.of(context).currentTheme,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) {
        child = virtualWindowFrameBuilder(context, child);
        child = botToastBuilder(context, child);
        return child;
      }
    );
  }

  @override
  void onTrayIconMouseDown() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {

  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'exit_app') {
      // do something
      windowManager.destroy();
    }
  }

  @override
  Future<void> onWindowClose() async {
    final storage = Storage();
    if(storage.readBoolean("closeToTray", defaultValue: true)) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }
}