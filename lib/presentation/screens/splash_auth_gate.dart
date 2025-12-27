import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashAuthGate extends StatefulWidget {
  const SplashAuthGate({super.key});

  @override
  State<SplashAuthGate> createState() => _SplashAuthGateState();
}

class _SplashAuthGateState extends State<SplashAuthGate> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isValid = await _authService.isSessionValid();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isValid ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
