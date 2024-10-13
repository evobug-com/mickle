import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mickle/screens/settings_screen/settings_content.dart';
import 'package:mickle/screens/settings_screen/settings_models.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';
import 'package:mickle/screens/settings_screen/settings_sidebar.dart';
import '../layout/my_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  final String tab;
  final String? item;

  const SettingsScreen({super.key, required this.tab, this.item});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late final settingsTabController;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    settingsTabController = SettingsTabController(vsync: this, categories: settingsCategories, tab: widget.tab, item: widget.item);

    final currentTab = settingsCategories.firstWhere((element) => element.tab == widget.tab);
    if (widget.item != null && currentTab.items.containsKey(widget.item)) {
      // Scroll to the item after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentItem = currentTab.items[widget.item!];
        _scrollToItem(currentItem!.key);
      });
    }
  }

  void _scrollToItem(String itemKey) {
    // TOOD: scroll to item _scrollController.animateTo()
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: AnimatedContainer(
        padding: const EdgeInsets.all(8),
        duration: const Duration(milliseconds: 300),
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.escape): const ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  if (isSearching) {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSidebar(
                  settingsTabController: settingsTabController,
                  isSearching: isSearching,
                  onSearch: (isSearching) {
                    setState(() {
                      this.isSearching = isSearching;
                    });
                  },
                ),
                const VerticalDivider(
                  width: 20,
                ),
                const SizedBox(width: 8),
                if (!isSearching) ...[
                  Expanded(
                    child: ListenableBuilder(
                      listenable: SettingsPreferencesProvider(),
                      builder: (context, child) {
                        return ClipRect(
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SettingsContent(
                              settingsTabController: settingsTabController,
                            ),
                          ),
                        );
                      })),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
