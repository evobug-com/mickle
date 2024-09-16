import 'package:flutter/material.dart';

class KeyedTextEditingController extends TextEditingController {
  final String key;

  KeyedTextEditingController(this.key, {super.text});
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
      tab: 'server',
      icon: Icons.settings_remote,
      title: 'Server',
      items: {
        // Change Password
        'server-change-password': SettingItem(
            tab: 'server',
            key: 'server-change-password',
            name: 'Change Password'
        ),

        // Delete Account
        'server-delete-account': SettingItem(
            tab: 'server',
            key: 'server-delete-account',
            name: 'Delete Account'
        ),

        // Multi Factor Authentication
        'server-multi-factor-authentication': SettingItem(
            tab: 'server',
            key: 'server-multi-factor-authentication',
            name: 'Multi Factor Authentication'
        ),

        // Email
        'server-email': SettingItem(
            tab: 'server',
            key: 'server-email',
            name: 'Email'
        ),

        // First Name
        'server-first-name': SettingItem(
            tab: 'server',
            key: 'server-first-name',
            name: 'First Name'
        ),

        // Last Name
        'server-last-name': SettingItem(
            tab: 'server',
            key: 'server-last-name',
            name: 'Last Name'
        ),

        // Display Name
        'server-display-name': SettingItem(
            tab: 'server',
            key: 'server-display-name',
            name: 'Display Name'
        ),

        // Username
        'server-username': SettingItem(
            tab: 'server',
            key: 'server-username',
            name: 'Username'
        ),
      }
  ),
  SettingMetadata(
      tab: 'general',
      icon: Icons.home,
      title: 'Home',
      items: {
        // Language
        'general-language': SettingItem(
            tab: 'general',
            key: 'general-language',
            name: 'Language'
        ),
      }
  ),
  SettingMetadata(
      tab: 'behaviour',
      icon: Icons.rule,
      title: 'Behaviour',
      items: {
        'behaviour-autostartup': SettingItem(
            tab: 'behaviour',
            key: 'behaviour-autostartup',
            name: 'Launch at startup'
        ),
        'behaviour-exit-to-tray': SettingItem(
            tab: 'behaviour',
            key: 'behaviour-exit-to-tray',
            name: 'Exit to tray'
        ),
        'behaviour-send-message-on-enter': SettingItem(
            tab: 'behaviour',
            key: 'behaviour-send-message-on-enter',
            name: 'Send message on Enter'
        ),
        'behaviour-message-date-format': SettingItem(
            tab: 'behaviour',
            key: 'behaviour-message-date-format',
            name: 'Message Date Format'
        ),
      }
  ),
  SettingMetadata(tab: 'notifications', icon: Icons.notifications, title: 'Notifications',
      items: {
        'notifications-sound-any-message': SettingItem(tab: 'notifications', key: 'notifications-sound-any-message', name: 'Sound on Any Message'),
        'notifications-sound-mention': SettingItem(tab: 'notifications', key: 'notifications-sound-mention', name: 'Sound on Mention'),
        'notifications-sound-error': SettingItem(tab: 'notifications', key: 'notifications-sound-error', name: 'Sound on Error'),
        'notifications-desktop': SettingItem(tab: 'notifications', key: 'notifications-desktop', name: 'Desktop Notifications'),
      }),
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
    'about-version': SettingItem(
        tab: 'about',
        key: 'about-version',
        name: 'Version'
    ),
    'about-developer': SettingItem(
        tab: 'about',
        key: 'about-developer',
        name: 'Developer'
    ),
  }),
];


