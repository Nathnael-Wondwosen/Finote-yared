import 'package:flutter/material.dart';
import 'base_layout.dart';
import 'constants/spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenType = AppSpacing.getScreenType(context);
    final isTabletOrLarger =
        screenType == ScreenType.tablet ||
        screenType == ScreenType.laptop ||
        screenType == ScreenType.desktop;
    final settings = Provider.of<AppSettingsProvider>(context);

    return BaseLayout(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: screenHeight * (isTabletOrLarger ? 0.4 : 0.3),
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/church_choir.jpg',
                        fit:
                            BoxFit
                                .contain, // Changed to contain to show the full image
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
                      Container(color: Colors.black.withOpacity(0.4)),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.xl,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "እንኳን ደህና መጡ",
                        style: GoogleFonts.poppins(
                          fontSize: isTabletOrLarger ? 38 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.tealAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTabletOrLarger ? AppSpacing.xl : AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  // Church Information Card
                  _buildInfoCard(context, isTabletOrLarger: isTabletOrLarger),
                  SizedBox(height: AppSpacing.lg),
                  // Instructions Card
                  _buildInstructionsCard(
                    context,
                    isTabletOrLarger: isTabletOrLarger,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required bool isTabletOrLarger,
  }) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Card(
      elevation: 4,
      color: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              settings.isDarkMode
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "የቦሌ ሰሚት መካነ ሰላም መድኃኔዓለም እና መጥምቀ መለኮት ቅዱስ ዮሃንስ ቤተ ክርስቲያን",
              style: GoogleFonts.poppins(
                fontSize: isTabletOrLarger ? 24 : 20,
                fontWeight: FontWeight.w600,
                color:
                    settings.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E2F3D),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              "ፍኖተ ሰላም ሰንበት ት/ቤት መዝሙር ጥራዝ",
              style: GoogleFonts.poppins(
                fontSize: isTabletOrLarger ? 18 : 16,
                color:
                    settings.isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF1E2F3D).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(
    BuildContext context, {
    required bool isTabletOrLarger,
  }) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final instructionTitleColor =
        settings.isDarkMode ? const Color(0xFF64FFDA) : const Color(0xFF00494D);

    return Card(
      elevation: 4,
      color: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              settings.isDarkMode
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "መዝሙሮችን ለማግኘት:",
              style: GoogleFonts.poppins(
                fontSize: isTabletOrLarger ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: instructionTitleColor,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ...instructionItems.map(
              (item) => InstructionTile(
                icon: item.icon,
                text: item.text,
                isTabletOrLarger: isTabletOrLarger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructionItem {
  final IconData icon;
  final String text;

  const InstructionItem({required this.icon, required this.text});
}

final instructionItems = [
  const InstructionItem(icon: Icons.swipe, text: "ወደ ቀኝ ያንሸራትቱ"),
  const InstructionItem(icon: Icons.category, text: " በመቀጠል የሚፈልጉትን ምድብ ይምረጡ"),
  const InstructionItem(icon: Icons.music_note, text: "በመቀጠል መዝሙሩን ይምረጡ!"),
];

class InstructionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isTabletOrLarger;

  const InstructionTile({
    required this.icon,
    required this.text,
    required this.isTabletOrLarger,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final iconColor =
        settings.isDarkMode ? const Color(0xFF64FFDA) : const Color(0xFF00494D);
    final textColor =
        settings.isDarkMode
            ? Colors.white.withOpacity(0.9)
            : const Color(0xFF1E2F3D);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isTabletOrLarger ? 28 : 24,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isTabletOrLarger ? 16 : 14,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
