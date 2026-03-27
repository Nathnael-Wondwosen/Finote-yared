import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../base_layout.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentNavIndex = 3; // Set to 3 for Settings tab
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isBrightnessExpanded =
      false; // Track expansion state of brightness section

  // Predefined theme colors with gradient pairs
  final List<Map<String, dynamic>> _themeColorOptions = [
    {
      'main': const Color.fromARGB(255, 1, 56, 66), // Default teal
      'gradient': const Color.fromARGB(247, 1, 71, 76),
      'name': 'ቲል',
    },
    {
      'main': const Color(0xFF1976D2), // Blue
      'gradient': const Color(0xFF42A5F5),
      'name': 'ሰማያዊ',
    },
    {
      'main': const Color(0xFF4CAF50), // Green
      'gradient': const Color(0xFF81C784),
      'name': 'አረንጓዴ',
    },
    {
      'main': const Color(0xFFE91E63), // Pink
      'gradient': const Color(0xFFF48FB1),
      'name': 'ሮዝ',
    },
    {
      'main': const Color(0xFF9C27B0), // Purple
      'gradient': const Color(0xFFBA68C8),
      'name': 'ወይን ጠጅ',
    },
    {
      'main': const Color(0xFFFF9800), // Orange
      'gradient': const Color(0xFFFFB74D),
      'name': 'ብርቱካናማ',
    },
    {
      'main': const Color(0xFF795548), // Brown
      'gradient': const Color(0xFFA1887F),
      'name': 'ቡናማ',
    },
    {
      'main': const Color(0xFF607D8B), // Blue Grey
      'gradient': const Color(0xFF90A4AE),
      'name': 'ሰማያዊ-ግራጫ',
    },
  ];

  // Build bottom navigation similar to other screens
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
          // Already on Settings screen - no navigation needed
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

  // Build enhanced color selection widget with gradients
  Widget _buildColorSelector(AppSettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _themeColorOptions.length,
          itemBuilder: (context, index) {
            final colorOption = _themeColorOptions[index];
            final mainColor = colorOption['main'] as Color;
            final gradientColor = colorOption['gradient'] as Color;
            final colorName = colorOption['name'] as String;
            final isSelected = settings.primaryColor.value == mainColor.value;

            return GestureDetector(
              onTap: () => settings.setPrimaryColor(mainColor),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [mainColor, gradientColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color:
                              isSelected
                                  ? settings.isDarkMode
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child:
                          isSelected
                              ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: mainColor,
                                    size: 20,
                                  ),
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorName,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          settings.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Color preview and brightness adjustment section
        Card(
          elevation: 0,
          color:
              settings.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: settings.adjustedPrimaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Preview section (always visible)
              InkWell(
                onTap: () {
                  setState(() {
                    _isBrightnessExpanded = !_isBrightnessExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: settings.adjustedPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: settings.adjustedPrimaryColor.withOpacity(
                                0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'የቀለም ብርሃን ማስተካከያ',
                              style: settings.getTextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ቀለሙን ይበልጥ ጨለማ ወይም ብርሃናማ ያድርጉት',
                              style: settings.getTextStyle(
                                fontSize: 14,
                                color:
                                    settings.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isBrightnessExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color:
                            settings.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable brightness adjustment section
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.brightness_low,
                            color:
                                settings.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                            size: 20,
                          ),
                          Expanded(
                            child: Slider(
                              value: settings.colorBrightness,
                              min: -1.0,
                              max: 1.0,
                              divisions: 20,
                              activeColor: settings.adjustedPrimaryColor,
                              inactiveColor:
                                  settings.isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                              onChanged: (value) {
                                settings.setColorBrightness(value);
                              },
                            ),
                          ),
                          Icon(
                            Icons.brightness_high,
                            color:
                                settings.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),
                      // Color brightness preview
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBrightnessPreview(settings, -0.8, 'ጨለማ'),
                            _buildBrightnessPreview(settings, -0.4, ''),
                            _buildBrightnessPreview(settings, 0.0, 'መደበኛ'),
                            _buildBrightnessPreview(settings, 0.4, ''),
                            _buildBrightnessPreview(settings, 0.8, 'ብርሃናማ'),
                          ],
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            settings.setColorBrightness(0.0);
                          },
                          child: Text(
                            'ወደ መጀመሪያው ቀለም መመለስ',
                            style: TextStyle(
                              color: settings.adjustedPrimaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState:
                    _isBrightnessExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build brightness preview
  Widget _buildBrightnessPreview(
    AppSettingsProvider settings,
    double brightnessValue,
    String label,
  ) {
    // Create a temporary color with this brightness value
    final HSLColor hsl = HSLColor.fromColor(settings.primaryColor);
    double lightness = hsl.lightness;

    if (brightnessValue > 0) {
      lightness = lightness + (brightnessValue * (1.0 - lightness));
    } else {
      lightness = lightness * (1.0 + brightnessValue);
    }

    final previewColor = hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
    final isSelected = (settings.colorBrightness - brightnessValue).abs() < 0.1;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: previewColor,
            shape: BoxShape.circle,
            border:
                isSelected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  // Helper to launch URLs
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('ማስጠንቀቂያ'),
              content: const Text('ይህን አድራሻ መክፈት አልተቻለም።'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('እሺ'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, child) {
        return BaseLayout(
          appBar: AppBar(
            backgroundColor: settings.adjustedPrimaryColor,
            elevation: 0,
            title: Text(
              'ቅንብሮች',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Reset to defaults button
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'ወደ ነባሪ መመለስ',
                onPressed: () {
                  _showResetConfirmationDialog(context, settings);
                },
              ),
            ],
          ),
          child: Scaffold(
            key: _scaffoldKey,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Appearance Section
                    Text(
                      'የመተግበሪያ ገጽታ',
                      style: settings.getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: settings.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(
                              'ጨለማ ሁነታ',
                              style: settings.getTextStyle(),
                            ),
                            subtitle: Text(
                              'ለምሽት ንባብ የሚመች ጨለማ ገጽታ',
                              style: settings.getTextStyle(
                                fontSize: 14,
                                color:
                                    settings.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            value: settings.isDarkMode,
                            onChanged: (value) => settings.setDarkMode(value),
                            secondary: Icon(
                              settings.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color:
                                  settings.isDarkMode
                                      ? Colors.amber
                                      : Colors.orange,
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'የመተግበሪያ ቀለም',
                                  style: settings.getTextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'የሚፈልጉትን የመተግበሪያ ቀለም ይምረጡ',
                                  style: settings.getTextStyle(
                                    fontSize: 14,
                                    color:
                                        settings.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildColorSelector(settings),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Text Settings Section
                    Text(
                      'የጽሑፍ ቅንብሮች',
                      style: settings.getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: settings.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'የጽሑፍ መጠን',
                              style: settings.getTextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'A',
                                  style: settings.getTextStyle(fontSize: 14),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: settings.textSize,
                                    min: 12.0,
                                    max: 24.0,
                                    divisions: 12,
                                    label: settings.textSize.round().toString(),
                                    activeColor: settings.primaryColor,
                                    onChanged:
                                        (value) => settings.setTextSize(value),
                                  ),
                                ),
                                Text(
                                  'A',
                                  style: settings.getTextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    settings.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'የናሙና ጽሑፍ',
                                    style: settings.getTextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ይህ ጽሑፍ የተመረጠውን የጽሑፍ መጠን ያሳያል። ለእርስዎ ምቹ የሆነውን መጠን ይምረጡ።',
                                    style: settings.getTextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About App Section
                    Text(
                      'ስለ መተግበሪያው',
                      style: settings.getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: settings.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(
                              'የመተግበሪያ ስሪት',
                              style: settings.getTextStyle(),
                            ),
                            subtitle: Text(
                              '1.0.0',
                              style: settings.getTextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const Divider(),
                          ExpansionTile(
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: Text(
                              'የግላዊነት ፖሊሲ',
                              style: settings.getTextStyle(),
                            ),
                            trailing: const Icon(
                              Icons.arrow_drop_down,
                              size: 28,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'የግላዊነት ፖሊሲ: መተግበሪያው የግላዊ መረጃዎትን አይሰበስብም። የተሰጡት ፈቃዶች ለመተግበሪያው ብቻ ናቸው። መረጃዎት በደህና ይጠበቃል።',
                                  style: settings.getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Contact & Support
                    Text(
                      'ድጋፍ እና እርዳታ',
                      style: settings.getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: settings.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.star_outline),
                            title: Text(
                              'መተግበሪያውን ይገምግሙ',
                              style: settings.getTextStyle(),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              _launchUrl(
                                'https://play.google.com/store/apps/details?id=com.your.appid',
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigation(),
          ),
        );
      },
    );
  }

  // Show reset confirmation dialog
  void _showResetConfirmationDialog(
    BuildContext context,
    AppSettingsProvider settings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ወደ ነባሪ መመለስ',
            style: settings.getTextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'ሁሉንም ቅንብሮች ወደ ነባሪ ዋጋዎች መመለስ ይፈልጋሉ?',
            style: settings.getTextStyle(),
          ),
          actions: [
            TextButton(
              child: Text(
                'ይቅር',
                style: settings.getTextStyle(color: Colors.grey[600]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: settings.primaryColor,
              ),
              child: const Text('መመለስ', style: TextStyle(color: Colors.white)),
              onPressed: () {
                settings.resetToDefaults();
                Navigator.of(context).pop();

                // Show confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('ቅንብሮች ወደ ነባሪ ተመልሰዋል'),
                    backgroundColor: settings.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
