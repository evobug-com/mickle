

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
    final items = widget.settingsCategories.firstWhere((element) => element.tab == 'experimental').items;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experimental',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text('Settings that are experimental and may not work as expected. They may not be available in the final version.', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          buildSettingsSection(
              context,
              "Chat Settings",
              [
                _buildReplaceTextEmoji(items),
              ]
          ),
        ],
      ),
    );
  }

  Widget _buildReplaceTextEmoji(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['experimental-text-emoji']!.key,
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