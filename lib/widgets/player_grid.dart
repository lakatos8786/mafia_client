import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/ui_provider.dart';

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
    final judgementTarget = ref.watch(
      actionProvider.select((s) => s.judgementTarget),
    );
    final showSurvivorsOnly = ref.watch(showSurvivorsOnlyProvider);

    // --- Phase-Aware Filtering Logic ---
    // Ignore filter during Judgment, Last Word, or Result phases
    final isSpecialPhase =
        gamePhase == GamePhase.judgement ||
        gamePhase == GamePhase.lastWord ||
        gamePhase == GamePhase.result;

    final displayPlayers = (showSurvivorsOnly && !isSpecialPhase)
        ? players.where((p) => p.isAlive).toList()
        : players;

    // --- Spotlight Effect for Last Word ---
    if (gamePhase == GamePhase.lastWord && judgementTarget != null) {
      final targetPlayer = players.firstWhere(
        (p) => p.id == judgementTarget,
        orElse: () => Player(id: '', nickname: '?', isAlive: true),
      );

      return Center(
        child: ZoomIn(
          duration: const Duration(milliseconds: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '최후의 변론',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [Shadow(color: Colors.amber, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 240, // Enlarged size
                child: PlayerCard(
                  player: targetPlayer,
                  isMe: targetPlayer.id == socketId,
                  isMyVoteTarget: false,
                  selectionTargets: const [],
                  voteCount: 0,
                  votersList: '',
                  showMafiaIndicator: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(
                height: 100,
              ), // Push up a bit to be seen above chat
            ],
          ),
        ),
      );
    }

    // Standard Grid View
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate card width for 2 columns
          final cardWidth = (constraints.maxWidth - 12) / 2; // 12 = spacing

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: displayPlayers.map((player) {
              // Note: index for animation delay should be based on filtered list index
              final filterIndex = displayPlayers.indexOf(player);
              final isMe = player.id == socketId;
              final voteCount = votes[player.id] ?? 0;

              // Selection logic
              final selectionTargetForRole = nightSelections.entries
                  .where((entry) => entry.value == player.id)
                  .map((entry) => entry.key)
                  .toList();

              final isJudgementTarget =
                  gamePhase == GamePhase.judgement &&
                  judgementTarget == player.id;

              final isMyVoteTarget =
                  voters[socketId] == player.id || isJudgementTarget;

              final showMafiaIndicator =
                  gamePhase == GamePhase.night &&
                  player.isAlive &&
                  myRole == GameRole.mafia &&
                  player.role == GameRole.mafia &&
                  player.id != socketId;

              String votersList = '';
              final isMafiaNightVote =
                  gamePhase == GamePhase.night && myRole == GameRole.mafia;

              if ((gamePhase == GamePhase.day || isMafiaNightVote) &&
                  player.isAlive &&
                  voteCount > 0) {
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

              return SizedBox(
                width: cardWidth,
                child: FadeInUp(
                  key: ValueKey(player.id), // Add key for stable animations
                  delay: Duration(milliseconds: 50 * filterIndex),
                  child: PlayerCard(
                    player: player,
                    isMe: isMe,
                    isMyVoteTarget: isMyVoteTarget,
                    selectionTargets: selectionTargetForRole,
                    voteCount: (gamePhase == GamePhase.day || isMafiaNightVote)
                        ? voteCount
                        : 0,
                    votersList: votersList,
                    showMafiaIndicator: showMafiaIndicator,
                    onTap: () {
                      // Check if *I* am alive using GLOBAL player list
                      final me = players.firstWhere(
                        (p) => p.id == socketId,
                        orElse: () => Player(
                          id: 'unknown',
                          nickname: '?',
                          isAlive: false,
                        ),
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
          );
        },
      ),
    );
  }
}
