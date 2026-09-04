import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Clean Light Botanical Color Palette (High Daytime Visibility)
  static const Color darkBackground = Color(0xFFF4FAF6); // Fresh Soft Botanical Backdrop
  static const Color surfaceCard = Color(0xFFFFFFFF); // Pure White Surface
  static const Color surfaceBorder = Color(0xFFCCE8D9); // Soft Mint Sage Border
  static const Color surfaceGlass = Color(0xF2FFFFFF);
  static const Color primaryForest = Color(0xFF166534); // Deep Forest Green
  static const Color accentLime = Color(0xFF15803D); // Lush Botanical Green #15803D
  static const Color emeraldNeon = Color(0xFF059669); // Vibrant Emerald #059669
  static const Color amberAccent = Color(0xFFD97706); // Warm Amber
  static const Color warningAmber = Color(0xFFD97706);
  static const Color sageText = Color(0xFF047857); // Deep Sage Text #047857
  static const Color textPrimary = Color(0xFF0B2B1B); // Deep Dark Evergreen Text
  static const Color textSecondary = Color(0xFF2D4A3E); // Soft Charcoal Evergreen
  static const Color textMuted = Color(0xFF64748B);

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: surfaceBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.light(
        primary: accentLime,
        secondary: emeraldNeon,
        surface: surfaceCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.dmSans(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.syne(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 2,
        shadowColor: const Color(0xFF15803D).withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: surfaceBorder, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentLime,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
