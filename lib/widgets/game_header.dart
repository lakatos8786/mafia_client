import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/game_provider.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  game.gameState == '낮'
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  color: game.gameState == '낮'
                      ? Colors.orangeAccent
                      : Colors.purpleAccent,
                ),
                const SizedBox(width: 10),
                Text(
                  '${game.gameState} - ${game.dayCount}일차',
                  style: GoogleFonts.gowunDodum(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Role Counts
            if (game.roleCounts.isNotEmpty)
              Wrap(
                spacing: 15,
                children: game.roleCounts.entries.map((e) {
                  return Text(
                    '${e.key} ${e.value}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // My Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3460), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF0F3460),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '나의 직업: ',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    TextSpan(
                      text: game.myRole ?? "알 수 없음",
                      style: GoogleFonts.gowunDodum(
                        color: const Color(0xFFE94560),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
