import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../theme/noir_design.dart';
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
    Color roleIndicatorColor = NoirColors.textSecondary;
    String roleEmoji = '👤';
    if (player.role == GameRole.mafia) {
      roleIndicatorColor = NoirColors.crimson;
      roleEmoji = '🕶️';
    } else if (player.role == GameRole.doctor) {
      roleIndicatorColor = NoirColors.textPrimary;
      roleEmoji = '💉';
    } else if (player.role == GameRole.police) {
      roleIndicatorColor = NoirColors.textPrimary;
      roleEmoji = '🚨';
    } else {
      roleIndicatorColor = NoirColors.textTertiary;
    }

    final Color cardBgColor = isWinner
        ? NoirColors.surface.withValues(alpha: 0.3)
        : (player.isAlive
              ? NoirColors.surfaceDark.withValues(alpha: 0.8)
              : Colors.black.withValues(alpha: 0.8));

    final borderColor = isWinner
        ? (mainColor == NoirColors.crimson
              ? NoirColors.crimson
              : NoirColors.textPrimary)
        : NoirColors.border;
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
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: borderWidth),
                    boxShadow: isWinner
                        ? [
                            BoxShadow(
                              color: mainColor.withValues(alpha: 0.2),
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
                          color: NoirColors.surfaceDark,
                          border: Border.all(
                            color: roleIndicatorColor,
                            width: 2,
                          ),
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
                              style: GoogleFonts.gowunDodum(
                                color: player.isAlive
                                    ? NoirColors.textPrimary
                                    : NoirColors.textSecondary,
                                fontSize: ResponsiveUtils.fontSize(context, 14),
                                fontWeight: FontWeight.w900,
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
                                color: NoirColors.textTertiary,
                                fontSize: ResponsiveUtils.fontSize(context, 11),
                                fontWeight: FontWeight.bold,
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
                      decoration: BoxDecoration(
                        color: mainColor == NoirColors.crimson
                            ? NoirColors.crimson
                            : NoirColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: ResponsiveUtils.iconSize(context, 12),
                        color: Colors.black,
                      ),
                    ),
                  ),
                if (!player.isAlive)
                  Positioned(
                    top: ResponsiveUtils.spacing(context, 6),
                    right: ResponsiveUtils.spacing(context, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💀', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '사망',
                            style: GoogleFonts.gowunDodum(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
