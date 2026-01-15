import 'package:flutter/material.dart';

class ColorUtils {
  static const List<Color> _senderColors = [
    Color(0xFF38BDF8), // Sky Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6366F1), // Indigo
    Color(0xFFF43F5E), // Rose
    Color(0xFF2DD4BF), // Teal
  ];

  /// Generates a deterministic color based on the input string
  static Color getSenderColor(String name) {
    if (name.isEmpty) return Colors.white70;

    // Simple hash to select color
    final int hash = name.hashCode;
    return _senderColors[hash.abs() % _senderColors.length];
  }
}
