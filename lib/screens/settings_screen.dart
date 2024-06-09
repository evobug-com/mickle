import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/notifiers/theme_controller.dart';
import '../layout/my_scaffold.dart';

class KeyedTextEditingController extends TextEditingController {
  final String key;

  KeyedTextEditingController(this.key, {String? text}) : super(text: text);
}

class SettingsData extends ChangeNotifier {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _initialValues = {};
  final List<String> keys;

  SettingsData(this.keys, Map<String, String> initialValues) {
    for (var key in keys) {
      _controllers[key] = KeyedTextEditingController(key, text: initialValues[key]);
      _initialValues[key] = initialValues[key] ?? '';
      _controllers[key]!.addListener(() {
        notifyListeners();
      });
    }
  }

  TextEditingController getController(String key) {
    return _controllers[key]!;
  }

  void saveChanges() {
    final changedValues = <String, String>{};
    _controllers.forEach((key, controller) {
      if (_initialValues[key] != controller.text) {
        changedValues[key] = controller.text;
      }
    });

    print('Changed values: $changedValues');
  }

  void cancelChanges() {
    _controllers.forEach((key, controller) {
      controller.text = _initialValues[key]!;
    });
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
  late SettingsData settingsData;

  @override
  void initState() {
    super.initState();
    print('SettingsScreen: tab=${widget.tab}, item=${widget.item}');
    // settingsData = SettingsData(context);

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
        child: Row(
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
              Expanded(child: SettingsContent(tab: widget.tab, item: widget.item, settingsData: settingsData)),
            ]
          ],
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
        'display-name': SettingItem(tab: 'general', key: 'display-name', name: 'Display Name'),
        // 'account-email': SettingItem(tab: 'general', key: 'account-email', name: 'Account Email'),
        'account-password': SettingItem(tab: 'general', key: 'account-password', name: 'Account Password'),
        'account-logout': SettingItem(tab: 'general', key: 'account-logout', name: 'Account Logout'),
      }
  ),
  SettingMetadata(tab: 'appearance', icon: Icons.color_lens, title: 'Appearance', items: {}),
  SettingMetadata(tab: 'about', icon: Icons.info, title: 'About', items: {}),
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
    final defaultText = scheme.onSurface!;

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
  final SettingsData settingsData;

  const SettingsContent({super.key, this.tab, this.item, required this.settingsData});

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case 'general':
        return GeneralSettingsTab(item: item, settingsData: settingsData);
      case 'appearance':

      case 'about':

      default:
        return GeneralSettingsTab(item: item, settingsData: settingsData);
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
  final SettingsData settingsData;
  const GeneralSettingsTab({super.key, this.item, required this.settingsData});

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