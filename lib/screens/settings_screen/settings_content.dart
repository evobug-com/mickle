
import 'package:flutter/material.dart';
import 'package:talk/screens/settings_screen/tabs/server_settings_tab.dart';

import 'settings_models.dart';
import 'tabs/about_settings_tab.dart';
import 'tabs/appearance_settings_tab.dart';
import 'tabs/audio_settings_tab.dart';
import 'tabs/behaviour_settings_tab.dart';
import 'tabs/experimental_settings_tab.dart';
import 'tabs/general_settings_tab.dart';
import 'tabs/notifications_settings_tab.dart';

class SettingsContent extends StatelessWidget {
  final String? tab;
  final String? item;

  const SettingsContent({super.key, this.tab, this.item});

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case 'server':
        return ServerSettingsTab(item: item, settingsCategories: settingsCategories);
      case 'general':
        return GeneralSettingsTab(item: item, settingsCategories: settingsCategories,);
      case 'behaviour':
        return BehaviourSettingsTab(item: item, settingsCategories: settingsCategories,);
      case 'audio':
        return AudioSettingsTab(item: item, settingsCategories: settingsCategories);
      case 'notifications':
        return NotificationsSettingsTab(item: item, settingsCategories: settingsCategories);
      case 'appearance':
        return AppearanceSettingsTab(item: item, settingsCategories: settingsCategories);
      case 'experimental':
        return ExperimentalSettingsTab(item: item, settingsCategories: settingsCategories);
      case 'about':
        return AboutSettingsTab(item: item, settingsCategories: settingsCategories);
      default:
        return GeneralSettingsTab(item: item, settingsCategories: settingsCategories);
    }
  }
}