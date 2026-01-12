import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

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
                    content: Text('복사됨: ${game.roomId}'),
                    backgroundColor: AppColors.surface,
                    duration: const Duration(seconds: 2),
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
          // Background
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.surface.withOpacity(0.4),
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
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                            child: Container(
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
                                      ? AppColors.primary.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isMe
                                        ? AppColors.primary
                                        : Colors.white24,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      player.nickname,
                                      style: TextStyle(
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
                            return ElevatedButton(
                              onPressed: () {
                                game.startGame();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                '게임 시작',
                                style: TextStyle(
                                  fontSize: 20,
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
                              child: const Text(
                                '방장 대기 중...',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
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
