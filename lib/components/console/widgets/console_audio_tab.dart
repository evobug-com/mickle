import 'package:flutter/material.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';

import '../../../core/managers/audio_manager.dart';
import '../../../core/storage/storage.dart';

class ConsoleAudioTab extends StatefulWidget {
  const ConsoleAudioTab({super.key});

  @override
  ConsoleAudioTabState createState() => ConsoleAudioTabState();
}

class ConsoleAudioTabState extends State<ConsoleAudioTab> {
  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManager();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio tab with volume control, show audio devices, connected devices, each audio source
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Hlavní hlasitost"),
                  subtitle: ListenableBuilder(
                      listenable: audioManager.masterVolume,
                      builder: (context, child) {
                        return Slider(
                          value: audioManager.masterVolume.value,
                          onChanged: (value) {
                            audioManager.masterVolume.value = value;
                            SettingsPreferencesProvider().setMasterVolume(value);
                          },
                          max: 1.0,
                          min: 0.0,
                          divisions: 50,
                          label: "${(audioManager.masterVolume.value * 100).round()}%",
                        );
                      }
                  ),
                ),
                const ListTile(
                  title: Text("Hlasitost hudby"),
                  subtitle: Slider(
                    value: 0.5,
                    onChanged: null,
                  ),
                ),
                const ListTile(
                  title: Text("Hlasitost zvukových efektů"),
                  subtitle: Slider(
                    value: 0.5,
                    onChanged: null,
                  ),
                ),
                const ListTile(
                  title: Text("Hlasitost hlasu"),
                  subtitle: Slider(
                    value: 0.5,
                    onChanged: null,
                  ),
                ),
              ],
            ),
          ),
        ]
    );
  }
}