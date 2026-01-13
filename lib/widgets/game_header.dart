import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/game_enums.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import 'phase_timer.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.only(
          top: 15 + topPadding, // Add status bar height
          bottom: 15,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Phase label with timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: game.gamePhase == GamePhase.day
                            ? Colors.orangeAccent.withValues(alpha: 0.4)
                            : const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        game.gamePhase == GamePhase.day
                            ? Icons.wb_sunny
                            : Icons.nightlight_round,
                        color: game.gamePhase == GamePhase.day
                            ? Colors.orangeAccent
                            : const Color(0xFF818CF8),
                        size: 28,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        '${game.gamePhase.label} ${game.dayCount}일차',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: game.gamePhase == GamePhase.day
                                  ? Colors.orangeAccent
                                  : const Color(0xFF6366F1),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Timer widget
                const PhaseTimer(),
              ],
            ),

            const SizedBox(height: 8),

            // Role Counts
            if (game.roleCountDisplayStrings.isNotEmpty)
              Wrap(
                spacing: 15,
                children: game.roleCountDisplayStrings.map((displayString) {
                  return Text(
                    displayString,
                    style: GoogleFonts.gowunDodum(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 10),

            // My Role Badge - with role-specific colors
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getRoleColor(game.myRoleEnum).withValues(alpha: 0.3),
                    AppColors.surface.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _getRoleColor(game.myRoleEnum).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getRoleColor(
                      game.myRoleEnum,
                    ).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getRoleEmoji(game.myRoleEnum),
                    style: TextStyle(
                      fontSize: 22,
                      color: _getRoleColor(game.myRoleEnum),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    game.myRole ?? AppStrings.unknownRole,
                    style: GoogleFonts.gowunDodum(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return AppColors.mafiaRed;
      case GameRole.doctor:
        return AppColors.doctorGreen;
      case GameRole.police:
        return AppColors.policeBlue;
      case GameRole.citizen:
        return AppColors.citizenLink;
      default:
        return AppColors.primary;
    }
  }

  String _getRoleEmoji(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return '🕶️'; // Sunglasses - cool and mysterious
      case GameRole.doctor:
        return '💉'; // Syringe
      case GameRole.police:
        return '🚨'; // Police siren
      case GameRole.citizen:
        return '👤'; // Person silhouette
      default:
        return '❓'; // Question mark for unknown
    }
  }
}
