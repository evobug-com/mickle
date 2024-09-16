
import 'package:flutter/material.dart';

import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class NotificationsSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const NotificationsSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<NotificationsSettingsTab> createState() => _NotificationsSettingsTabState();
}

class _NotificationsSettingsTabState extends State<NotificationsSettingsTab> {

  @override
  Widget build(BuildContext context) {
    final items = widget.settingsCategories.firstWhere((element) => element.tab == 'notifications').items;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          buildSettingsSection(
              context,
              "Sound Notifications",
              [
                _buildSoundAnyMessage(items),
                _buildSoundMention(items),
                _buildSoundError(items),
              ]
          ),
          buildSettingsSection(
            context,
            'Visual Notifications',
            [
              _buildDesktopNotifications(items),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundAnyMessage(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['notifications-sound-any-message']!.key,
      child: SwitchListTile(
        title: Text(items['notifications-sound-any-message']!.name),
        subtitle: const Text('Play sound when any message is received'),
        value: SettingsProvider().playSoundOnAnyMessage,
        onChanged: (value) {
          setState(() {
            SettingsProvider().playSoundOnAnyMessage = value;
          });
        },
      ),
    );
  }

  Widget _buildSoundMention(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['notifications-sound-mention']!.key,
      child: SwitchListTile(
        title: Text(items['notifications-sound-mention']!.name),
        subtitle: const Text('Play sound on mentioning my username'),
        value: SettingsProvider().playSoundOnMention,
        onChanged: (value) {
          setState(() {
            SettingsProvider().playSoundOnMention = value;
          });
        },
      ),
    );
  }

  Widget _buildSoundError(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['notifications-sound-error']!.key,
      child: SwitchListTile(
        title: Text(items['notifications-sound-error']!.name),
        subtitle: const Text('Play sound on application error'),
        value: SettingsProvider().playSoundOnError,
        onChanged: (value) {
          setState(() {
            SettingsProvider().playSoundOnError = value;
          });
        },
      ),
    );
  }

  Widget _buildDesktopNotifications(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['notifications-desktop']!.key,
      child: SwitchListTile(
        key: items['notifications-desktop']!.keyRef,
        title: Text(items['notifications-desktop']!.name),
        subtitle: const Text('Show desktop notifications'),
        value: SettingsProvider().showDesktopNotifications,
        onChanged: (value) {
          setState(() {
            SettingsProvider().showDesktopNotifications = value;
          });
        },
      ),
    );
  }
}