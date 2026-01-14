import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../theme/app_colors.dart';

class ResultPlayerCard extends StatelessWidget {
  final dynamic
  player; // using dynamic to avoid tight coupling if Player model varies, but generally it's Player
  final int index;
  final bool isWinner;
  final Color mainColor;

  const ResultPlayerCard({
    super.key,
    required this.player,
    required this.index,
    required this.isWinner,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    Color roleColor = Colors.grey;
    String roleEmoji = '👤';
    if (player.role == GameRole.mafia) {
      roleColor = AppColors.mafiaRed;
      roleEmoji = '🕶️';
    } else if (player.role == GameRole.doctor) {
      roleColor = AppColors.doctorGreen;
      roleEmoji = '💉';
    } else if (player.role == GameRole.police) {
      roleColor = AppColors.policeBlue;
      roleEmoji = '🚨';
    } else {
      roleColor = Colors.white70;
    }

    final borderColor = isWinner
        ? AppColors.voteGold
        : Colors.grey.withValues(alpha: 0.3);
    final borderWidth = isWinner ? 3.0 : 1.0;

    return FadeInLeft(
      delay: Duration(milliseconds: 50 * index),
      duration: const Duration(milliseconds: 400),
      child: SizedBox(
        width: 180,
        height: 85,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isWinner
                    ? mainColor.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isWinner ? mainColor : borderColor,
                  width: borderWidth,
                ),
                boxShadow: isWinner
                    ? [
                        BoxShadow(
                          color: mainColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: roleColor.withValues(alpha: 0.2),
                      border: Border.all(color: roleColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        roleEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          player.nickname,
                          style: GoogleFonts.gowunDodum(
                            color: player.isAlive ? Colors.white : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: player.isAlive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          player.role?.label ?? '알 수 없음',
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isWinner)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.voteGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
