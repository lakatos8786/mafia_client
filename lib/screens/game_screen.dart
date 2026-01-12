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
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // If screen is too short (e.g. window resize on desktop), make it scrollable
                  if (constraints.maxHeight < 600) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const GameHeader(),
                          const ActionButtons(),
                          const SizedBox(height: 300, child: PlayerGrid()),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 250, child: ChatWidget()),
                        ],
                      ),
                    );
                  }

                  // Default responsive layout
                  return Column(
                    children: [
                      // --- Custom Header Area ---
                      const GameHeader(),

                      // Skip Vote & Role Actions
                      const ActionButtons(),

                      // Game Area
                      Expanded(
                        flex: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 2
                            : 3,
                        child: PlayerGrid(),
                      ),
                      const Divider(color: Colors.white10),
                      // Chat Area
                      Expanded(
                        flex: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 3
                            : 1,
                        child: ChatWidget(),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (game.gameState == '결과') GameResultOverlay(game: game),
          ],
        ),
      ),
    );
  }
}
