
import 'package:flutter/material.dart';

import '../../../core/notifiers/theme_controller.dart';
import '../../chat_screen.dart';
import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class AppearanceSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const AppearanceSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<AppearanceSettingsTab> createState() => _AppearanceSettingsTabState();
}

class _AppearanceSettingsTabState extends State<AppearanceSettingsTab> {
  ThemeData _selectedTheme = ThemeController().currentTheme;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'appearance').title),
        const SizedBox(height: 20),

        // Text with live preview of the selected theme
        const Text('Live Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        // Scrollable screen
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(child: Theme(child: ChatScreen(), data: _selectedTheme,)),
          ),
        ),

        // Row with all themes as tile boxes
        Highlightable(
          highlight: widget.item == 'appearance-theme',
          child: SizedBox(
            height: 130,
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.bottom,
              thumbVisibility: true,
              trackVisibility: true,
              controller: scrollController,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.hardEdge,
                children: ThemeController.themes.map((theme) {
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        ListTile(
                            dense: true,
                            title: Center(child: Text(theme.name, style: TextStyle(color: theme.value.colorScheme.onSurface))),
                            // contentPadding: const EdgeInsets.all(0),
                            tileColor: theme.value.colorScheme.surfaceContainerLow,
                            titleAlignment: ListTileTitleAlignment.center,
                            onTap: () {
                              setState(() {
                                _selectedTheme = theme.value;
                              });
                              //
                              // // Set theme
                              // ThemeController.of(context, listen: false)
                              //     .setTheme(theme.value);
                              //
                              // // Save theme to settings
                              // Settings().theme = theme.name;
                            }
                        ),
                        if (_selectedTheme == theme.value) // Overlay
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                              ),
                              child: Center(child: Icon(Icons.check, color: Colors.white, size: 50,))
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // Apply button
        ElevatedButton(
          onPressed: () {
            // Set theme
            ThemeController.of(context, listen: false)
                .setTheme(_selectedTheme);
            // Save theme to settings
            SettingsProvider().theme = ThemeController.of(context, listen: false).currentThemeName;
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}