import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 팔레트 상수 정의 - Consolidated Midnight Mystery
class AppColors {
  // --- Core Backgrounds ---
  static const Color backgroundMain = Color(0xFF120E24); // Deep Midnight
  static const Color backgroundDark = Color(0xFF0B0818); // Darker shade
  static const Color surface = Color(
    0xFF1F1A3D,
  ); // Panel/Card background (merged)

  // --- Core Neon Accents ---
  static const Color accentCyan = Color(
    0xFF00D4FF,
  ); // Action/Info (Police, Doctor)
  static const Color accentMagenta = Color(0xFFFF007F); // Mafia/Danger/Error
  static const Color accentYellow = Colors.yellowAccent; // Highlight/Warning

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
  static const Color doctor = accentCyan;
  static const Color police = accentCyan;
  static const Color citizen = textSecondary;
  static const Color dead = accentMagenta;
  static const Color voteGold = Color(0xFFF59E0B);

  // --- Greys (Simplified) ---
  static const Color greyDark = Color(0xFF1E293B);
  static const Color greyMuted = Color(0xFF757575);

  // --- Overlays & Glass ---
  static const Color overlayBlack85 = Color(0xD9000000);
  static const Color overlayBlack50 = Color(0x80000000);
  static const Color overlayWhite10 = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // --- Compatibility Aliases (Avoid breaking existing code) ---
  static const Color backgroundLighter = surface;
  static const Color backgroundDayStart = surface;
  static const Color backgroundDayEnd = backgroundMain;
  static const Color backgroundNightStart = backgroundMain;
  static const Color backgroundNightEnd = backgroundDark;
  static const Color loginButtonSecondary = surface;
  static const Color votePillEnd = accentMagenta;
  static const Color doctorDark = Color(0xFF0056B3);
  static const Color policeDark = Color(0xFF0056B3);
  static const Color citizenDark = textMuted;
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
