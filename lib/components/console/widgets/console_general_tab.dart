import 'package:flutter/material.dart';
import 'package:talk/components/console/components/console_change_password_item.dart';
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
      children: const [
        ConsoleChangePasswordItem(),
        ConsoleListRolesItem()
      ],
    );
  }
}