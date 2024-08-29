import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/layout/my_scaffold.dart';
import 'package:talk/services/auth_service.dart';
import 'login_screen/login_constants.dart';

final _logger = Logger('SplashScreen');

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = _attemptAutoLogin();
  }

  Future<bool> _attemptAutoLogin() async {
    try {
      final selectedServerProvider = SelectedServerProvider.of(context, listen: false);
      return await AuthService().autoLogin(
        context,
        selectedServerProvider: selectedServerProvider,
      ).timeout(const Duration(seconds: AppConstants.autoLoginTimeout));
    } catch (e) {
      _logger.warning('Auto-login failed: $e');
      if(e is Error) {
        _logger.warning(e.stackTrace);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return MyScaffold(
      body: FutureBuilder<bool>(
        future: _autoLoginFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (snapshot.data == true) {
                context.go('/chat');
              } else {
                context.go('/login');
              }
            });
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}