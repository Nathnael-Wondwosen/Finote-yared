import 'package:flutter/material.dart';
import '../base_layout.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _currentImageIndex = 0;

  // Sample images - replace with your actual images
  final List<String> galleryImages = [
    'assets/images/betechrstian.jpg',
    'assets/images/we.jpg',
    'assets/images/app-logo.png',
    // Add more image paths as needed
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: settings.primaryColor,
        title: const Text(
          'ስለ እኛ',
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
              // Title
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: settings.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settings.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 12,
                    ), // Reduced spacing for a more compact look
                    Expanded(
                      // Use Expanded to make the text responsive
                      child: Text(
                        'በስመ አብ ወወልድ ወመንፈስቅዱስ አሐዱ አምላክ አሜን',
                        style: TextStyle(
                          fontSize:
                              14, // Increased font size for better readability
                          fontWeight:
                              FontWeight.w600, // Slightly bolder for emphasis
                          color: settings.primaryColor,
                        ),
                        textAlign: TextAlign.center, // Align text to the start
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Church Information
              _buildSection(
                context,
                'የቦሌ ሰሚት መካነ ሰላም መድኃኔዓለም እና መጥምቀ መለኮት ቅዱስ ዮሃንስ ቤተ ክርስቲያን',
                'በአዲስ አበባ ሀገረ ስብከት የቦሌ ሰሚት መካነ ሰላም መድኃኔዓለም እና መጥምቀ መለኮት ቅዱስ ዮሃንስ ቤተ ክርስቲያን ነሃሴ 18 በ1994 ዓ.ም ተመሰረተ። አድራሻው ከሰሚት አደባባይ ወደ ጎሮ በሚወስደው መንገድ ላይ ይገኛል።',
                Icons.church,
              ),
              // Advanced classic section for Sunday School
              _buildSection(
                context,
                'የፍኖተ ሰላም ሰ/ት/ቤት',
                'ሰንበት ት/ቤታችን የተመሰረተው በ1995 ዓ.ም ጥር 9 ሲሆን በአሁኑ ሰዓት የቤተ-ክርስቲያናችንን ዶግማዋን፣ ቀኖናዋን እንዲሁም ትውፊቷን በጠበቀ መልኩ የት/ት ፣ የመዝሙር ፣  በተጨማሪም ለወጣቱ የሚጠቅው ልዩ ልዩ አገልግሎቶችን እየሰጠ ይገኛል፡፡',
                Icons.school,
              ),

              // Image Gallery with Parallax Effect
              const SizedBox(height: 30),
              _buildImageGallery(context),
              const SizedBox(height: 30),

              // App Information
              _buildSection(
                context,
                'ስለ መተግበሪያው',
                'ይህ መተግበሪያ በቦሌ ሰሚት መካነ ሰላም መድኃኔዓለም እና መጥምቀ መለኮት ቅዱስ ዮሃንስ ቤተ-ክርስቲያን የፍኖተ ሰላም ሰንበት ት/ቤት አይቲ (IT ) እና ሚዲያ (media) ክፍል ከ መዝሙር ክፍሉ ጋር በመተባበር የተሰራ ሲሆን ፤ ዓላማው የቅድስት ቤተ ክርስቲያን ቱፊት የጠበቁ መዝሙሮችን በቀላሉ ለምዕመናን ማዳረስ ይቻል ዘንድ ታስቦ ነው።',
                Icons.app_shortcut,
              ),

              // Mission
              _buildSection(
                context,
                'ራዕያችን',
                'የቅድስት ቤተ ክርስቲያን መዝሙሮችን ለሁሉም ተደራሽ ማድረግና የቅዱስ ያሬድን ውርስ ለቀጣዩ ትውልድ ማስተላለፍ።\n\nመዝሙር ክፍል 2017 ዓ.ም',
                Icons.visibility,
              ),
              const SizedBox(height: 30),
              _buildLocationSection(context),
              const SizedBox(
                height: 18,
              ), // Reduced gap for a tighter, modern look
              _buildContactUsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          // child: Text(
          //   'ፎቶዎች',
          //   style: TextStyle(
          //     fontSize: 22,
          //     fontWeight: FontWeight.bold,
          //     color: settings.primaryColor,
          //   ),
          // ),
        ),
        CarouselSlider.builder(
          itemCount: galleryImages.length,
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.3,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildParallaxImage(context, index);
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              galleryImages.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == entry.key
                            ? settings.primaryColor
                            : Colors.grey.withOpacity(0.5),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildParallaxImage(BuildContext context, int index) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Parallax effect with image
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark ? Colors.black : Colors.white,
                  ],
                  stops: const [0.7, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: Image.asset(
                galleryImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
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
            ),
            // Optional: Add a caption or description at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: settings.primaryColor,
                    ),
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

  // Helper to launch URLs (call, email, web, map)
  Future<void> _launchUrl(Uri uri) async {
    try {
      // Check if the URI scheme is for phone or email
      if (uri.scheme == 'tel' || uri.scheme == 'mailto') {
        // For phone and email, directly launch without checking for an app
        await launchUrl(uri);
      } else {
        // For other URLs, check if they can be launched
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Handle the case where no app can handle the URL
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No app found to handle this action.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Advanced, minimal Contact Us Section (no card, no bold, no duplicate icons)
  Widget _buildContactUsSection(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.grey[200] : Colors.grey[800];
    final iconColor = settings.primaryColor;
    final divider = Divider(
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      height: 10, // Minimal gap
      thickness: 1,
      indent: 0,
      endIndent: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Website description and link
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: 12, // Added more bottom gap
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.5,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: ' የተለያዩ የመረጃ ይዘቶችን በድህረ ገፃችን'),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () async {
                            final connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Internet Issue. Please check your network.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            final uri = Uri.parse('https://finoteselamss.org');
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Text(
                            'finoteselamss.org',
                            style: TextStyle(
                              color: settings.primaryColor,
                              fontSize: 15.5,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' ላይ ማግኘት ይችላሉ። ለበለጠ መረጃ ከታች በተዘረዘሩት የመገናኛ አማራጮች ያገኙናል።',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Minimized dropdowns
          divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  visualDensity: VisualDensity.compact,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  childrenPadding: const EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(Icons.mail_outline, color: iconColor, size: 20),
                  title: Text(
                    'Email',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.only(
                        left: 36,
                        right: 12,
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse('mailto:it@finoteselamss.org');
                          await _launchUrl(uri);
                        },
                        child: Text(
                          'it@finoteselamss.org',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.only(
                        left: 36,
                        right: 12,
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(
                            'mailto:mezmurkfil@finoteselamss.org',
                          );
                          await _launchUrl(uri);
                        },
                        child: Text(
                          'mezmurkfil@finoteselamss.org',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  visualDensity: VisualDensity.compact,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  childrenPadding: const EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(Icons.phone, color: iconColor, size: 20),
                  title: Text(
                    'Phone',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.only(
                        left: 36,
                        right: 12,
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse('tel:+251951710002');
                          await _launchUrl(uri);
                        },
                        child: Text(
                          '+251951710002',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.only(
                        left: 36,
                        right: 12,
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse('tel:+251913197692');
                          await _launchUrl(uri);
                        },
                        child: Text(
                          '+251913197692',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          divider,
          // Social Media Carousel (no title, minimal gaps)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Center(
              child: SizedBox(
                height: 48,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 48,
                    viewportFraction: 0.28,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 700,
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                  items: [
                    _buildSocialIcon(
                      context,
                      assetPath: 'assets/images/tg.png',
                      url: 'https://t.me/finotemedia',
                      tooltip: 'Telegram',
                    ),
                    _buildSocialIcon(
                      context,
                      assetPath: 'assets/images/tiktok.png',
                      url:
                          'https://www.tiktok.com/@tseyahief?_t=ZM-8x65fIZRYdp',
                      tooltip: 'TikTok',
                    ),
                    _buildSocialIcon(
                      context,
                      assetPath: 'assets/images/insta.png',
                      url:
                          'https://www.instagram.com/tseyahie_finot?igsh=MXZyc3NqZWNwcm9uMA%3D%3D&utm_source=qr',
                      tooltip: 'Instagram',
                    ),
                    _buildSocialIcon(
                      context,
                      assetPath: 'assets/images/YT.png',
                      url:
                          'https://youtube.com/channel/UCaYMSBrq7WmKGlCKPwwrzug?si=NTJ8HnuUWoQSWJ0Y',
                      tooltip: 'YouTube',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 16, thickness: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 0),
            child: Text(
              '© 2017 E.C ፍኖተ ሰላም ሰንበት ት/ቤት (Finote Selam Sunday School). All rights reserved.',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Add this helper method inside _AboutScreenState
  Widget _buildSocialIcon(
    BuildContext context, {
    required String assetPath, // Use asset image instead of IconData
    required String url,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () async {
          final connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult == ConnectivityResult.none) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Internet Issue. Please check your network.'),
                ),
              );
            }
            return;
          }
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Tooltip(
          message: tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: Image.asset(
                assetPath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to show the location image and open Google Maps on tap
  Widget _buildLocationSection(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'ለበለጠ መረጃ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: settings.primaryColor,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final geoUri = Uri.parse(
              'geo:9.0022911,38.7646381?q=Bole+Semit+Medhanealem',
            );
            final browserUrl = Uri.parse(
              'https://www.google.com/maps/place/Bole+Semit+Medhanealem+%E1%8A%A0%E1%8B%B5%E1%88%B5+%E1%8A%A0%E1%89%A0%E1%89%A3+%E1%8A%A0%E1%8B%B5%E1%88%B5+%E1%8A%A0%E1%89%A0%E1%89%A3+%E1%8A%A0%E1%89%A0%E1%89%A3/@9.0022911,38.7646381,13z/data=!4m6!3m5!1s0x164b9ac1fab9c7df:0x3ba7a62b9c6641f7!8m2!3d9.0022911!4d38.8046381!16s%2Fg%2F11c5w2w2qg?entry=ttu',
            );
            if (await canLaunchUrl(geoUri)) {
              await launchUrl(geoUri, mode: LaunchMode.externalApplication);
            } else {
              await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Google Maps app not found. Opened in browser.',
                    ),
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: settings.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/location.png', // Replace with your map image asset
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                ),
                Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.black.withOpacity(0.15),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: settings.primaryColor,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View on Google Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  } // END _buildLocationSection
}
