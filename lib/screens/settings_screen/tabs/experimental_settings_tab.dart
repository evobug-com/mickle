

import 'package:flutter/material.dart';

import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class ExperimentalSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  
  const ExperimentalSettingsTab({super.key, required this.settingsTabController});

  @override
  State<ExperimentalSettingsTab> createState() => _ExperimentalSettingsTabState();
}

class _ExperimentalSettingsTabState extends State<ExperimentalSettingsTab> {

  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'experimental');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(category: category, subtitle: 'Settings that are experimental and may not work as expected. They may not be available in the final version.'),
        Expanded(
            child: ListView(
              children: [
                buildSettingsSection(
                    context,
                    "Chat Settings",
                    [
                      _buildReplaceTextEmoji(category.items),
                    ]
                ),
              ],
            )
        )
      ],
    );
  }

  Widget _buildReplaceTextEmoji(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['experimental-text-emoji']!.key,
      child: SwitchListTile(
        title: Text(items['experimental-text-emoji']!.name),
        subtitle: const Text('Replace text-emoji with emoji, such as \':D\' or \':grinning_face:\' to 😃 and \':P\' to 😛, etc.'),
        value: SettingsProvider().replaceTextEmoji,
        onChanged: (value) {
          // Save text-emoji to settings
          SettingsProvider().replaceTextEmoji = value;
        },
      ),
    );
  }
}