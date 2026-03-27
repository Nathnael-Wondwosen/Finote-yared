import 'package:flutter/material.dart';
import '../base_layout.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class KidusYaredScreen extends StatelessWidget {
  const KidusYaredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = screenHeight > screenWidth;

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: settings.primaryColor,
        title: const Text(
          'ቅዱስ ያሬድ',
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
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section with portrait image
              Container(
                width: double.infinity,
                height: isPortrait ? screenHeight * 0.4 : screenHeight * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      settings.primaryColor.withOpacity(0.8),
                      settings.primaryColor.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: PatternPainter(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Portrait image
                    Center(
                      child: Container(
                        height:
                            isPortrait
                                ? screenHeight * 0.35
                                : screenHeight * 0.45,
                        width:
                            isPortrait ? screenWidth * 0.6 : screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/yared.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image is not found
                              return Container(
                                color: settings.primaryColor.withOpacity(0.3),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 80,
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'ቅዱስ ያሬድ',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: settings.primaryColor.withOpacity(
                          isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: settings.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.music_note,
                            color: settings.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'ቅዱስ ያሬድ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: settings.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Biography section
                    _buildSection(
                      context,
                      'የቅዱስ ያሬድ ታሪክ',
                      'ቅዱስ ያሬድ ውልደትና እድገቱ ኢትዮጵያ ውስጥ፣ አክሱም ከተማ ከአባቱ ከአብድዩ እና ከእናቱ ታውክልያ ነው፤ ዕድሜው ለትምህርት ሲደርስ እናቱ መምህር ወደ ሆነው አጎቱ አባ ጌዲዮን ትወስደዋለች፡፡ እርሱ ግን በመጀመሪያ ትምህርት ሊገባው አልቻለም፡፡ ከዕለታት በአንድ ቀን መምህር ጌዲዮን ያሬድን ሲገርፈው በምሬት አለቀሰ፤ ማይኪራህ ወደምትባል ቦታም ተጓዝ፤ በመንገድ ላይ ሳለ ውኃ ስለተጠማ በዚያች ስፍራ ካለ ምንጭ ውኃ ጠጥቶ በዛፉ ሥር ለማረፍ ቁጭ አለ፤ ወደ ላይም በሚመለከትበት ጊዜ ከዛፉ ላይ አንዲት ትል ፍሬ ለመብላት ከታች ወደ ላይ ስትወጣ ስትወርድ ተመለከተ፡፡ እርሱም ትኩር ብሎ አያት፤ ትሏም ስድስት ጊዜ ያለመሰልቸት ከወጣች ከወረደች በኋላ በሰባተኛው ፍሬው ካለበት መድረስ ቻለች፤ ፍሬውንም መብላት ጀመረች፡፡ በዚያን ወቅት ቅዱስ ያሬድ አሰበ፤ እንዲህም አለ፤ «ይህች ትል ፍሬውን ለመብላት እንዲህ ከታገሠች እኔም እኮ ትምህርት ለመማር ብታገሥ እግዚአብሔር አምላክ ይገልጽልኛል፡፡» ወደ ጉባኤውም ተመልሶ መምህሩን ይቅርታ ከጠየቀ በኋላ መማር ጀመረ፤ እግዚአብሔር አምላክም የ፹ወ፩ መጻሐፍትን እና የሊቃውንት መጽሐፍትን እንዲሁም ሌሎች ቤተ ክርስቲያን የተቀበለቻቸውን የቅዱሳት መጻሕፍትን ምሥጢር ገለጸለት፤ መምህሩ ጌዲዮን ሲሞት የእርሱን ቦታ ተረክቦ ማሰተማር ቀጠለ፡፡\n\nበ፭፻፴፬ ዓ.ም. ኅዳር ፮ ቀን ወደ ሰማይ ተነጠቀ፤ በሰማይ ቅዱሳን መላእክት እግዚአብሔርን ልዩ በሆነ ጣዕመ ዝማሬ ሲያመሰግኑ ሰማ፡፡ ወደ ምድርም በተመለሰ ጊዜ አክሱም ጽዮን ውስጥ ወደ ምሥራቅ በኩል በመዞር ከሰማይ የሰማውን ዝማሬ ዘመረ፤ ዝማሬውንም አርያም ብሎም ሰየመው፡፡  በዚሁም በ፭፻፴፰ ዓ.ም. ቅዱስ ያሬድ ማሕሌትን ጀመረ፡፡  ታኅሣሥ ፩፣ በዕለተ ሰኞ ምህላ ያዘ፤ እሰከ ታኅሣሥ ፮፣ ቀዳሚት ሰንበት ድረስም ዘለቀ፤ በዚያች ዕለት ጌታችን መድኃኒታችን ኢየሱስ ክርስቶስ በመልዕልተ መስቀል አንደተሰቀለ ሆነ ከቅዱሳን መላእክት ጋር ተገለጸለት፡፡\n\nቅዱስ ያሬድም ጌታ የተገለጸለትን የመጀመሪያውን ሳምንት ‹ስብከት› ብሎ ሰየመው፤ በሳምንቱም እንደገና በብርሃን አምሳል ስለተገለጸለት ያን ዕለት ‹ብርሃን› ብሎ ሰየመው፤ በሦስተኛው ሳምንት እንዲሁ በአምሳለ ኖላዊ ስለተገለጸለት ‹ኖላዊ› ብሎ ሰየመው፡፡ በመጨረሻም ሳምንት በአምሳለ መርዓዊ ሲገለጽለት ዕለቱን ‹መረዓዊ› ብሎ ሰይሞታል፡፡\n\nከዚህም በኋላ ቅዱስ ያሬድ ፭ የዜማ መጻሕፍትን ደረሰ፤ እነዚህም ድጓ፣ ጾመ ድጓ፣ ምዕራፍ፣ ዝማሬና መዋሥዕት ናቸው፡፡ ከደረሳቸው የዜማ መጽሐፍቶችም ውስጥ ትልቁ ድጓ ነው፤ በሦስትም ይከፈላል፤ የዮሐንስ፤ አስተምህሮና ፋሲካም ይባላሉ፡፡ በንባባት ብቻ ይቀደስባቸው የነበሩትን ፲፬ቱ ቅዳሴያት በዜማ የደረሳቸው ቅዱስ ያሬድ ነው፤  ዝማሬም በ፭ ይከፈላል፤ኅብስት፣ጽዋዕ፣መንፈስ፣አኮቴትና ምሥጢር ይባላል፡፡\n\nይህ ቅዱስ ደራሲ በተወለደ በ፸፭ ዓመቱ በሰሜን ተራራ ውስጥ ደብረ ሐዊ ከሚባል ገዳም  ግንቦት ፲፩ ቀን ተሠውሯል፡፡ የዝማሬና መዋሥዕት መምህራን የቅዱስ ያሬድን ጉባኤ ተክተው  አሁን በማስተማር ላይ እስካሉት መጋቤ ብርሃናት ፈንታ ድረስ ፵፮ ናቸው፡፡\n\nየኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን ባለውለታ፣ ቅዱስ ያሬድ  መምህር ወሐዋርያ፣ መጻሕፍትን በጣዕመ ዜማ የደረሰ፣ መዝሙረ ዳዊትን ጨምሮ ሌሎችንም ቅዱሳት መጻሕፍትን በተለያየ ዜማ ያመሳጠረ ታላቅ ኢትዮጵያዊ ሊቅ ነው፡፡',
                      Icons.history,
                    ),

                    // Contribution section
                    _buildSection(context, 'የቅዱሥ ያሬድ የዜማ ዓይነቶች', '''

''', Icons.music_note),
                  ],
                ),
              ),
            ],
          ),
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
            // Custom rendering for the Zema types section
            if (title == 'የቅዱሥ ያሬድ የዜማ ዓይነቶች') ...[
              Text(
                'የቅዱስ ያሬድ የዜማ ዓይነቶች 3ት ናቸው፡፡ እነርሱም:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              // Bulleted and explained list
              _buildZemaListWithDescription(isDark, settings),
              const SizedBox(height: 12),
              Text(
                content
                    .replaceAll('ግእዝ', '')
                    .replaceAll('ዕዝል', '')
                    .replaceAll('አራራይ', ''),
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ] else ...[
              Text(
                content,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // Draw diagonal lines
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Add this helper widget at the end of the file (outside the class)
Widget _buildZemaListWithDescription(
  bool isDark,
  AppSettingsProvider settings,
) {
  final zemaList = [
    {
      'title': 'ግእዝ',
      'desc':
          'ማለት በመጀመሪያ የተገኘ ማለት ነው፡፡ የቃሉ ትርጓሜም ‹‹ገዐዘ›› ነጻ ወጣ ማለት ሲሆን በዜማነቱ ሲተረጎም ስልቱ የቀና ርቱዕ ቀጥ ያለ ጠንካራ ማለት ይሆናል፡፡ ምሳሌነቱም የአብ ሲሆን ከዜማው ጠንካራነት የተነሳ ሊቃንቱ ደረቅ ዜማ ብለውታል፡፡',
    },
    {
      'title': 'ዕዝል',
      'desc':
          'ከግእዝ ጋር ተደርቦ ወይም ታዝሎ የሚዜም ለስላሳ ዜማ ነው ዕዝል ጽኑዕ ዜማ ማለት ሲሆን በወልድ ይመሰላል፡፡ ምክንያቱም ወልድ ጽኑዕ መከራን ተቀብሏልና፡፡',
    },
    {
      'title': 'አራራይ',
      'desc':
          'የሚያራራ የሚያሳዝንና ልብን የሚመስጥ ቀጠን ያለ ዜማ ነው፡፡ በመንፈስ ቅዱስ ይመሰላል፡፡ ሐዋርያትን ከበዓለ ጰንጠቆስጤ /ከበዓለ ጰራቅሊጦስ/ በኋላ ያረጋጋ፣ ያጽናና እና ጥብዓት /ጽፍረት/ የሰጣቸው እግዚአብሔር መንፈስ ቅዱስ ነውና፡፡የሐዋ፣፣2',
    },
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:
        zemaList
            .map(
              (zema) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: settings.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          zema['title']! + ':',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                isDark ? Colors.white : settings.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(
                        zema['desc']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
  );
}
