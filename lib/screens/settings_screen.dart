import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:talk/core/audio/audio_manager.dart';
import 'package:talk/core/notifiers/theme_controller.dart';
import 'package:talk/core/version.dart';
import '../core/storage/storage.dart';
import '../layout/my_scaffold.dart';

class KeyedTextEditingController extends TextEditingController {
  final String key;

  KeyedTextEditingController(this.key, {super.text});
}

class Settings extends ChangeNotifier {
  static final Settings _singleton = Settings._internal();
  factory Settings() => _singleton;
  Settings._internal();

  bool get replaceTextEmoji => Storage().readBoolean('replaceTextEmoji', defaultValue: false);
  set replaceTextEmoji(bool value) {
    Storage().write('replaceTextEmoji', value.toString());
    notifyListeners();
  }

  bool get autostartup => Storage().readBoolean('autostartup', defaultValue: false);
  set autostartup(bool value) {
    Storage().write('autostartup', value.toString());
    notifyListeners();
  }

  bool get exitToTray => Storage().readBoolean('exitToTray', defaultValue: true);
  set exitToTray(bool value) {
    Storage().write('exitToTray', value.toString());
    notifyListeners();
  }

  String? get microphoneDevice => Storage().read('microphoneDevice');
  set microphoneDevice(value) {
    Storage().write('microphoneDevice', value);
    notifyListeners();
  }

  String get theme => Storage().readString('theme', defaultValue: ThemeController().currentThemeName);
  set theme(String value) {
    Storage().write('theme', value);
    notifyListeners();
  }

  String get language => Storage().readString('locale', defaultValue: 'en-us');
  set language(String value) {
    Storage().write('locale', value);
    notifyListeners();
  }
}

class SettingsScreen extends StatefulWidget {
  final String? tab;
  final String? item;

  const SettingsScreen({super.key, this.tab, this.item});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    print('SettingsScreen: tab=${widget.tab}, item=${widget.item}');

