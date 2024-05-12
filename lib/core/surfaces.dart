import 'package:flutter/material.dart';
import 'package:talk/core/notifiers/theme_controller.dart';

enum SurfaceType {
  lowest,
  low,
  normal,
  high,
  highest,
}

class Surface extends StatelessWidget {
  final Widget child;
  final SurfaceType surfaceType;
  final BoxDecoration? decoration;

  const Surface({super.key, required this.surfaceType, required this.child, this.decoration});

  getColor(BuildContext context, SurfaceType type) {
    switch (type) {
      case SurfaceType.lowest:
        return ThemeController.scheme(context).surfaceContainerLowest;
      case SurfaceType.low:
        return ThemeController.scheme(context).surfaceContainerLow;
      case SurfaceType.normal:
        return ThemeController.scheme(context).surfaceContainer;
      case SurfaceType.high:
        return ThemeController.scheme(context).surfaceContainerHigh;
      case SurfaceType.highest:
        return ThemeController.scheme(context).surfaceContainerHighest;
    }
  }

  getTextColor(BuildContext context, SurfaceType type) {
    switch (type) {
      case SurfaceType.lowest:
        return ThemeController.scheme(context).onSurface;
      case SurfaceType.low:
        return ThemeController.scheme(context).onSurface;
      case SurfaceType.normal:
        return ThemeController.scheme(context).onSurface;
      case SurfaceType.high:
        return ThemeController.scheme(context).onSurface;
      case SurfaceType.highest:
        return ThemeController.scheme(context).onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: (decoration ?? const BoxDecoration()).copyWith(color: getColor(context, surfaceType)),
      child: DefaultTextStyle(
        style: TextStyle(color: getTextColor(context, surfaceType)),
        child: child,
      ),
    );
  }

  const Surface.surfaceContainerLowest({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.lowest;
  const Surface.surfaceContainerLow({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.low;
  const Surface.surfaceContainer({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.normal;
  const Surface.surfaceContainerHigh({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.high;
  const Surface.surfaceContainerHighest({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.highest;
}