import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';
import 'snippets/login_screen_snippet.dart';

void main() async {
  final createAppWidget = await initTestEnvironment();
  late LoginScreenSnippet snippet;

  group('E2E - ', () {
    testWidgets("Login", (tester) async {
      await tester.pumpWidget(createAppWidget());
      snippet = LoginScreenSnippet(tester: tester);
      snippet.verify();
    });
  });
}