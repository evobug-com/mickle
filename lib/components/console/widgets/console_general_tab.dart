import 'package:flutter/material.dart';
import 'package:talk/components/console/components/console_autostartup_item.dart';
import 'package:talk/components/console/components/console_autoupdate_item.dart';
import 'package:talk/components/console/components/console_change_avatar_item.dart';
import 'package:talk/components/console/components/console_change_display_name_item.dart';
import 'package:talk/components/console/components/console_change_password_item.dart';
import 'package:talk/components/console/components/console_change_presence_item.dart';
import 'package:talk/components/console/components/console_change_status_item.dart';
import 'package:talk/components/console/components/console_change_theme_item.dart';
import 'package:talk/components/console/components/console_list_roles_item.dart';

class ConsoleGeneralTab extends StatefulWidget {
  const ConsoleGeneralTab({super.key});

  @override
  ConsoleGeneralTabState createState() => ConsoleGeneralTabState();
}

class ConsoleGeneralTabState extends State<ConsoleGeneralTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ConsoleAutoStartupItem(),
        const ConsoleAutoUpdateItem(),
        const ConsoleChangeAvatarItem(),
        const ConsoleChangeDisplayNameItem(),
        const ConsoleChangePasswordItem(),
        const ConsoleChangePresenceItem(),
        const ConsoleChangeStatusItem(),
        const ConsoleChangeThemeItem(),
        const ConsoleListRolesItem()
      ],
    );
  }
}