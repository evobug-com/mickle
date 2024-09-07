
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/screens/settings_screen/settings_models.dart';

import '../../core/notifiers/theme_controller.dart';

class SettingsSidebar extends StatefulWidget {
  final String? tab;
  final bool isSearching;
  final Function(bool) onSearch;
  final List<SettingMetadata> settingsCategories;

  const SettingsSidebar({
    super.key,
    this.tab,
    required this.isSearching,
    required this.onSearch,
    required this.settingsCategories,
  });

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 48,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: widget.isSearching,
                decoration: InputDecoration(
                  hintText: 'Search settings',
                  prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
                  suffixIcon: widget.isSearching
                      ? IconButton(
                    icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearch(false);
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onTap: () => widget.onSearch(true),
                onChanged: (query) => setState(() => searchQuery = query),
              ),
            ),
          ),
          Expanded(
            child: widget.isSearching
                ? _buildSearchResults(filteredSettings)
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchResults(List<Map<String, dynamic>> filteredSettings) {
    return ListView.builder(
      itemCount: filteredSettings.length,
      itemBuilder: (context, index) {
        final result = filteredSettings[index];
        final item = result['item'] as SettingItem;
        final matches = result['matches'] as List<int>;
        final category = widget.settingsCategories.firstWhere((element) => element.tab == result['tab']);

        return ListTile(
          leading: Icon(category.icon, color: ThemeController.scheme(context).primary),
          title: _buildHighlightedText(item.name, matches, context),
          subtitle: Text(category.title, style: TextStyle(color: ThemeController.scheme(context).onSurfaceVariant)),
          onTap: () {
            context.pushReplacementNamed(
              'settings',
              queryParameters: {'tab': result['tab']!, 'item': item.key},
            );
            widget.onSearch(false);
          },
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: widget.settingsCategories.length,
      itemBuilder: (context, index) {
        final setting = widget.settingsCategories[index];
        final scheme = ThemeController.scheme(context);
        final isSelected = widget.tab == setting.tab;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? scheme.surfaceContainerHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              setting.icon,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            title: Text(
              setting.title,
              style: TextStyle(
                color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              context.pushReplacementNamed('settings', queryParameters: {'tab': setting.tab});
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
    );
  }
}