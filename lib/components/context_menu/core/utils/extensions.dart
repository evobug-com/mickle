import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';

extension BuildContextExtensions on BuildContext {
  Rect? getWidgetBounds() {
    final widgetRenderBox = findRenderObject() as RenderBox?;
    if (widgetRenderBox == null) return null;
    final widgetPosition = widgetRenderBox.localToGlobal(Offset.zero);
    final widgetSize = widgetRenderBox.size;
    return widgetPosition & widgetSize;
  }

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

final Tween<double> reverseTween = Tween<double>(
  begin: 0,
  end: -1,
);

/// Extension on [Animation<double>] to provide reverse animation functionality.
/// Returns an [Animation<double>] that goes from 0 to -1, reversing the direction of the original animation.
extension ReverseAnimation on Animation<double> {
  Animation<double> toReversed() {
    return reverseTween.animate(this);
  }
}


extension DateTimeExtension on DateTime {

  DateTime toLocal() {
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch, isUtc: true).toLocal();
  }

  get formatted {
    return DateFormat(SettingsProvider().messageDateFormat).format(this);
  }
}