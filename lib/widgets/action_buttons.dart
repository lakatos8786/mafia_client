import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

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
        if (game.gameState == '낮')
          Builder(
            builder: (context) {
              // Logic to find who voted 'skip'
              final skipVoters = game.voters.entries
                  .where((entry) => entry.value == 'skip')
                  .map((entry) {
                    final voter = game.players.firstWhere(
                      (p) => p.id == entry.key,
                      orElse: () =>
                          Player(id: 'unknown', nickname: '?', isAlive: true),
                    );
                    return voter.nickname;
                  })
                  .toList();

              final myId = game.socket.id;
              final iVotedSkip = game.voters[myId] == 'skip';

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (game.votes['skip'] != null && game.votes['skip']! > 0)
                      Flexible(
                        child: Text(
                          '건너뛰기 투표: ${game.votes['skip']} (${skipVoters.join(", ")})  ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iVotedSkip
                            ? const Color(0xFF0F3460) // Active dark blue
                            : Colors.grey[800],
                        foregroundColor: Colors.white,
                        elevation: iVotedSkip ? 5 : 0,
                        shadowColor: const Color(0xFF0F3460).withOpacity(0.5),
                        side: iVotedSkip
                            ? const BorderSide(
                                color: Color(0xFFE94560), // Red accent border
                                width: 1,
                              )
                            : BorderSide(color: Colors.white.withOpacity(0.1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        game.vote('skip');
                      },
                      child: const Text(
                        '투표 건너뛰기',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        if (game.gameState == '밤' && game.myRole == '마피아')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Builder(
                  builder: (context) {
                    final isMafiaSkip = game.nightSelections['마피아'] == 'skip';
                    final actor = game.nightActionActors['마피아'] ?? '';
                    final btnText = isMafiaSkip ? '킬 건너뛰기 ($actor)' : '킬 건너뛰기';

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMafiaSkip
                            ? const Color(0xFFE94560)
                            : const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFFE94560).withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        game.nightAction('kill', 'skip');
                      },
                      child: Text(
                        btnText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
