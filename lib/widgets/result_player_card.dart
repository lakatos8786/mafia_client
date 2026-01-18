import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_utils.dart';

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
    } else if (player.role == GameRole.madman) {
      roleColor = AppColors.madman;
      roleEmoji = '🤡';
    } else if (player.role == GameRole.politician) {
      roleColor = AppColors.politician;
      roleEmoji = '🏛️';
    } else if (player.role == GameRole.soldier) {
      roleColor = AppColors.soldier;
      roleEmoji = '🎖️';
    } else {
      roleColor = Colors.white70;
    }

    final identityColor = AppColors.getIdentityColor(player.nickname);

    final borderColor = isWinner
        ? AppColors.voteGold
        : identityColor.withValues(alpha: 0.2);
    final borderWidth = isWinner ? 3.0 : 1.0;

    return FadeInLeft(
      delay: Duration(milliseconds: 50 * index),
      duration: const Duration(milliseconds: 400),
      child: Builder(
        builder: (context) {
          return SizedBox(
            width: ResponsiveUtils.iconSize(context, 160),
            height: ResponsiveUtils.iconSize(context, 75),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.padding(context, 8),
                    vertical: ResponsiveUtils.padding(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: isWinner
                        ? mainColor.withValues(alpha: 0.1)
                        : identityColor.withValues(alpha: 0.08),
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
                        width: ResponsiveUtils.iconSize(context, 36),
                        height: ResponsiveUtils.iconSize(context, 36),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: roleColor.withValues(alpha: 0.2),
                          border: Border.all(color: roleColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            roleEmoji,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              player.nickname,
                              style: GoogleFonts.ibmPlexSansKr(
                                color: player.isAlive
                                    ? identityColor
                                    : Colors.grey,
                                fontSize: ResponsiveUtils.fontSize(context, 14),
                                fontWeight: FontWeight.bold,
                                decoration: player.isAlive
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.overlayBlack50.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                player.role?.label ?? '알 수 없음',
                                style: TextStyle(
                                  color: roleColor,
                                  fontSize: ResponsiveUtils.fontSize(
                                    context,
                                    10,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
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
                    top: ResponsiveUtils.spacing(context, -6),
                    right: ResponsiveUtils.spacing(context, -6),
                    child: Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.padding(context, 3),
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.voteGold,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: ResponsiveUtils.iconSize(context, 12),
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
