import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple Liquid Glass meets Indian Native Flora Palette
  static const Color darkBackground = Color(0xFFF5F7F4); // Soft Botanical White / Neutral
  static const Color surfaceCard = Color(0xFFFFFFFF); // Pure White Surface
  static const Color surfaceBorder = Color(0xFFE2E8E4); // Subtle Sage Border
  static const Color surfaceGlass = Color(0xD8FFFFFF); // Translucent Liquid Glass
  static const Color surfaceGlassDark = Color(0xB3173F2A); // Translucent Dark Glass Overlay
  
  // Nature Accent Palette
  static const Color primaryForest = Color(0xFF173F2A); // Deep Forest #173F2A
  static const Color accentForest = Color(0xFF2E7D4F); // Forest Green #2E7D4F
  static const Color leafGreen = Color(0xFF5FAF72); // Lush Leaf #5FAF72
  static const Color softSage = Color(0xFFDCEBDD); // Soft Sage #DCEBDD
  static const Color mistBackground = Color(0xFFF4F7F3); // Mist #F4F7F3

  // Typography Colors
  static const Color textPrimary = Color(0xFF121C16); // Near-Black Evergreen
  static const Color textSecondary = Color(0xFF5C6B61); // Muted Sage Gray
  static const Color textMuted = Color(0xFF8A9A90); // Soft Muted Gray
  static const Color textOnDark = Color(0xFFFFFFFF); // Pure White

  // Secondary Accents
  static const Color amberAccent = Color(0xFFD97706); // Warm Amber
  static const Color warningAmber = Color(0xFFD97706);
  static const Color sageText = Color(0xFF2E7D4F);
  static const Color accentLime = Color(0xFF2E7D4F);
  static const Color emeraldNeon = Color(0xFF5FAF72);

  // Glass Material Parameters
  static const double blurSmall = 12.0;
  static const double blurMedium = 20.0;
  static const double blurLarge = 30.0;

  static const double opacityLow = 0.65;
  static const double opacityMedium = 0.85;
  static const double opacityHigh = 0.95;

  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusXL = 36.0;

  // Solid Card Decoration
  static BoxDecoration get solidCardDecoration => BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(color: surfaceBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: primaryForest.withValues(alpha: 0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Fallback Glass Decoration when BackdropFilter is disabled
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceGlass,
        borderRadius: BorderRadius.circular(radiusXL),
        border: Border.all(color: const Color(0x60FFFFFF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryForest.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.light(
        primary: accentForest,
        secondary: leafGreen,
        surface: surfaceCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.18,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: surfaceBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accentForest,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
