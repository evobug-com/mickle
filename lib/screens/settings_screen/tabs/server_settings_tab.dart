import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:mickle/core/providers/scoped/connection_provider.dart';
import 'package:mickle/screens/settings_screen/settings_widgets.dart';
import 'package:mickle/ui/text_field_list_tile.dart';
import '../settings_models.dart';
import '../settings_provider.dart';

class ServerSettingsTab extends StatefulWidget {
  final SettingsTabController settingsTabController;
  
  const ServerSettingsTab({super.key, required this.settingsTabController});

  @override
  State<ServerSettingsTab> createState() => _ServerSettingsTabState();
}

class _ServerSettingsTabState extends State<ServerSettingsTab> {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _firstNameController = TextEditingController();
  late final TextEditingController _lastNameController = TextEditingController();
  late final TextEditingController _usernameController = TextEditingController();
  late final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = ConnectionProvider.of(context, listen: false).user;
    _emailController.text = user.email ?? '';
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _usernameController.text = user.username ?? '';
    _displayNameController.text = user.displayName ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final category = widget.settingsTabController.categories.firstWhere((element) => element.tab == 'server');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingTitle(category: category),
        Expanded(
          child: ListView(
            children: [
              buildSettingsSection(
                  context,
                  "${_displayNameController.text}'s Account",
                  [
                    _buildUsername(category.items),
                    _buildChangePassword(category.items),
                    _buildMultiFactorAuthentication(category.items),
                    _buildEmail(category.items),

                    _buildFirstName(category.items),
                    _buildLastName(category.items),
                    _buildDeleteAccount(category.items),
                    _buildSubmitButton(context),
                  ]
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          BotToast.showText(text: 'Submit');
        },
        child: const Text('Submit'),
      ),
    );
  }

  Widget _buildChangePassword(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-change-password']!.key,
      child: ListTile(
        title: Text(items['server-change-password']!.name),
        onTap: () {
          // Navigator.of(context).pushNamed('/settings/server/change-password');
        },
      ),
    );
  }

  Widget _buildMultiFactorAuthentication(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-multi-factor-authentication']!.key,
      child: ListTile(
        title: Text(items['server-multi-factor-authentication']!.name),
        onTap: () {
          // Navigator.of(context).pushNamed('/settings/server/multi-factor-authentication');
        },
      ),
    );
  }

  Widget _buildEmail(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-email']!.key,
      child: TextFieldListTile(
        title: items['server-email']!.name,
        subtitle: 'This email is used for account recovery and notifications',
        controller: _emailController,
      )
    );
  }

  Widget _buildFirstName(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-first-name']!.key,
      child: TextFieldListTile(
        title: items['server-first-name']!.name,
        controller: _firstNameController,
      )
    );
  }

  Widget _buildLastName(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-last-name']!.key,
      child: TextFieldListTile(
        title: items['server-last-name']!.name,
        controller: _lastNameController,
      )
    );
  }

  Widget _buildUsername(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-username']!.key,
      child: TextFieldListTile(
        title: items['server-username']!.name,
        controller: _usernameController,
        enabled: false,
      )
    );
  }

  Widget _buildDeleteAccount(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.settingsTabController.item == items['server-delete-account']!.key,
      child: ListTile(
        title: Text(items['server-delete-account']!.name),
        onTap: () {
          // Navigator.of(context).pushNamed('/settings/server/delete-account');
        },
      ),
    );
  }
}