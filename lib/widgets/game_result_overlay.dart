import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';

import '../providers/game_state_provider.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';
import 'game_log_view.dart';
import 'result_player_card.dart';
// Note: GameState needs to expose `returnToLobby` via Notifier.
// And GameState object needs `endGamePlayers`, `winner`, `canReturnToLobby`.
// We assume they exist in GameState or GameStateNotifier.

class GameResultOverlay extends ConsumerStatefulWidget {
  // If we passed `game` (GameProvider) before, now we pass `gameState` or just use ref.
  // Ideally, overlays should just watch state.
  // But GameScreen passed it. Let's make it watch internally.
  const GameResultOverlay({super.key});

  @override
  ConsumerState<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends ConsumerState<GameResultOverlay> {
  bool _showCards = false;
  bool _showGameLog = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Start card reveal shortly after header appears
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showCards = true;
        });
      }
    });

    // Start periodic refresh to check canReturnToLobby (which depends on time)
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update time-dependent UI
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final winner = gameState.winner;

    // Normalize winner string to check who won
    GameRole? winnerRole = GameRole.fromString(winner);
    final isMafiaWin = winnerRole == GameRole.mafia;

    // Theme colors based on winner
    final mainColor = isMafiaWin ? AppColors.mafiaRed : AppColors.doctorGreen;

    return Positioned.fill(
      child: FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Container(
          color: Colors.black.withValues(alpha: 0.9), // Darkened background
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Ambient Background Glow
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mainColor.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withValues(alpha: 0.3),
                        blurRadius: 150,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20), // Reduced top spacing
                    // 1. Winner Announcement (Big & Clear)
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: mainColor,
                            size: 80, // Much larger icon
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isMafiaWin
                                ? AppStrings.winMafia
                                : AppStrings.winCitizen,
                            style: GoogleFonts.gowunDodum(
                              fontSize: 50, // Massive font
                              fontWeight: FontWeight.w900,
                              color: mainColor, // Color the text itself
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(blurRadius: 15, color: mainColor),
                              ],
                            ),
                          ),
                          Text(
                            isMafiaWin
                                ? AppStrings.winMafiaDesc
                                : AppStrings.winCitizenDesc,
                            style: GoogleFonts.gowunDodum(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30), // More spacing
                    // 2. Results Grid (Highlight Winners)
                    Expanded(
                      child: _showCards
                          ? SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: gameState.endGamePlayers.map((p) {
                                    final index = gameState.endGamePlayers
                                        .indexOf(p);

                                    // Determine if this player won
                                    bool isPlayerWinner = false;
                                    final role = p.role;
                                    if (isMafiaWin) {
                                      if (role == GameRole.mafia) {
                                        isPlayerWinner = true;
                                      }
                                    } else {
                                      // Citizen win: All non-mafia win
                                      if (role != GameRole.mafia) {
                                        isPlayerWinner = true;
                                      }
                                    }

                                    return ResultPlayerCard(
                                      player: p, // Player object
                                      index: index,
                                      isWinner: isPlayerWinner,
                                      mainColor: mainColor,
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),

                    const SizedBox(height: 15),

                    // 3. Action Buttons - Centered
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!gameState.canReturnToLobby)
                          Pulse(
                            infinite: true,
                            child: const Text(
                              AppStrings.pleaseWait,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          )
                        else
                          FadeInUp(
                            child: ElevatedButton(
                              onPressed: () {
                                if (gameState.canReturnToLobby) {
                                  ref
                                      .read(gameStateProvider.notifier)
                                      .returnToLobby();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 5,
                                shadowColor: mainColor.withValues(alpha: 0.5),
                              ),
                              child: Text(
                                AppStrings.returnToLobby,
                                style: GoogleFonts.gowunDodum(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Game Log Button
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showGameLog = true;
                              });
                            },
                            child: Text(
                              AppStrings.viewGameLog,
                              style: GoogleFonts.gowunDodum(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Game Log Overlay
              if (_showGameLog)
                GameLogView(
                  gameLog: gameState.gameLog,
                  onClose: () {
                    setState(() {
                      _showGameLog = false;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
