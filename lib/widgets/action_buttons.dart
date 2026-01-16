import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_strings.dart';
import '../theme/noir_design.dart';
import '../utils/responsive_utils.dart';
import 'common/noir_button.dart';

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

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Skip Vote Row
          if (gameState.gamePhase == GamePhase.day)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12, // Increased for spacing
                runSpacing: 8,
                children: [
                  if (actionState.votes[GameAction.skip] != null &&
                      actionState.votes[GameAction.skip]! > 0)
                    Text(
                      '건너뛰기 투표: ${actionState.votes[GameAction.skip]} (${skipVoterNicknames.join(", ")})',
                      style: TextStyle(
                        color:
                            (gameState.gamePhase == GamePhase.night
                                    ? NoirColors.textSecondary
                                    : NoirColors.borderBright)
                                .withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.fontSize(context, 11),
                      ),
                    ),
                  NoirButton(
                    text: iVotedSkip
                        ? AppStrings.skipVote
                        : AppStrings.skipVote,
                    onPressed: () {
                      ref.read(actionProvider.notifier).vote(GameAction.skip);
                    },
                    style: iVotedSkip
                        ? NoirButtonStyle.primary
                        : NoirButtonStyle.ghost,
                    icon: Icons.skip_next,
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
                  NoirButton(
                    text: mafiaSkipButtonText,
                    onPressed: () {
                      ref
                          .read(actionProvider.notifier)
                          .nightAction(NightAction.kill, GameAction.skip);
                    },
                    style: isMafiaSkip
                        ? NoirButtonStyle.primary
                        : NoirButtonStyle.ghost,
                    icon: Icons.close,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
