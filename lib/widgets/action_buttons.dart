import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_enums.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Check if player is alive
    if (!game.players.any((p) => p.id == game.socket.id && p.isAlive)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Skip Vote Row
        if (game.gamePhase == GamePhase.day)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (game.votes[GameAction.skip] != null &&
                    game.votes[GameAction.skip]! > 0)
                  Flexible(
                    child: Text(
                      '건너뛰기 투표: ${game.votes[GameAction.skip]} (${game.skipVoterNicknames.join(", ")})  ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: game.iVotedSkip
                        ? const LinearGradient(
                            colors: [AppColors.policeBlue, Color(0xFF0284C7)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF334155), AppColors.surface],
                          ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: game.iVotedSkip
                        ? [
                            BoxShadow(
                              color: AppColors.policeBlue.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: game.iVotedSkip
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      game.vote(GameAction.skip);
                    },
                    child: Text(
                      AppStrings.skipVote,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (game.gamePhase == GamePhase.night &&
            game.myRoleEnum == GameRole.mafia)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: game.isMafiaSkip
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
                    boxShadow: game.isMafiaSkip
                        ? [
                            BoxShadow(
                              color: AppColors.mafiaRed.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: game.isMafiaSkip
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      game.nightAction(NightAction.kill, GameAction.skip);
                    },
                    child: Text(
                      game.mafiaSkipButtonText,
                      style: const TextStyle(
                        fontSize: 14,
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
