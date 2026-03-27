import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _textSize = 16.0;
  Color _primaryColor = const Color(0xFF00494D); // Default teal primary color
  double _colorBrightness =
      0.0; // Range from -1.0 (darker) to 1.0 (lighter), 0.0 is original

  // Default values
  static const bool DEFAULT_DARK_MODE = false;
  static const double DEFAULT_TEXT_SIZE = 16.0;
  static const Color DEFAULT_PRIMARY_COLOR = Color(0xFF00494D); // Default teal

  bool get isDarkMode => _isDarkMode;
  double get textSize => _textSize;
  Color get primaryColor => _primaryColor;
  double get colorBrightness => _colorBrightness;

  // Get the adjusted primary color based on brightness
  Color get adjustedPrimaryColor {
    if (_colorBrightness == 0.0) return _primaryColor;

    final HSLColor hsl = HSLColor.fromColor(_primaryColor);
    double lightness = hsl.lightness;

    // Adjust lightness based on brightness value
    if (_colorBrightness > 0) {
      // Make lighter (increase lightness, but cap at 1.0)
      lightness = lightness + (_colorBrightness * (1.0 - lightness));
    } else {
      // Make darker (decrease lightness, but keep above 0.0)
      lightness = lightness * (1.0 + _colorBrightness);
    }

    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  // Get the current theme based on dark mode setting
  ThemeData get theme => _isDarkMode ? _buildDarkTheme() : _buildLightTheme();

  // Build a complete dark theme
  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: adjustedPrimaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: adjustedPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: ThemeData.dark().bottomNavigationBarTheme
          .copyWith(
            backgroundColor: const Color(0xFF1E1E1E),
            selectedItemColor: adjustedPrimaryColor,
            unselectedItemColor: Colors.grey,
          ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      colorScheme: ColorScheme.dark(
        primary: adjustedPrimaryColor,
        secondary: adjustedPrimaryColor.withOpacity(0.7),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: Colors.redAccent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3E3E3E),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white70,
        textColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return adjustedPrimaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return adjustedPrimaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: adjustedPrimaryColor,
        thumbColor: adjustedPrimaryColor,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Build a complete light theme
  ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: adjustedPrimaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: adjustedPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: ThemeData.light().bottomNavigationBarTheme
          .copyWith(
            backgroundColor: Colors.white,
            selectedItemColor: adjustedPrimaryColor,
            unselectedItemColor: Colors.grey,
          ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF333333)),
        bodyMedium: TextStyle(color: Color(0xFF333333)),
        titleLarge: TextStyle(color: Color(0xFF333333)),
        titleMedium: TextStyle(color: Color(0xFF333333)),
        titleSmall: TextStyle(color: Color(0xFF333333)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      colorScheme: ColorScheme.light(
        primary: adjustedPrimaryColor,
        secondary: adjustedPrimaryColor.withOpacity(0.7),
        surface: Colors.white,
        background: const Color(0xFFF5F7FA),
        error: Colors.redAccent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF666666),
        textColor: Color(0xFF333333),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return adjustedPrimaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return adjustedPrimaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: adjustedPrimaryColor,
        thumbColor: adjustedPrimaryColor,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  AppSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? DEFAULT_DARK_MODE;
    _textSize = prefs.getDouble('textSize') ?? DEFAULT_TEXT_SIZE;
    _colorBrightness = prefs.getDouble('colorBrightness') ?? 0.0;

    // Load primary color if saved
    final primaryColorValue = prefs.getInt('primaryColor');
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setTextSize(double value) async {
    _textSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', value);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  Future<void> setColorBrightness(double value) async {
    _colorBrightness = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('colorBrightness', value);
    notifyListeners();
  }

  // Get text style with appropriate color based on dark mode
  TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: (fontSize ?? _textSize),
      fontWeight: fontWeight,
      color: color ?? (_isDarkMode ? Colors.white : Colors.black87),
      height: height,
    );
  }

  // Get sidebar background color based on theme
  Color get sidebarBackgroundColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : adjustedPrimaryColor;

  // Get sidebar text color based on theme
  Color get sidebarTextColor => Colors.white;

  // Get sidebar icon color based on theme
  Color get sidebarIconColor => Colors.white70;

  // Reset all settings to default values
  Future<void> resetToDefaults() async {
    _isDarkMode = DEFAULT_DARK_MODE;
    _textSize = DEFAULT_TEXT_SIZE;
    _primaryColor = DEFAULT_PRIMARY_COLOR;
    _colorBrightness = 0.0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', DEFAULT_DARK_MODE);
    await prefs.setDouble('textSize', DEFAULT_TEXT_SIZE);
    await prefs.setInt('primaryColor', DEFAULT_PRIMARY_COLOR.value);
    await prefs.setDouble('colorBrightness', 0.0);

    notifyListeners();
  }
}
