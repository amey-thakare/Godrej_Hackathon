import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Field Intelligence Color Palette
  static const Color darkBackground = Color(0xFF070E09); // Deepest Emerald Midnight
  static const Color surfaceCard = Color(0xD90E1A11); // Glass card rgba(14,26,17,0.85)
  static const Color surfaceBorder = Color(0x3B10B981); // Neon Emerald Border
  static const Color surfaceGlass = Color(0xE60A140C);
  static const Color primaryForest = Color(0xFF132A1C); // Rich Forest Green
  static const Color accentLime = Color(0xFFA3E635); // Electric Lime #A3E635
  static const Color emeraldNeon = Color(0xFF10B981); // Vibrant Emerald #10B981
  static const Color amberAccent = Color(0xFFF59E0B); // Warm Amber
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color sageText = Color(0xFF86EFAC); // Soft Sage Green
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF64748B);

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: surfaceBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentLime,
        secondary: emeraldNeon,
        surface: darkBackground,
        onPrimary: darkBackground,
        onSecondary: textPrimary,
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
          color: darkBackground,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
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
        backgroundColor: Color(0xF5070E09),
        selectedItemColor: accentLime,
        unselectedItemColor: sageText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
