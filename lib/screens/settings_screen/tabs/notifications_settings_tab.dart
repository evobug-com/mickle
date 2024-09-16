
import 'package:flutter/material.dart';

import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class NotificationsSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  
  const NotificationsSettingsTab({super.key, required this.settingsTabController});

  @override
  State<NotificationsSettingsTab> createState() => _NotificationsSettingsTabState();
}

class _NotificationsSettingsTabState extends State<NotificationsSettingsTab> {

  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'notifications');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(category: category),
        Expanded(
            child: ListView(
              children: [
                buildSettingsSection(
                    context,
                    "Sound Notifications",
                    [
                      _buildSoundAnyMessage(category.items),
                      _buildSoundMention(category.items),
                      _buildSoundError(category.items),
                    ]
                ),
                buildSettingsSection(
                  context,
                  'Visual Notifications',
                  [
                    _buildDesktopNotifications(category.items),
                  ],
                ),
              ],
            )
        )

      ],
    );
  }

  Widget _buildSoundAnyMessage(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['notifications-sound-any-message']!.key,
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
      highlight: widget.settingsTabController.item == items['notifications-sound-mention']!.key,
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
      highlight: widget.settingsTabController.item == items['notifications-sound-error']!.key,
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
      highlight: widget.settingsTabController.item == items['notifications-desktop']!.key,
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