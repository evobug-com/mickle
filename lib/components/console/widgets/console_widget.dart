import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk/components/console/widgets/console_general_tab.dart';

import '../../../core/notifiers/theme_controller.dart';
import 'console_audio_tab.dart';
import 'console_database_tab.dart';
import 'console_errors_tab.dart';
import 'console_network_tab.dart';

class ConsoleWidget extends StatefulWidget {
  const ConsoleWidget({super.key});

  @override
  ConsoleWidgetState createState() => ConsoleWidgetState();
}

class ConsoleWidgetState extends State<ConsoleWidget> {
  bool _isVisible = false;

  bool _keyboardToggleConsole(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.f12 && event is KeyDownEvent) {
      setState(() {
        _isVisible = !_isVisible;
      });
      return true;
    }
    return false;
  }

  @override void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyboardToggleConsole);
  }

  @override void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardToggleConsole);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeController.scheme(context);
    final tabs = {
      "Obecné": const ConsoleGeneralTab(),
      "Chyby": const ConsoleErrorsTab(),
      "Zvuk": const ConsoleAudioTab(),
      "Síť": const ConsoleNetworkTab(),
      "Databáze": const ConsoleDatabaseTab(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: !_isVisible ? const SizedBox.shrink() : Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withOpacity(0.99)),
        child: DefaultTabController(
          length: tabs.length,
          child: Expanded(
            child: Column(
              children: [
                TabBar(
                  // The tab is at the top of the screen
                  tabs: tabs.keys.map((e) => Tab(text: e)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                      children: tabs.values.toList()
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}