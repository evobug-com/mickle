import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/areas/connection/connection_manager.dart';
import 'package:talk/layout/my_scaffold.dart';

import '../core/providers/global/selected_server_provider.dart';
import '../generated/l10n.dart';
import 'login_screen/login_form.dart';

final _logger = Logger('LoginScreen');
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // if (auth.errorMessage != null || auth.isLoading) {
        //   print("Error or loading");
        //   return MyScaffold(
        //     body: ConnectionWidget(
        //       client: auth.currentLoggingClient,
        //       onCancel: auth.abortLogin,
        //       errorMessage: auth.errorMessage,
        //     ),
        //   );
        // }

        return MyScaffold(
          showSidebar: ConnectionManager().connections.isNotEmpty,
          showSearchBar: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWelcomeMessage(context),
                    const SizedBox(width: 32),
                    LoginForm(onLogin: (username, password, serverHost) async {
                      final connection = await ConnectionManager().connect('$serverHost:55000');
                      if(connection.error != null) {
                        // TODO: Show error?
                        return;
                      }

                      await connection.authenticate(username: username, password: password);
                      if(connection.error != null) {
                        // TODO: Show error?
                        return;
                      }

                      // Save the connection
                      await ConnectionManager().save(connection);
                      SelectedServerProvider.of(context, listen: false).selectServer(connection);
                      context.goNamed('chat');
                      _logger.fine("Logged in successfully");
                    }),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).loginScreenWelcomeTester, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          Text(S.of(context).loginScreenThisIsAnUnpublishedTestingVersionOfMickleYourCredentials),
        ],
      ),
    );
  }
}