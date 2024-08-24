import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/connection/client.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/layout/my_scaffold.dart';

import '../core/providers/global/selected_server_provider.dart';
import 'login_screen/connection_widget.dart';
import 'login_screen/login_constants.dart';
import 'login_screen/login_form.dart';

final _logger = Logger('LoginScreen');
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        if (auth.errorMessage != null || auth.isLoading) {
          return MyScaffold(
            body: ConnectionWidget(
              client: auth.currentLoggingClient,
              onCancel: auth.abortLogin,
              errorMessage: auth.errorMessage,
            ),
          );
        }

        return MyScaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildWelcomeMessage(),
                  const SizedBox(width: 32),
                  LoginForm(onLogin: (username, password, serverHost) {
                    var loginResult = auth.login(context, username: username, password: password, address: ClientAddress(host: serverHost, port: 55000));
                    loginResult.then((client) {
                      // If client is not null, the login was successful
                      if(client != null) {
                        // If login is success, select the server
                        SelectedServerProvider.of(context, listen: false).selectServer(client);
                        // Go to chat screen
                        context.goNamed('chat');
                        _logger.fine("Logged in successfully.");
                      }
                    }).catchError((e) {
                      _logger.severe("Login failed: $e");
                    });
                  }),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.welcomeTester, style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text(AppStrings.testVersionNotice),
        ],
      ),
    );
  }
}