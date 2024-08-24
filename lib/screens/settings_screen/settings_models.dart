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
      tab: 'general',
      icon: Icons.home,
      title: 'Home',
      items: {
        'home-autostartup': SettingItem(tab: 'general', key: 'home-autostartup', name: 'Autostartup'),
        'home-exit-to-tray': SettingItem(tab: 'general', key: 'home-exit-to-tray', name: 'Exit to Tray'),
        'display-name': SettingItem(tab: 'general', key: 'display-name', name: 'Display Name'),
        // 'account-email': SettingItem(tab: 'general', key: 'account-email', name: 'Account Email'),
        'account-password': SettingItem(tab: 'general', key: 'account-password', name: 'Account Password'),
        'account-logout': SettingItem(tab: 'general', key: 'account-logout', name: 'Account Logout'),
      }
  ),
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
    'about-version': SettingItem(tab: 'about', key: 'about-version', name: 'Version'),
  }),
];


