import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';
import '../providers/app_settings_provider.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import '../song_lyrics_screen.dart';
import '../base_layout.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  int _currentNavIndex = 2; // Set to 2 for Search tab

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // Set initial query if provided (from voice search)
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Perform search with a slight delay to allow the screen to build
      Future.delayed(const Duration(milliseconds: 300), () {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await DBHelper.instance.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty && _selectedCategory == null) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await DBHelper.instance.searchSongs(
        query,
        category: _selectedCategory,
      );

      // Sort results by relevance if there's a query
      if (query.isNotEmpty) {
        results.sort((a, b) {
          final aTitle = a['title']?.toString().toLowerCase() ?? '';
          final bTitle = b['title']?.toString().toLowerCase() ?? '';
          final queryLower = query.toLowerCase();

          // If title starts with query, it's more relevant
          final aStartsWithQuery = aTitle.startsWith(queryLower);
          final bStartsWithQuery = bTitle.startsWith(queryLower);

          if (aStartsWithQuery && !bStartsWithQuery) return -1;
          if (!aStartsWithQuery && bStartsWithQuery) return 1;

          // Otherwise sort alphabetically
          return aTitle.compareTo(bTitle);
        });
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error searching: $e')));
      }
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });

        // Handle navigation based on index
        if (index == 0) {
          // Navigate to Home screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else if (index == 1) {
          // Navigate to Favorites screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            (route) => false,
          );
        } else if (index == 2) {
          // Already on Search screen - no navigation needed
        } else if (index == 3) {
          // Navigate to Settings screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
            (route) => false,
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? settings.primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? settings.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'መነሻ'),
          _buildNavItem(1, Icons.favorite, 'ተወዳጆች'),
          _buildNavItem(2, Icons.search, 'ፍለጋ'),
          _buildNavItem(3, Icons.settings, 'ማስተካከያ'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: settings.primaryColor,
        title: const Text('ፍለጋ'),
        elevation: 0,
      ),
      child: Column(
        children: [
          // Search input and filters
          Container(
            padding: const EdgeInsets.all(16.0),
            color: settings.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
            child: Column(
              children: [
                // Search input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'መዝሙር ይፈልጉ...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: settings.primaryColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onChanged: (value) {
                    _debouncer.run(() => _performSearch(value));
                  },
                ),
                const SizedBox(height: 12),

                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All" filter
                      FilterChip(
                        label: Text(
                          'ሁሉም',
                          style: TextStyle(
                            color:
                                _selectedCategory == null
                                    ? settings.primaryColor
                                    : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                          _performSearch(_searchController.text);
                        },
                        backgroundColor:
                            isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        selectedColor: settings.primaryColor.withOpacity(0.2),
                        checkmarkColor: settings.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color:
                                _selectedCategory == null
                                    ? settings.primaryColor
                                    : (isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!),
                            width: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Category filters
                      ..._categories.map((category) {
                        final categoryName = category['category'] as String;
                        final isSelected = _selectedCategory == categoryName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(
                              categoryName,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? settings.primaryColor
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory =
                                    selected ? categoryName : null;
                              });
                              _performSearch(_searchController.text);
                            },
                            backgroundColor:
                                isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            selectedColor: settings.primaryColor.withOpacity(
                              0.2,
                            ),
                            checkmarkColor: settings.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? settings.primaryColor
                                        : (isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!),
                                width: 1.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: settings.primaryColor,
                      ),
                    )
                    : _searchResults.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isEmpty
                                ? Icons.search
                                : Icons.search_off,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'መዝሙር ለመፈለግ ይጀምሩ'
                                : 'ምንም ውጤት አልተገኘም',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final song = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              song['title'] ?? 'ያልታወቀ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              song['category'] ?? 'ያልታወቀ ምድብ',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onTap: () async {
                              // Save to recently viewed
                              try {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final recentlyViewedJson =
                                    prefs.getString('recently_viewed_songs') ??
                                    '[]';
                                final recentlyViewed = List<
                                  Map<String, dynamic>
                                >.from(
                                  (jsonDecode(recentlyViewedJson) as List).map(
                                    (item) => Map<String, dynamic>.from(item),
                                  ),
                                );

                                // Remove if already exists
                                recentlyViewed.removeWhere(
                                  (item) => item['id'] == song['id'],
                                );

                                // Add to beginning of list
                                recentlyViewed.insert(0, {
                                  'id': song['id'],
                                  'title': song['title'],
                                  'category': song['category'],
                                  'timestamp':
                                      DateTime.now().millisecondsSinceEpoch,
                                });

                                // Keep only the most recent 10
                                if (recentlyViewed.length > 10) {
                                  recentlyViewed.removeRange(
                                    10,
                                    recentlyViewed.length,
                                  );
                                }

                                // Save back to prefs
                                await prefs.setString(
                                  'recently_viewed_songs',
                                  jsonEncode(recentlyViewed),
                                );
                              } catch (e) {
                                debugPrint(
                                  'Error saving recently viewed song: $e',
                                );
                              }

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => SongLyricsScreen(
                                          title: song['title'] ?? 'ያልታወቀ',
                                          lyrics: song['lyrics'] ?? '',
                                          songId: song['id'],
                                        ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
