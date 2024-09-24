
import 'package:flutter/material.dart';
import 'package:mickle/ui/dropdown_llist_tile.dart';

import '../../../core/managers/audio_manager.dart';
import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class AudioSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  
  const AudioSettingsTab({super.key, required this.settingsTabController});

  @override
  State<AudioSettingsTab> createState() => _AudioSettingsTabState();
}

class _AudioSettingsTabState extends State<AudioSettingsTab> {

  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'audio');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(category: category),
        Expanded(
          child: ListView(
            children: [
              buildSettingsSection(
                  context,
                  "Input and Output",
                  [
                    _buildMicrophone(category.items),
                    _buildSpeaker(category.items),
                  ]
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicrophone(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['audio-microphone']!.key,
      child: FutureBuilder(
          future: AudioManager.getInputDevices(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            if(snapshot.hasError) {
              return FormField<String>(builder: (FormFieldState<String> state) {
                return Text('Error: ${snapshot.error}');
              }, key: const Key('audio-microphone-error'));
            }

            if(snapshot.data!.isEmpty) {
              return const Text('No microphone devices found');
            }

            final defaultMicrophone = snapshot.data!.firstWhere((element) => element.isDefault);

            return DropdownListTile(
              title: 'Microphone',
              key: const Key('audio-microphone'),
              value: SettingsProvider().microphoneDevice ?? defaultMicrophone.id,
              items: snapshot.data!.map((device) {
                return DropdownMenuItem<String>(
                  value: device.id,
                  child: Text(device.name),
                );
              }).toList(),
              onChanged: (value) {
                // Save microphone device to settings
              },
            );
          }
      ),
    );
  }

  Widget _buildSpeaker(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['audio-speaker']!.key,
      child: FutureBuilder(
          future: AudioManager.getOutputDevices(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            if(snapshot.hasError) {
              return FormField<String>(builder: (FormFieldState<String> state) {
                return Text('Error: ${snapshot.error}');
              }, key: const Key('audio-speaker-error'));
            }

            if(snapshot.data!.isEmpty) {
              return const Text('No speaker devices found');
            }

            final defaultSpeaker = snapshot.data!.firstWhere((element) => element.isDefault);

            return DropdownListTile(
              title: 'Speaker',
              key: const Key('audio-speaker'),
              value: defaultSpeaker.id,
              items: snapshot.data!.map((device) {
                return DropdownMenuItem<String>(
                  value: device.id,
                  child: Text(device.name),
                );
              }).toList(),
              onChanged: (value) {
                // Save speaker device to settings
              },
            );
          }
      ),
    );
  }
}