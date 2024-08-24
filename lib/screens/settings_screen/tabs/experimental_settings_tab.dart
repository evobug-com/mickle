

import 'package:flutter/material.dart';

import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class ExperimentalSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const ExperimentalSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<ExperimentalSettingsTab> createState() => _ExperimentalSettingsTabState();
}

class _ExperimentalSettingsTabState extends State<ExperimentalSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'experimental').title),
        const Text('Settings that are experimental and may not work as expected. They may not be available in the final version.', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Replace text-emoji with emoji such as :D to 😃 and :P to 😛, etc.
        Highlightable(
          highlight: widget.item == 'experimental-text-emoji',
          child: SwitchListTile(
            title: const Text('Text Emoji'),
            subtitle: const Text('Replace text-emoji with emoji, such as \':D\' or \':grinning_face:\' to 😃 and \':P\' to 😛, etc.'),
            value: SettingsProvider().replaceTextEmoji,
            onChanged: (value) {
              // Save text-emoji to settings
              SettingsProvider().replaceTextEmoji = value;
            },
          ),
        ),
      ],
    );
  }
}