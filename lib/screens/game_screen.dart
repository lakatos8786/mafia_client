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
  bool _isChatExpanded = false;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset:
          true, // Revert to true to standard handle keyboard
      body: DayNightBackground(
        phase: game.gamePhase,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    // --- Custom Header Area ---
                    const GameHeader(),

                    // Skip Vote & Role Actions
                    const ActionButtons(),

                    // Game Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 160,
                        ), // Fixed padding for collapsed chat
                        child: PlayerGrid(),
                      ),
                    ),
                  ],
                ),

                // Expandable Chat Layer
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  left: 0,
                  right: 0,
                  bottom: 0, // Dock to bottom of RESIZED scaffold
                  // Expanded: 70% of RESPONSIVE height
                  height: _isChatExpanded
                      ? MediaQuery.of(context).size.height * 0.7
                      : 160,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: ChatWidget(
                      isExpanded: _isChatExpanded,
                      onToggleExpand: () {
                        setState(() {
                          _isChatExpanded = !_isChatExpanded;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (game.gameState == '결과') GameResultOverlay(game: game),
          ],
        ),
      ),
    );
  }
}
