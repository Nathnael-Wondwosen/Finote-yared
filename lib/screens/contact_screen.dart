import 'package:flutter/material.dart';
import '../base_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final socialMediaList =
        [
          {
            'name': 'Telegram',
            'icon': Icons.telegram,
            'color': Colors.blue,
            'url': 'https://t.me/zemafnot',
          },
          {
            'name': 'Facebook',
            'icon': Icons.facebook,
            'color': const Color(0xFF1877F2),
            'url': 'https://facebook.com/zemafnot',
          },
          {
            'name': 'YouTube',
            'icon': Icons.youtube_searched_for,
            'color': Colors.red,
            'url': 'https://youtube.com/@zemafnot',
          },
          {
            'name': 'Instagram',
            'icon': Icons.camera_alt,
            'color': const Color(0xFFE4405F),
            'url': 'https://instagram.com/zemafnot',
          },
          {
            'name': 'TikTok',
            'icon': Icons.music_note,
            'color': Colors.black,
            'url': 'https://tiktok.com/@zemafnot',
          },
        ].map((item) => Map<String, dynamic>.from(item)).toList();

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: settings.primaryColor,
        title: const Text(
          'አግኙን',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Church Contact Information
              _buildSection(
                context,
                'የቤተ ክርስቲያን አድራሻ',
                'ቦሌ ሰሚት መድሃኒዓለም እና መጥምቀ መልኮት ቅዱስ ዮሃንስ ቤተ ክርስቲያን\nሰሚት,አዲስ አበባ, ኢትዮጵያ',
                Icons.location_on,
              ),

              // Phone and Email Section
              _buildSection(
                context,
                'ስልክ ቁጥር',
                '+251 903 324 489\n+251 911 789 012',
                Icons.phone,
              ),

              _buildSection(
                context,
                'ኢሜይል',
                'info@finoteselmass.org\nit@finoteselamss.org',
                Icons.email,
              ),

              // Social Media Section
              _buildSocialMediaSection(context, socialMediaList),

              // Hours Information
              _buildSection(
                context,
                'የሰዓታት',
                'ከሰኞ እስከ ዓርብ: 11:00 - 1:00\nቅዳሜ: 9:00 - 1:00\nእሁድ: ሙሉ ቀን',
                Icons.access_time,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(
    BuildContext context,
    List<Map<String, dynamic>> socialMediaList,
  ) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: settings.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: settings.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'ማህበራዊ ሚዲያ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: settings.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Classic, simple social media icons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    socialMediaList.map((social) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _launchUrl(social['url'] as String),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? const Color(0xFF2A2A2A)
                                            : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    social['icon'] as IconData,
                                    color: social['color'] as Color,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: settings.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: settings.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: settings.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
