import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 팔레트 상수 정의
class AppColors {
  // --- Core Palette ---
  static const Color backgroundMain = Color(0xFF0F172A); // Deep Slate
  static const Color backgroundDark = Color(0xFF1A1A2E); // Deep Dark Blue
  static const Color backgroundLighter = Color(0xFF1E293B);
  static const Color surface = Color(0xFF1E293B);

  // --- Background Gradients ---
  static const Color backgroundDayStart = Color(0xFF38BDF8);
  static const Color backgroundDayEnd = Color(0xFF0284C7);
  static const Color backgroundNightStart = Color(0xFF312E81);
  static const Color backgroundNightEnd = Color(0xFF1E1B4B);

  // --- Primary Accents ---
  static const Color primary = Color(0xFFF43F5E); // Neon Crimson
  static const Color secondary = Color(0xFF0EA5E9); // Cyber Blue
  static const Color nightAccent = Color(0xFF818CF8);
  static const Color accentYellow = Colors.yellowAccent;

  // --- Role Colors ---
  static const Color mafia = Color(0xFFE94560);
  static const Color mafiaDark = Color(0xFF9F1239);
  static const Color doctor = Color(0xFF4ECCA3);
  static const Color doctorDark = Color(0xFF065F46);
  static const Color police = Color(0xFF38BDF8);
  static const Color policeDark = Color(0xFF1E3A8A);
  static const Color citizen = Color(0xFF94A3B8);
  static const Color citizenDark = Color(0xFF475569);

  // --- Status & Feedback ---
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Colors.orangeAccent;
  static const Color info = Color(0xFF60A5FA);
  static const Color dead = Color(0xFFFF1744);
  static const Color deadOverlay = Color(0x4DFF0000);
  static const Color voteGold = Color(0xFFF59E0B);

  // --- Text ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Color(0xFFA1A1AA);

  // --- Overlays & Transparencies ---
  static const Color overlayBlack85 = Color(0xD9000000);
  static const Color overlayBlack50 = Color(0x80000000);
  static const Color overlayWhite12 = Color(0x1FFFFFFF);
  static const Color overlayWhite10 = Color(0x1AFFFFFF);

  // --- Specialized ---
  static const Color votePillEnd = Color(0xFFE11D48);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey600 = Color(0xFF757575);
  static const Color greyDark = Color(0xFF1E293B);
  static const Color glassBorder = Color(0x33FFFFFF);

  // --- Legacy Mappings ---
  static const Color mafiaRed = mafia;
  static const Color doctorGreen = doctor;
  static const Color policeBlue = police;
  static const Color citizenLink = citizen;
  static const Color deadRed = dead;
  static const Color textWhite = textPrimary;
  static const Color textDim = textSecondary;
  static const Color mafiaRedDark = mafiaDark;
  static const Color doctorGreenDark = doctorDark;
  static const Color policeBlueDark = policeDark;
  static const Color statusReady = success;
  static const Color statusNotReady = error;
  static const Color loginButtonSecondary = Color(0xFF0F3460);
  static const Color overlayWhite90 = Color(0xE6FFFFFF);
  static const Color overlayWhite70 = Color(0xB3FFFFFF);
  static const Color overlayWhite20 = Color(0x33FFFFFF);
}
