import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../theme/noir_design.dart';
import '../theme/app_strings.dart';
import '../providers/game_state_provider.dart';
import '../utils/responsive_utils.dart';
import 'common/noir_card.dart';
import 'common/noir_badge.dart';

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
    final phase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final isNight = phase == GamePhase.night || phase == GamePhase.result;
    final isSelected = selectionTargets.isNotEmpty || isMyVoteTarget;

    return NoirCard(
      variant: isSelected
          ? NoirCardVariant.light
          : (isNight ? NoirCardVariant.dark : NoirCardVariant.base),
      elevation: isSelected
          ? NoirCardElevation.elevated
          : NoirCardElevation.subtle,
      hasCrimsonBorder: isMyVoteTarget,
      padding: ResponsiveUtils.padding(context, 12),
      onTap: onTap,
      child: ColorFiltered(
        colorFilter: player.isConnected
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
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
            children: [
              // Avatar Section
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: player.isAlive
                            ? NoirColors.textSecondary.withValues(alpha: 0.2)
                            : NoirColors.textTertiary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: isNight
                          ? NoirColors.surfaceDark
                          : NoirColors.surfaceLight,
                      child: Icon(
                        player.isAlive
                            ? (player.isConnected
                                  ? Icons.person
                                  : Icons.wifi_off)
                            : Icons.close,
                        color: player.isAlive
                            ? (isNight
                                  ? NoirColors.textPrimary
                                  : NoirColors.backgroundDeep)
                            : (isNight
                                  ? NoirColors.textTertiary
                                  : NoirColors.borderBright),
                        size: 24,
                      ),
                    ),
                  ),
                  if (showMafiaIndicator)
                    NoirBadge(
                      text: '마피아',
                      type: NoirBadgeType.crimson,
                      icon: Icons.visibility,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Name Section
              Text(
                player.nickname + (isMe ? ' (나)' : ''),
                style: GoogleFonts.gowunDodum(
                  color: player.isAlive
                      ? (isNight
                            ? NoirColors.textPrimary
                            : NoirColors.backgroundDeep)
                      : (isNight
                            ? NoirColors.textTertiary
                            : NoirColors.borderBright),
                  fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
                  decoration: player.isAlive
                      ? null
                      : TextDecoration.lineThrough,
                  fontSize: ResponsiveUtils.fontSize(context, 15),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!player.isConnected && player.isAlive)
                Text(
                  '연결 끊김',
                  style: GoogleFonts.gowunDodum(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              // Status Pillars
              if (player.isAlive && voteCount > 0) ...[
                const SizedBox(height: 8),
                NoirBadge(text: '$voteCount표', type: NoirBadgeType.crimson),
                if (votersList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      votersList,
                      style: TextStyle(
                        color: isNight
                            ? NoirColors.textTertiary
                            : NoirColors.borderBright,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              if (!player.isAlive) ...[
                const SizedBox(height: 8),
                NoirBadge(
                  text: AppStrings.dead,
                  type: NoirBadgeType.info,
                  icon: Icons.dangerous,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
