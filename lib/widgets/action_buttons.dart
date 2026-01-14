import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../utils/responsive_utils.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final actionState = ref.watch(actionProvider);
    final socketId = ref.watch(connectionProvider.notifier).socketId;

    // Derived values
    final skipVoterNicknames = ref.watch(skipVoterNicknamesProvider);
    final iVotedSkip = ref.watch(iVotedSkipProvider);
    final isMafiaSkip = ref.watch(isMafiaSkipProvider);
    final mafiaSkipButtonText = ref.watch(mafiaSkipButtonTextProvider);

    // Check if player is alive
    if (!gameState.players.any((p) => p.id == socketId && p.isAlive)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Skip Vote Row
        if (gameState.gamePhase == GamePhase.day)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (actionState.votes[GameAction.skip] != null &&
                    actionState.votes[GameAction.skip]! > 0)
                  Flexible(
                    child: Text(
                      '건너뛰기 투표: ${actionState.votes[GameAction.skip]} (${skipVoterNicknames.join(", ")})  ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.fontSize(context, 11),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: iVotedSkip
                        ? const LinearGradient(
                            colors: [AppColors.policeBlue, Color(0xFF0284C7)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF334155), AppColors.surface],
                          ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: iVotedSkip
                        ? [
                            BoxShadow(
                              color: AppColors.policeBlue.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: iVotedSkip
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 16),
                        vertical: ResponsiveUtils.padding(context, 10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      ref.read(actionProvider.notifier).vote(GameAction.skip);
                    },
                    child: Text(
                      AppStrings.skipVote,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (gameState.gamePhase == GamePhase.night &&
            gameState.myRole == GameRole.mafia)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: isMafiaSkip
                        ? const LinearGradient(
                            colors: [AppColors.mafiaRed, Color(0xFFE11D48)],
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              AppColors.backgroundMain,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isMafiaSkip
                        ? [
                            BoxShadow(
                              color: AppColors.mafiaRed.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: isMafiaSkip
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 16),
                        vertical: ResponsiveUtils.padding(context, 10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(actionProvider.notifier)
                          .nightAction(NightAction.kill, GameAction.skip);
                    },
                    child: Text(
                      mafiaSkipButtonText,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