    final currentCategory = settingsCategories.firstWhere((element) => element.tab == widget.tab);
    if(widget.item != null && currentCategory.items.containsKey(widget.item)) {
      final currentItem = currentCategory.items[widget.item!];
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: AnimatedContainer(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        duration: const Duration(milliseconds: 300),
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.escape): const ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  if(isSearching) {
                    setState(() {
                      isSearching = false;
                    });
                  } else {
                    context.pop();
                  }
                  return null;
                },
              ),
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsSidebar(
                      tab: widget.tab,
                      isSearching: isSearching,
                      onSearch: (isSearching) {
                        setState(() {
                          this.isSearching = isSearching;
                        });
                      },
                    ),
                    if (!isSearching) ...[
                      const SizedBox(width: 30),
                      Expanded(child: ListenableBuilder(
                        listenable: Settings(),
                        builder: (context, child) {
                          return SettingsContent(tab: widget.tab, item: widget.item);
                        }
                      )),
                    ]
                  ],
                ),
                IconButton(onPressed: () {
                  if(context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/chat');
                  }
                }, icon: const Icon(Icons.close)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingItem {
  final String tab;
  final String key;
  final String name;
  final Key keyRef;
  SettingItem({required this.tab, required this.key, required this.name}): keyRef = Key(key);
}

class SettingMetadata {
  final String tab;
  final String title;
  final IconData icon;
  final Map<String, SettingItem> items;

  SettingMetadata({required this.tab, required this.icon, required this.title, required this.items});
}

// Create settings list with name and icon
// Create settings list with keys and names
final List<SettingMetadata> settingsCategories = [
  SettingMetadata(
      tab: 'general',
      icon: Icons.home,
      title: 'Home',
      items: {
        'home-autostartup': SettingItem(tab: 'general', key: 'home-autostartup', name: 'Autostartup'),
        'home-exit-to-tray': SettingItem(tab: 'general', key: 'home-exit-to-tray', name: 'Exit to Tray'),
        'display-name': SettingItem(tab: 'general', key: 'display-name', name: 'Display Name'),
        // 'account-email': SettingItem(tab: 'general', key: 'account-email', name: 'Account Email'),
        'account-password': SettingItem(tab: 'general', key: 'account-password', name: 'Account Password'),
        'account-logout': SettingItem(tab: 'general', key: 'account-logout', name: 'Account Logout'),
      }
  ),
  SettingMetadata(tab: 'audio', icon: Icons.audiotrack, title: 'Audio', items: {
    'audio-microphone': SettingItem(tab: 'audio', key: 'audio-microphone', name: 'Microphone'),
    'audio-speaker': SettingItem(tab: 'audio', key: 'audio-speaker', name: 'Speaker'),
  }),
  SettingMetadata(tab: 'appearance', icon: Icons.color_lens, title: 'Appearance', items: {
    'appearance-theme': SettingItem(tab: 'appearance', key: 'appearance-theme', name: 'Theme'),
  }),
  SettingMetadata(tab: 'experimental', icon: Icons.science, title: 'Experimental', items: {
    'experimental-text-emoji': SettingItem(tab: 'experimental', key: 'experimental-text-emoji', name: 'Text Emoji'),
  }),
  SettingMetadata(tab: 'about', icon: Icons.info, title: 'About', items: {
    'about-version': SettingItem(tab: 'about', key: 'about-version', name: 'Version'),
  }),
];

class SettingsSidebar extends StatefulWidget {
  final String? tab;
  final bool isSearching;
  final Function(bool) onSearch;

  const SettingsSidebar({super.key, this.tab, required this.isSearching, required this.onSearch});

  @override
  State<SettingsSidebar> createState() => _SettingsSidebarState();
}

class MatchResult {
  final bool isMatch;
  final List<int> matchIndices;

  MatchResult(this.isMatch, this.matchIndices);
}

MatchResult _matchesSearchQuery(String item, String query) {
  // Normalize the query and item strings by replacing -_ with space and removing extra spaces
  final normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'[-_]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  final normalizedItem = item.toLowerCase().replaceAll(RegExp(r'[-_]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  // Split query into words
  final queryWords = normalizedQuery.split(' ');
  final itemWords = normalizedItem.split(' ');

  List<int> matchIndices = [];
  int itemIndex = 0;

  // Iterate over query words
  for (final queryWord in queryWords) {
    bool wordMatched = false;

    // Find a word in item that matches the current query word
    while (itemIndex < normalizedItem.length) {
      int queryWordIndex = 0;
      int startMatchIndex = itemIndex;

      // Check if the query word matches at the current position in the item
      while (queryWordIndex < queryWord.length &&
          itemIndex < normalizedItem.length &&
          normalizedItem[itemIndex] == queryWord[queryWordIndex]) {
        matchIndices.add(itemIndex);
        queryWordIndex++;
        itemIndex++;
      }

      // If the whole query word matched, break to check the next query word
      if (queryWordIndex == queryWord.length) {
        wordMatched = true;
        break;
      } else {
        // If the whole query word did not match, reset and continue searching
        matchIndices.removeRange(matchIndices.length - queryWordIndex, matchIndices.length);
        itemIndex = startMatchIndex + 1;
      }
    }

    // If the current query word did not match anywhere in the item, return no match
    if (!wordMatched) {
      return MatchResult(false, []);
    }

    // Move itemIndex to the start of the next word in the item
    itemIndex = normalizedItem.indexOf(' ', itemIndex) + 1;
    if (itemIndex <= 0) break;
  }

  return MatchResult(true, matchIndices);
}

class _SettingsSidebarState extends State<SettingsSidebar> {
  String searchQuery = '';

  List<Map<String, dynamic>> getFilteredSettings() {
    return settingsCategories.expand((setting) {
      return setting.items.values
          .map((item) {
            final matchResult = _matchesSearchQuery(item.name, searchQuery);
            if (matchResult.isMatch) {
              return {'tab': setting.tab, 'item': item, 'matches': matchResult.matchIndices};
            } else {
              return null;
            }
          })
          .where((result) => result != null)
          .toList()
          .cast<Map<String, dynamic>>();
    }).toList();
  }

  Widget _buildHighlightedText(String text, List<int> matchIndices, BuildContext context) {
    final scheme = ThemeController.scheme(context, listen: false);
    final defaultText = scheme.onSurface;

    final textSpans = <TextSpan>[];
    int lastMatchIndex = -1;

    for (int i = 0; i < text.length; i++) {
      if (matchIndices.contains(i)) {
        if (i != lastMatchIndex + 1) {
          textSpans.add(TextSpan(text: text.substring(lastMatchIndex + 1, i), style: TextStyle(color: defaultText)));
        }
        textSpans.add(TextSpan(text: text[i], style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)));
        lastMatchIndex = i;
      }
    }

    if (lastMatchIndex != text.length - 1) {
      textSpans.add(TextSpan(text: text.substring(lastMatchIndex + 1), style: TextStyle(color: defaultText)));
    }

    return RichText(text: TextSpan(children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeController.scheme(context);

    final filteredSettings = getFilteredSettings();

    final result = Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: widget.isSearching,
                decoration: InputDecoration(
                  hintText: 'Search settings',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: scheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () {
                  widget.onSearch(true);
                },
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),
            if(widget.isSearching) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  widget.onSearch(false);
                },
                icon: const Icon(Icons.close),
              ),
            ]
          ],
        ),
        const SizedBox(height: 5),
        if (widget.isSearching)
          Expanded(
            child: ListView(
              children: filteredSettings.map((result) {
                final item = result['item'] as SettingItem;
                final matches = result['matches'] as List<int>;
                final category = settingsCategories.firstWhere((element) => element.tab == result['tab']);
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon),
                      const SizedBox(width: 4),
                      Text(category.title),
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHighlightedText(item.name, matches, context),
                      Text(item.key, style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),
                    ],
                  ),
                  onTap: () {
                    context.pushReplacementNamed(
                      'settings',
                      queryParameters: {'tab': result['tab']!, 'item': item.key},
                    );
                    widget.onSearch(false);
                  },
                );
              }).toList(),
            ),
          )
        else
          Expanded(
            child: ListView(
              children: settingsCategories.map((setting) {
                return ListTile(
                  title: Text(setting.title),
                  onTap: () {
                    context.pushReplacementNamed('settings', queryParameters: { 'tab': setting.tab });
                  },
                  selected: widget.tab == setting.tab,
                  selectedTileColor: scheme.surfaceContainerHigh,
                  selectedColor: scheme.onSurface,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.tab == setting.tab) Container(width: 3, height: 20, color: scheme.primary),
                      Icon(setting.icon, color: scheme.onSurface),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );

    return widget.isSearching ? Expanded(child: result) : SizedBox(width: 200, child: result);
  }
}

class SettingsContent extends StatelessWidget {
  final String? tab;
  final String? item;

  const SettingsContent({super.key, this.tab, this.item});

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case 'general':
        return GeneralSettingsTab(item: item);
      case 'audio':
        return AudioSettingsTab(item: item);
      case 'appearance':
        return AppearanceSettingsTab(item: item);
      case 'experimental':
        return ExperimentalSettingsTab(item: item);
      case 'about':
        return AboutSettingsTab(item: item);
      default:
        return GeneralSettingsTab(item: item);
    }
  }
}

