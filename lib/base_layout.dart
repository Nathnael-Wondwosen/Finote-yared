import 'package:flutter/material.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/kidus_yared_screen.dart';
import 'screens/contact_screen.dart';
import 'category_songs_screen.dart';
import 'widgets/category_dropdown.dart';
import 'db_helper.dart';
import 'screens/home_screen.dart';
import 'screens/admin_login_screen.dart';
import 'utils/auth_middleware.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';
import '../about_zema_screen.dart';
import 'gisot_screen.dart';
import '../about_amharic_letters_screen.dart';

class BaseLayout extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;

  const BaseLayout({super.key, this.appBar, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await AuthMiddleware.isAdminLoggedIn();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  void _openDrawer() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          _openDrawer();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar:
            widget.appBar ??
            PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Consumer<AppSettingsProvider>(
                builder:
                    (context, settings, _) => AppBar(
                      backgroundColor: settings.adjustedPrimaryColor,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: _openDrawer,
                        tooltip: 'Open menu',
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
              ),
            ),
        drawer: Consumer<AppSettingsProvider>(
          builder:
              (context, settings, _) => Drawer(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        settings.isDarkMode
                            ? const Color(
                              0xFF121212,
                            ) // Darker background for dark mode
                            : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                            settings.isDarkMode
                                ? Colors.black26
                                : Colors.black12,
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Premium Header Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              settings.adjustedPrimaryColor,
                              settings.adjustedPrimaryColor.withOpacity(0.8),
                              settings.adjustedPrimaryColor.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 40.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFF64FFDA),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF64FFDA,
                                          ).withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF0A192F),
                                          width: 2,
                                        ),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/church_choir.jpg',
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'ፍኖተ ያሬድ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'የፍኖተ ሰላም ሰንበት ት/ቤት መዝሙሮች',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          children: [
                            _buildMenuItem(
                              icon: Icons.home_filled,
                              title: 'መነሻ ገጽ',
                              isSelected: true,
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                            // Enhanced Category Dropdown
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      settings.isDarkMode
                                          ? const Color(0xFF1E1E1E)
                                          : const Color(0xFFF5F7FA),
                                  border: Border.all(
                                    color:
                                        settings.isDarkMode
                                            ? const Color(0xFF333333)
                                            : const Color(0xFFE0E5EC),
                                    width: 1,
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    hoverColor:
                                        settings.isDarkMode
                                            ? const Color(0xFF2A2A2A)
                                            : const Color(0xFFE8F4F8),
                                    splashColor: const Color(
                                      0xFF64FFDA,
                                    ).withOpacity(0.1),
                                  ),
                                  child: ExpansionTile(
                                    title: Text(
                                      'መዝሙር ምድቦች',
                                      style: TextStyle(
                                        color:
                                            settings.isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF0A192F),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.category,
                                      color:
                                          settings.isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF0A192F),
                                    ),
                                    collapsedIconColor:
                                        settings.isDarkMode
                                            ? Colors.white70
                                            : const Color(0xFF0A192F),
                                    iconColor:
                                        settings.isDarkMode
                                            ? Colors.white70
                                            : const Color(0xFF0A192F),
                                    childrenPadding: const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                      bottom: 8,
                                    ),
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    children: [
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                        future:
                                            DBHelper.instance.getCategories(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFF0A192F)),
                                                ),
                                              ),
                                            );
                                          }
                                          final categories = snapshot.data!;
                                          return Column(
                                            children:
                                                categories.map((category) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      final songs = await DBHelper
                                                          .instance
                                                          .getSongsByCategory(
                                                            category['category'],
                                                          );
                                                      if (context.mounted) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => CategorySongsScreen(
                                                                  category:
                                                                      category['category'],
                                                                  songs: songs,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                            horizontal: 16,
                                                          ),
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        color:
                                                            settings.isDarkMode
                                                                ? const Color(
                                                                  0xFF2A2A2A,
                                                                )
                                                                : Colors.white,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color:
                                                                  settings.isDarkMode
                                                                      ? const Color(
                                                                        0xFF64FFDA,
                                                                      )
                                                                      : const Color.fromARGB(
                                                                        255,
                                                                        0,
                                                                        33,
                                                                        54,
                                                                      ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              category['category'],
                                                              style: TextStyle(
                                                                color:
                                                                    settings.isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : const Color(
                                                                          0xFF0A192F,
                                                                        ),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              height: 20,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            _buildMenuItem(
                              icon: Icons.person_outline,
                              title: 'ስለ ቅዱስ ያሬድ',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const KidusYaredScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              icon: Icons.library_music,
                              title: 'ስለ ዜማ',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AboutZemaScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              icon: Icons.history_edu,
                              title: 'ስለ ፊደላት',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AboutAmharicLettersScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildMenuItem(
                              icon: Icons.language,
                              title: 'የግዕዝ ግሶች ከነትርጉማቸው',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GisotScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildMenuItem(
                              icon: Icons.info_outline,
                              title: 'ስለ እኛ',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildMenuItem(
                              icon: Icons.settings_outlined,
                              title: 'ቅንብሮች',
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
                            const Divider(
                              height: 20,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            if (_isAdmin)
                              _buildMenuItem(
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Panel',
                                iconColor: const Color(0xFF64FFDA),
                                textColor: const Color(0xFF0A192F),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AdminLoginScreen(),
                                    ),
                                  );
                                },
                              )
                            else
                              _buildMenuItem(
                                icon: Icons.admin_panel_settings_outlined,
                                title: 'Admin Login',
                                iconColor: Colors.grey,
                                textColor: Colors.grey,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AdminLoginScreen(),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
        body: widget.child,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? settings.isDarkMode
                      ? settings.primaryColor.withOpacity(0.2)
                      : const Color(0xFFF0F8FF)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(
                    color: settings.primaryColor.withOpacity(0.3),
                    width: 1,
                  )
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor:
                settings.isDarkMode
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFF0A192F).withOpacity(0.05),
            splashColor: const Color(0xFF64FFDA).withOpacity(0.2),
            highlightColor: const Color(0xFF64FFDA).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color:
                        iconColor ??
                        (settings.isDarkMode
                            ? Colors.white70
                            : const Color(0xFF0A192F).withOpacity(0.8)),
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          textColor ??
                          (settings.isDarkMode
                              ? Colors.white
                              : const Color(0xFF0A192F).withOpacity(0.9)),
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            settings.isDarkMode
                                ? const Color(0xFF64FFDA)
                                : const Color(0xFF64FFDA),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
