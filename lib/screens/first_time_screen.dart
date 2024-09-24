import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:mickle/core/storage/preferences.dart';
import 'package:mickle/layout/my_scaffold.dart';
import 'package:mickle/core/theme/theme_controller.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';

import 'settings_screen/settings_widgets.dart';

class FirstTimeScreen extends StatefulWidget {
  const FirstTimeScreen({super.key});

  @override
  _FirstTimeScreenState createState() => _FirstTimeScreenState();
}

class _FirstTimeScreenState extends State<FirstTimeScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MyScaffold(
      showSidebar: false,
      showSearchBar: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          gradient: _currentStep == 0 ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
              colorScheme.tertiary
            ],
          ) : null,
          color: _currentStep == 2 ? colorScheme.surface : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildStep(_currentStep),
                ),
              ),
              if (_currentStep > 0) _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _ExperienceSelectionStep(
          key: ValueKey(step),
          onSelected: (isFirstTime) {
            setState(() {
              _currentStep = 1; // Always go to the next step, regardless of selection
            });
          },
        );
      case 1:
        return _WelcomeStep(key: ValueKey(step));
      case 2:
        return _AppearanceSelectionStep(key: ValueKey(step));
      case 3:
        return _SettingsStep(key: ValueKey(step));
      case 4:
        return _CompletionStep(key: ValueKey(step));
      default:
        return Container();
    }
  }

  Widget _buildNavigationButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      opacity: _currentStep > 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0 && _currentStep < _totalSteps - 1)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: colorScheme.secondaryContainer,
                //   foregroundColor: colorScheme.onSecondaryContainer,
                // ),
              )
            else
              const SizedBox.shrink(),
            if (_currentStep < _totalSteps - 1)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep++;
                  });
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: colorScheme.primaryContainer,
                //   foregroundColor: colorScheme.onPrimaryContainer,
                // ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.5), end: const Offset(0, 0));
  }
}

class _ExperienceSelectionStep extends StatelessWidget {
  final Function(bool) onSelected;

  const _ExperienceSelectionStep({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Mickle!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slide(),
          const SizedBox(height: 32),
          Text(
            'How would you like to begin?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slide(),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildExperienceCard(
                context,
                'Fresh Start',
                'Embark on a new journey',
                Icons.rocket_launch,
                    () => onSelected(true),
              ),
              const SizedBox(width: 24),
              _buildExperienceCard(
                context,
                'Import',
                'Bring your existing data',
                Icons.cloud_download,
                    () => onSelected(false),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.onPrimary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 100,
            color: colorScheme.onSurface,
          ).animate().scale(duration: 600.ms).fadeIn(),
          const SizedBox(height: 32),
          Text(
            'Welcome to Mickle',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slide(),
          const SizedBox(height: 16),
          Text(
            'Unleash the power of next-gen communication',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slide(),
          const SizedBox(height: 32),
          Text(
            'Get ready to explore infinite possibilities',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slide(),
        ],
      ),
    );
  }
}

class _AppearanceSelectionStep extends StatefulWidget {
  const _AppearanceSelectionStep({super.key});

  @override
  State<_AppearanceSelectionStep> createState() => _AppearanceSelectionStepState();
}

class _AppearanceSelectionStepState extends State<_AppearanceSelectionStep> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Make it yours',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms).slide(),
          const SizedBox(height: 16),
          Text(
            'Choose a look that suits your style',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slide(),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 1000),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: ThemeController.themes.length,
              itemBuilder: (context, index) {
                final theme = ThemeController.themes[index];
                return _buildThemeOption(context, theme);
              },
            ).animate().fadeIn(delay: 600.ms).scale(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeItem theme) {
    final isSelected = ThemeController.of(context).currentThemeName == theme.name;
    return InkWell(
      onTap: () {
        ThemeController.of(context, listen: false).setTheme(theme.value);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.value.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette, color: theme.value.colorScheme.primary, size: 48),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: TextStyle(color: theme.value.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsStep extends StatelessWidget {
  const _SettingsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ListenableBuilder(
        listenable: SettingsProvider(),
        builder: (context, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Customize your experience',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms).slide(),
              const SizedBox(height: 32),
              buildSettingSwitchOption(
                context: context,
                title: 'Launch at startup',
                description: 'Automatically start Mickle when your system boots up',
                icon: Icons.power_settings_new,
                value: SettingsProvider().launchAtStartup,
                onChanged: (value) async {
                  if (value) {
                    launchAtStartup.enable().then((_) {
                      SettingsProvider().launchAtStartup = true;
                    }).catchError((error) {
                      _showErrorNotification(context, 'Error enabling autostartup', error.toString());
                    });
                  } else {
                    launchAtStartup.disable().then((_) {
                      SettingsProvider().launchAtStartup = false;
                    }).catchError((error) {
                      _showErrorNotification(context, 'Error disabling autostartup', error.toString());
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              buildSettingSwitchOption(
                context: context,
                title: 'Exit to tray',
                description: 'Keep Mickle running in the background when you close the window',
                icon: Icons.minimize,
                value: SettingsProvider().exitToTray,
                onChanged: (value) {
                  SettingsProvider().exitToTray = value;
                }
              ),
            ],
          );
        }
      ),
    );
  }

  void _showErrorNotification(BuildContext context, String title, String message) {
    final scheme = ThemeController.scheme(context, listen: false);
    BotToast.showNotification(
      title: (_) => Text(title, style: TextStyle(color: scheme.onErrorContainer)),
      subtitle: (_) => Text(message, style: TextStyle(color: scheme.onErrorContainer)),
      duration: const Duration(seconds: 6),
      backgroundColor: scheme.errorContainer,
    );
  }
}

class _CompletionStep extends StatelessWidget {
  const _CompletionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(
        Icons.celebration,
        size: 100,
        color: colorScheme.onSurface,
    ).animate().scale().fadeIn(duration: 600.ms),
    const SizedBox(height: 32),
    Text(
    'You\'re all set!',
    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
    color: colorScheme.onSurface,
    fontWeight: FontWeight.bold,
    ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slide(),
    const SizedBox(height: 16),
          Text(
            'Get ready to experience next-gen communication',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slide(),
          const SizedBox(height: 32),
          Text(
            'Mickle is all set up and ready to go. Dive in and start exploring the infinite possibilities!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slide(),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              Preferences.setFirstTime(false);
              context.goNamed('login');
            },
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Launch Mickle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
          ).animate().fadeIn(delay: 1200.ms).scale(),
        ],
        ),
    );
  }
}
