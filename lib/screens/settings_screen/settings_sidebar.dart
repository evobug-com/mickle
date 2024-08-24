
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/screens/settings_screen/settings_models.dart';

import '../../core/notifiers/theme_controller.dart';

class SettingsSidebar extends StatefulWidget {
  final String? tab;
  final bool isSearching;
  final Function(bool) onSearch;
  final List<SettingMetadata> settingsCategories;

  const SettingsSidebar({super.key, this.tab, required this.isSearching, required this.onSearch, required this.settingsCategories});

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
    return widget.settingsCategories.expand((setting) {
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
                final category = widget.settingsCategories.firstWhere((element) => element.tab == result['tab']);
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
              children: widget.settingsCategories.map((setting) {
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