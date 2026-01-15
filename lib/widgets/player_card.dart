import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../utils/responsive_utils.dart';
import '../utils/color_utils.dart';

class PlayerCard extends ConsumerWidget {
  final Player player;
  final bool isMe;
  final bool isMyVoteTarget;
  final List<String> selectionTargets;
  final VoidCallback onTap;
  final int voteCount;
  final String votersList;
  final bool showMafiaIndicator;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isMe,
    required this.isMyVoteTarget,
    required this.selectionTargets,
    required this.onTap,
    this.voteCount = 0,
    this.votersList = '',
    this.showMafiaIndicator = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define Colors based on state
    final isSelected = selectionTargets.isNotEmpty || isMyVoteTarget;

    // Identity Color
    final identityColor = ColorUtils.getSenderColor(player.nickname);

    // Border Color Logic
    Color borderColor = AppColors.overlayWhite12;
    if (!player.isAlive) {
      borderColor = AppColors.deadOverlay;
    } else if (isSelected) {
      if (isMyVoteTarget) {
        borderColor = AppColors.voteGold;
      } else if (selectionTargets.contains(GameRole.mafia.name)) {
        borderColor = AppColors.statusNotReady;
      } else if (selectionTargets.contains(GameRole.doctor.name)) {
        borderColor = AppColors.statusReady;
      } else {
        borderColor = AppColors.statusDefault;
      }
    }

    // Gradient Colors
    List<Color> gradientColors = [
      AppColors.backgroundMain.withValues(alpha: 0.8),
      AppColors.backgroundMain.withValues(alpha: 0.8),
    ];

    if (player.isAlive && isSelected) {
      if (isMyVoteTarget) {
        gradientColors = [
          const Color(0xFFF59E0B).withValues(alpha: 0.6),
          Colors.transparent,
        ];
      } else if (selectionTargets.contains(GameRole.mafia.name)) {
        gradientColors = [
          AppColors.mafiaRedDark.withValues(alpha: 0.6),
          Colors.transparent,
        ];
      } else if (selectionTargets.contains(GameRole.doctor.name)) {
        gradientColors = [
          AppColors.doctorGreenDark.withValues(alpha: 0.6),
          Colors.transparent,
        ];
      } else {
        // Police or others
        gradientColors = [
          AppColors.policeBlueDark.withValues(alpha: 0.6),
          Colors.transparent,
        ];
      }
    } else if (player.isAlive && !isSelected) {
      // Idle alive state: Subtle identity-based background with dark base
      gradientColors = [
        identityColor.withValues(alpha: 0.4),
        const Color(0xFF0F172A).withValues(alpha: 0.85),
      ];
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? borderColor.withValues(alpha: 0.9)
                    : identityColor.withValues(alpha: 0.45),
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: isSelected && player.isAlive
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection Glow Effect
                if (isSelected && player.isAlive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            borderColor.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.padding(context, 10),
                    vertical: ResponsiveUtils.padding(context, 8),
                  ),
                  child: ColorFiltered(
                    colorFilter: player.isConnected
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          )
                        : const ColorFilter.matrix(<double>[
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: Opacity(
                      opacity: player.isConnected ? 1.0 : 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar with Halo
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: player.isAlive
                                  ? LinearGradient(
                                      colors: [
                                        identityColor,
                                        identityColor.withValues(alpha: 0.5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: player.isAlive ? null : AppColors.grey800,
                              boxShadow: player.isAlive
                                  ? [
                                      BoxShadow(
                                        color: identityColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surface,
                              child: Icon(
                                player.isAlive
                                    ? (player.isConnected
                                          ? Icons.person
                                          : Icons.wifi_off)
                                    : Icons.close,
                                color: player.isAlive
                                    ? Colors.white
                                    : AppColors.grey600,
                                size: ResponsiveUtils.iconSize(context, 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  player.nickname + (isMe ? ' (나)' : ''),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.gowunDodum(
                                    color: player.isAlive
                                        ? Colors.white
                                        : AppColors.grey600,
                                    fontWeight: isMe
                                        ? FontWeight.w900
                                        : FontWeight.bold,
                                    decoration: player.isAlive
                                        ? null
                                        : TextDecoration.lineThrough,
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      15,
                                    ), // Increased from 14
                                    shadows: isMe
                                        ? [
                                            BoxShadow(
                                              color: identityColor.withValues(
                                                alpha: 0.8,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : [
                                            const BoxShadow(
                                              color: Colors.black45,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                ),
                                if (!player.isConnected && player.isAlive)
                                  Text(
                                    '연결 끊김',
                                    style: GoogleFonts.gowunDodum(
                                      color: Colors.orangeAccent,
                                      fontSize: ResponsiveUtils.fontSize(
                                        context,
                                        11,
                                      ), // Increased from 10
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Vote Count Pill
                          if (player.isAlive && voteCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF43F5E),
                                    AppColors.votePillEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF43F5E,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                '$voteCount표',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveUtils.fontSize(
                                    context,
                                    12,
                                  ), // Increased from 11
                                ),
                              ),
                            ),
                          // Voters List
                          if (player.isAlive &&
                              voteCount > 0 &&
                              votersList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                votersList,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: ResponsiveUtils.fontSize(
                                    context,
                                    11,
                                  ), // Increased from 10
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Dead Overlay with Skull
                if (!player.isAlive)
                  IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.overlayBlack50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💀', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.deadRed.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.dead,
                              style: GoogleFonts.gowunDodum(
                                fontSize: ResponsiveUtils.fontSize(
                                  context,
                                  15,
                                ), // Increased from 14
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Mafia indicator for fellow mafia
                if (showMafiaIndicator)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.mafiaRed.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
