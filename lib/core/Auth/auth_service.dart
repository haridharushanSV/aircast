import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _loginTimeKey = 'login_time';
  static const sessionDuration = Duration(days: 3);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(
      _loginTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    return result.user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginTimeKey);
    await _auth.signOut();
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_loginTimeKey);

    if (loginTime == null) return false;

    final lastLogin = DateTime.fromMillisecondsSinceEpoch(loginTime);

    return DateTime.now().difference(lastLogin).compareTo(sessionDuration) < 0;
  }
}
