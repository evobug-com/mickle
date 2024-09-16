import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_utils.dart';
import 'schemes.dart';

class ThemeController extends ChangeNotifier {
  ThemeData _currentTheme;
  String _currentThemeName;

  ThemeData get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;

  static const defaultTheme = 'Dark';

  ThemeController({ThemeData? theme}):
        _currentTheme = theme ?? themes.firstWhere((element) => element.name == defaultTheme).value,
        _currentThemeName = theme != null ? themes.firstWhere((element) => element.value == theme).name : defaultTheme;

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    _currentThemeName = themes.firstWhere((element) => element.value == theme).name;
    print("Theme set to $_currentThemeName");
    notifyListeners();
  }

  static final TextTheme _textTheme = Typography.material2021().black;

  static final themes = [
    ThemeItem(
      "M3 Light",
      generateThemeData(
        colorScheme: ThemeData.light(useMaterial3: true).colorScheme,
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "M3 Dark",
      generateThemeData(
        colorScheme: ThemeData.dark(useMaterial3: true).colorScheme,
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Light",
      generateThemeData(
        colorScheme: CustomColorSchemes.lightScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Dark",
      generateThemeData(
        colorScheme: CustomColorSchemes.darkScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Light High Contrast",
      generateThemeData(
        colorScheme: CustomColorSchemes.lightHighContrastScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Dark High Contrast",
      generateThemeData(
        colorScheme: CustomColorSchemes.darkHighContrastScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Light Medium Contrast",
      generateThemeData(
        colorScheme: CustomColorSchemes.lightMediumContrastScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Dark Medium Contrast",
      generateThemeData(
        colorScheme: CustomColorSchemes.darkMediumContrastScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Light Green",
      generateThemeData(
        colorScheme: CustomColorSchemes.lightGreenScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Dark Green",
      generateThemeData(
        colorScheme: CustomColorSchemes.darkGreenScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Light Blue",
      generateThemeData(
        colorScheme: CustomColorSchemes.lightBlueScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
    ThemeItem(
      "Dark Blue",
      generateThemeData(
        colorScheme: CustomColorSchemes.darkBlueScheme.toColorScheme(),
        textTheme: _textTheme,
      ),
    ),
  ];

  static ColorScheme scheme(BuildContext context, {bool listen = true}) {
    return of(context, listen: listen).currentTheme.colorScheme;
  }

  static ThemeData theme(BuildContext context, {bool listen = true}) {
    return of(context, listen: listen).currentTheme;
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