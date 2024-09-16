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
      setTheme(theme);
    }
  }

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    _currentThemeName = themes.firstWhere((element) => element.value == theme).name;
    print("Theme set to $_currentThemeName");
    notifyListeners();
  }

  static TextTheme get textThemeDark {
    return Typography.englishLike2021;
  }

  static TextTheme get textThemeLight {
    return Typography.englishLike2021;
  }
  
  static final themes = [

    ThemeItem("M3 Dark", ThemeData.dark(useMaterial3: true)),
    ThemeItem("M3 Light", ThemeData.light(useMaterial3: true)),

    ThemeItem("Dark", MaterialTheme(textThemeDark).dark()),
    ThemeItem("Dark High Contrast", MaterialTheme(textThemeDark).darkHighContrast()),
    ThemeItem("Dark Medium Contrast", MaterialTheme(textThemeDark).darkMediumContrast()),

    ThemeItem("Light", MaterialTheme(textThemeLight).light()),
    ThemeItem("Light High Contrast", MaterialTheme(textThemeLight).lightHighContrast()),
    ThemeItem("Light Medium Contrast", MaterialTheme(textThemeLight).lightMediumContrast()),

    ThemeItem("Light Green", MaterialTheme(textThemeLight).lightGreen()),
    ThemeItem("Dark Green", MaterialTheme(textThemeDark).darkGreen()),
    ThemeItem("Light Blue", MaterialTheme(textThemeLight).lightBlue()),
    ThemeItem("Dark Blue", MaterialTheme(textThemeDark).darkBlue()),
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
