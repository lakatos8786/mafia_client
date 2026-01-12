import 'package:flutter/material.dart';
import 'particle_background.dart';

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
    Decoration mainDecoration;

    if (phase == '낮') {
      // Day: Cyber Blue Sky with bright center
      mainDecoration = const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.5,
          colors: [
            Color(0xFF38BDF8), // Light Blue
            Color(0xFF0284C7), // Darker Blue
            Color(0xFF0F172A), // Dark Fade
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      );
    } else {
      // Night: Deep Noir with Purple haze
      mainDecoration = const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.5, -0.3),
          radius: 1.3,
          colors: [
            Color(0xFF312E81), // Indigo
            Color(0xFF1E1B4B), // Deep Indigo
            Color(0xFF000000), // Pure Black
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: mainDecoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle noise/grain effect simulation (optional, or just vignetting)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6), // Heavier vignette
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          // Particle Layer
          ParticleBackground(mode: {'type': phase}),

          child,
        ],
      ),
    );
  }
}
