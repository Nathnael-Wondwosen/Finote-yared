import 'package:flutter/material.dart';

class AppSpacing {
  // Base spacing constants
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;

  // Screen breakpoints
  static const double kMobileS = 320.0; // Small mobile
  static const double kMobileM = 375.0; // Medium mobile
  static const double kMobileL = 425.0; // Large mobile
  static const double kTablet = 768.0; // Tablet
  static const double kLaptop = 1024.0; // Small laptop
  static const double kLaptopL = 1440.0; // Large laptop

  // Screen type detection
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < kMobileS) return ScreenType.mobileXS;
    if (width < kMobileM) return ScreenType.mobileS;
    if (width < kMobileL) return ScreenType.mobileM;
    if (width < kTablet) return ScreenType.mobileL;
    if (width < kLaptop) return ScreenType.tablet;
    if (width < kLaptopL) return ScreenType.laptop;
    return ScreenType.desktop;
  }

  // Responsive padding
  static EdgeInsets getHeaderPadding(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobileXS:
        return EdgeInsets.symmetric(vertical: sm, horizontal: md);
      case ScreenType.mobileS:
        return EdgeInsets.symmetric(vertical: md, horizontal: md);
      case ScreenType.mobileM:
        return EdgeInsets.symmetric(vertical: lg, horizontal: md);
      case ScreenType.mobileL:
        return EdgeInsets.symmetric(vertical: lg, horizontal: lg);
      case ScreenType.tablet:
        return EdgeInsets.symmetric(vertical: xl, horizontal: lg);
      case ScreenType.laptop:
      case ScreenType.desktop:
        return EdgeInsets.symmetric(vertical: xxl, horizontal: xl);
    }
  }

  // Responsive logo size
  static double getLogoSize(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobileXS:
        return 48;
      case ScreenType.mobileS:
        return 60;
      case ScreenType.mobileM:
        return 80;
      case ScreenType.mobileL:
        return 100;
      case ScreenType.tablet:
        return 120;
      case ScreenType.laptop:
      case ScreenType.desktop:
        return 140;
    }
  }

  // Responsive text styles
  static TextStyle getTitleStyle(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobileXS:
        return const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        );
      case ScreenType.mobileS:
        return const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        );
      case ScreenType.mobileM:
        return const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        );
      case ScreenType.mobileL:
        return const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.7,
        );
      case ScreenType.tablet:
        return const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        );
      case ScreenType.laptop:
      case ScreenType.desktop:
        return const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        );
    }
  }

  static TextStyle getSubtitleStyle(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobileXS:
        return const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          letterSpacing: 0.2,
        );
      case ScreenType.mobileS:
        return const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          letterSpacing: 0.3,
        );
      case ScreenType.mobileM:
        return const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          letterSpacing: 0.3,
        );
      case ScreenType.mobileL:
        return const TextStyle(
          color: Colors.white70,
          fontSize: 18,
          letterSpacing: 0.4,
        );
      case ScreenType.tablet:
        return const TextStyle(
          color: Colors.white70,
          fontSize: 20,
          letterSpacing: 0.5,
        );
      case ScreenType.laptop:
      case ScreenType.desktop:
        return const TextStyle(
          color: Colors.white70,
          fontSize: 22,
          letterSpacing: 0.6,
        );
    }
  }

  // Enhanced container decorations
  static BoxDecoration get headerContainerDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00494D),
        const Color(0xFF00494D).withOpacity(0.8),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration get logoContainerDecoration => BoxDecoration(
    color: Colors.white24,
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white30, width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Standard spacings
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // Vertical spacers
  static const SizedBox vSpaceXS = SizedBox(height: xs);
  static const SizedBox vSpaceSM = SizedBox(height: sm);
  static const SizedBox vSpaceMD = SizedBox(height: md);
  static const SizedBox vSpaceLG = SizedBox(height: lg);
  static const SizedBox vSpaceXL = SizedBox(height: xl);

  // Horizontal spacers
  static const SizedBox hSpaceXS = SizedBox(width: xs);
  static const SizedBox hSpaceSM = SizedBox(width: sm);
  static const SizedBox hSpaceMD = SizedBox(width: md);
  static const SizedBox hSpaceLG = SizedBox(width: lg);
  static const SizedBox hSpaceXL = SizedBox(width: xl);
}

// Screen type enum
enum ScreenType {
  mobileXS, // Extra small phones
  mobileS, // Small phones
  mobileM, // Medium phones
  mobileL, // Large phones
  tablet, // Tablets
  laptop, // Laptops
  desktop, // Desktops
}
