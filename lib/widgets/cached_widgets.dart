import 'package:flutter/material.dart';

class CachedWidgets {
  static final Map<String, Widget> _widgetCache = {};

  static Widget getCachedWidget(String key, Widget Function() builder) {
    return _widgetCache.putIfAbsent(key, builder);
  }

  static void clearCache() {
    _widgetCache.clear();
  }
}

// Example usage:
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildExpensiveHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Column(
        children: [
          Text(
            'Welcome to Sibhate Finot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Your spiritual music companion',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CachedWidgets.getCachedWidget('home_header', _buildExpensiveHeader);
  }
}
