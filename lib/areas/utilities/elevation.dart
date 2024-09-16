import 'package:flutter/material.dart';

import 'elevation_inherited.dart';

class Elevation extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final bool? border;
  final int? offset;

  const Elevation({super.key, required this.child, this.borderRadius, this.border, this.offset});

  // Surface at elevation +4 and +5 are being deprecated, it is recommended to use Surface Container Highest by default as a replacement.
  // As an alternative Surface Container High, or Surface Dim can be used depending on the specific use case.
  Color? getElevationColor(int currentElevation, BuildContext context) {
    final theme = Theme.of(context);

    switch (currentElevation) {
      case 0:
        return null;
        // return theme.colorScheme.surfaceContainerLowest;
      case 1:
        return theme.colorScheme.surfaceContainerLow;
      case 2:
        return theme.colorScheme.surfaceContainer;
      case 3:
      case 4:
        return theme.colorScheme.surfaceContainerHigh;
    }

    return theme.colorScheme.surfaceContainerHighest;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final parentElevation = ElevationInherited.of(context)?.elevation ?? 0;
        final currentElevation = parentElevation + 1 + (offset ?? 0);
        // print('Elevation: $currentElevation, color: ${getElevationColor(currentElevation, context)}');
        final scheme = Theme.of(context).colorScheme;

        return ElevationInherited(
          elevation: currentElevation,
          child: Material(
            color: getElevationColor(currentElevation, context),
            elevation: currentElevation.toDouble(),
            borderRadius: borderRadius,
            clipBehavior: borderRadius != null ? Clip.hardEdge : Clip.none,
            surfaceTintColor: scheme.surfaceTint,
            textStyle: TextStyle(color: scheme.onSurface),
            child: Container(
              decoration: BoxDecoration(
                border: border == true ? Border.all(color: scheme.outlineVariant) : null,
                borderRadius: borderRadius,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}