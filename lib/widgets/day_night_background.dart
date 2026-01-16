import 'package:flutter/material.dart';
import '../models/game_enums.dart'; // Import GameEnum
import 'particle_background.dart';
import '../theme/noir_design.dart';

class DayNightBackground extends StatelessWidget {
  final GamePhase phase;
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

    if (phase == GamePhase.day) {
      // Day: Bright Light Theme
      mainDecoration = BoxDecoration(color: NoirColors.highlightBright);
    } else {
      // Night: Deep Dark Theme
      mainDecoration = BoxDecoration(color: NoirColors.backgroundDeep);
    }

    return AnimatedContainer(
      duration: const Duration(
        seconds: 4,
      ), // Slower, more atmospheric transition
      decoration: mainDecoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Particle Layer
          ParticleBackground(phase: phase),

          child,
        ],
      ),
    );
  }
}
