import 'package:flutter_test/flutter_test.dart';
import 'package:mickle/core/widget_keys.dart';

class LoginScreenSnippet {
  final WidgetTester tester;
  LoginScreenSnippet({required this.tester});

  void verify() {
    final loginScreen = find.byKey(WidgetKeys.loginScreen);
    expect(loginScreen, findsOneWidget);
  }


}