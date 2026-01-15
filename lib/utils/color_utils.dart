import 'package:flutter/material.dart';

class ColorUtils {
  static const List<Color> _senderColors = [
    // 1. Red/Rose Group
    Color(0xFFFB7185), // Rose 400
    Color(0xFFF43F5E), // Rose 500
    Color(0xFFE11D48), // Rose 600
    Color(0xFFBE123C), // Rose 700
    Color(0xFF9F1239), // Rose 800
    // 2. Orange/Amber Group
    Color(0xFFFBBF24), // Amber 400
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFD97706), // Amber 600
    Color(0xFFB45309), // Amber 700
    Color(0xFF92400E), // Amber 800
    // 3. Green/Emerald Group
    Color(0xFF34D399), // Emerald 400
    Color(0xFF10B981), // Emerald 500
    Color(0xFF059669), // Emerald 600
    Color(0xFF047857), // Emerald 700
    Color(0xFF065F46), // Emerald 800
    // 4. Blue/Sky Group
    Color(0xFF38BDF8), // Sky 400
    Color(0xFF0EA5E9), // Sky 500
    Color(0xFF0284C7), // Sky 600
    Color(0xFF0369A1), // Sky 700
    Color(0xFF075985), // Sky 800
    // 5. Indigo/Purple Group
    Color(0xFF818CF8), // Indigo 400
    Color(0xFF6366F1), // Indigo 500
    Color(0xFF4F46E5), // Indigo 600
    Color(0xFF4338CA), // Indigo 700
    Color(0xFF3730A3), // Indigo 800
    // 6. Fuchsia/Pink Group
    Color(0xFFE879F9), // Fuchsia 400
    Color(0xFFD946EF), // Fuchsia 500
    Color(0xFFC026D3), // Fuchsia 600
    Color(0xFFA21CAF), // Fuchsia 700
    Color(0xFF86198F), // Fuchsia 800
  ];

  /// Generates a deterministic color based on the input string
  /// Uses a prime multiplier to improve distribution and reduce collisions
  static Color getSenderColor(String name) {
    if (name.isEmpty) return Colors.white70;

    // Use a more robust mixing logic for similar names
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = (hash * 31) + name.codeUnitAt(i);
    }

    // Add another layer of scrambling to disperse near-identical strings
    hash = (hash ^ (hash >> 16)) * 0x45d9f3b;
    hash = (hash ^ (hash >> 16)) * 0x45d9f3b;
    hash = hash ^ (hash >> 16);

    return _senderColors[hash.abs() % _senderColors.length];
  }
}
