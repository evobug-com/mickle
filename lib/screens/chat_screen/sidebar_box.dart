import 'package:flutter/material.dart';

import '../../core/surfaces.dart';

class SidebarBox extends StatelessWidget {
  final Widget child;

  const SidebarBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Material: https://github.com/flutter/flutter/issues/73315
    return Material(
        child: Surface.surfaceContainer(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: child));
  }
}