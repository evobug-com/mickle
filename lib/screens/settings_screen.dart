import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/areas/utilities/elevation.dart';
import 'package:talk/screens/settings_screen/settings_content.dart';
import 'package:talk/screens/settings_screen/settings_models.dart';
import 'package:talk/screens/settings_screen/settings_provider.dart';
import 'package:talk/screens/settings_screen/settings_sidebar.dart';
import '../layout/my_scaffold.dart';

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

    final currentCategory =
        settingsCategories.firstWhere((element) => element.tab == widget.tab);
    if (widget.item != null && currentCategory.items.containsKey(widget.item)) {
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
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsSidebar(
                      settingsCategories: settingsCategories,
                      tab: widget.tab,
                      isSearching: isSearching,
                      onSearch: (isSearching) {
                        setState(() {
                          this.isSearching = isSearching;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    if (!isSearching) ...[
                      Expanded(
                          child: ListenableBuilder(
                              listenable: SettingsProvider(),
                              builder: (context, child) {
                                return Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SettingsContent(
                                      tab: widget.tab,
                                      item: widget.item),
                                );
                              })),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
