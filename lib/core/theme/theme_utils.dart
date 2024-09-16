import 'package:flutter/material.dart';

ThemeData generateThemeData({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );
}