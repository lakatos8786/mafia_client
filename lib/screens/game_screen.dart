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
    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final dayCount = ref.watch(gameStateProvider.select((s) => s.dayCount));

    // Show role modal when game starts or role changes
    final shouldShowRoleModal =
        myRole != null &&
        gamePhase != GamePhase.waiting &&
        gamePhase != GamePhase.result &&
        (!_roleRevealed ||
            _shownRole != myRole ||
            (_lastDayCount != dayCount && dayCount == 1));

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: DayNightBackground(
        phase: gamePhase,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    RepaintBoundary(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
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
                                  bottom:
                                      (constraints.maxHeight < 480 &&
                                              MediaQuery.of(
                                                    context,
                                                  ).orientation ==
                                                  Orientation.landscape) ||
                                          constraints.maxHeight < 600
                                      ? 120
                                      : 200, // Extra padding for chat area
                                ),
                                child: const PlayerGrid(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Expandable Chat Layer
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _isChatExpanded
                          ? ((constraints.maxHeight < 480 &&
                                        MediaQuery.of(context).orientation ==
                                            Orientation.landscape) ||
                                    constraints.maxHeight < 600
                                ? constraints.maxHeight * 0.85
                                : constraints.maxHeight * 0.7)
                          : ((constraints.maxHeight < 480 &&
                                        MediaQuery.of(context).orientation ==
                                            Orientation.landscape) ||
                                    constraints.maxHeight < 600
                                ? 140
                                : 160),
                      child: Container(
                        padding: const EdgeInsets.all(0),
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
                );
              },
            ),
            if (gamePhase == GamePhase.result) const GameResultOverlay(),

            // Role Reveal Modal
            if (shouldShowRoleModal && !_roleRevealed)
              RoleRevealModal(
                role: myRole,
                onDismiss: () {
                  setState(() {
                    _roleRevealed = true;
                    _shownRole = myRole;
                    _lastDayCount = dayCount;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
