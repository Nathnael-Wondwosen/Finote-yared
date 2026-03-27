import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';

class InitializationService {
  static Future<void> initializeApp() async {
    return compute(_initializeInBackground, null);
  }

  static Future<void> _initializeInBackground(void _) async {
    try {
      final dbHelper = DBHelper.instance;
      // Use database getter instead of initializeDatabase
      await dbHelper.database;
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  static Future<void> preloadAssets(List<String> assetPaths) async {
    final chunks = _splitList(assetPaths, 5); // Process 5 assets at a time
    for (final chunk in chunks) {
      await Future.wait(chunk.map((path) => _loadAsset(path)));
    }
  }

  static Future<void> _loadAsset(String path) async {
    try {
      await rootBundle.load(path);
    } catch (e) {
      debugPrint('Asset loading error: $e');
    }
  }

  static List<List<T>> _splitList<T>(List<T> list, int chunkSize) {
    return List.generate(
      (list.length / chunkSize).ceil(),
      (i) => list.skip(i * chunkSize).take(chunkSize).toList(),
    );
  }
}
