import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/core/providers/global/selected_server_provider.dart';
import 'package:talk/layout/my_scaffold.dart';

import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final result = await AuthService().autoLogin(context, selectedServerProvider: SelectedServerProvider.of(context, listen: false));
    if(!result) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyScaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}