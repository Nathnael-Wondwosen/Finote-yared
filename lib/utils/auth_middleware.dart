import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Correct import
import '../screens/admin_login_screen.dart';

class AuthMiddleware {
  static Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdminLoggedIn') ?? false;
  }

  static Future<void> checkAuth(BuildContext context) async {
    if (!await isAdminLoggedIn()) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        );
      }
    }
  }
}