class SettingTitle extends StatelessWidget {
  final String? title;
  const SettingTitle({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title!, style: Theme.of(context).textTheme.displaySmall);
  }
}

class Highlightable extends StatelessWidget {
  final bool highlight;
  final Widget child;

  const Highlightable({super.key, required this.child, required this.highlight});

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          // Right aligned text Found
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("Found", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
            child: Row(
              children: [
                Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.primary),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      );
    }
    return child;
  }
}

class GeneralSettingsTab extends StatefulWidget {
  final String? item;
  const GeneralSettingsTab({super.key, this.item});

  @override
  State<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends State<GeneralSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final items = settingsCategories.firstWhere((element) => element.tab == 'general').items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: settingsCategories.firstWhere((element) => element.tab == 'general').title),
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
                      Settings().autostartup = true;
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
                      Settings().autostartup = false;
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
            value: Settings().exitToTray,
            onChanged: (value) {
              // Save exit to tray to settings
              Settings().exitToTray = value;
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

class AudioSettingsTab extends StatefulWidget {
  final String? item;
  const AudioSettingsTab({super.key, this.item});

  @override
  State<AudioSettingsTab> createState() => _AudioSettingsTabState();
}

class _AudioSettingsTabState extends State<AudioSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: settingsCategories.firstWhere((element) => element.tab == 'audio').title),
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
                          value: Settings().microphoneDevice ?? defaultMicrophone.id,
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

