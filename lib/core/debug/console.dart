// Console is a overlay that can be used to display messages, errors, and warnings.
// It can be used to control the audio volume, etc...

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/storage/storage.dart';
import 'package:talk/ui/scheme.dart';

import '../notifiers/theme_controller.dart';

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<StatefulWidget> createState() => ConsoleState();
}

class ConsoleState extends State<Console> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyboardToggleConsole);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardToggleConsole);
    super.dispose();
  }

  bool _keyboardToggleConsole(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.f12 && event is KeyDownEvent) {
      setState(() {
        _isVisible = !_isVisible;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: _isVisible ? _buildConsole() : const SizedBox.shrink(),
    );
  }

  Widget _buildConsole() {
    AudioManager audioManager = AudioManager();
    return ListenableBuilder(
      listenable: ThemeController(),
      builder: (context, child) {
        ThemeData theme = ThemeController().theme;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.colorScheme.onInverseSurface.withOpacity(0.99)),

          // Tabs with different sections, like Audio, Network, etc...
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Console", style: TextStyle(fontSize: 20)),
                  Text("Select a tab to view more information",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              Divider(),
              // Audio section
              DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        // The tab is at the top of the screen
                        tabs: [
                          Tab(text: "Audio"),
                          Tab(text: "Network"),
                          Tab(text: "Settings"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Audio tab with volume control, show audio devices, connected devices, each audio source
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          title: Text("Master Volume"),
                                          subtitle: ListenableBuilder(
                                            listenable: audioManager.masterVolume,
                                            builder: (context, child) {
                                              return Slider(
                                                value: audioManager.masterVolume.value,
                                                onChanged: (value) {
                                                  audioManager.masterVolume.value = value;
                                                  Storage().write("masterVolume", value.toString());
                                                },
                                                max: 1.0,
                                                min: 0.0,
                                                divisions: 50,
                                                label: "${(audioManager.masterVolume.value * 100).round()}%",
                                              );
                                            }
                                          ),
                                        ),
                                        ListTile(
                                          title: Text("Music Volume"),
                                          subtitle: Slider(
                                            value: 0.5,
                                            onChanged: null,
                                          ),
                                        ),
                                        ListTile(
                                          title: Text("Sound Effects Volume"),
                                          subtitle: Slider(
                                            value: 0.5,
                                            onChanged: null,
                                          ),
                                        ),
                                        ListTile(
                                          title: Text("Voice Volume"),
                                          subtitle: Slider(
                                            value: 0.5,
                                            onChanged: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                          Text("Network"),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              DropdownMenu<ThemeItem>(
                                label: Text("Theme"),
                                dropdownMenuEntries: ThemeController().themes.map((e) => DropdownMenuEntry(value: e, label: e.name)).toList(),
                                initialSelection: ThemeController().themes.firstWhere((element) => element.theme == ThemeController().theme, orElse: () => ThemeController().themes.first),
                                onSelected: (value) {
                                  if(value != null) {
                                    ThemeController().setTheme(value.theme);
                                    Storage().write("theme", value.name);
                                  }
                                },
                                enableSearch: false,
                                enableFilter: false,
                              )
                            ],
                          )
                        ]
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
