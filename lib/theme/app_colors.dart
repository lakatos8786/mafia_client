import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 팔레트 상수 정의 - Consolidated Midnight Mystery
class AppColors {
  // --- Core Backgrounds ---
  static const Color backgroundMain = Color(0xFF120E24); // Deep Midnight
  static const Color backgroundDark = Color(0xFF0B0818); // Darker shade
  static const Color surface = Color(0xFF1F1A3D); // Panel/Card background

  // --- Core Neon Accents ---
  static const Color accentCyan = Color(0xFF00FBFF); // Neon Cyan
  static const Color accentMagenta = Color(
    0xFFFF0055,
  ); // Sharp Neon Red-Pink (Less purple)
  static const Color accentYellow = Color(0xFFFFFF00); // Neon Yellow

  // --- Theme Mappings ---
  static const Color primary = accentCyan;
  static const Color secondary = accentMagenta;

  // --- Text (Midnight Purple context) ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(
    0xFFB3A0CD,
  ); // Lavender - secondary info
  static const Color textMuted = Color(0xFF6B5B95); // Deep Purple - muted info

  // --- Status & Roles ---
  static const Color mafia = accentMagenta;
  static const Color mafiaDark = Color(0xFF800040);
  static const Color doctor = Color(0xFF00FF9F); // Fresh Greenish Neon
  static const Color police = Color(0xFF007BFF); // Police Blue
  static const Color policeRed = Color(0xFFFF0033); // Police Red
  static const Color citizen = textSecondary;
  static const Color madman = Color(0xFF9D50BB); // Neon Purple
  static const Color madmanDark = Color(0xFF3B0066);
  static const Color politician = Color(0xFFFFD700); // Neon Gold
  static const Color politicianDark = Color(0xFF8B7500);
  static const Color soldier = Color(0xFF4CAF50); // Military Green
  static const Color soldierDark = Color(0xFF1B5E20);
  static const Color dead = Color(0xFFFF3131); // Bright Neon Red
  static const Color voteGold = Color(0xFFFFAC1C); // Neon Orange/Gold

  // --- Greys (Simplified) ---
  static const Color greyDark = Color(0xFF1E293B);
  static const Color greyMuted = Color(0xFF757575);

  // --- Overlays & Glass ---
  static const Color overlayBlack85 = Color(0xD9000000);
  static const Color overlayBlack50 = Color(0x80000000);
  static const Color overlayWhite10 = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // --- Identity Neon Palette (For Nicknames & Player Cards) ---
  static const List<Color> _neonIdentityColors = [
    Color(0xFF00FBFF), // Cyan
    Color(0xFFFF00FF), // Magenta
    Color(0xFF00FF9F), // Spring Green
    Color(0xFFFFFF00), // Yellow
    Color(0xFFFF3131), // Red
    Color(0xFF8A2BE2), // Blue Violet
    Color(0xFF00E5FF), // Electric Blue
    Color(0xFF39FF14), // Alien Green
    Color(0xFFFF6EC7), // Neon Pink
    Color(0xFFFFD700), // Neon Gold
    Color(0xFFE0B0FF), // Mauve
    Color(0xFFCCFF00), // Lime
    Color(0xFF7DF9FF), // Electric Blue
    Color(0xFFFF4901), // Neon Orange
    Color(0xFFF0F8FF), // Alice Blue
  ];

  /// Generates a deterministic neon color based on the input string (nickname)
  static Color getIdentityColor(String name) {
    if (name.isEmpty) return Colors.white70;

    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = (hash * 31) + name.codeUnitAt(i);
    }

    // Scramble to reduce collisions
    hash = (hash ^ (hash >> 16)) * 0x45d9f3b;
    hash = (hash ^ (hash >> 16)) * 0x45d9f3b;
    hash = hash ^ (hash >> 16);

    return _neonIdentityColors[hash.abs() % _neonIdentityColors.length];
  }

  // --- Compatibility Aliases ---
  static const Color backgroundLighter = surface;
  static const Color backgroundDayStart = surface;
  static const Color backgroundDayEnd = backgroundMain;
  static const Color backgroundNightStart = backgroundMain;
  static const Color backgroundNightEnd = backgroundDark;
  static const Color loginButtonSecondary = surface;
  static const Color votePillEnd = accentMagenta;
  static const Color doctorDark = Color(0xFF008F5B);
  static const Color policeDark = Color(0xFF008BBB);
  static const Color citizenDark = textMuted;
  static const Color madmanPurple = madman;
  static const Color politicianGold = politician;
  static const Color soldierGreen = soldier;
  static const Color mafiaRed = mafia;
  static const Color doctorGreen = doctor;
  static const Color policeBlue = police;
  static const Color citizenLink = citizen;
  static const Color deadRed = dead;
  static const Color error = accentMagenta;
  static const Color nightAccent = Color(0xFF818CF8);
  static const Color statusNotReady = secondary;
  static const Color grey800 = backgroundDark;
  static const Color grey700 = greyDark;
  static const Color grey600 = greyMuted;
}
