import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talk/ui/scheme.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._();

  factory ThemeController() => _instance;

  ThemeController._();

  ThemeData _theme = MaterialTheme(TextTheme()).light();

  ThemeData get theme => _theme;

  void setTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  final themes = [
    ThemeItem("Light", MaterialTheme(TextTheme()).light()),
    ThemeItem("Light High Contrast", MaterialTheme(TextTheme()).lightHighContrast()),
    ThemeItem("Light Medium Contrast", MaterialTheme(TextTheme()).lightMediumContrast()),
    ThemeItem("Dark", MaterialTheme(TextTheme()).dark()),
    ThemeItem("Dark High Contrast", MaterialTheme(TextTheme()).darkHighContrast()),
    ThemeItem("Dark Medium Contrast", MaterialTheme(TextTheme()).darkMediumContrast()),
  ];
}


class ThemeItem {
  final String name;
  final ThemeData theme;

  const ThemeItem(this.name, this.theme);

}
