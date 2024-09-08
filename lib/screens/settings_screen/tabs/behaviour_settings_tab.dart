import 'package:flutter/material.dart';

import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class BehaviourSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const BehaviourSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<BehaviourSettingsTab> createState() => _BehaviourSettingsTabState();
}

class _BehaviourSettingsTabState extends State<BehaviourSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final items = widget.settingsCategories.firstWhere((element) => element.tab == 'behaviour').items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'behaviour').title),
        const SizedBox(height: 20),

        const Text("Chat Behaviour", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Highlightable(
          highlight: widget.item == 'behaviour-send-message-on-enter',
          child: SwitchListTile(
            key: const Key('behaviour-send-message-on-enter'),
            title: const Text('Send message on Enter'),
            subtitle: const Text('When enabled, pressing Enter will send the message. When disabled, use Shift+Enter to send.'),
            value: SettingsProvider().sendMessageOnEnter,
            onChanged: (value) {
              setState(() {
                SettingsProvider().sendMessageOnEnter = value;
              });
            },
          ),
        ),
      ],
    );
  }
}