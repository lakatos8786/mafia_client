import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/day_night_background.dart';
import '../widgets/game_header.dart';
import '../widgets/player_grid.dart';
import '../widgets/chat_widget.dart';
import '../widgets/action_buttons.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: DayNightBackground(
        phase: game.gameState,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const SafeArea(
              child: Column(
                children: [
                  // --- Custom Header Area ---
                  GameHeader(),

                  // Skip Vote & Role Actions
                  ActionButtons(),

                  // Game Area
                  Expanded(flex: 3, child: PlayerGrid()),
                  Divider(color: Colors.white10),
                  // Chat Area
                  Expanded(flex: 1, child: ChatWidget()),
                ],
              ),
            ),
            if (game.gameState == '결과')
              Positioned.fill(
                child: FadeIn(
                  duration: const Duration(milliseconds: 1000),
                  child: GestureDetector(
                    onTap: () {
                      if (game.canReturnToLobby) {
                        game.returnToLobby();
                      }
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.9),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZoomIn(
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.yellowAccent,
                              size: 100,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'GAME OVER',
                            style: GoogleFonts.blackHanSans(
                              fontSize: 50,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'WINNER: ${game.winner ?? "?"}',
                            style: GoogleFonts.blackHanSans(
                              fontSize: 30,
                              color: Colors.yellowAccent,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Results Table
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: SingleChildScrollView(
                              child: Table(
                                border: TableBorder.all(color: Colors.white24),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                },
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.white10,
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'PLAYER',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'ROLE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'SURVIVED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...game.endGamePlayers.map((p) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            p.nickname,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            p.role ?? '-',
                                            style: TextStyle(
                                              color: p.role == '마피아'
                                                  ? Colors.redAccent
                                                  : Colors.greenAccent,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Icon(
                                            p.isAlive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: p.isAlive
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (!game.canReturnToLobby)
                            Pulse(
                              infinite: true,
                              child: const Text(
                                "Returning to lobby...",
                                style: TextStyle(
                                  color: Colors.grey,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            )
                          else
                            FadeInUp(
                              child: const Text(
                                "Tap to Return",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
