import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import '../home_screen.dart' as legacy_home;

/// This widget decides which screen to show on app launch.
class LaunchDecider extends StatefulWidget {
  const LaunchDecider({super.key});

  @override
  State<LaunchDecider> createState() => _LaunchDeciderState();
}

class _LaunchDeciderState extends State<LaunchDecider> {
  bool? _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('is_first_launch') ?? true;
    if (isFirst) {
      await prefs.setBool('is_first_launch', false);
    }
    setState(() {
      _isFirstLaunch = isFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLaunch == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Show legacy HomeScreen (intro) only on first launch, otherwise show main HomeScreen from screens/
    return _isFirstLaunch!
        ? const legacy_home.HomeScreen()
        : const HomeScreen();
  }
}
