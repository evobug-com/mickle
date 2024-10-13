import 'package:flutter_test/flutter_test.dart';
import 'package:mickle/core/storage/preferences.dart';
import 'package:mickle/core/widget_keys.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';

class FirstTimeScreenSnippet {
  final WidgetTester tester;
  FirstTimeScreenSnippet({required this.tester});

  void verify() {
    final firstTimeScreen = find.byKey(WidgetKeys.firstTimeScreen);
    expect(firstTimeScreen, findsOneWidget);
  }

  Future<void> tapFreshStartButton() async {
    final freshStartButton = find.byKey(WidgetKeys.firstTimeScreenFreshStartButton);
    expect(freshStartButton, findsOneWidget);
    await tester.tap(freshStartButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapNextButton() async {
    final nextButton = find.byKey(WidgetKeys.firstTimeScreenNextButton);
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapThemeButton(String theme) async {
    final themeButton = find.byKey(WidgetKeys.firstTimeScreenThemeDynamicButton(theme));
    expect(themeButton, findsOneWidget);
    await tester.tap(themeButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapLaunchAtStartupSwitch() async {
    final launchAtStartupSwitch = find.byKey(WidgetKeys.firstTimeScreenLaunchAtStartupSwitch);
    expect(launchAtStartupSwitch, findsOneWidget);
    await tester.tap(launchAtStartupSwitch);
    await tester.pumpAndSettle();
  }

  Future<void> tapExitToTraySwitch() async {
    final exitToTraySwitch = find.byKey(WidgetKeys.firstTimeScreenExitToTraySwitch);
    expect(exitToTraySwitch, findsOneWidget);
    await tester.tap(exitToTraySwitch);
    await tester.pumpAndSettle();
  }

  Future<void> tapLaunchMickleButton() async {
    final launchMickleButton = find.byKey(WidgetKeys.firstTimeScreenLaunchMickleButton);
    expect(launchMickleButton, findsOneWidget);
    await tester.tap(launchMickleButton);
    await tester.pumpAndSettle();
  }

  Future<void> verifyLaunchAtStartup(bool expected) async {
    expect(await SettingsPreferencesProvider().getLaunchAtStartup(), expected);
  }

  Future<void> verifyExitToTray(bool expected) async {
    expect(await SettingsPreferencesProvider().getExitToTray(), expected);
  }

  Future<void> verifyTheme(String theme) async {
    expect(await SettingsPreferencesProvider().getTheme(), theme);
  }

  Future<void> verifyIsFirstTime(bool expected) async {
    expect(await Preferences.getIsFirstTime(), expected);
  }
}