import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../widgets/particle_background.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../widgets/custom_snackbar.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final myId = ref.watch(connectionProvider.notifier).socketId;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '방 번호: ${gameState.roomId}',
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
              if (gameState.roomId != null) {
                Clipboard.setData(ClipboardData(text: gameState.roomId!));
                CustomSnackBar.show(context, '복사됨: ${gameState.roomId}');
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ParticleBackground(phase: GamePhase.day),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
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
                  itemCount: gameState.players.length,
                  itemBuilder: (context, index) {
                    final player = gameState.players[index];
                    final isMe = player.id == myId;

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
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isMe
                                      ? AppColors.primary.withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: isMe ? 1.5 : 1.0,
                                ),
                                boxShadow: isMe
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
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
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${gameState.players.length}명 참가 중',
                        style: GoogleFonts.gowunDodum(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
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
                        if (gameState.roomId != null) {
                          final isHost = gameState.players.any(
                            (p) => p.id == myId && p.isHost,
                          );
                          if (isHost) {
                            return ElevatedButton(
                              onPressed: () {
                                ref.read(actionProvider.notifier).startGame();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                AppStrings.startGame,
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
