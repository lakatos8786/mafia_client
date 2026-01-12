import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart'; // For GamePhase
import '../widgets/particle_background.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Using standard theme colors through AppColors
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '방 번호: ${game.roomId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.mafiaRed),
            onPressed: () {
              if (game.roomId != null) {
                Clipboard.setData(ClipboardData(text: game.roomId!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '복사됨: ${game.roomId}',
                      style: GoogleFonts.gowunDodum(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.grey[800],
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating, // Floating is better
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dynamic Particle Background (Day theme for Lobby)
          const ParticleBackground(phase: GamePhase.day),

          // 2. Ambient Glow Overlay (to make it distinct from GameScreen)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.3,
              ), // Slightly darker for text readability
            ),
          ),

          // Background Glow Effect (Original preserved but refined)
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1), // Adjusted opacity
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 150,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 100),
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '플레이어 대기 중...',
                    style: GoogleFonts.gowunDodum(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: game.players.length,
                  itemBuilder: (context, index) {
                    final player = game.players[index];
                    final isMe = player.id == game.socket.id;

                    return FadeInLeft(
                      delay: Duration(milliseconds: 100 * index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.primary.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isMe
                                      ? AppColors.primary.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.1),
                                  width: isMe ? 1.5 : 1.0,
                                ),
                                boxShadow: isMe
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.2,
                                          ),
                                          blurRadius: 15,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isMe
                                        ? AppColors.primary
                                        : Colors.white12,
                                    foregroundColor: Colors.white,
                                    child: const Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      player.nickname,
                                      style: GoogleFonts.gowunDodum(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: player.isAlive
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  if (player.isHost)
                                    const Tooltip(
                                      message: '방장',
                                      child: Text(
                                        '👑',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  if (isMe)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        Icons.star,
                                        color: AppColors.accentYellow,
                                        size: 20,
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
                ),
              ),

              const SizedBox(height: 20),

              // Player count display
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${game.players.length}명 참가 중',
                        style: GoogleFonts.gowunDodum(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      if (game.players.length < 2) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '최소 2명 필요',
                            style: GoogleFonts.gowunDodum(
                              color: AppColors.accentYellow,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Builder(
                      builder: (context) {
                        if (game.roomId != null) {
                          if (game.players.any(
                            (p) => p.id == game.myId && p.isHost,
                          )) {
                            final canStart = game.players.length >= 2;
                            return ElevatedButton(
                              onPressed: canStart
                                  ? () => game.startGame()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canStart
                                    ? AppColors.primary
                                    : Colors.grey[700],
                                foregroundColor: Colors.white,
                                elevation: canStart ? 8 : 0,
                                shadowColor: AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                canStart
                                    ? AppStrings.startGame
                                    : '${2 - game.players.length}명 더 필요',
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                AppStrings.waitingForHost,
                                style: GoogleFonts.gowunDodum(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
