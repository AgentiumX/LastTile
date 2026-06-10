import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color primary = Color(0xFF4A9EFF);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color tileNormal = Color(0xFF3A3A3A);
  static const Color tileVisited = Color(0xFF1A1A1A);
  static const Color tileStart = Color(0xFF4A9EFF);
  static const Color tileEnd = Color(0xFFFFD93D);
  static const Color tileTeleport = Color(0xFFB967FF);
  static const Color tileKey = Color(0xFF52C41A);
  static const Color tileLock = Color(0xFFFA8C16);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData get light => ThemeData(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: textPrimary,
            letterSpacing: 4,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
      );
}
