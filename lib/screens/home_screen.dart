import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../base_layout.dart';
import '../db_helper.dart';
import '../song_lyrics_screen.dart';
import '../category_songs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'dart:math'; // Add this import for min function
import '../services/voice_recognition_service.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> recentSongs = [];
  List<Map<String, dynamic>> allSongs = []; // Store all songs for filtering
  bool _isLoading = true;
  late AnimationController _controller;
  int _currentCarouselIndex = 0;
  int _currentNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample carousel items - replace with actual data
  final List<Map<String, dynamic>> carouselItems = [
    {
      'title': 'ፍኖተ ያሬድ',
      'description': 'የሰሚት መካነ ሰላም ፍኖተ ሰላም ሰንበት ት/ቤት መዝሙር ጥራዝ',
      'image': 'assets/images/homeyared.jpeg',
    },
    {
      'title': 'ዘማሪያን',
      'description': 'የተመረጡ መዝሙሮች',
      'image': 'assets/images/8.jpeg',
    },
    {
      'title': 'ዝማሬዎች',
      'description': 'የሰ/ት/ቤታችን መዝሙሮች/ዝማሬዎች',
      'image': 'assets/images/9.jpeg',
    },

    {
      'title': 'የምስጋና መዝሙሮች',
      'description': 'የተለያዪ ይዘት ያላቸውን ዝማሬዎች',
      'image': 'assets/images/4.jpeg',
    },
    {
      'title': 'የንስሐ መዝሙሮች',
      'description': 'ነፍስን የሚያሳርፉ ቆየት ያሉ የንስሐ ዝማሬዎች',
      'image': 'assets/images/6.jpeg',
    },
    {
      'title': 'ንሴብሖ ለእግዚአብሔር',
      'description': 'የሰ/ት/ቤታችን ዝማሬዎችን እዚህ ያገኛሉ',
      'image': 'assets/images/2.jpeg',
    },

    {
      'title': 'ቤተ ክርስቲያን ባሕረ ጥበባት',
      'description': 'የፊደላት ትርጉም በቤተ ክርስቲያን ምሥጢር ተቃኝቶ',
      'image': 'assets/images/7.jpeg',
    },
  ];

  AudioPlayer? _audioPlayer;
  int? _currentlyPlayingIndex;

  // Map the 6 audios to the first 6 Finote Selam songs
  final List<String> finoteSelamAudioPaths = [
    'audios/memhre.mp3',
    'audios/temahitsenku.mp3',
    'audios/selam.mp3',
    'audios/medhanialem.mp3',
    'audios/lelidetke.mp3',
    'audios/ahadu.mp3',
  ];

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load categories
      final loadedCategories = await DBHelper.instance.getCategories();

      // Get today's songs (changes only once per day)
      final todaysSongs = await _getTodaysSongs(6);

      // Load all songs for filtering
      final loadedAllSongs = await DBHelper.instance.getSongs();

      if (mounted) {
        setState(() {
          categories = loadedCategories;
          recentSongs = todaysSongs;
          allSongs = loadedAllSongs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error in _loadData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  // Get today's songs - songs that are randomly selected but consistent for the day
  Future<List<Map<String, dynamic>>> _getTodaysSongs(int count) async {
    try {
      // Get today's date as a string to use as a seed
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month}-${today.day}';

      // Use shared preferences to store/retrieve today's songs
      final prefs = await SharedPreferences.getInstance();
      final todaySongsKey = 'today_songs_$dateString';

      // Check if we already have songs for today
      final storedSongsJson = prefs.getString(todaySongsKey);
      if (storedSongsJson != null) {
        final decoded = jsonDecode(storedSongsJson) as List;
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      // If not, get new random songs
      final randomSongs = await _getRandomSongsFromDifferentCategories(count);

      // Store today's songs
      await prefs.setString(todaySongsKey, jsonEncode(randomSongs));

      return randomSongs;
    } catch (e) {
      debugPrint('Error getting today\'s songs: $e');
      // Fallback to regular random songs if there's an error
      return await _getRandomSongsFromDifferentCategories(count);
    }
  }

  // Force refresh today's songs
  Future<void> _refreshTodaysSongs() async {
    setState(() => _isLoading = true);

    try {
      // Get new random songs
      final newRandomSongs = await _getRandomSongsFromDifferentCategories(6);

      // Update today's songs in SharedPreferences
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month}-${today.day}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'today_songs_$dateString',
        jsonEncode(newRandomSongs),
      );

      if (mounted) {
        setState(() {
          recentSongs = newRandomSongs;
          _isLoading = false;
        });

        // Show confirmation
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('የዛሬ መዝሙሮች ዘምነዋል')));
      }
    } catch (e) {
      debugPrint('Error refreshing today\'s songs: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error refreshing songs: $e')));
      }
    }
  }

  // Get recently viewed songs from SharedPreferences
  Future<List<Map<String, dynamic>>> _getRecentlyViewedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyViewedJson = prefs.getString('recently_viewed_songs');

      if (recentlyViewedJson != null && recentlyViewedJson.isNotEmpty) {
        final decoded = jsonDecode(recentlyViewedJson) as List;
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading recently viewed songs: $e');
    }

    return [];
  }

  // Save a song to recently viewed
  Future<void> _saveToRecentlyViewed(Map<String, dynamic> song) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get current list
      List<Map<String, dynamic>> recentlyViewed =
          await _getRecentlyViewedSongs();

      // Remove if already exists to avoid duplicates
      recentlyViewed.removeWhere((s) => s['id'] == song['id']);

      // Add to beginning
      recentlyViewed.insert(0, song);

      // Keep only 10 most recent
      if (recentlyViewed.length > 10) {
        recentlyViewed = recentlyViewed.sublist(0, 10);
      }

      // Save back to prefs
      await prefs.setString(
        'recently_viewed_songs',
        jsonEncode(recentlyViewed),
      );

      // Update state if needed
      if (mounted) {
        setState(() {
          recentSongs = recentlyViewed;
        });
      }
    } catch (e) {
      debugPrint('Error saving recently viewed song: $e');
    }
  }

  void _navigateToSongDetails(Map<String, dynamic> song) async {
    // Save to recently viewed before navigation
    await _saveToRecentlyViewed(song);

    if (!mounted) return;

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
    ).then((_) {
      // Refresh the recent songs list when returning from song details
      _loadData();
    });
  }
  // ============================================search bar start============================

  Widget _buildSearchBar() {
    final settings = Provider.of<AppSettingsProvider>(context);

    return GestureDetector(
      onTap: () {
        // Navigate to search screen using MaterialPageRoute instead of named route
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: settings.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          border: Border.all(
            color:
                settings.isDarkMode
                    ? const Color(0xFF64FFDA).withOpacity(0.5)
                    : Theme.of(context).primaryColor.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color:
                  settings.isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              'መዝሙሮችን ይፈልጉ...',
              style: TextStyle(
                color:
                    settings.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // Handle voice search separately
                _startVoiceSearch();
              },
              child: Icon(
                Icons.mic,
                color:
                    settings.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle voice search
  Future<void> _startVoiceSearch() async {
    try {
      // Show a dialog indicating voice search is starting
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('በድምፅ ይፈልጉ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('እባክዎ ይናገሩ...'),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('ይቁም'),
                ),
              ],
            ),
          );
        },
      );

      // Simulate voice recognition with a delay
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pop(context); // Close the dialog

        // For now, just navigate to the search screen with a placeholder
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );

        // Show a message that this feature is in development
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('የድምፅ ፍለጋ በመስራት ላይ ነው። በቅርብ ጊዜ ይገኛል።'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in voice search: $e');
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close the dialog if open
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('የድምፅ ፍለጋ ስህተት: $e')));
      }
    }
  }

  // ========= searchbar end ================================

  // ============================hero carousel start=======================
  Widget _buildHeroCarousel() {
    return SizedBox(
      height: 200, // Reduced height for a more compact look
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: carouselItems.length,
        itemBuilder: (context, index) {
          final item = carouselItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Reduced border radius
              child: Container(
                width: 300, // Reduced width for a smaller size
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color.fromARGB(0, 0, 0, 0),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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

  // ====================hero carousel end =====================

  // ==========================category start===========================

  Widget _buildCategorySection() {
    final settings = Provider.of<AppSettingsProvider>(context);
    bool _showAllCategories = false;

    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                child: Text(
                  _showAllCategories ? 'View Less' : 'View All',
                  style: TextStyle(
                    color:
                        settings.isDarkMode
                            ? const Color(0xFF64FFDA)
                            : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_showAllCategories)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () async {
                    final songs = await DBHelper.instance.getSongsByCategory(
                      category['category'],
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CategorySongsScreen(
                                category: category['category'] as String,
                                songs: songs,
                              ),
                        ),
                      ).then((_) => _loadData()); // Refresh on return
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          settings.isDarkMode
                              ? Colors.grey[800]
                              : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            settings.isDarkMode
                                ? Colors.grey[600]!
                                : Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              settings.isDarkMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        category['category'] ?? 'Unknown',
                        style: TextStyle(
                          color:
                              settings.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF333333),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () async {
                    final songs = await DBHelper.instance.getSongsByCategory(
                      category['category'],
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CategorySongsScreen(
                                category: category['category'] as String,
                                songs: songs,
                              ),
                        ),
                      ).then((_) => _loadData()); // Refresh on return
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          settings.isDarkMode
                              ? Colors.grey[800]
                              : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            settings.isDarkMode
                                ? Colors.grey[600]!
                                : Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              settings.isDarkMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        category['category'] ?? 'Unknown',
                        style: TextStyle(
                          color:
                              settings.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF333333),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ========================= end category list=====================

  // ============================================start aduio card==================================
  Widget _buildFinoteSelamSongs() {
    final settings = Provider.of<AppSettingsProvider>(context);
    final finoteSelamSongs = getFinoteSelamSongs();

    if (finoteSelamSongs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              'የፍኖተ ሰላም መዝሙሮች',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: settings.isDarkMode ? Colors.white : Colors.black87,
                letterSpacing: 0.15,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // More compact height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: finoteSelamSongs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final song = finoteSelamSongs[index];
                final hasAudio = index < finoteSelamAudioPaths.length;
                final isPlaying = _currentlyPlayingIndex == index;

                return GestureDetector(
                  onTap: () => _navigateToSongDetails(song),
                  child: Container(
                    width: 160, // More narrow cards
                    decoration: BoxDecoration(
                      color:
                          settings.isDarkMode
                              ? Colors.grey.shade900.withOpacity(0.4)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Album art with subtle overlay
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      settings.primaryColor.withOpacity(0.8),
                                      settings.primaryColor.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.music_note,
                                    size: 36,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0,
                                        height: 1.3,
                                        color:
                                            settings.isDarkMode
                                                ? Colors.white
                                                : Colors.grey.shade900,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song['category'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.0,
                                        color:
                                            settings.isDarkMode
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Play button overlay
                          if (hasAudio && !isPlaying)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: settings.primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  onPressed: () => _playFinoteSelamAudio(index),
                                ),
                              ),
                            ),

                          // Now playing overlay
                          if (isPlaying)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      settings.primaryColor.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        song['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.0,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.white
                                              .withOpacity(0.3),
                                          trackHeight: 2.5,
                                          thumbColor: Colors.white,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                enabledThumbRadius: 5,
                                              ),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                                overlayRadius: 10,
                                              ),
                                        ),
                                        child: Slider(
                                          value:
                                              _currentPosition.inSeconds
                                                  .toDouble(),
                                          min: 0,
                                          max:
                                              _totalDuration.inSeconds
                                                  .toDouble(),
                                          onChanged: (value) {
                                            _seekFinoteSelamAudio(
                                              Duration(seconds: value.toInt()),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _formatDuration(_currentPosition),
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              _formatDuration(_totalDuration),
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.skip_previous_rounded,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed:
                                                  index > 0
                                                      ? () =>
                                                          _playFinoteSelamAudio(
                                                            index - 1,
                                                          )
                                                      : null,
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(
                                                _audioPlayer?.state ==
                                                        PlayerState.playing
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                if (_audioPlayer?.state ==
                                                    PlayerState.playing) {
                                                  _pauseFinoteSelamAudio();
                                                } else {
                                                  _resumeFinoteSelamAudio();
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.skip_next_rounded,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed:
                                                  index <
                                                          finoteSelamSongs
                                                                  .length -
                                                              1
                                                      ? () =>
                                                          _playFinoteSelamAudio(
                                                            index + 1,
                                                          )
                                                      : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================end audio card==================================

  // ==============================recent songs start ================================
  Widget _buildRecentSongs() {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'የዛሬ መዝሙሮች',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: settings.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
              : recentSongs.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 48,
                        color:
                            settings.isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'መዝሙሮችን በመጫን ላይ...',
                        style: TextStyle(
                          color:
                              settings.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadData,
                        child: Text(
                          'እንደገና ይሞክሩ',
                          style: TextStyle(color: settings.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentSongs.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final song = recentSongs[index];
                  return Card(
                    elevation: 2,
                    color:
                        settings.isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _navigateToSongDetails(song),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song['title'] ?? 'Untitled',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          settings.isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song['category'] ?? 'Unknown Category',
                                    style: TextStyle(
                                      color:
                                          settings.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.play_circle_outline,
                              color: Theme.of(context).primaryColor,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  // ==================================recent songs end=========================================
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
          // Already on Home screen - no navigation needed
        } else if (index == 1) {
          // Navigate to Favorites screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            (route) => false,
          );
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

  void _openDrawer() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  // Improved method to get random songs with higher probability for "ንስሀ" category
  Future<List<Map<String, dynamic>>> _getRandomSongsFromDifferentCategories(
    int count,
  ) async {
    try {
      // Get all songs directly
      final allSongs = await DBHelper.instance.getSongs();

      // Debug: Check total songs available
      debugPrint('Total songs in database: ${allSongs.length}');

      if (allSongs.isEmpty) {
        debugPrint('No songs found in database');
        return [];
      }

      // Create a mutable copy of the list
      final mutableSongs = List<Map<String, dynamic>>.from(allSongs);

      // Separate songs from "ንስሀ" category
      final nishaCategory = "ንስሀ";
      final nishaSongs =
          mutableSongs
              .where(
                (song) =>
                    song['category'] != null &&
                    song['category'].toString().toLowerCase() ==
                        nishaCategory.toLowerCase(),
              )
              .toList();

      final otherSongs =
          mutableSongs
              .where(
                (song) =>
                    song['category'] == null ||
                    song['category'].toString().toLowerCase() !=
                        nishaCategory.toLowerCase(),
              )
              .toList();

      // Debug: Check how many songs are in each category
      debugPrint('Found ${nishaSongs.length} songs in ንስሀ category');
      debugPrint('Found ${otherSongs.length} songs in other categories');

      // Shuffle both lists
      nishaSongs.shuffle();
      otherSongs.shuffle();

      // Create result list with higher probability for ንስሀ songs
      final result = <Map<String, dynamic>>[];

      // Ensure at least 2-3 ንስሀ songs if available (higher probability)
      final nishaCount = min(
        nishaSongs.length,
        count ~/ 2 + 1,
      ); // ~50% of slots for ንስሀ
      if (nishaCount > 0) {
        result.addAll(nishaSongs.take(nishaCount));
      }

      // Fill remaining slots with other songs
      final remainingSlots = count - result.length;
      if (remainingSlots > 0 && otherSongs.isNotEmpty) {
        result.addAll(otherSongs.take(remainingSlots));
      }

      // If we still need more songs (e.g., not enough in other categories)
      if (result.length < count && nishaSongs.length > nishaCount) {
        result.addAll(nishaSongs.skip(nishaCount).take(count - result.length));
      }

      // Shuffle the final result to mix ንስሀ and other songs
      result.shuffle();

      return result;
    } catch (e) {
      debugPrint('Error loading random songs: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> getFinoteSelamSongs() {
    return allSongs
        .where((song) => (song['category'] ?? '').trim() == 'የፍኖተ ሰላም መዝሙሮች')
        .toList();
  }

  Future<void> _playFinoteSelamAudio(int index) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        await _audioPlayer!.release();
      }
      final player = AudioPlayer();
      setState(() {
        _audioPlayer = player;
        _currentlyPlayingIndex = index;
        _currentPosition = Duration.zero;
        _totalDuration = Duration.zero;
      });
      player.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration;
        });
      });
      player.onPositionChanged.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });
      player.onPlayerComplete.listen((event) {
        setState(() {
          _currentlyPlayingIndex = null;
          _currentPosition = Duration.zero;
        });
      });
      await player.play(AssetSource(finoteSelamAudioPaths[index]));
    } catch (e) {
      debugPrint('Audio play error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ድምፅ ማጫወት አልተቻለም: $e')));
    }
  }

  Future<void> _pauseFinoteSelamAudio() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.pause();
      setState(() {});
    }
  }

  Future<void> _resumeFinoteSelamAudio() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.resume();
      setState(() {});
    }
  }

  Future<void> _seekFinoteSelamAudio(Duration position) async {
    if (_audioPlayer != null) {
      await _audioPlayer!.seek(position);
      setState(() {
        _currentPosition = position;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: settings.primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Use the Builder's context which is under the Scaffold
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Open menu',
            );
          },
        ),
        title: const Text(
          'ፍኖተ ያሬድ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(), // Search bar at the very top
                  _buildHeroCarousel(),
                  _buildCategorySection(),
                  _buildFinoteSelamSongs(),
                  _buildRecentSongs(),
                  const SizedBox(height: 80), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }
}
