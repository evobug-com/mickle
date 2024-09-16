
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
        Text(
          'About',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),

        buildSettingsSection(
          context,
          'App Information',
          [
            _buildVersion(),
            _buildDeveloper(),
          ],
        ),
      ],
    );
  }

  Widget _buildVersion() {
    return Highlightable(
      highlight: widget.item == 'about-version',
      child: const ListTile(
        title: Text('Version'),
        subtitle: SelectableText(version),
      ),
    );
  }

  Widget _buildDeveloper() {
    return Highlightable(
      highlight: widget.item == 'about-developer',
      child: const ListTile(
        title: Text('Developer'),
        subtitle: SelectableText('evobug.com'),
      ),
    );
  }
}