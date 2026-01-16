import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';

import '../providers/game_state_provider.dart';
import '../theme/app_strings.dart';
import '../theme/noir_design.dart';
import '../utils/responsive_utils.dart';
import '../widgets/common/noir_button.dart';
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
    final mainColor = isMafiaWin ? NoirColors.crimson : NoirColors.textPrimary;

    return Positioned.fill(
      child: FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Container(
          color: NoirColors.backgroundDeep.withValues(alpha: 0.98),
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
                    color: mainColor.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withValues(alpha: 0.2),
                        blurRadius: 150,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ), // Reduced top spacing
                                // 1. Winner Announcement (Big & Clear)
                                ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: mainColor,
                                        size: ResponsiveUtils.iconSize(
                                          context,
                                          80,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        isMafiaWin
                                            ? AppStrings.winMafia
                                            : AppStrings.winCitizen,
                                        style: GoogleFonts.gowunDodum(
                                          fontSize: ResponsiveUtils.fontSize(
                                            context,
                                            50,
                                          ), // Massive font
                                          fontWeight: FontWeight.w900,
                                          color:
                                              mainColor, // Color the text itself
                                          letterSpacing: 2.0,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 20,
                                              color: mainColor.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        isMafiaWin
                                            ? AppStrings.winMafiaDesc
                                            : AppStrings.winCitizenDesc,
                                        style: GoogleFonts.gowunDodum(
                                          fontSize: ResponsiveUtils.fontSize(
                                            context,
                                            16,
                                          ),
                                          color: NoirColors.textTertiary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: ResponsiveUtils.spacing(context, 30),
                                ), // More spacing
                                // 2. Results Grid (Highlight Winners)
                                if (_showCards)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          ResponsiveUtils.horizontalPadding(
                                            context,
                                            16,
                                          ),
                                    ),
                                    child: Center(
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: ResponsiveUtils.spacing(
                                          context,
                                          12,
                                        ),
                                        runSpacing: ResponsiveUtils.spacing(
                                          context,
                                          12,
                                        ),
                                        children: gameState.endGamePlayers.map((
                                          p,
                                        ) {
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
                                  ),

                                SizedBox(
                                  height: ResponsiveUtils.spacing(context, 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 3. Action Buttons - Fixed at Bottom
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.horizontalPadding(
                              context,
                              20,
                            ),
                            vertical: ResponsiveUtils.verticalPadding(
                              context,
                              20,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!gameState.canReturnToLobby)
                                Pulse(
                                  infinite: true,
                                  child: Text(
                                    AppStrings.pleaseWait,
                                    style: TextStyle(
                                      color: NoirColors.textTertiary,
                                      fontSize: ResponsiveUtils.fontSize(
                                        context,
                                        14,
                                      ),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                )
                              else
                                FadeInUp(
                                  child: NoirButton(
                                    text: AppStrings.returnToLobby,
                                    onPressed: () {
                                      if (gameState.canReturnToLobby) {
                                        ref
                                            .read(gameStateProvider.notifier)
                                            .returnToLobby();
                                      }
                                    },
                                    style: isMafiaWin
                                        ? NoirButtonStyle.primary
                                        : NoirButtonStyle.secondary,
                                    fullWidth: false,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Game Log Button
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showGameLog = true;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.viewGameLog,
                                    style: GoogleFonts.gowunDodum(
                                      color: NoirColors.textSecondary
                                          .withValues(alpha: 0.7),
                                      fontSize: ResponsiveUtils.fontSize(
                                        context,
                                        15,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
