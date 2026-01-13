import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

class PlayerGrid extends StatelessWidget {
  const PlayerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Using Wrap for natural centered alignment as requested
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 15, // Gap between items horizontally
          runSpacing: 15, // Gap between lines
          children: game.players.map((player) {
            final index = game.players.indexOf(player);
            // ... (keep existing logic variables)
            final isMe = player.id == game.socket.id;
            final voteCount = game.votes[player.id] ?? 0;

            // Selection logic
            final selectionTargetForRole = game.nightSelections.entries
                .where((entry) => entry.value == player.id)
                .map((entry) => entry.key)
                .toList();

            final isMyVoteTarget = game.voters[game.socket.id] == player.id;

            // Standard Card Size (similar to previous GridView settings)
            return SizedBox(
              key: ValueKey(player.id),
              width: 140,
              height: 190, // Aspect Ratio ~0.74
              child: FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: InkWell(
                      onTap: () {
                        // Check if *I* am alive first
                        final me = game.players.firstWhere(
                          (p) => p.id == game.socket.id,
                          orElse: () => Player(
                            id: 'unknown',
                            nickname: '?',
                            isAlive: false,
                          ),
                        );
                        if (!me.isAlive) return;
                        if (!player.isAlive) return;

                        // Voting/Action Logic
                        if (game.gamePhase == GamePhase.day) {
                          game.vote(player.id);
                        } else if (game.gamePhase == GamePhase.night) {
                          String? action;
                          // Use strict Enums now
                          if (game.myRoleEnum == GameRole.mafia) {
                            action = NightAction.kill;
                          }
                          if (game.myRoleEnum == GameRole.doctor) {
                            action = NightAction.heal;
                          }
                          if (game.myRoleEnum == GameRole.police) {
                            action = NightAction.investigate;
                          }
                          if (action != null) {
                            game.nightAction(action, player.id);
                          }
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          // Dynamic Gradient based on state
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: player.isAlive
                                ? ((selectionTargetForRole.isNotEmpty ||
                                          isMyVoteTarget)
                                      ? [
                                          isMyVoteTarget
                                              ? const Color(
                                                  0xFFF59E0B,
                                                ).withOpacity(
                                                  0.6,
                                                ) // Orange for Vote
                                              : selectionTargetForRole.contains(
                                                  GameRole.mafia.name,
                                                )
                                              ? const Color(
                                                  0xFF9F1239,
                                                ).withOpacity(0.6)
                                              : selectionTargetForRole.contains(
                                                  GameRole.doctor.name,
                                                )
                                              ? const Color(
                                                  0xFF065F46,
                                                ).withOpacity(0.6)
                                              : const Color(
                                                  0xFF1E3A8A,
                                                ).withOpacity(0.6),
                                          const Color(
                                            0xFF000000,
                                          ).withOpacity(0.0),
                                        ]
                                      : [
                                          const Color(
                                            0xFF1E293B,
                                          ).withOpacity(0.7),
                                          const Color(
                                            0xFF0F172A,
                                          ).withOpacity(0.7),
                                        ])
                                : [
                                    const Color(0xFF0F172A).withOpacity(0.8),
                                    const Color(0xFF0F172A).withOpacity(0.8),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: player.isAlive
                                ? ((selectionTargetForRole.isNotEmpty ||
                                          isMyVoteTarget)
                                      ? (isMyVoteTarget
                                                ? AppColors.voteGold
                                                : selectionTargetForRole
                                                      .contains(
                                                        GameRole.mafia.name,
                                                      )
                                                ? const Color(0xFFF43F5E)
                                                : selectionTargetForRole
                                                      .contains(
                                                        GameRole.doctor.name,
                                                      )
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF60A5FA))
                                            .withOpacity(0.8)
                                      : Colors.white.withOpacity(0.12))
                                : Colors.red.withOpacity(0.3),
                            width:
                                (selectionTargetForRole.isNotEmpty ||
                                    isMyVoteTarget)
                                ? 2.5
                                : 1.2,
                          ),
                          boxShadow: [
                            if (player.isAlive &&
                                (selectionTargetForRole.isNotEmpty ||
                                    isMyVoteTarget))
                              BoxShadow(
                                color:
                                    (isMyVoteTarget
                                            ? AppColors.voteGold
                                            : selectionTargetForRole.contains(
                                                GameRole.mafia.name,
                                              )
                                            ? const Color(0xFFF43F5E)
                                            : selectionTargetForRole.contains(
                                                GameRole.doctor.name,
                                              )
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF60A5FA))
                                        .withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Selection Glow Effect
                            if (player.isAlive &&
                                (selectionTargetForRole.isNotEmpty ||
                                    isMyVoteTarget))
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        (isMyVoteTarget
                                                ? const Color(0xFFF59E0B)
                                                : selectionTargetForRole
                                                      .contains(
                                                        GameRole.mafia.name,
                                                      )
                                                ? const Color(0xFFF43F5E)
                                                : selectionTargetForRole
                                                      .contains(
                                                        GameRole.doctor.name,
                                                      )
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF60A5FA))
                                            .withOpacity(0.15),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar with Halo
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: player.isAlive
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF38BDF8),
                                              Color(0xFF818CF8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: player.isAlive
                                        ? null
                                        : Colors.grey[800],
                                    boxShadow: player.isAlive
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF38BDF8,
                                              ).withOpacity(0.4),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF1E293B),
                                    child: Icon(
                                      player.isAlive
                                          ? Icons.person
                                          : Icons.close,
                                      color: player.isAlive
                                          ? Colors.white
                                          : Colors.grey[600],
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    player.nickname + (isMe ? ' (나)' : ''),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.gowunDodum(
                                      color: player.isAlive
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: isMe
                                          ? FontWeight.w900
                                          : FontWeight.bold,
                                      decoration: player.isAlive
                                          ? null
                                          : TextDecoration.lineThrough,
                                      fontSize: 14,
                                      shadows: isMe
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(
                                                  0.8,
                                                ),
                                                blurRadius: 10,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                                // Vote Count Pill
                                if (game.gamePhase == GamePhase.day &&
                                    player.isAlive &&
                                    voteCount > 0)
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
                                          Color(0xFFE11D48),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFF43F5E,
                                          ).withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '$voteCount표',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                // Voters List Logic (Preserved)
                                if (game.gamePhase == GamePhase.day &&
                                    player.isAlive &&
                                    voteCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Builder(
                                      builder: (context) {
                                        final votersForThisPlayer = game
                                            .voters
                                            .entries
                                            .where((e) => e.value == player.id)
                                            .map(
                                              (e) => game.players
                                                  .firstWhere(
                                                    (p) => p.id == e.key,
                                                    orElse: () => Player(
                                                      id: '',
                                                      nickname: '?',
                                                      isAlive: true,
                                                    ),
                                                  )
                                                  .nickname,
                                            )
                                            .toList()
                                            .join(', ');

                                        return Text(
                                          votersForThisPlayer,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            // Dead Overlay with Skull
                            if (!player.isAlive)
                              IgnorePointer(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '💀',
                                        style: TextStyle(fontSize: 40),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '사망',
                                          style: GoogleFonts.gowunDodum(
                                            fontSize: 14,
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
                            if (player.isAlive &&
                                game.myRoleEnum == GameRole.mafia &&
                                player.role == GameRole.mafia &&
                                player.id != game.socket.id)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.mafiaRed.withOpacity(0.8),
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
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
