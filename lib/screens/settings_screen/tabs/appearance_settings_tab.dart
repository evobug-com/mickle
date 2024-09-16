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
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme selection and Apply button
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Highlightable(
                        highlight: widget.item == 'appearance-theme',
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: ThemeController.themes.length,
                          itemBuilder: (context, index) {
                            final theme = ThemeController.themes[index];
                            return InkWell(
                              onTap: () => setState(() => _selectedTheme = theme.value),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.value.colorScheme.surfaceContainerLow,
                                  border: Border.all(
                                    color: _selectedTheme == theme.value
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.palette, color: theme.value.colorScheme.primary),
                                    const SizedBox(height: 4),
                                    Text(
                                      theme.name,
                                      style: TextStyle(color: theme.value.colorScheme.onSurface),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          ThemeController.of(context, listen: false).setTheme(_selectedTheme);
                          SettingsProvider().theme = ThemeController.of(context, listen: false).currentThemeName;
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Apply Theme'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Live preview
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Live Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Theme(
                          data: _selectedTheme,
                          child: const ChatPreviewWrapper(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatPreviewWrapper extends StatelessWidget {
  const ChatPreviewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: 0.5,  // Adjust this value as needed
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth * 2,
                height: constraints.maxHeight * 2,
                child: const ChatScreen(),
              ),
            ),
          ),
        );
      },
    );
  }
}