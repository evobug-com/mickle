
import 'package:flutter/material.dart';

import '../../../core/managers/audio_manager.dart';
import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class AudioSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const AudioSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<AudioSettingsTab> createState() => _AudioSettingsTabState();
}

class _AudioSettingsTabState extends State<AudioSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'audio').title),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input settings
                  const Text('Input', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Microphone device
                  Highlightable(highlight: widget.item == 'audio-microphone', child:
                  FutureBuilder(
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

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Microphone'),
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
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Output settings
                  const Text('Output', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Speaker device
                  Highlightable(
                    highlight: widget.item == 'audio-speaker',
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

                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Speaker'),
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
                  )
                ],
              ),
            ),
          ],
        ),

      ],
    );
  }
}