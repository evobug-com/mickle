import 'package:flutter/material.dart';
import 'package:talk/areas/utilities/elevation.dart';

import '../../core/surfaces.dart';

class SidebarBox extends StatelessWidget {
  final Widget child;

  const SidebarBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Elevation(
        borderRadius: BorderRadius.circular(12),
        border: false,
        child: child);
  }
}