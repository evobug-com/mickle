import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mickle/areas/connection/connection_manager.dart';
import 'package:mickle/areas/utilities/elevation.dart';
import 'package:mickle/core/providers/global/selected_server_provider.dart';
import 'package:mickle/layout/my_scaffold.dart';
import 'package:mickle/generated/l10n.dart';

import '../areas/connection/connection.dart';
import 'login_screen/login_connection_diagnostics.dart';

class LoginRegistrationScreen extends StatefulWidget {
  const LoginRegistrationScreen({Key? key}) : super(key: key);

  @override
  _LoginRegistrationScreenState createState() => _LoginRegistrationScreenState();
}

class _LoginRegistrationScreenState extends State<LoginRegistrationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _serverHostController = TextEditingController(text: "localhost");
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _serverSelected = false;
  String? _errorMessage;
  Connection? _currentConnection;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serverHostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyScaffold(
      showSidebar: ConnectionManager().connections.length > 1,
      showSearchBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
              colorScheme.tertiary
            ],
          ),
        ),
        child: Center(
          child: Elevation(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).loginScreenWelcome((_currentConnection?.connectionUrl != null) ? 'to \n${_currentConnection!.connectionUrl}' : ''),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms).slide(),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).loginScreenThisIsAnUnpublishedTestingVersionOfMickleYourCredentials,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    const SizedBox(height: 32),
                    if (!_serverSelected) ...[
                      _buildServerHostField(),
                      const SizedBox(height: 16),
                      _buildContinueButton(),
                      if (_errorMessage != null)
                        _buildErrorMessage(),
                    ] else ...[
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: S.of(context).loginScreenLogin),
                          Tab(text: S.of(context).loginScreenRegister),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        child: ListenableBuilder(
                          listenable: _tabController,
                          builder: (context, _) {
                            return SizedBox(
                              height: _tabController.index == 0 ? 250 : 350,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  SingleChildScrollView(child: _buildLoginTab()),
                                  SingleChildScrollView(child: _buildRegisterTab()),
                                ],
                              ),
                            );
                          }
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 300, // Adjust this value as needed
      child: _currentConnection != null
          ? LoginConnectionDiagnostics(
        serverHost: _serverHostController.text,
        connection: _currentConnection!,
      )
          : const SizedBox(), // Or some placeholder widget if no connection
    );
  }

  Widget _buildServerHostField() {
    return TextFormField(
      controller: _serverHostController,
      decoration: InputDecoration(
        labelText: S.of(context).loginScreenServerHost,
        prefixIcon: const Icon(Icons.computer),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).loginScreenServerHostRequired;
        }
        return null;
      },
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _checkServerConnection,
      child: _isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
        ),
      )
          : Text(S.of(context).loginScreenContinue),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildLoginButton(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slide(),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRepasswordField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 32),
          _buildRegisterButton(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slide(),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: S.of(context).loginScreenUsername,
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).loginScreenUsernameRequired;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: S.of(context).loginScreenPassword,
        prefixIcon: const Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).loginScreenPasswordRequired;
        }
        return null;
      },
    );
  }

  Widget _buildRepasswordField() {
    return TextFormField(
      controller: _repasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: S.of(context).loginScreenRePassword,
        prefixIcon: const Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).loginScreenRePasswordRequired;
        }
        if (value != _passwordController.text) {
          return S.of(context).loginScreenPasswordsDoNotMatch;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: S.of(context).loginScreenEmail,
        prefixIcon: const Icon(Icons.email),
        helperText: S.of(context).loginScreenEmailHelperText,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && !value.contains('@')) {
          return S.of(context).loginScreenInvalidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      child: _isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
        ),
      )
          : Text(S.of(context).loginScreenLogin),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
      child: _isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
        ),
      )
          : Text(S.of(context).loginScreenRegister),
    );
  }

  void _checkServerConnection() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        _currentConnection = await ConnectionManager().connect(
          '${_serverHostController.text}:55000',
          disableAutoReconnect: true,
        );

        if (_currentConnection!.error != null) {
          setState(() {
            _errorMessage = S.of(context).loginScreenServerConnectionErrorDetailed;
          });
        } else {
          setState(() {
            _serverSelected = true;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = S.of(context).loginScreenUnexpectedErrorDetailed;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (_currentConnection == null) {
          _currentConnection = await ConnectionManager().connect(
            '${_serverHostController.text}:55000'
          );
        }

        if (_currentConnection!.error != null) {
          setState(() {
            _errorMessage = S.of(context).loginScreenConnectionError;
          });
          return;
        }

        final authResult = await _currentConnection!.authenticate(
          username: _usernameController.text,
          password: _passwordController.text,
        );

        if (_currentConnection!.error != null) {
          setState(() {
            _errorMessage = S.of(context).loginScreenAuthenticationError(_currentConnection!.error!.message);
          });
          return;
        }

        await ConnectionManager().save(_currentConnection!);
        SelectedServerProvider.of(context, listen: false).selectServer(_currentConnection);
        context.goNamed('chat');
      } catch (e) {
        setState(() {
          _errorMessage = S.of(context).loginScreenUnexpectedError;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Implement registration logic here
        // For now, we'll just show a success message
        await Future.delayed(const Duration(seconds: 2)); // Simulating network request
        context.goNamed('chat'); // Redirect to chat screen after successful registration
      } catch (e) {
        setState(() {
          _errorMessage = S.of(context).loginScreenUnexpectedError;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}