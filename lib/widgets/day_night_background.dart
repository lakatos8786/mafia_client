import 'package:flutter/material.dart';
import '../models/game_enums.dart';
import 'particle_background.dart';
import '../theme/app_colors.dart';

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
      // Day: Cyber Blue Sky with bright center
      mainDecoration = const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.5,
          colors: [
            AppColors.backgroundDayStart,
            AppColors.backgroundDayEnd,
            AppColors.backgroundMain,
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
            AppColors.backgroundNightStart,
            AppColors.backgroundNightEnd,
            Colors.black,
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
          // Vignette effect
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppColors.overlayBlack50.withValues(alpha: 0.6),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          // Particle Layer
          ParticleBackground(phase: phase),

          child,
        ],
      ),
    );
  }
}
