
import 'package:flutter/material.dart';

import '../../../core/version.dart';
import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class AboutSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  
  const AboutSettingsTab({super.key, required this.settingsTabController});

  @override
  State<AboutSettingsTab> createState() => _AboutSettingsTabState();
}

class _AboutSettingsTabState extends State<AboutSettingsTab> {

  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'about');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       SettingTitle(category: category),

        Expanded(
          child: ListView(
            children: [
              buildSettingsSection(
                context,
                'App Information',
                [
                  _buildVersion(category.items),
                  _buildDeveloper(category.items),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersion(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['about-version']!.key,
      child: const ListTile(
        title: Text('Version'),
        subtitle: SelectableText(version),
      ),
    );
  }

  Widget _buildDeveloper(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['about-developer']!.key,
      child: const ListTile(
        title: Text('Developer'),
        subtitle: SelectableText('evobug.com'),
      ),
    );
  }
}