
import 'package:flutter/material.dart';

class ElevationInherited extends InheritedWidget {
  final int elevation;

  const ElevationInherited({
    super.key,
    required this.elevation,
    required super.child,
  });

  static ElevationInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ElevationInherited>();
  }

  @override
  bool updateShouldNotify(ElevationInherited oldWidget) {
    return elevation != oldWidget.elevation;
  }
}