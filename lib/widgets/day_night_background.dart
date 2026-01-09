import 'package:flutter/material.dart';

class DayNightBackground extends StatelessWidget {
  final String phase; // '낮' or '밤'
  final Widget child;

  const DayNightBackground({
    super.key,
    required this.phase,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on phase
    List<Color> gradientColors;

    if (phase == '낮') {
      // Day colors: Light Blue to lighter Blue
      gradientColors = [
        Color(0xFF4FC3F7), // Light Blue 300
        Color(0xFFE1F5FE), // Light Blue 50
      ];
    } else {
      // Night or other (default) colors: Dark Blue to Black
      gradientColors = [
        Color(0xFF0D47A1), // Blue 900
        Colors.black,
      ];
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: child,
    );
  }
}
