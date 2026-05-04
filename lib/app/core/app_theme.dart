import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryGreen = Color(0xFF1A4A3A);
  static const Color lightGreen = Color(0xFF2D7A5E);
  static const Color tealAccent = Color(0xFF4DB893);
  static const Color goldAccent = Color(0xFFD4A843);
  static const Color darkBg = Color(0xFF0D1F17);
  static const Color darkCard = Color(0xFF1A2E22);
  static const Color lightBg = Color(0xFFF5F7F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warmYellow = Color(0xFFF59E0B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
        iconTheme: IconThemeData(color: primaryGreen),
      ),
    );
  }
}