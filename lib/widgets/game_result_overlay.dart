import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';

class GameResultOverlay extends StatefulWidget {
  final GameProvider game;

  const GameResultOverlay({super.key, required this.game});

  @override
  State<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends State<GameResultOverlay> {
  bool _showCards = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.game.winner;
    final isMafiaWin = winner == '마피아';

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
                    const SizedBox(height: 40),

                    // 1. Winner Announcement (Fast ZoomIn)
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: mainColor, size: 80),
                          const SizedBox(height: 10),
                          Text(
                            isMafiaWin ? '마피아 승리' : '시민 승리',
                            style: GoogleFonts.blackHanSans(
                              fontSize: 40,
                              color: Colors.white,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(blurRadius: 20, color: mainColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 2. Results Grid (Staggered Reveal)
                    Expanded(
                      child: _showCards
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                final players = widget.game.endGamePlayers;
                                // 2 columns for better visibility of details
                                return GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.5, // Wide cards
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: players.length,
                                  itemBuilder: (context, index) {
                                    final p = players[index];

                                    // Determine role style
                                    Color roleColor = Colors.grey;
                                    IconData roleIcon = Icons.person;
                                    if (p.role == '마피아') {
                                      roleColor = const Color(0xFFE94560);
                                      roleIcon =
                                          Icons.security; // Or distinct icon
                                    } else if (p.role == '의사') {
                                      roleColor = Colors.greenAccent;
                                      roleIcon = Icons.medical_services;
                                    } else if (p.role == '경찰') {
                                      roleColor = Colors.blueAccent;
                                      roleIcon = Icons.local_police;
                                    } else {
                                      roleColor = Colors.white70;
                                    }

                                    return FadeInLeft(
                                      // Fast stagger: 100ms * index
                                      delay: Duration(
                                        milliseconds: 100 * index,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: p.isAlive
                                                ? roleColor.withOpacity(0.5)
                                                : Colors.grey.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            // Creating a nice list tile style
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              child: Row(
                                                children: [
                                                  // Avatar / Rank
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: roleColor
                                                          .withOpacity(0.2),
                                                    ),
                                                    child: Icon(
                                                      roleIcon,
                                                      color: roleColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
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
                                                          style: TextStyle(
                                                            color: p.isAlive
                                                                ? Colors.white
                                                                : Colors.grey,
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
                                                          p.role ?? '시민',
                                                          style: TextStyle(
                                                            color: roleColor,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Dead Stamp
                                            if (!p.isAlive)
                                              Positioned(
                                                right: 10,
                                                bottom: 5,
                                                child: Transform.rotate(
                                                  angle: -0.2,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      '사망',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : const SizedBox(),
                    ),

                    const SizedBox(height: 20),

                    // 3. Return Button (Pulsing)
                    if (!widget.game.canReturnToLobby)
                      Pulse(
                        infinite: true,
                        child: const Text(
                          "로비로 돌아가는 중...",
                          style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 1.5,
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
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            shadowColor: mainColor.withOpacity(0.5),
                          ),
                          child: const Text(
                            "로비로 돌아가기",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
