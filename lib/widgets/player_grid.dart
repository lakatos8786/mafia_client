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

    // Standard Responsive Grid using MaxCrossAxisExtent
    // This automatically calculates columns based on width
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      physics: const BouncingScrollPhysics(), // Standard mobile feel
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150, // Standard width for player cards
        childAspectRatio: 0.75, // Standard card ratio
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: game.players.length,
      itemBuilder: (context, index) {
        final player = game.players[index];
        final isMe = player.id == game.socket.id;
        final voteCount = game.votes[player.id] ?? 0;

        // Selection logic
        final selectionTargetForRole = game.nightSelections.entries
            .where((entry) => entry.value == player.id)
            .map((entry) => entry.key)
            .toList();

        // Colors Logic moved to AnimatedContainer decoration

        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Rounded corners
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass effect
              child: InkWell(
                onTap: () {
                  // Check if *I* am alive first
                  final me = game.players.firstWhere(
                    (p) => p.id == game.socket.id,
                    orElse: () =>
                        Player(id: 'unknown', nickname: '?', isAlive: false),
                  );
                  if (!me.isAlive) return;
                  if (!player.isAlive) return;

                  // Voting/Action Logic
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    // Dynamic Gradient based on state
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: player.isAlive
                          ? (selectionTargetForRole.isNotEmpty
                                ? [
                                    selectionTargetForRole.contains('마피아')
                                        ? const Color(
                                            0xFF9F1239,
                                          ).withOpacity(0.6)
                                        : selectionTargetForRole.contains('의사')
                                        ? const Color(
                                            0xFF065F46,
                                          ).withOpacity(0.6)
                                        : const Color(
                                            0xFF1E40AF,
                                          ).withOpacity(0.6),
                                    Colors.black.withOpacity(0.4),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ])
                          : [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.9),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectionTargetForRole.isNotEmpty
                          ? Colors.white.withOpacity(
                              0.8,
                            ) // Selected glow border
                          : Colors.white.withOpacity(0.1),
                      width: selectionTargetForRole.isNotEmpty ? 1.5 : 1,
                    ),
                    boxShadow: selectionTargetForRole.isNotEmpty
                        ? [
                            BoxShadow(
                              color: selectionTargetForRole.contains('마피아')
                                  ? const Color(0xFFF43F5E).withOpacity(0.6)
                                  : selectionTargetForRole.contains('의사')
                                  ? const Color(0xFF34D399).withOpacity(0.6)
                                  : const Color(0xFF38BDF8).withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              color: player.isAlive ? null : Colors.grey[800],
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
                                player.isAlive ? Icons.person : Icons.close,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                          color: Colors.blue.withOpacity(0.8),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                          // Vote Count Pill
                          if (game.gameState == '낮' &&
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
                          if (game.gameState == '낮' &&
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
                                      color: Colors.white.withOpacity(0.5),
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
                      // Dead Overlay Text
                      if (!player.isAlive)
                        IgnorePointer(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '사망',
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.withOpacity(0.8),
                                    letterSpacing: 2.0,
                                  ),
                                ),
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
  }
}
