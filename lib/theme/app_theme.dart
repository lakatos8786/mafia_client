import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'noir_design.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: NoirColors.crimson,
      scaffoldBackgroundColor: NoirColors.highlightBright,
      colorScheme: const ColorScheme.light(
        primary: NoirColors.crimson,
        secondary: NoirColors.textSecondary,
        surface: NoirColors.highlightBright,
        error: NoirColors.crimson,
      ),
      textTheme: GoogleFonts.gowunDodumTextTheme().copyWith(
        displayLarge: GoogleFonts.gowunDodum(
          color: NoirColors.backgroundDeep,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.gowunDodum(color: NoirColors.backgroundDeep),
      ),
      iconTheme: const IconThemeData(color: NoirColors.backgroundDeep),
      cardTheme: const CardThemeData(
        color: NoirColors.highlightBright,
        elevation: 2,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: NoirColors.crimson,
      scaffoldBackgroundColor: NoirColors.backgroundDeep,
      colorScheme: const ColorScheme.dark(
        primary: NoirColors.crimson,
        secondary: NoirColors.textSecondary,
        surface: NoirColors.surface,
        error: NoirColors.crimson,
      ),
      textTheme: GoogleFonts.gowunDodumTextTheme().copyWith(
        displayLarge: GoogleFonts.gowunDodum(
          color: NoirColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.gowunDodum(color: NoirColors.textPrimary),
      ),
      cardTheme: const CardThemeData(color: NoirColors.surface, elevation: 0),
    );
  }
}
