import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';

import 'player_card.dart';

class PlayerGrid extends ConsumerWidget {
  const PlayerGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final actionState = ref.watch(actionProvider);
    final socketId = ref.watch(connectionProvider.notifier).socketId;

    // Using Wrap for natural centered alignment as requested
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 15, // Gap between items horizontally
          runSpacing: 15, // Gap between lines
          children: gameState.players.map((player) {
            final index = gameState.players.indexOf(player);
            // ... (keep existing logic variables)
            final isMe = player.id == socketId;
            final voteCount = actionState.votes[player.id] ?? 0;

            // Selection logic
            final selectionTargetForRole = actionState.nightSelections.entries
                .where((entry) => entry.value == player.id)
                .map((entry) => entry.key)
                .toList();

            final isMyVoteTarget = actionState.voters[socketId] == player.id;

            final showMafiaIndicator =
                player.isAlive &&
                gameState.myRole == GameRole.mafia &&
                player.role == GameRole.mafia &&
                player.id != socketId;

            String votersList = '';
            if (gameState.gamePhase == GamePhase.day &&
                player.isAlive &&
                voteCount > 0) {
              votersList = actionState.voters.entries
                  .where((e) => e.value == player.id)
                  .map(
                    (e) => gameState.players
                        .firstWhere(
                          (p) => p.id == e.key,
                          orElse: () =>
                              Player(id: '', nickname: '?', isAlive: true),
                        )
                        .nickname,
                  )
                  .toList()
                  .join(', ');
            }

            // Standard Card Size (similar to previous GridView settings)
            return SizedBox(
              key: ValueKey(player.id),
              width: 140,
              height: 190, // Aspect Ratio ~0.74
              child: FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: PlayerCard(
                  player: player,
                  isMe: isMe,
                  isMyVoteTarget: isMyVoteTarget,
                  selectionTargets: selectionTargetForRole,
                  voteCount: gameState.gamePhase == GamePhase.day
                      ? voteCount
                      : 0,
                  votersList: votersList,
                  showMafiaIndicator: showMafiaIndicator,
                  onTap: () {
                    // Check if *I* am alive first
                    final me = gameState.players.firstWhere(
                      (p) => p.id == socketId,
                      orElse: () =>
                          Player(id: 'unknown', nickname: '?', isAlive: false),
                    );
                    if (!me.isAlive) return;
                    if (!player.isAlive) return;

                    // Voting/Action Logic
                    if (gameState.gamePhase == GamePhase.day) {
                      ref.read(actionProvider.notifier).vote(player.id);
                    } else if (gameState.gamePhase == GamePhase.night) {
                      String? action;
                      // Use strict Enums now
                      if (gameState.myRole == GameRole.mafia) {
                        action = NightAction.kill;
                      }
                      if (gameState.myRole == GameRole.doctor) {
                        action = NightAction.heal;
                      }
                      if (gameState.myRole == GameRole.police) {
                        action = NightAction.investigate;
                      }
                      if (action != null) {
                        ref
                            .read(actionProvider.notifier)
                            .nightAction(action, player.id);
                      }
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
