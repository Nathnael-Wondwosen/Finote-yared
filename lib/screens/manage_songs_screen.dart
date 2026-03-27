import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../utils/auth_middleware.dart';

class ManageSongsScreen extends StatefulWidget {
  const ManageSongsScreen({super.key});

  @override
  State<ManageSongsScreen> createState() => _ManageSongsScreenState();
}

class _ManageSongsScreenState extends State<ManageSongsScreen> {
  final DBHelper _dbHelper = DBHelper.instance;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAuth(context);
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final isEmpty = await _dbHelper.isDatabaseEmpty();
      if (isEmpty) {
        await _dbHelper.reloadInitialData();
      }

      final categories = await _dbHelper.getCategories();
      setState(() {
        _categories = categories;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editCategory(Map<String, dynamic> category) async {
    final TextEditingController controller = TextEditingController(
      text: category['category'],
    );

    final newName = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Category Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != category['category']) {
      try {
        await _dbHelper.updateCategory(category['id'] as int, newName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating category: $e')),
          );
        }
      }
    }
  }

  Future<void> _editSong(Map<String, dynamic> song) async {
    final titleController = TextEditingController(text: song['title']);
    final lyricsController = TextEditingController(text: song['lyrics']);
    String? selectedCategory = song['category'];

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Song'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem(
                            value: category['category'] as String,
                            child: Text(category['category'] as String),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lyricsController,
                    decoration: const InputDecoration(
                      labelText: 'Lyrics',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _dbHelper.updateSong(
                      song['id'] as int,
                      titleController.text,
                      selectedCategory!,
                      lyricsController.text,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Song updated successfully'),
                        ),
                      );
                      _loadData();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating song: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _viewCategorySongs(Map<String, dynamic> category) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final songs = await _dbHelper.getSongsByCategory(category['category']);
      if (!mounted) return;

      Navigator.pop(context); // Remove loading dialog

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Expanded(child: Text(category['category'])),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                      _editCategory(category);
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child:
                    songs.isEmpty
                        ? const Center(
                          child: Text(
                            'No songs in this category',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return Card(
                              key: ValueKey(song['id']),
                              child: ListTile(
                                title: Text(song['title'] ?? 'Untitled'),
                                subtitle: Text(
                                  'Tap to view lyrics',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: 96,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _editSong(song);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _deleteSong(song);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => _showLyrics(song),
                              ),
                            );
                          },
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading songs: $e')));
      }
    }
  }

  void _showLyrics(Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(song['title'] ?? 'Untitled'),
            content: SingleChildScrollView(
              child: Text(song['lyrics'] ?? 'No lyrics available'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final categoryName = category['category'] as String;
    final songs = await _dbHelper.getSongsByCategory(categoryName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "$categoryName" and all its ${songs.length} songs?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteCategory(category['id'] as int);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category and its songs deleted successfully'),
          ),
        );
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteSong(Map<String, dynamic> song) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Song'),
            content: Text(
              'Are you sure you want to delete "${song['title']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        if (song['id'] == null) {
          throw Exception('Song ID is missing');
        }
        await _dbHelper.deleteSong(song['id'] as int);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song deleted successfully')),
        );
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting song: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Songs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF00494D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    key: ValueKey(category['id']),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(category['category'] ?? 'Unnamed Category'),
                      onTap: () => _viewCategorySongs(category),
                      trailing: SizedBox(
                        width: 96,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editCategory(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(category),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
