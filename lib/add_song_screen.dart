import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'utils/auth_middleware.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  AddSongScreenState createState() => AddSongScreenState();
}

class AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper.instance;
  String _title = '';
  String _lyrics = '';
  String? _category;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _isCustomCategory = false; // New flag for custom category

  @override
  void initState() {
    super.initState();
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAuth(context);
    });
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      _formKey.currentState!.save();
      await _dbHelper.insertSong({
        'title': _title,
        'lyrics': _lyrics,
        'category': _category,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song added successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding song: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Song',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              // Switch between dropdown and text input
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child:
                            !_isCustomCategory
                                ? Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        constraints.maxWidth -
                                        48, // Account for icon button
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    isDense:
                                        true, // Makes the dropdown more compact
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    value: _category,
                                    items:
                                        _categories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value:
                                                category['category'] as String,
                                            child: Text(
                                              category['category'] as String,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                    validator: (value) {
                                      if (!_isCustomCategory &&
                                          (value == null || value.isEmpty)) {
                                        return 'Please select a category';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _category = value;
                                      });
                                    },
                                  ),
                                )
                                : TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'New Category',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (_isCustomCategory &&
                                        (value == null || value.isEmpty)) {
                                      return 'Please enter a category name';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _category = value;
                                  },
                                ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: Icon(
                            _isCustomCategory ? Icons.list : Icons.add,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCustomCategory = !_isCustomCategory;
                              _category = null;
                            });
                          },
                          tooltip:
                              _isCustomCategory
                                  ? 'Select from existing categories'
                                  : 'Add new category',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Lyrics',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lyrics';
                  }
                  return null;
                },
                onSaved: (value) => _lyrics = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSong,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Add Song'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
