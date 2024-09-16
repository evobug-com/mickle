import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:talk/core/providers/scoped/connection_provider.dart';
import 'package:talk/screens/settings_screen/settings_widgets.dart';
import 'package:talk/ui/text_field_list_tile.dart';
import '../settings_models.dart';

class ServerSettingsTab extends StatefulWidget {
  final String? item;
  final List<SettingMetadata> settingsCategories;
  const ServerSettingsTab({super.key, this.item, required this.settingsCategories});

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
    final items = widget.settingsCategories.firstWhere((element) => element.tab == 'server').items;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Server',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          buildSettingsSection(
              context,
              "${_displayNameController.text}'s Account",
              [
                _buildUsername(items),
                _buildChangePassword(items),
                _buildMultiFactorAuthentication(items),
                _buildEmail(items),

                _buildFirstName(items),
                _buildLastName(items),
                _buildDeleteAccount(items),
                _buildSubmitButton(context),
              ]
          ),
        ],
      ),
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
      highlight: widget.item == items['server-change-password']!.key,
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
      highlight: widget.item == items['server-multi-factor-authentication']!.key,
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
      highlight: widget.item == items['server-email']!.key,
      child: TextFieldListTile(
        title: items['server-email']!.name,
        subtitle: 'This email is used for account recovery and notifications',
        controller: _emailController,
      )
    );
  }

  Widget _buildFirstName(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['server-first-name']!.key,
      child: TextFieldListTile(
        title: items['server-first-name']!.name,
        controller: _firstNameController,
      )
    );
  }

  Widget _buildLastName(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['server-last-name']!.key,
      child: TextFieldListTile(
        title: items['server-last-name']!.name,
        controller: _lastNameController,
      )
    );
  }

  Widget _buildUsername(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['server-username']!.key,
      child: TextFieldListTile(
        title: items['server-username']!.name,
        controller: _usernameController,
        enabled: false,
      )
    );
  }

  Widget _buildDeleteAccount(Map<String, SettingItem> items) {
    return Highlightable(
      highlight: widget.item == items['server-delete-account']!.key,
      child: ListTile(
        title: Text(items['server-delete-account']!.name),
        onTap: () {
          // Navigator.of(context).pushNamed('/settings/server/delete-account');
        },
      ),
    );
  }
}