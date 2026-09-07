import 'package:flutter/material.dart';

/// Centralized theme so colors/fonts/buttons are defined once,
/// not scattered across every screen.
///
/// Worth filling out properly: any text style left undefined here falls
/// back to Material's defaults, which don't follow this palette. Screens
/// use bodySmall and titleMedium, so those are defined rather than left
/// to chance.
class AppTheme {
  // Calm, clinical-but-friendly palette suitable for a health app
  static const Color primary = Color(0xFF2E7D6B); // teal-green
  static const Color primaryDark = Color(0xFF1B4D42);
  static const Color primaryLight = Color(0xFFE6F1EE);
  static const Color accent = Color(0xFFF2A65A); // warm amber for CTAs
  static const Color background = Color(0xFFF4F7F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF16211E);
  static const Color textSecondary = Color(0xFF667471);
  static const Color danger = Color(0xFFD9534F);
  static const Color success = Color(0xFF4C9A6A);
  static const Color border = Color(0xFFE2EAE7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          side: const BorderSide(color: border, width: 1.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight,
        selectedColor: primary,
        side: BorderSide.none,
        labelStyle: const TextStyle(
          color: primaryDark,
          fontWeight: FontWeight.w500,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 15),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }
}
