import 'package:flutter/material.dart';
import 'package:zema_finot/screens/home_screen.dart';
import 'package:zema_finot/screens/kidus_yared_screen.dart';

class RouteCache {
  static final Map<String, Widget> _cache = {};

  static Widget getRoute(String route) {
    if (_cache.containsKey(route)) {
      return _cache[route]!;
    }

    final widget = _createRoute(route);
    _cache[route] = widget;
    return widget;
  }

  static Widget _createRoute(String route) {
    switch (route) {
      case '/home':
        return const HomeScreen();
      case '/kidus-yared':
        return const KidusYaredScreen();
      // Add other routes
      default:
        return const HomeScreen();
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}
