import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  final Uri _linkedInUrl = Uri.parse(
    'https://www.linkedin.com/in/haridharushan-s-v-3a484b257/',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F8FC),
              Color(0xFFECEFF4),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 🔹 MAIN LOGIN CONTENT
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/applogo.png',
                          height: 72,
                        ),
                      ),

                      const SizedBox(height: 42),

                      _inputField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      _inputField(
                        controller: _passCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            elevation: 6,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.black.withOpacity(0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ).copyWith(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((_) => null),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2B2E4A),
                                  Color(0xFF1F2235),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.1,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 FOOTER (BOTTOM CENTER)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTap: _openLinkedIn,
                    child: const Text(
                      'Made with ❤️ by Haridharushan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- LOGIN ----------------

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showErrorDialog('Please enter email and password');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      _showErrorDialog('Invalid email or password');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------- LINKEDIN ----------------

  Future<void> _openLinkedIn() async {
    if (!await launchUrl(
      _linkedInUrl,
      mode: LaunchMode.externalApplication,
    )) {
      _showErrorDialog('Could not open LinkedIn profile');
    }
  }

  // ---------------- ERROR POPUP ----------------

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2B2E4A),
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF2B2E4A),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2B2E4A),
            width: 1.6,
          ),
        ),
      ),
    );
  }
}
