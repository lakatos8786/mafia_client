import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/game_enums.dart';
import '../theme/app_colors.dart';

class PhaseTimer extends StatelessWidget {
  const PhaseTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Don't show timer if no time is set
    if (game.timerTotal == 0) {
      return const SizedBox.shrink();
    }

    final isNight = game.gamePhase == GamePhase.night;
    final timerColor = isNight ? AppColors.mafiaRed : AppColors.policeBlue;
    final isLowTime = game.timerRemaining <= 10;

    return Semantics(
      label: '남은 시간 ${game.timerRemaining}초',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLowTime
                ? AppColors.deadRed.withOpacity(0.8)
                : timerColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: isLowTime
              ? [
                  BoxShadow(
                    color: AppColors.deadRed.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircularTimer(game.timerProgress, timerColor, isLowTime),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.gowunDodum(
                fontSize: isLowTime ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: isLowTime ? AppColors.deadRed : Colors.white,
              ),
              child: Text('${game.timerRemaining}'),
            ),
            Text(
              '초',
              style: GoogleFonts.gowunDodum(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTimer(double progress, Color color, bool isLowTime) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _TimerPainter(
          progress: progress,
          color: isLowTime ? AppColors.deadRed : color,
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress, // Sweep based on progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
