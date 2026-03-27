import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zema_finot.db');
    await ensureAdminTable();
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      // Get the database path
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      // Check if database exists
      final exists = await databaseExists(path);

      // If database exists but might be corrupted, delete it
      if (exists) {
        try {
          // Try to open it first to see if it's valid
          final testDb = await openDatabase(path, readOnly: true);
          await testDb.close();
        } catch (e) {
          print('Database exists but might be corrupted: $e');
          print('Deleting and recreating database...');
          await deleteDatabase(path);
        }
      }

      // Create directory if it doesn't exist
      final directory = Directory(dbPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Ensure the directory is writable
      if (!await directory.exists() || !await _isDirectoryWritable(directory)) {
        // Try to use application documents directory as fallback
        final appDocDir = await getApplicationDocumentsDirectory();
        final alternatePath = join(appDocDir.path, filePath);
        print('Using alternate database path: $alternatePath');

        return await openDatabase(
          alternatePath,
          version: 1,
          onCreate: _onCreate,
          onConfigure: _onConfigure,
          readOnly: false,
        );
      }

      print('Opening database at: $path');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
        readOnly: false,
      );
    } catch (e) {
      print('Error initializing database: $e');
      // Use in-memory database as last resort
      print('Falling back to in-memory database');
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
        readOnly: false,
      );
    }
  }

  // Helper method to check if a directory is writable
  Future<bool> _isDirectoryWritable(Directory directory) async {
    try {
      final testFile = File('${directory.path}/write_test.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      print('Directory is not writable: $e');
      return false;
    }
  }

  Future<void> _onConfigure(Database db) async {
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      await db.execute('PRAGMA journal_mode = DELETE');
      await db.execute('PRAGMA synchronous = OFF');
      await db.execute('PRAGMA temp_store = MEMORY');
    } catch (e) {
      print('Database configuration error: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    // Create admin credentials table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_credentials (
        id $idType,
        username $textType,
        password $textType
      )
    ''');

    // Insert default admin credentials
    await db.insert('admin_credentials', {
      'username': 'finotit',
      'password': 'sibhatefinot29',
    });

    // Create categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id $idType,
        category $textType,
        description TEXT
      )
    ''');

    // Create songs table (corrected)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS songs (
        id $idType,
        title $textType,
        lyrics $textType,
        category_id INTEGER,
        is_favorite INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Load initial data after creating tables
    await _loadInitialData(db);
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      // Load JSON data from assets
      final String jsonString = await rootBundle.loadString(
        'assets/songs.json',
      );
      final List<dynamic> songsData = json.decode(jsonString);

      // Create a set to track unique categories
      final Set<String> uniqueCategories = {};

      // Extract unique categories from songs
      for (var song in songsData) {
        if (song['category'] != null) {
          uniqueCategories.add(song['category'].toString());
        }
      }

      // Insert categories and maintain a map of category names to IDs
      final Map<String, int> categoryIds = {};
      final batch = db.batch();

      // Insert categories
      for (String category in uniqueCategories) {
        batch.insert('categories', {
          'category': category,
          'description': 'Description for $category',
        });
      }

      // Execute category insertions
      final results = await batch.commit();

      // Create category name to ID mapping
      for (int i = 0; i < uniqueCategories.length; i++) {
        categoryIds[uniqueCategories.elementAt(i)] = results[i] as int;
      }

      // Insert songs with proper category_id references
      final songBatch = db.batch();

      for (var song in songsData) {
        final categoryId = categoryIds[song['category']];
        if (categoryId != null) {
          songBatch.insert('songs', {
            'title': song['title'],
            'lyrics': song['lyrics'],
            'category_id': categoryId,
          });
        }
      }

      // Execute song insertions
      await songBatch.commit();

      print('Initial data loaded successfully');
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  // Method to check if database is empty
  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) count FROM songs');
    final count = Sqflite.firstIntValue(result);
    return count == 0;
  }

  Future<void> reloadInitialData() async {
    final db = await database;
    try {
      // Start a transaction
      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('songs');
        await txn.delete('categories');

        // Load JSON data from assets
        final String jsonString = await rootBundle.loadString(
          'assets/songs.json',
        );
        final List<dynamic> songsData = json.decode(jsonString);

        // Create a set to track unique categories
        final Set<String> uniqueCategories = {};

        // Extract unique categories from songs
        for (var song in songsData) {
          if (song['category'] != null) {
            uniqueCategories.add(song['category'].toString());
          }
        }

        // Insert categories and maintain a map of category names to IDs
        final Map<String, int> categoryIds = {};

        // Insert categories
        for (String category in uniqueCategories) {
          final categoryId = await txn.insert('categories', {
            'category': category,
            'description': 'Description for $category',
          });
          categoryIds[category] = categoryId;
        }

        // Insert songs with proper category_id references
        for (var song in songsData) {
          final categoryId = categoryIds[song['category']];
          if (categoryId != null) {
            await txn.insert('songs', {
              'title': song['title'],
              'lyrics': song['lyrics'],
              'category_id': categoryId,
            });
          }
        }
      });

      print('Initial data reloaded successfully');
    } catch (e) {
      print('Error reloading initial data: $e');
      throw Exception('Failed to reload initial data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getSongs({int? limit}) async {
    final db = await database;
    final query = '''
      SELECT songs.*, categories.category 
      FROM songs 
      LEFT JOIN categories ON songs.category_id = categories.id 
      ORDER BY songs.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';

    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getSongsByCategory(String category) async {
    try {
      final db = await database;
      return await db.rawQuery(
        '''
        SELECT 
          songs.id,
          songs.title,
          songs.lyrics,
          songs.is_favorite,
          songs.category_id,
          categories.category
        FROM songs 
        JOIN categories ON songs.category_id = categories.id 
        WHERE categories.category = ?
        ''',
        [category],
      );
    } catch (e) {
      print('Error getting songs by category: $e');
      return [];
    }
  }

  // Add this method to help debug
  Future<void> checkDatabaseContent() async {
    final db = await database;
    print('Checking database content...');

    // Check categories
    final categories = await db.query('categories');
    print('Categories: $categories');

    // Check songs
    final songs = await db.query('songs');
    print('Songs: $songs');
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<int> insertSong(Map<String, dynamic> song) async {
    final db = await database;

    // First, ensure the category exists and get its ID
    final categoryResult = await db.query(
      'categories',
      columns: ['id'],
      where: 'category = ?',
      whereArgs: [song['category']],
    );

    int categoryId;
    if (categoryResult.isEmpty) {
      // Category doesn't exist, create it
      categoryId = await insertCategory({
        'category': song['category'],
        'description': 'Description for ${song['category']}',
      });
    } else {
      categoryId = categoryResult.first['id'] as int;
    }

    // Insert the song with the correct category_id
    return await db.insert('songs', {
      'title': song['title'],
      'lyrics': song['lyrics'],
      'category_id': categoryId,
    });
  }

  Future<bool> verifyAdminCredentials(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'admin_credentials',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<void> ensureAdminTable() async {
    final db = await database;
    try {
      // Check if admin_credentials table exists
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'admin_credentials'],
      );

      if (tables.isEmpty) {
        // Create admin credentials table if it doesn't exist
        await db.execute('''
          CREATE TABLE admin_credentials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Insert default admin credentials
        await db.insert('admin_credentials', {
          'username': 'finotit',
          'password': 'sibhatefinot29',
        });

        print('Admin credentials table created and initialized');
      }
    } catch (e) {
      print('Error ensuring admin table: $e');
    }
  }

  Future<void> deleteSong(int id) async {
    final db = await database;
    try {
      await db.delete('songs', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting song: $e');
      throw Exception('Failed to delete song: $e');
    }
  }

  Future<void> updateSong(
    int id,
    String title,
    String category,
    String lyrics,
  ) async {
    final db = await database;
    await db.update(
      'songs',
      {'title': title, 'category': category, 'lyrics': lyrics},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    final db = await database;
    await db.transaction((txn) async {
      // First delete all songs in this category
      await txn.delete(
        'songs',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );

      // Then delete the category itself
      await txn.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
    });
  }

  Future<void> updateCategory(int id, String newName) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'categories',
        {'category': newName},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // Get all favorite songs
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT songs.*, categories.category 
      FROM songs 
      LEFT JOIN categories ON songs.category_id = categories.id 
      WHERE songs.is_favorite = 1
    ''');
  }

  // Toggle favorite status for a song
  Future<void> toggleFavorite(int songId) async {
    final db = await database;
    final song = await db.query(
      'songs',
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [songId],
    );

    final currentFavorite = song.first['is_favorite'] as int;
    final newFavorite = currentFavorite == 1 ? 0 : 1;

    await db.update(
      'songs',
      {'is_favorite': newFavorite},
      where: 'id = ?',
      whereArgs: [songId],
    );
  }

  Future<List<Map<String, dynamic>>> searchSongs(
    String query, {
    String? category,
  }) async {
    try {
      // For debugging
      print('Searching with query: "$query", category: $category');

      // Get all songs (or filtered by category)
      List<Map<String, dynamic>> allSongs;

      if (category != null) {
        allSongs = await getSongsByCategory(category);
      } else {
        allSongs = await getSongs();
      }

      // If no query, return all songs (or all in category)
      if (query.isEmpty) {
        return allSongs;
      }

      // Filter in memory (avoids SQLite issues with non-Latin characters)
      final queryLower = query.toLowerCase();
      final filteredSongs =
          allSongs.where((song) {
            final title = (song['title'] ?? '').toString().toLowerCase();
            final lyrics = (song['lyrics'] ?? '').toString().toLowerCase();

            return title.contains(queryLower) || lyrics.contains(queryLower);
          }).toList();

      print('Found ${filteredSongs.length} results');
      return filteredSongs;
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  Future<int> getSongCountByCategory(String category) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM songs WHERE category = ?',
      [category],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getSongById(int id) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT songs.*, categories.category 
      FROM songs 
      LEFT JOIN categories ON songs.category_id = categories.id 
      WHERE songs.id = ?
    ''',
      [id],
    );
  }
}
