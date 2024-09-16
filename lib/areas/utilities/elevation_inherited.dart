
import 'package:flutter/material.dart';

class ElevationInherited extends InheritedWidget {
  final int elevation;

  const ElevationInherited({
    Key? key,
    required this.elevation,
    required Widget child,
  }) : super(key: key, child: child);

  static ElevationInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ElevationInherited>();
  }

  @override
  bool updateShouldNotify(ElevationInherited oldWidget) {
    return elevation != oldWidget.elevation;
  }
}