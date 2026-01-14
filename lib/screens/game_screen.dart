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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: DayNightBackground(
        phase: gameState.gamePhase,
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
                        padding: const EdgeInsets.only(bottom: 160),
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
                  bottom: MediaQuery.of(context).viewInsets.bottom,
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
