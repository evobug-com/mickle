
import 'package:flutter/material.dart';
import '../settings_provider.dart';
import '../settings_widgets.dart';

class GeneralSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  
  const GeneralSettingsTab({super.key, required this.settingsTabController});

  @override
  State<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends State<GeneralSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'general');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(category: category),
        Expanded(
            child: ListView(
              children: [],
            )
        )

      ],
    );

  }
}