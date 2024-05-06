import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

Future<void> initSystemTray() async {
  String path =
  Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

  await trayManager.setIcon(path);
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'exit_app',
        label: 'Exit',
      ),
    ],
  );
  await trayManager.setContextMenu(menu);
}