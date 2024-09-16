import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    switch (type) {
      case SurfaceType.lowest:
        return theme.colorScheme.surfaceContainerLowest;
      case SurfaceType.low:
        return theme.colorScheme.surfaceContainerLow;
      case SurfaceType.normal:
        return theme.colorScheme.surfaceContainer;
      case SurfaceType.high:
        return theme.colorScheme.surfaceContainerHigh;
      case SurfaceType.highest:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  getTextColor(BuildContext context, SurfaceType type) {
    final theme = Theme.of(context);
    switch (type) {
      case SurfaceType.lowest:
        return theme.colorScheme.onSurface;
      case SurfaceType.low:
        return theme.colorScheme.onSurface;
      case SurfaceType.normal:
        return theme.colorScheme.onSurface;
      case SurfaceType.high:
        return theme.colorScheme.onSurface;
      case SurfaceType.highest:
        return theme.colorScheme.onSurface;
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

  // Surface Container Lowest is a new role
  // Surface at elevation +1 becomes Surface Container Low
  // Surface at elevation +2 becomes Surface Container
  // Surface at elevation +3 becomes Surface Container High

  const Surface.surfaceContainerLowest({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.lowest;
  const Surface.surfaceContainerLow({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.low;
  const Surface.surfaceContainer({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.normal;
  const Surface.surfaceContainerHigh({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.high;
  // @deprecated
  const Surface.surfaceContainerHighest({super.key, required this.child, this.decoration}) : surfaceType = SurfaceType.highest;
}