import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../providers/game_provider.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';
import 'game_log_view.dart';

class GameResultOverlay extends StatefulWidget {
  final GameProvider game;

  const GameResultOverlay({super.key, required this.game});

  @override
  State<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends State<GameResultOverlay> {
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

    // Refresh only for the first 2 seconds to check 'canReturnToLobby'
    // Then stop to prevent unnecessary rebuilds
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to check game.canReturnToLobby
        // Cancel after ~2 seconds (4 ticks of 500ms)
        if (timer.tick >= 4) {
          timer.cancel();
        }
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
    final winner = widget.game.winner;
    // Normalize winner string to check who won
    GameRole? winnerRole = GameRole.fromString(winner);
    final isMafiaWin = winnerRole == GameRole.mafia;

    // Fallback if 'winner' was already a Korean string like '마피아' (though fromString handles aliases if defined)
    // safe check: if winner is string '마피아' fromString might return mafia if aliases set,
    // otherwise manual check needed if strictly English.
    // Our refactored fromString handles Korean labels too! So this is safe.

    // Theme colors based on winner
    final mainColor = isMafiaWin
        ? const Color(0xFFE94560)
        : const Color(0xFF4ECCA3);

    return Positioned.fill(
      child: FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Container(
          color: Colors.black.withOpacity(0.9), // Darkened background
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
                    color: mainColor.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.3),
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
                            isMafiaWin ? '마피아 승리' : '시민 승리',
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
                            isMafiaWin ? '마피아가 도시를 장악했습니다.' : '도시의 평화를 지켜냈습니다.',
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
                                  children: widget.game.endGamePlayers.map((p) {
                                    final index = widget.game.endGamePlayers
                                        .indexOf(p);

                                    // Determine if this player won
                                    bool isPlayerWinner = false;
                                    final role = p.role;
                                    if (isMafiaWin) {
                                      if (role == GameRole.mafia)
                                        isPlayerWinner = true;
                                    } else {
                                      // Citizen win: All non-mafia win
                                      if (role != GameRole.mafia)
                                        isPlayerWinner = true;
                                    }

                                    Color roleColor = Colors.grey;
                                    IconData roleIcon = Icons.person;
                                    if (p.role == GameRole.mafia) {
                                      roleColor = const Color(0xFFE94560);
                                      roleIcon = Icons.water_drop; // Skull bug
                                    } else if (p.role == GameRole.doctor) {
                                      roleColor = Colors.greenAccent;
                                      roleIcon = Icons.medical_services;
                                    } else if (p.role == GameRole.police) {
                                      roleColor = Colors.blueAccent;
                                      roleIcon = Icons.local_police;
                                    } else {
                                      roleColor = Colors.white70;
                                    }

                                    // Winner styling
                                    final borderColor = isPlayerWinner
                                        ? const Color(
                                            0xFFFFD700,
                                          ) // Gold for winner
                                        : Colors.grey.withOpacity(0.3);
                                    final borderWidth = isPlayerWinner
                                        ? 3.0
                                        : 1.0;

                                    return FadeInLeft(
                                      delay: Duration(milliseconds: 50 * index),
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: SizedBox(
                                        width: 180,
                                        height: 85, // Slightly taller for badge
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isPlayerWinner
                                                    ? mainColor.withOpacity(0.1)
                                                    : Colors.white.withOpacity(
                                                        0.05,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isPlayerWinner
                                                      ? mainColor
                                                      : borderColor,
                                                  width: borderWidth,
                                                ),
                                                boxShadow: isPlayerWinner
                                                    ? [
                                                        BoxShadow(
                                                          color: mainColor
                                                              .withOpacity(0.4),
                                                          blurRadius: 15,
                                                          spreadRadius: 1,
                                                        ),
                                                      ]
                                                    : [],
                                              ),
                                              child: Row(
                                                children: [
                                                  // Avatar
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: roleColor
                                                          .withOpacity(0.2),
                                                      border: Border.all(
                                                        color: roleColor,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      roleIcon,
                                                      color: roleColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Texts
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          p.nickname,
                                                          style: GoogleFonts.gowunDodum(
                                                            color: p.isAlive
                                                                ? Colors.white
                                                                : Colors.grey,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                p.isAlive
                                                                ? null
                                                                : TextDecoration
                                                                      .lineThrough,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          p.role?.label ?? '시민',
                                                          style:
                                                              GoogleFonts.gowunDodum(
                                                                color:
                                                                    roleColor,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (!p.isAlive)
                                                    Text(
                                                      '💀',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            // Crown Badge for Winners
                                            if (isPlayerWinner)
                                              Positioned(
                                                top: -12,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: mainColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.emoji_events,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'WINNER',
                                                          style: GoogleFonts.roboto(
                                                            // Bold condensed font for badges
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
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
                        if (!widget.game.canReturnToLobby)
                          Pulse(
                            infinite: true,
                            child: const Text(
                              "로비로 돌아가는 중...",
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
                                if (widget.game.canReturnToLobby) {
                                  widget.game.returnToLobby();
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
                                shadowColor: mainColor.withOpacity(0.5),
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
                              '📜 게임 로그 보기',
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
                  gameLog: widget.game.gameLog,
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
