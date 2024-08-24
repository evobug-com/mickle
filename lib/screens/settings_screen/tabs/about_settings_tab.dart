
import 'package:flutter/material.dart';

import '../../../core/version.dart';
import '../settings_models.dart';
import '../settings_widgets.dart';

class AboutSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const AboutSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<AboutSettingsTab> createState() => _AboutSettingsTabState();
}

class _AboutSettingsTabState extends State<AboutSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'about').title),
        const SizedBox(height: 20),

        Highlightable(
          highlight: widget.item == 'about-version',
          child: const ListTile(
            title: Text('Version'),
            subtitle: Text(version),
          ),
        )
      ],
    );
  }
}