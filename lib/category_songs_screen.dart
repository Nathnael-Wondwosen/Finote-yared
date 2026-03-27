import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';
import 'song_lyrics_screen.dart';
import 'db_helper.dart';

class CategorySongsScreen extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> songs;

  const CategorySongsScreen({
    super.key,
    required this.category,
    required this.songs,
  });

  @override
  State<CategorySongsScreen> createState() => CategorySongsScreenState();
}

class CategorySongsScreenState extends State<CategorySongsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  Map<int, bool> _favoritesMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    setState(() => _isLoading = true);
    try {
      for (var song in widget.songs) {
        if (song['id'] != null) {
          final songData = await DBHelper.instance.getSongById(song['id']);
          if (songData.isNotEmpty) {
            setState(() {
              _favoritesMap[song['id']] = songData.first['is_favorite'] == 1;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(int songId) async {
    setState(() => _isLoading = true);
    try {
      await DBHelper.instance.toggleFavorite(songId);
      setState(() {
        _favoritesMap[songId] = !(_favoritesMap[songId] ?? false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoritesMap[songId] ?? false
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: _isScrolled ? 1 : 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: settings.adjustedPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: TextStyle(
            color: settings.adjustedPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: settings.adjustedPrimaryColor),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _CategorySearchDelegate(widget.songs, settings),
              );
            },
          ),
        ],
      ),
      body:
          widget.songs.isEmpty ? _buildEmptyState() : _buildSongsList(settings),
    );
  }

  Widget _buildEmptyState() {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'በዚህ ምድብ ውስጥ መዝሙሮች የሉም',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(AppSettingsProvider settings) {
    final isDark = settings.isDarkMode;

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: widget.songs.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
      itemBuilder:
          (context, index) => _buildSongItem(widget.songs[index], settings),
    );
  }

  Widget _buildSongItem(
    Map<String, dynamic> song,
    AppSettingsProvider settings,
  ) {
    final isDark = settings.isDarkMode;
    final songId = song['id'] as int;
    final isFavorite = _favoritesMap[songId] ?? false;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: settings.adjustedPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.music_note,
          color: settings.adjustedPrimaryColor,
          size: 20,
        ),
      ),
      title: Text(
        song['title'] ?? 'Untitled',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF333333),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Tap to view lyrics',
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color:
              isFavorite
                  ? Colors.red
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        onPressed: () => _toggleFavorite(songId),
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
        ).then((_) => _loadFavoriteStatus());
      },
    );
  }
}

class _CategorySearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> songs;
  final AppSettingsProvider settings;

  _CategorySearchDelegate(this.songs, this.settings);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = settings.isDarkMode;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(color: settings.adjustedPrimaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredSongs =
        query.isEmpty
            ? songs
            : songs
                .where(
                  (song) => song['title'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();

    final isDark = settings.isDarkMode;

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredSongs.length,
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
        itemBuilder: (context, index) {
          final song = filteredSongs[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: settings.adjustedPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.music_note,
                color: settings.adjustedPrimaryColor,
                size: 20,
              ),
            ),
            title: Text(
              song['title'] ?? 'Untitled',
              style: TextStyle(
                color: isDark ? Colors.white : settings.adjustedPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Tap to view lyrics',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            onTap: () {
              close(context, '');
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
              );
            },
          );
        },
      ),
    );
  }
}
