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

              // Note: All state logic (votes, selection, etc.) is now handled
              // internally by PlayerCard using ref.watch(select(...))
              // to prevent grid-wide rebuilds.

              return SizedBox(
                width: cardWidth,
                child: FadeInUp(
                  key: ValueKey(player.id), // Add key for stable animations
                  delay: Duration(milliseconds: 50 * filterIndex),
                  child: PlayerCard(
                    player: player,
                    isMe: isMe,
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
