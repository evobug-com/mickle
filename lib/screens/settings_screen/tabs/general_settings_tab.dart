
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../../core/notifiers/theme_controller.dart';
import '../settings_models.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class GeneralSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const GeneralSettingsTab({super.key, this.item, required this.settingsCategories});

  @override
  State<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends State<GeneralSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final items = widget.settingsCategories.firstWhere((element) => element.tab == 'general').items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: widget.settingsCategories.firstWhere((element) => element.tab == 'general').title),
        const SizedBox(height: 20),

        const Text("Behaviour", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        FutureBuilder(
            future: launchAtStartup.isEnabled(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              if(snapshot.hasError) {
                return FormField<String>(builder: (FormFieldState<String> state) {
                  return Text('Error: ${snapshot.error}');
                }, key: const Key('home-autostartup-error'));
              }

              return Highlightable(
                highlight: widget.item == items['home-autostartup']!.key,
                child: SwitchListTile(
                  key: items['home-autostartup']!.keyRef,
                  title: Text(items['home-autostartup']!.name),
                  subtitle: const Text('Automatically start the app when the system starts'),
                  value: snapshot.data as bool,
                  onChanged: (value) {
                    final scheme = ThemeController.scheme(context, listen: false);
                    // Save autostartup to settings
                    if(value) {
                      // Enable autostartup and show a toast message when enabled or with an error
                      launchAtStartup.enable().then((value) {
                        SettingsProvider().autostartup = true;
                      }).catchError((error) {
                        // Show a toast message
                        BotToast.showNotification(
                          title: (_) => Text('Error enabling autostartup', style: TextStyle(color: scheme.onErrorContainer)),
                          subtitle: (_) => Text(error.toString(), style: TextStyle(color: scheme.onErrorContainer)),
                          duration: const Duration(seconds: 6),
                          backgroundColor: scheme.errorContainer,
                        );
                      });
                    } else {
                      launchAtStartup.disable().then((value) {
                        SettingsProvider().autostartup = false;
                      }).catchError((error) {
                        // Show a toast message
                        BotToast.showNotification(
                          title: (_) => Text('Error disabling autostartup', style: TextStyle(color: scheme.onErrorContainer)),
                          subtitle: (_) => Text(error.toString(), style: TextStyle(color: scheme.onErrorContainer)),
                          duration: const Duration(seconds: 6),
                          backgroundColor: scheme.errorContainer,
                        );
                      });
                    }
                  },
                ),
              );
            }
        ),
        Highlightable(
          highlight: widget.item == items['home-exit-to-tray']!.key,
          child: SwitchListTile(
            key: items['home-exit-to-tray']!.keyRef,
            title: Text(items['home-exit-to-tray']!.name),
            subtitle: const Text('Minimize to tray when closing the app'),
            value: SettingsProvider().exitToTray,
            onChanged: (value) {
              // Save exit to tray to settings
              SettingsProvider().exitToTray = value;
            },
          ),
        ),

        // Highlightable(
        //   highlight: widget.item == widget.settingsData.accountNameController.key,
        //   child: TextField(
        //     key: items[widget.settingsData.accountNameController.key]!.keyRef,
        //     controller: widget.settingsData.accountNameController,
        //     decoration: InputDecoration(
        //       labelText: items[widget.settingsData.accountNameController.key]!.name,
        //     ),
        //   ),
        // ),

        // Highlightable(
        //   highlight: widget.item == 'account-email',
        //   child: TextField(
        //     key: items['account-email']!.keyRef,
        //     controller: _accountEmailController,
        //     decoration: InputDecoration(
        //       labelText: items['account-email']!.name,
        //     ),
        //   ),
        // ),

      ],
    );
  }
}