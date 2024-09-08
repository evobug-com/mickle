import 'package:flutter/material.dart';

import '../../core/surfaces.dart';

class SidebarBox extends StatelessWidget {
  final Widget child;

  const SidebarBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Surface.surfaceContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.surfaceContainerHighest),
        ),
        child: child);
  }
}