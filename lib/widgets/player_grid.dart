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
    final players = ref.watch(gameStateProvider.select((s) => s.players));
    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));

    final votes = ref.watch(actionProvider.select((s) => s.votes));
    final voters = ref.watch(actionProvider.select((s) => s.voters));
    final nightSelections = ref.watch(
      actionProvider.select((s) => s.nightSelections),
    );

    final socketId = ref.watch(connectionProvider.notifier).socketId;

    // Removed internal SingleChildScrollView to allow parent GameScreen to scroll the entire column
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 15,
          runSpacing: 15,
          children: players.map((player) {
            final index = players.indexOf(player);
            final isMe = player.id == socketId;
            final voteCount = votes[player.id] ?? 0;

            // Selection logic
            final selectionTargetForRole = nightSelections.entries
                .where((entry) => entry.value == player.id)
                .map((entry) => entry.key)
                .toList();

            final isMyVoteTarget = voters[socketId] == player.id;

            final showMafiaIndicator =
                player.isAlive &&
                myRole == GameRole.mafia &&
                player.role == GameRole.mafia &&
                player.id != socketId;

            String votersList = '';
            if (gamePhase == GamePhase.day && player.isAlive && voteCount > 0) {
              votersList = voters.entries
                  .where((e) => e.value == player.id)
                  .map(
                    (e) => players
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
                  voteCount: gamePhase == GamePhase.day ? voteCount : 0,
                  votersList: votersList,
                  showMafiaIndicator: showMafiaIndicator,
                  onTap: () {
                    // Check if *I* am alive first
                    final me = players.firstWhere(
                      (p) => p.id == socketId,
                      orElse: () =>
                          Player(id: 'unknown', nickname: '?', isAlive: false),
                    );
                    if (!me.isAlive) return;
                    if (!player.isAlive) return;

                    // Voting/Action Logic
                    if (gamePhase == GamePhase.day) {
                      ref.read(actionProvider.notifier).vote(player.id);
                    } else if (gamePhase == GamePhase.night) {
                      String? action;
                      // Use strict Enums now
                      if (myRole == GameRole.mafia) {
                        action = NightAction.kill;
                      }
                      if (myRole == GameRole.doctor) {
                        action = NightAction.heal;
                      }
                      if (myRole == GameRole.police) {
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
