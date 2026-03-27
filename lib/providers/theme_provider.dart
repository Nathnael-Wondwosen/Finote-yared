import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  double _textSize = 16.0;

  bool get isDarkMode => _isDarkMode;
  double get textSize => _textSize;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _textSize = prefs.getDouble('textSize') ?? 16.0;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setTextSize(double size) async {
    _textSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', _textSize);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
          primaryColor: Colors.teal,
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.tealAccent,
          ),
        )
        : ThemeData.light().copyWith(
          primaryColor: Colors.teal,
          colorScheme: const ColorScheme.light(
            primary: Colors.teal,
            secondary: Colors.tealAccent,
          ),
        );
  }
}
