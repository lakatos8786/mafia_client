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
      // Day colors: Stylish Blue
      gradientColors = [const Color(0xFF4FC3F7), const Color(0xFFE1F5FE)];
    } else {
      // Night: Deep Cyberpunk Blue
      gradientColors = [const Color(0xFF0F3460), const Color(0xFF1A1A2E)];
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Vignette Overlay for cinematic feel
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
