import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/day_night_background.dart';
import '../widgets/game_header.dart';
import '../widgets/player_grid.dart';
import '../widgets/chat_widget.dart';
import '../widgets/action_buttons.dart';
import '../widgets/game_result_overlay.dart';

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
            if (game.gameState == '결과') GameResultOverlay(game: game),
          ],
        ),
      ),
    );
  }
}
