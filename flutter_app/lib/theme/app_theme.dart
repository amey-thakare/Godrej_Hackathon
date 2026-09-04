import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Field Intelligence Color Palette (matching React + Tailwind v4 theme)
  static const Color darkBackground = Color(0xFF0D1410);
  static const Color surfaceCard = Color(0xB20D1410); // Glass card rgba(13,20,16,0.65)
  static const Color surfaceBorder = Color(0x24A8E63D); // rgba(168,230,61,0.14)
  static const Color surfaceGlass = Color(0xB20D1410);
  static const Color primaryForest = Color(0xFF2D4A2D); // Moss Green #2D4A2D
  static const Color accentLime = Color(0xFFA8E63D); // Electric Lime #A8E63D
  static const Color amberAccent = Color(0xFFE8A030); // Amber #E8A030
  static const Color warningAmber = Color(0xFFE8A030); // Backward-compat alias
  static const Color sageText = Color(0xFF6B8F6B); // Sage #6B8F6B
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE0EAD0);
  static const Color textMuted = Color(0xFF6B8F6B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentLime,
        secondary: primaryForest,
        surface: Color(0xFF0D1410),
        onPrimary: darkBackground,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.bold,
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
          fontSize: 20,
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
          color: darkBackground,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xF20D1410),
        selectedItemColor: accentLime,
        unselectedItemColor: sageText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
