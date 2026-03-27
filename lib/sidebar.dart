import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'category_songs_screen.dart';
import 'screens/settings_screen.dart';

class Sidebar extends StatefulWidget {
  final bool isSidebarOpen;
  final Function onMenuTap;

  const Sidebar({
    required this.isSidebarOpen,
    required this.onMenuTap,
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _dbHelper = DBHelper.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200), // Faster animation
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Smoother animation curve
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSidebarOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.isSidebarOpen
                ? 0
                : -MediaQuery.of(context).size.width * 0.85,
            0,
          ),
          child: Material(
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFF00494D),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00494D),
                          const Color(0xFF00494D).withOpacity(0.8),
                        ],
                      ),
                      border: const Border(
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Place for logo
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white70,
                            size: 40,
                          ), // This will be replaced with your actual logo
                        ),
                        const Text(
                          'ፍኖተ ያሬድ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'የፍኖተ ሰላም ሰንበት ት/ቤት መዝሙሮች',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dbHelper.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Error loading categories: ${snapshot.error}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Loading categories...',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        }

                        final categories = snapshot.data!;

                        return ListView(
                          children: [
                            // Categories Section
                            if (categories.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'የመዝሙር ምድቦች',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ...categories.map((category) {
                                final categoryName = category['category'];
                                return ListTile(
                                  leading: Icon(
                                    Icons.category,
                                    color: Colors.white70,
                                  ),
                                  title: Text(
                                    categoryName ?? 'Unnamed Category',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white60,
                                    size: 16,
                                  ),
                                  onTap: () async {
                                    final songs = await _dbHelper
                                        .getSongsByCategory(categoryName);
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CategorySongsScreen(
                                                category: categoryName,
                                                songs: songs,
                                              ),
                                        ),
                                      );
                                      if (MediaQuery.of(context).size.width <
                                          600) {
                                        widget.onMenuTap();
                                      }
                                    }
                                  },
                                );
                              }),
                              Divider(color: Colors.white24, height: 1),
                            ],

                            // Additional Navigation Options
                            ListTile(
                              leading: Icon(Icons.home, color: Colors.white70),
                              title: Text(
                                'መነሻ ገጽ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/');
                                if (MediaQuery.of(context).size.width < 600) {
                                  widget.onMenuTap();
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.music_note,
                                color: Colors.white70,
                              ),
                              title: Text(
                                'ስለ ቅዱስ ያሬድ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/kidus-yared');
                                if (MediaQuery.of(context).size.width < 600) {
                                  widget.onMenuTap();
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.info, color: Colors.white70),
                              title: Text(
                                'ስለ እኛ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/about');
                                if (MediaQuery.of(context).size.width < 600) {
                                  widget.onMenuTap();
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.contact_support,
                                color: Colors.white70,
                              ),
                              title: Text(
                                'አግኙን',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/contact');
                                if (MediaQuery.of(context).size.width < 600) {
                                  widget.onMenuTap();
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.settings,
                                color: Colors.white70,
                              ),
                              title: Text(
                                'Settings / ቅንብሮች',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.library_music,
                                color: Colors.white70,
                              ),
                              title: Text(
                                'ስለ ዜማ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/about-zema');
                                if (MediaQuery.of(context).size.width < 600) {
                                  widget.onMenuTap();
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.language,
                                color: Colors.white70,
                              ),
                              title: Text(
                                'ስለ ፊደላት',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/about-amharic-letters',
                                );
                                if (MediaQuery.of(context).size.width < 600) {
                                  widget.onMenuTap();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
