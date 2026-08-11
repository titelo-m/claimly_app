import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF49D86A);
  static const Color secondaryColor = Color(0xFF49D86A);
  static const Color accentColor = Color(0xFF49D86A);
  static const Color backgroundColor = Color(0xFF061815);
  static const Color surfaceColor = Color(0xFF081D18);
  static const Color cardColor = Color(0xFF0B2F27);
  
  static final ThemeData lightTheme = _buildDarkTheme();
  static final ThemeData darkTheme = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: Colors.white.withOpacity(0.08),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        background: Color.fromARGB(255, 12, 53, 46),
        surface: Color.fromARGB(255, 16, 67, 55),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color.fromARGB(0, 44, 42, 42),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color.fromARGB(255, 12, 53, 44),
      ),
    );
  }
}
