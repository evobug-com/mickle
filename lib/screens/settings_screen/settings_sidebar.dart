import 'package:flutter/material.dart';
import 'package:talk/screens/settings_screen/settings_models.dart';

import '../../core/notifiers/theme_controller.dart';
import 'settings_provider.dart';

class SettingsSidebar extends StatefulWidget {
  final bool isSearching;
  final Function(bool) onSearch;
  
  final SettingsTabController settingsTabController;

  const SettingsSidebar({
    super.key,
    required this.isSearching,
    required this.onSearch,
    required this.settingsTabController,
  });

  @override
  State<SettingsSidebar> createState() => _SettingsSidebarState();
}

class _SettingsSidebarState extends State<SettingsSidebar> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSettings = getFilteredSettings();

    return SizedBox(
      width: 250,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(6.0),
                //   child: _buildSearchInput(scheme),
                // ),
                Expanded(
                  child: widget.isSearching
                      ? _buildSearchResults(filteredSettings)
                      : _buildCategoryList(),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 8),
          // ElevatedButton(
          //     // minWidth: double.infinity,
          //     // padding: const EdgeInsets.all(16),
          //     style: ElevatedButton.styleFrom(
          //       minimumSize: Size(double.infinity, 48),
          //     ),
          //     onPressed: () {
          //       if (context.canPop()) {
          //         context.pop();
          //       } else {
          //         context.go('/chat');
          //       }
          //     },
          //     child: Text('Back')),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> getFilteredSettings() {
    return widget.settingsTabController.categories.expand((setting) {
      return setting.items.values
          .map((item) {
        final matchResult = _matchesSearchQuery(item.name, searchQuery);
        if (matchResult.isMatch) {
          return {
            'tab': setting.tab,
            'item': item,
            'matches': matchResult.matchIndices
          };
        } else {
          return null;
        }
      })
          .where((result) => result != null)
          .toList()
          .cast<Map<String, dynamic>>();
    }).toList();
  }

  Widget _buildHighlightedText(
      String text, List<int> matchIndices, BuildContext context) {
    final scheme = ThemeController.scheme(context, listen: false);
    final defaultText = scheme.onSurface;

    final textSpans = <TextSpan>[];
    int lastMatchIndex = -1;

    for (int i = 0; i < text.length; i++) {
      if (matchIndices.contains(i)) {
        if (i != lastMatchIndex + 1) {
          textSpans.add(TextSpan(
              text: text.substring(lastMatchIndex + 1, i),
              style: TextStyle(color: defaultText)));
        }
        textSpans.add(TextSpan(
            text: text[i],
            style:
            TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)));
        lastMatchIndex = i;
      }
    }

    if (lastMatchIndex != text.length - 1) {
      textSpans.add(TextSpan(
          text: text.substring(lastMatchIndex + 1),
          style: TextStyle(color: defaultText)));
    }

    return RichText(text: TextSpan(children: textSpans));
  }

  TextField _buildSearchInput(ColorScheme scheme) {
    return TextField(
                    controller: _searchController,
                    autofocus: widget.isSearching,
                    decoration: InputDecoration(
                      hintText: 'Search settings',
                      prefixIcon:
                          Icon(Icons.search, color: scheme.onSurfaceVariant),
                      suffixIcon: widget.isSearching
                          ? IconButton(
                              icon: Icon(Icons.close,
                                  color: scheme.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearch(false);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onTap: () => widget.onSearch(true),
                    onChanged: (query) => setState(() => searchQuery = query),
                  );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> filteredSettings) {
    return ListView.builder(
      itemCount: filteredSettings.length,
      itemBuilder: (context, index) {
        final result = filteredSettings[index];
        final item = result['item'] as SettingItem;
        final matches = result['matches'] as List<int>;
        final category = widget.settingsTabController.categories
            .firstWhere((element) => element.tab == result['tab']);

        return ListTile(
          leading: Icon(category.icon,
              color: ThemeController.scheme(context).primary),
          title: _buildHighlightedText(item.name, matches, context),
          subtitle: Text(category.title,
              style: TextStyle(
                  color: ThemeController.scheme(context).onSurfaceVariant)),
          onTap: () {
            widget.settingsTabController.setCurrent(
              tab: result['tab']!,
              item: item.key,
            );
            widget.onSearch(false);
          },
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return ListenableBuilder(
      listenable: widget.settingsTabController,
      builder: (context, _) {
        return ListView.builder(
          itemCount: widget.settingsTabController.categories.length,
          itemBuilder: (context, index) {
            final setting = widget.settingsTabController.categories[index];
            final scheme = ThemeController.scheme(context);
            final isSelected = widget.settingsTabController.tab == setting.tab;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? scheme.surfaceContainerHigh : Colors.transparent,
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
                  widget.settingsTabController.setCurrent(tab: setting.tab);
                  // context.pushReplacementNamed('settings',
                  //     queryParameters: {'tab': setting.tab});
                },
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
        );
      }
    );
  }
}


class MatchResult {
  final bool isMatch;
  final List<int> matchIndices;

  MatchResult(this.isMatch, this.matchIndices);
}

MatchResult _matchesSearchQuery(String item, String query) {
  // Normalize the query and item strings by replacing -_ with space and removing extra spaces
  final normalizedQuery = query
      .toLowerCase()
      .replaceAll(RegExp(r'[-_]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final normalizedItem = item
      .toLowerCase()
      .replaceAll(RegExp(r'[-_]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // Split query into words
  final queryWords = normalizedQuery.split(' ');

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
        matchIndices.removeRange(
            matchIndices.length - queryWordIndex, matchIndices.length);
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