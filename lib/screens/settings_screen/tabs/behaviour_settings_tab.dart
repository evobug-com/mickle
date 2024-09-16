import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:talk/areas/utilities/elevation.dart';
import 'package:talk/core/theme/theme_controller.dart';
import 'package:talk/ui/text_field_list_tile.dart';
import 'package:talk/areas/utilities/debouncer.dart';
import 'package:talk/screens/settings_screen/settings_models.dart';
import 'package:talk/screens/settings_screen/settings_provider.dart';

import '../settings_widgets.dart';

class BehaviourSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  

  const BehaviourSettingsTab({super.key, required this.settingsTabController});

  @override
  _BehaviourSettingsTabState createState() => _BehaviourSettingsTabState();
}

class _BehaviourSettingsTabState extends State<BehaviourSettingsTab> {
  late final TextEditingController _dateFormatController;
  final _dateFormatDebounce = Debouncer(delay: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _dateFormatController = TextEditingController(text: SettingsProvider().messageDateFormat);
    _dateFormatController.addListener(_onDateFormatChanged);
  }

  void _onDateFormatChanged() {
    _dateFormatDebounce.run(() {
      SettingsProvider().messageDateFormat = _dateFormatController.text;
    });
  }

  @override
  void dispose() {
    _dateFormatController.removeListener(_onDateFormatChanged);
    _dateFormatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'behaviour');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(category: category),
        Expanded(
          child: ListView(
            children: [
              buildSettingsSection(
                  context,
                  "Application Behaviour",
                  [
                    _buildAutostartup(category.items),
                    _buildExitToTray(category.items),
                  ]
              ),
              buildSettingsSection(
                context,
                'Chat Behaviour',
                [
                  _buildSendMessageOnEnterTile(category.items),
                  _buildMessageDateFormatTile(category.items),
                  const SizedBox(height: 24),
                  const DateFormatGuide(),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAutostartup(Map<String, SettingItem> items) {
    return FutureBuilder<bool>(
      future: launchAtStartup.isEnabled(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Data is loaded, show the actual SwitchListTile
          return Highlightable(
            highlight: widget.settingsTabController.item == items['behaviour-autostartup']!.key,
            child: SwitchListTile(
              key: items['behaviour-autostartup']!.keyRef,
              title: Text(items['behaviour-autostartup']!.name),
              subtitle: const Text('Automatically start Mickle when your system boots up'),
              value: snapshot.data!,
              onChanged: (value) {
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
          );
        } else if (snapshot.hasError) {
          // Handle error state
          return ListTile(
            title: Text('Error loading autostartup setting'),
            subtitle: Text('${snapshot.error}'),
          );
        } else {
          // While loading, show a disabled SwitchListTile
          return Highlightable(
            highlight: widget.settingsTabController.item == items['behaviour-autostartup']!.key,
            child: SwitchListTile(
              key: items['behaviour-autostartup']!.keyRef,
              title: Text(items['behaviour-autostartup']!.name),
              subtitle: const Text('Loading...'),
              value: false,
              onChanged: null, // Disable the switch
            ),
          );
        }
      },
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

  Widget _buildExitToTray(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['behaviour-exit-to-tray']!.key,
      child: SwitchListTile(
        key: items['behaviour-exit-to-tray']!.keyRef,
        title: Text(items['behaviour-exit-to-tray']!.name),
        subtitle: const Text('Keep Mickle running in the background when you close the window'),
        value: SettingsProvider().exitToTray,
        onChanged: (value) {
          // Save exit to tray to settings
          SettingsProvider().exitToTray = value;
        },
      ),
    );
  }

  Widget _buildSendMessageOnEnterTile(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['behaviour-send-message-on-enter']!.key,
      child: SwitchListTile(
        title: Text(items['behaviour-send-message-on-enter']!.name),
        subtitle: Text('When enabled, pressing Enter will send the message. When disabled, use Shift+Enter to send.'),
        value: SettingsProvider().sendMessageOnEnter,
        onChanged: (value) {
          setState(() {
            SettingsProvider().sendMessageOnEnter = value;
          });
        },
      ),
    );
  }

  Widget _buildMessageDateFormatTile(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['behaviour-message-date-format']!.key,
      child: TextFieldListTile(
        title: items['behaviour-message-date-format']!.name,
        subtitle: 'Enter a custom date format for messages',
        controller: _dateFormatController,
        hintText: 'e.g., HH:mm:ss',
      ),
    );
  }
}

class DateFormatGuide extends StatelessWidget {
  const DateFormatGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Elevation(
      borderRadius: BorderRadius.circular(12),
      child: ExpansionTile(
        title: Text('Date Format Guide', style: theme.textTheme.titleMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _dateFormatEntries.length,
              itemBuilder: (context, index) {
                final entry = _dateFormatEntries[index];
                return Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Material(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            // Copy the symbol to the clipboard and show a snackbar
                            Clipboard.setData(ClipboardData(text: entry.symbol));
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Copied ${entry.meaning} (${entry.symbol}) to clipboard'),
                            ));
                          },
                          child: Center(
                            child: Text(
                              entry.symbol,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(entry.meaning, style: theme.textTheme.bodySmall),
                          Text(entry.example, style: theme.textTheme.bodySmall?.copyWith(color: scheme.secondary)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static final List<_DateFormatEntry> _dateFormatEntries = [
    _DateFormatEntry('G', 'era designator', 'AD'),
    _DateFormatEntry('y', 'year', '1996'),
    _DateFormatEntry('M', 'month in year', 'July & 07'),
    _DateFormatEntry('L', 'standalone month', 'July & 07'),
    _DateFormatEntry('d', 'day in month', '10'),
    _DateFormatEntry('c', 'standalone day', '10'),
    _DateFormatEntry('h', 'hour in am/pm (1~12)', '12'),
    _DateFormatEntry('H', 'hour in day (0~23)', '0'),
    _DateFormatEntry('m', 'minute in hour', '30'),
    _DateFormatEntry('s', 'second in minute', '55'),
    _DateFormatEntry('S', 'fractional second', '978'),
    _DateFormatEntry('E', 'day of week', 'Tuesday'),
    _DateFormatEntry('D', 'day in year', '189'),
    _DateFormatEntry('a', 'am/pm marker', 'PM'),
    _DateFormatEntry('k', 'hour in day (1~24)', '24'),
    _DateFormatEntry('K', 'hour in am/pm (0~11)', '0'),
    _DateFormatEntry('Q', 'quarter', 'Q3'),
  ];
}

class _DateFormatEntry {
  final String symbol;
  final String meaning;
  final String example;

  _DateFormatEntry(this.symbol, this.meaning, this.example);
}