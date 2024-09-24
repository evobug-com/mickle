import 'package:flutter/material.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';
import 'package:mickle/screens/settings_screen/tabs/server_settings_tab.dart';

import 'tabs/about_settings_tab.dart';
import 'tabs/appearance_settings_tab.dart';
import 'tabs/audio_settings_tab.dart';
import 'tabs/behaviour_settings_tab.dart';
import 'tabs/experimental_settings_tab.dart';
import 'tabs/general_settings_tab.dart';
import 'tabs/notifications_settings_tab.dart';

class SettingsContent extends StatefulWidget {
  final SettingsTabController settingsTabController;
  const SettingsContent({Key? key, required this.settingsTabController}) : super(key: key);

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final children = [
      ServerSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('server'),),
      GeneralSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('general')),
      BehaviourSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('behaviour')),
      AudioSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('audio')),
      NotificationsSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('notifications')),
      AppearanceSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('appearance')),
      ExperimentalSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('experimental')),
      AboutSettingsTab(settingsTabController: widget.settingsTabController, key: const ValueKey('about')),
    ];

    // Sort by index in settingsCategories
    children.sort((a, b) {
      ValueKey aKey = a.key as ValueKey;
      ValueKey bKey = b.key as ValueKey;
      return widget.settingsTabController.categories.indexWhere((element) => element.tab == aKey.value) - widget.settingsTabController.categories.indexWhere((element) => element.tab == bKey.value);
    });

    return TabBarView(
      controller: widget.settingsTabController,
      children: children,
    );
  }
}