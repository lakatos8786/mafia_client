import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';

class PlayerGrid extends StatelessWidget {
  const PlayerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Dynamic grid calc (reused logic but styled)
    return LayoutBuilder(
      builder: (context, constraints) {
        final playerCount = game.players.length;
        if (playerCount == 0) return const SizedBox.shrink();

        final availableWidth = constraints.maxWidth - 20;
        final availableHeight = constraints.maxHeight - 20;
        final spacing = 8.0;

        const double minItemHeight = 110.0;
        const double minItemWidth = 80.0;

        int cols = 4;
        if (playerCount <= 4) {
          cols = 2;
        } else if (playerCount <= 9)
          cols = 3;
        else
          cols = 4;
        if (playerCount > 12) cols = 5;

        final fitRows = (playerCount / cols).ceil();
        final fitItemHeight =
            (availableHeight - (fitRows - 1) * spacing) / fitRows;
        bool useScroll = fitItemHeight < minItemHeight;

        ScrollPhysics scrollPhysics = useScroll
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics();
        if (useScroll) {
          cols = (availableWidth / minItemWidth).floor().clamp(3, 8);
        }

        double ratio = useScroll
            ? 0.75
            : ((availableWidth - (cols - 1) * spacing) / cols) / fitItemHeight;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          physics: scrollPhysics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: ratio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: playerCount,
          itemBuilder: (context, index) {
            final player = game.players[index];
            final isMe = player.id == game.socket.id;
            final voteCount = game.votes[player.id] ?? 0;

            // Selection logic
            final selectionTargetForRole = game.nightSelections.entries
                .where((entry) => entry.value == player.id)
                .map((entry) => entry.key)
                .toList();

            // Colors
            Color baseColor = Colors.white.withOpacity(0.05);
            Color borderColor = Colors.white.withOpacity(0.1);

            if (game.gameState == '밤' && selectionTargetForRole.isNotEmpty) {
              if (selectionTargetForRole.contains('마피아')) {
                baseColor = Colors.red.withOpacity(0.2);
                borderColor = Colors.redAccent;
              } else if (selectionTargetForRole.contains('의사')) {
                baseColor = Colors.green.withOpacity(0.2);
                borderColor = Colors.greenAccent;
              } else if (selectionTargetForRole.contains('경찰')) {
                baseColor = Colors.blue.withOpacity(0.2);
                borderColor = Colors.blueAccent;
              }
            } else if (!player.isAlive) {
              baseColor = Colors.black54;
              borderColor = Colors.grey.withOpacity(0.3);
            }

            return FadeInUp(
              delay: Duration(milliseconds: 50 * index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                      if (!me.isAlive) {
                        // feedback
                        return;
                      }
                      if (!player.isAlive) return;

                      // Copied logic from refactor
                      if (game.gameState == '낮') {
                        game.vote(player.id);
                      } else if (game.gameState == '밤') {
                        String? action;
                        if (game.myRole == '마피아') action = 'kill';
                        if (game.myRole == '의사') action = 'heal';
                        if (game.myRole == '경찰') action = 'investigate';
                        if (action != null) game.nightAction(action, player.id);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                        boxShadow: selectionTargetForRole.isNotEmpty
                            ? [
                                BoxShadow(
                                  color: borderColor.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Avatar
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: player.isAlive
                                        ? Colors.white10
                                        : Colors.red.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    player.isAlive ? Icons.person : Icons.close,
                                    color: player.isAlive
                                        ? Colors.white
                                        : Colors.red,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Name
                                Text(
                                  player.nickname + (isMe ? ' (나)' : ''),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: player.isAlive
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: isMe
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    decoration: player.isAlive
                                        ? null
                                        : TextDecoration.lineThrough,
                                    fontSize: 14,
                                  ),
                                ),
                                // Vote Count Bubble
                                if (game.gameState == '낮' &&
                                    player.isAlive &&
                                    voteCount > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE94560),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$voteCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                // Voters List (New: "Who voted for me")
                                if (game.gameState == '낮' &&
                                    player.isAlive &&
                                    voteCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Builder(
                                      builder: (context) {
                                        final votersForThisPlayer = game
                                            .voters
                                            .entries
                                            .where((e) => e.value == player.id)
                                            .map((e) {
                                              return game.players
                                                  .firstWhere(
                                                    (p) => p.id == e.key,
                                                    orElse: () => Player(
                                                      id: '',
                                                      nickname: '?',
                                                      isAlive: true,
                                                    ),
                                                  )
                                                  .nickname;
                                            })
                                            .toList();

                                        final displayStr = votersForThisPlayer
                                            .join(', ');

                                        return Tooltip(
                                          message:
                                              displayStr, // Show ALL voters on long press
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE94560),
                                            ),
                                          ),
                                          textStyle: GoogleFonts.gowunDodum(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              displayStr,
                                              style: const TextStyle(
                                                color: Colors.yellowAccent,
                                                fontSize: 11, // Slightly larger
                                              ),
                                              maxLines: 2, // Allow 2 lines
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Dead Overlay
                          if (!player.isAlive)
                            Center(
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  '사망',
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(
                                      0xFFE94560,
                                    ).withOpacity(0.8),
                                    shadows: [
                                      const Shadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
