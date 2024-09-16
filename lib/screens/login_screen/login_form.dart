import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk/areas/utilities/elevation.dart';
import 'package:talk/generated/l10n.dart';

import '../../core/notifiers/theme_controller.dart';
import 'login_validators.dart';

class LoginForm extends StatefulWidget {
  final Function(String username, String password, String serverHost) onLogin;

  const LoginForm({super.key, required this.onLogin});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _serverHostController = TextEditingController(text: kDebugMode ? "localhost" : "vps.sionzee.cz");
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _serverHostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Elevation(
        border: true,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(S.of(context).loginScreenWelcome, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                if (kDebugMode) _buildServerHostField(),
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildFormActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerHostField() {
    return TextFormField(
      controller: _serverHostController,
      decoration: InputDecoration(labelText: S.of(context).loginScreenServerHost),
      validator: Validators.serverHost(context),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(labelText: S.of(context).loginScreenUsername),
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      validator: Validators.username(context),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(labelText: S.of(context).loginScreenPassword),
      validator: Validators.password(context),
    );
  }

  Widget _buildFormActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _handleLogin,
          child: Text(S.of(context).loginScreenLogin),
        ),
        Tooltip(
          message: S.of(context).loginScreenRegistrationIsNotAvailableInThisVersionOfTalk,
          child: TextButton(
            onPressed: null,
            child: Text(S.of(context).loginScreenRegister),
          ),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(
        _usernameController.text,
        _passwordController.text,
        _serverHostController.text,
      );
    }
  }
}