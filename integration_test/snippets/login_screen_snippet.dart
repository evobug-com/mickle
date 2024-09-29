import 'package:flutter_test/flutter_test.dart';
import 'package:mickle/core/storage/preferences.dart';
import 'package:mickle/core/widget_keys.dart';
import 'package:mickle/screens/settings_screen/settings_provider.dart';

class LoginScreenSnippet {
  final WidgetTester tester;
  LoginScreenSnippet({required this.tester});

  void verify() {
    final loginScreen = find.byKey(WidgetKeys.loginScreen);
    expect(loginScreen, findsOneWidget);
  }


}