import 'package:flutter_test/flutter_test.dart';

import 'snippets/login_screen_snippet.dart';
import 'utils.dart';
import 'snippets/first_time_screen_snippet.dart';

void main() async {
  final createAppWidget = await initTestEnvironment();
  late FirstTimeScreenSnippet snippet;

  group('E2E - ', () {
    testWidgets("First Start", (tester) async {
      await tester.pumpWidget(createAppWidget());
      await tester.pumpAndSettle();
      snippet = FirstTimeScreenSnippet(tester: tester);

      snippet.verify();
      await snippet.tapFreshStartButton();
      await snippet.tapNextButton();
      await snippet.tapThemeButton("Dark Blue");
      await snippet.verifyTheme("Dark Blue");
      await snippet.tapNextButton();
      await snippet.tapLaunchAtStartupSwitch();
      await snippet.verifyLaunchAtStartup(true);
      await snippet.tapLaunchAtStartupSwitch();
      await snippet.verifyLaunchAtStartup(false);
      await snippet.tapExitToTraySwitch();
      await snippet.verifyExitToTray(false);
      await snippet.tapExitToTraySwitch();
      await snippet.verifyExitToTray(true);
      await snippet.tapNextButton();
      await snippet.tapLaunchMickleButton();
    });

    testWidgets("Not first start", (tester) async {
      await tester.pumpWidget(createAppWidget());
      await tester.pumpAndSettle();

      // Expect to be on the login screen
      final LoginScreenSnippet loginSnippet = LoginScreenSnippet(tester: tester);
      loginSnippet.verify();
    });
  });
}