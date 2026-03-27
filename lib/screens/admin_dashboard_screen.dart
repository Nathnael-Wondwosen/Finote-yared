import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';
import '../add_song_screen.dart';
import 'admin_login_screen.dart';
import 'manage_songs_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminLoggedIn', false);

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _loadSongsFromJson(BuildContext context) async {
    try {
      final dbHelper = DBHelper.instance;
      await dbHelper.reloadInitialData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Songs loaded successfully from JSON'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading songs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00494D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: Color(0xFF00494D)),
                title: const Text(
                  'Add New Song',
                  style: TextStyle(
                    color: Color(0xFF00494D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSongScreen(),
                    ),
                  );
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Song added successfully')),
                    );
                  }
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.list, color: Color(0xFF00494D)),
                title: const Text(
                  'Manage Songs',
                  style: TextStyle(
                    color: Color(0xFF00494D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageSongsScreen(),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.file_download,
                  color: Color(0xFF00494D),
                ),
                title: const Text(
                  'Load Songs from JSON',
                  style: TextStyle(
                    color: Color(0xFF00494D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Import songs from assets/songs.json',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Load Songs'),
                          content: const Text(
                            'This will replace all existing songs with the ones from the JSON file. Continue?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Continue'),
                            ),
                          ],
                        ),
                  );

                  if (confirmed == true) {
                    await _loadSongsFromJson(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
