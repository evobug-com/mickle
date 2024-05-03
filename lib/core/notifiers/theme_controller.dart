import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk/ui/scheme.dart';

class ThemeController extends ChangeNotifier {
  ThemeData _currentTheme = const MaterialTheme(TextTheme()).light();
  String _currentThemeName = "Light";
  ThemeData get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;

  ThemeController({ThemeData? theme}) {
    if(theme != null) {
      _currentTheme = theme;
      _currentThemeName = themes.firstWhere((element) => element.value == theme).name;

      print("Theme set to $_currentThemeName");
    }
  }

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    _currentThemeName = themes.firstWhere((element) => element.value == theme).name;
    notifyListeners();
  }

  static final themes = [
    ThemeItem("Light", MaterialTheme(ThemeData.fallback(useMaterial3: true).textTheme).light()),
    ThemeItem("Light High Contrast", MaterialTheme(ThemeData.fallback(useMaterial3: true).textTheme).lightHighContrast()),
    ThemeItem("Light Medium Contrast", MaterialTheme(ThemeData.fallback(useMaterial3: true).textTheme).lightMediumContrast()),
    ThemeItem("Dark", MaterialTheme(ThemeData.fallback(useMaterial3: true).textTheme).dark()),
    ThemeItem("Dark High Contrast", MaterialTheme(ThemeData.fallback(useMaterial3: true).textTheme).darkHighContrast()),
    ThemeItem("Dark Medium Contrast", MaterialTheme(ThemeData.fallback(useMaterial3: true).textTheme).darkMediumContrast()),
  ];

  static ColorScheme scheme(BuildContext context, {bool listen = true}) {
    return of(context, listen: listen).currentTheme.colorScheme;
    return Theme.of(context).colorScheme;
  }

  static ThemeData theme(BuildContext context, {bool listen = true}) {
    return of(context, listen: listen).currentTheme;
    return Theme.of(context);
  }

  static ThemeController of(BuildContext context, {bool listen = true}) {
    return Provider.of<ThemeController>(context, listen: listen);
  }
}

class ThemeItem {
  final String name;
  final ThemeData value;
  const ThemeItem(this.name, this.value);
}
