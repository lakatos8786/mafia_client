import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundMain = Color(0xFF0F172A); // Deep Slate
  static const Color backgroundDark = Color(0xFF1A1A2E); // Deep Dark Blue
  static const Color backgroundLighter = Color(
    0xFF1E293B,
  ); // Slightly Lighter Blue
  static const Color surface = Color(0xFF1E293B);

  // Primary Accents
  static const Color primary = Color(0xFFF43F5E); // Neon Crimson
  static const Color secondary = Color(0xFF0EA5E9); // Cyber Blue
  static const Color accentYellow = Colors.yellowAccent;

  // Roles
  static const Color mafiaRed = Color(0xFFE94560);
  static const Color doctorGreen = Color(0xFF4ECCA3);
  static const Color policeBlue = Color(0xFF38BDF8);
  static const Color citizenLink = Color(0xFF94A3B8);

  // Status
  static const Color deadRed = Color(0xFFFF1744);
  static const Color textWhite = Colors.white;
  static const Color textDim = Colors.white70;

  // Selection Highlights
  static const Color voteGold = Color(0xFFF59E0B); // Gold for vote selection
  static const Color mafiaRedDark = Color(0xFF9F1239); // Darker mafia red
  static const Color doctorGreenDark = Color(0xFF065F46); // Darker doctor green
  static const Color policeBlueDark = Color(0xFF1E3A8A); // Darker police blue

  // Vote Pill
  static const Color votePillStart = Color(0xFFF43F5E);
  static const Color votePillEnd = Color(0xFFE11D48);

  // Overlay & Transparencies
  static const Color overlayBlack85 = Color(0xD9000000); // Black 85%
  static const Color overlayBlack50 = Color(0x80000000); // Black 50%
  static const Color overlayWhite90 = Color(0xE6FFFFFF); // White 90%
  static const Color overlayWhite70 = Color(0xB3FFFFFF); // White 70%
  static const Color overlayWhite20 = Color(0x33FFFFFF); // White 20%
  static const Color overlayWhite12 = Color(0x1FFFFFFF); // White 12%
  static const Color overlayWhite10 = Color(0x1AFFFFFF); // White 10%

  // Player Grid Status
  static const Color statusReady = Color(0xFF10B981); // Green-ish
  static const Color statusNotReady = Color(0xFFF43F5E); // Red-ish
  static const Color statusDefault = Color(0xFF60A5FA); // Blue-ish
  static const Color deadOverlay = Color(0x4DFF0000); // Red 30%
  static const Color citizenGradientEnd = Color(0xFF475569); // Slate 600

  // Gradients
  static const Color gradientSky = Color(0xFF38BDF8);
  static const Color gradientIndigo = Color(0xFF818CF8);

  // Greys
  static const Color grey800 = Color(0xFF424242);
  static const Color grey600 = Color(0xFF757575);
}
