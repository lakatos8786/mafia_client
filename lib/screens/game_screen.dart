import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_provider.dart';
import '../models/game_enums.dart';
import '../widgets/day_night_background.dart';
import '../widgets/game_header.dart';
import '../widgets/player_grid.dart';
import '../widgets/chat_widget.dart';
import '../widgets/action_buttons.dart';
import '../widgets/game_result_overlay.dart';
import '../widgets/role_reveal_modal.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _isChatExpanded = false;
  bool _roleRevealed = false;
  int? _lastDayCount;
  GameRole? _shownRole;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    // Show role modal when game starts or role changes
    final shouldShowRoleModal =
        gameState.myRole != null &&
        gameState.gamePhase != GamePhase.waiting &&
        gameState.gamePhase != GamePhase.result &&
        (!_roleRevealed ||
            _shownRole != gameState.myRole ||
            _lastDayCount != gameState.dayCount && gameState.dayCount == 1);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: DayNightBackground(
        phase: gameState.gamePhase,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        // --- Custom Header Area ---
                        const GameHeader(),

                        // Skip Vote & Role Actions
                        const ActionButtons(),

                        // Game Area
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height < 600
                                ? 120
                                : 200, // Extra padding for chat area
                          ),
                          child: const PlayerGrid(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expandable Chat Layer
                // Chat Layer (Non-animated positioning as requested)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _isChatExpanded
                      ? (MediaQuery.of(context).size.height < 600
                            ? MediaQuery.of(context).size.height * 0.85
                            : MediaQuery.of(context).size.height * 0.7)
                      : (MediaQuery.of(context).size.height < 600 ? 140 : 160),
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
            if (gameState.gamePhase == GamePhase.result)
              const GameResultOverlay(),
            // If Overlay expects "GameProvider", I need to migrate Overlay too.
            // Assuming Overlay expects "game" which was "GameProvider".
            // Since I pass "gameState" (type GameState), Overlay will break if not migrated.
            // I should migrate Overlay later or remove argument and let it watch.

            // Role Reveal Modal
            if (shouldShowRoleModal && !_roleRevealed)
              RoleRevealModal(
                role: gameState.myRole!,
                onDismiss: () {
                  setState(() {
                    _roleRevealed = true;
                    _shownRole = gameState.myRole;
                    _lastDayCount = gameState.dayCount;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
