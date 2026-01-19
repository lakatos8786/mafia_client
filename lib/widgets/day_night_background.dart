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

    if (phase == GamePhase.day ||
        phase == GamePhase.lastWord ||
        phase == GamePhase.judgement) {
      // Day: Slightly lighter midnight purple with cyan ambient glow
      mainDecoration = const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.5,
          colors: [
            AppColors.backgroundLighter,
            AppColors.backgroundDayEnd,
            AppColors.backgroundMain,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      );
    } else {
      // Night: Deeper midnight purple with magenta/crimson haze
      mainDecoration = const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.5, -0.3),
          radius: 1.3,
          colors: [
            AppColors.backgroundNightStart,
            AppColors.backgroundNightEnd,
            AppColors.backgroundDark,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: mainDecoration,
            child: Container(
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
          ),
        ),
        // Particle Layer (already has its own internal RepaintBoundary)
        ParticleBackground(phase: phase),
        // The rest of the app
        child,
      ],
    );
  }
}
