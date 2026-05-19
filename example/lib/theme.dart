import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandCenterTheme {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color secondaryCyan = Color(0xFF00BCD4);
  static const Color darkBg = Color(0xFF0A0E12);
  static const Color cardBg = Color(0xFF161B22);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color pulseGreen = Color(0xFF4CAF50);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: secondaryCyan,
        surface: cardBg,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.publicSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headlineMedium: GoogleFonts.publicSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
            labelSmall: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(13)),
        ),
      ),
    );
  }
}
