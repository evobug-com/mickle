
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'notifications').title),
        const SizedBox(height: 20),

        const Text("Sound Notifications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Highlightable(
          highlight: widget.item == items['notifications-sound-any-message']!.key,
          child: SwitchListTile(
            key: items['notifications-sound-any-message']!.keyRef,
            title: Text(items['notifications-sound-any-message']!.name),
            subtitle: const Text('Play sound when any message is received'),
            value: SettingsProvider().playSoundOnAnyMessage,
            onChanged: (value) {
              setState(() {
                SettingsProvider().playSoundOnAnyMessage = value;
              });
            },
          ),
        ),

        Highlightable(
          highlight: widget.item == items['notifications-sound-mention']!.key,
          child: SwitchListTile(
            key: items['notifications-sound-mention']!.keyRef,
            title: Text(items['notifications-sound-mention']!.name),
            subtitle: const Text('Play sound on mentioning my username'),
            value: SettingsProvider().playSoundOnMention,
            onChanged: (value) {
              setState(() {
                SettingsProvider().playSoundOnMention = value;
              });
            },
          ),
        ),

        Highlightable(
          highlight: widget.item == items['notifications-sound-error']!.key,
          child: SwitchListTile(
            key: items['notifications-sound-error']!.keyRef,
            title: Text(items['notifications-sound-error']!.name),
            subtitle: const Text('Play sound on application error'),
            value: SettingsProvider().playSoundOnError,
            onChanged: (value) {
              setState(() {
                SettingsProvider().playSoundOnError = value;
              });
            },
          ),
        ),

        const SizedBox(height: 20),
        const Text("Visual Notifications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Highlightable(
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
        ),
      ],
    );
  }
}