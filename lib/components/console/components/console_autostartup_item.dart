import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

class ConsoleAutoStartupItem extends StatefulWidget {
  const ConsoleAutoStartupItem({super.key});

  @override
  ConsoleAutoStartupItemState createState() => ConsoleAutoStartupItemState();
}

class ConsoleAutoStartupItemState extends State<ConsoleAutoStartupItem> {

  bool _autoStartupEnabled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init () async {
    _autoStartupEnabled = await launchAtStartup.isEnabled();
  }

  setAutoStartup(bool value) async {
    if(value) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
    _autoStartupEnabled = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.autorenew),
      title: const Text("Spustit při startu systému"),
      trailing: Switch(
        value: _autoStartupEnabled,
        onChanged: setAutoStartup,
      ),
    );
  }
}