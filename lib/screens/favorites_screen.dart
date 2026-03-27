import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../song_lyrics_screen.dart';
import '../base_layout.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  int _currentNavIndex = 1; // Set to 1 for Favorites tab
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await DBHelper.instance.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading favorites: $e')));
      }
    }
  }

  Future<void> _removeFavorite(int songId) async {
    try {
      await DBHelper.instance.toggleFavorite(songId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
      _loadFavorites(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing favorite: $e')));
    }
  }

  // Build bottom navigation similar to HomeScreen
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
          _buildNavItem(2, Icons.search, 'ፍለጋ'), // Changed from book to search
          _buildNavItem(3, Icons.settings, 'ማስተካከያ'),
        ],
      ),
    );
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
          // Already on favorites - no navigation needed
        } else if (index == 2) {
          // Navigate to Search screen (changed from Books)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
            (route) => false,
          );
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
            color:
                isSelected
                    ? settings.primaryColor
                    : settings.isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected
                      ? settings.primaryColor
                      : settings.isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: settings.primaryColor,
        elevation: 0,
        title: const Text(
          'ተወዳጆች',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        body: RefreshIndicator(
          onRefresh: _loadFavorites,
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _favorites.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color:
                              settings.isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                settings.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add songs to your favorites',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                settings.isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final song = _favorites[index];
                      return Dismissible(
                        key: Key(song['id'].toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeFavorite(song['id']);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color:
                              settings.isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: settings.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              song['title'] ?? 'Untitled',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    settings.isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              song['category'] ?? 'Unknown Category',
                              style: TextStyle(
                                color:
                                    settings.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeFavorite(song['id']),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SongLyricsScreen(
                                        title: song['title'] ?? 'Untitled',
                                        lyrics: song['lyrics'] ?? '',
                                        songId: song['id'],
                                      ),
                                ),
                              ).then((_) => _loadFavorites());
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }
}
