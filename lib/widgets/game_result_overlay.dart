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
                    const SizedBox(height: 20), // Reduced top spacing
                    // 1. Winner Announcement (Compact)
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        // Changed to Row for compactness
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: mainColor,
                            size: 50,
                          ), // Smaller icon
                          const SizedBox(width: 10),
                          Text(
                            isMafiaWin ? '마피아 승리' : '시민 승리',
                            style: GoogleFonts.gowunDodum(
                              fontSize: 32, // Smaller font
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(blurRadius: 15, color: mainColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15), // Reduced gap
                    // 2. Results Grid (Dense)
                    Expanded(
                      child: _showCards
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                final players = widget.game.endGamePlayers;
                                final playerCount = players.length;

                                // More aggressive columns
                                int cols = 2;
                                if (playerCount > 4) cols = 3;
                                if (playerCount > 9) cols = 4;

                                return GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16, // Reduced padding
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: cols,
                                        childAspectRatio: 2.4, // Flatter cards
                                        crossAxisSpacing: 6,
                                        mainAxisSpacing: 6,
                                      ),
                                  itemCount: players.length,
                                  itemBuilder: (context, index) {
                                    // ... cell content logic ... (keep it simple for brevity in replacement if possible, but forced here due to tool nature)
                                    final p = players[index];
                                    Color roleColor = Colors.grey;
                                    IconData roleIcon = Icons.person;
                                    if (p.role == '마피아') {
                                      roleColor = const Color(0xFFE94560);
                                      roleIcon = Icons.security;
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
                                      delay: Duration(milliseconds: 50 * index),
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: p.isAlive
                                                ? roleColor.withOpacity(0.6)
                                                : Colors.grey.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Avatar
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: roleColor.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                              child: Icon(
                                                roleIcon,
                                                color: roleColor,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // Texts
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    p.nickname,
                                                    style:
                                                        GoogleFonts.gowunDodum(
                                                          color: p.isAlive
                                                              ? Colors.white
                                                              : Colors.grey,
                                                          fontSize:
                                                              14, // Larger
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration: p.isAlive
                                                              ? null
                                                              : TextDecoration
                                                                    .lineThrough,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    p.role ?? '시민',
                                                    style:
                                                        GoogleFonts.gowunDodum(
                                                          color: roleColor,
                                                          fontSize:
                                                              12, // Larger
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!p.isAlive)
                                              Transform.rotate(
                                                angle: -0.2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.redAccent
                                                          .withOpacity(0.8),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '사망',
                                                    style:
                                                        GoogleFonts.gowunDodum(
                                                          color:
                                                              Colors.redAccent,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
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

                    const SizedBox(height: 15),

                    // 3. Compact Return Button
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
                        child: SizedBox(
                          height: 40, // Height for compact button
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.game.canReturnToLobby) {
                                widget.game.returnToLobby();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                              shadowColor: mainColor.withOpacity(0.5),
                            ),
                            child: const Text(
                              "로비로 돌아가기",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
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