class AppearanceSettingsTab extends StatefulWidget {
  final String? item;
  const AppearanceSettingsTab({super.key, this.item});

  @override
  State<AppearanceSettingsTab> createState() => _AppearanceSettingsTabState();
}

class _AppearanceSettingsTabState extends State<AppearanceSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: settingsCategories.firstWhere((element) => element.tab == 'appearance').title),
        const SizedBox(height: 20),

        Highlightable(
          highlight: widget.item == 'appearance-theme',
          child: DropdownButtonFormField<String>(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: const InputDecoration(labelText: 'Theme'),
            key: const Key('appearance-theme'),
            value: Settings().theme,
            items: ThemeController.themes.map((theme) {
              return DropdownMenuItem<String>(
                value: theme.name,
                child: Text(theme.name),
              );
            }).toList(),
            onChanged: (value) {
              final theme = ThemeController.themes.firstWhere((element) => element.name == value);

              // Set theme
              ThemeController.of(context, listen: false)
                  .setTheme(theme.value);

              // Save theme to settings
              Settings().theme = value!;
            },
          ),
        )
      ],
    );
  }
}

class ExperimentalSettingsTab extends StatefulWidget {
  final String? item;
  const ExperimentalSettingsTab({super.key, this.item});

  @override
  State<ExperimentalSettingsTab> createState() => _ExperimentalSettingsTabState();
}

class _ExperimentalSettingsTabState extends State<ExperimentalSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: settingsCategories.firstWhere((element) => element.tab == 'experimental').title),
        const Text('Settings that are experimental and may not work as expected. They may not be available in the final version.', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Replace text-emoji with emoji such as :D to 😃 and :P to 😛, etc.
        Highlightable(
          highlight: widget.item == 'experimental-text-emoji',
          child: SwitchListTile(
            title: const Text('Text Emoji'),
            subtitle: const Text('Replace text-emoji with emoji, such as \':D\' or \':grinning_face:\' to 😃 and \':P\' to 😛, etc.'),
            value: Settings().replaceTextEmoji,
            onChanged: (value) {
              // Save text-emoji to settings
              Settings().replaceTextEmoji = value;
            },
          ),
        ),
      ],
    );
  }
}

class AboutSettingsTab extends StatefulWidget {
  final String? item;
  const AboutSettingsTab({super.key, this.item});

  @override
  State<AboutSettingsTab> createState() => _AboutSettingsTabState();
}

class _AboutSettingsTabState extends State<AboutSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(title: settingsCategories.firstWhere((element) => element.tab == 'about').title),
        const SizedBox(height: 20),

        Highlightable(
          highlight: widget.item == 'about-version',
          child: const ListTile(
            title: Text('Version'),
            subtitle: Text(version),
          ),
        )
      ],
    );
  }
}