import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_enums.dart';
import '../widgets/day_night_background.dart';
import '../widgets/game_header.dart';
import '../widgets/player_grid.dart';
import '../widgets/chat_widget.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/action_buttons.dart';
import '../widgets/game_result_overlay.dart';
import '../widgets/role_reveal_modal.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isChatExpanded = false;
  bool _roleRevealed = false;
  int? _lastDayCount;
  GameRole? _shownRole;
  int _unreadCount = 0;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    // Show role modal when game starts or role changes
    final shouldShowRoleModal =
        game.myRoleEnum != null &&
        game.gamePhase != GamePhase.waiting &&
        game.gamePhase != GamePhase.result &&
        (!_roleRevealed ||
            _shownRole != game.myRoleEnum ||
            _lastDayCount != game.dayCount && game.dayCount == 1);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Disable Flutter's automatic keyboard avoidance - we handle it manually
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside input areas
          FocusScope.of(context).unfocus();
        },
        child: DayNightBackground(
          phase: game.gamePhase,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main game content
              SafeArea(
                bottom: false, // We handle bottom padding manually
                child: Column(
                  children: [
                    // --- Custom Header Area ---
                    const GameHeader(),

                    // Skip Vote & Role Actions
                    const ActionButtons(),

                    // Game Area - expands/contracts based on chat state
                    Expanded(
                      flex: _isChatExpanded ? 1 : 3,
                      child: PlayerGrid(),
                    ),

                    // Chat area - expands based on state
                    // Add bottom padding to account for keyboard + input area
                    Expanded(
                      flex: _isChatExpanded ? 3 : 1,
                      child: Padding(
                        padding: EdgeInsets.only(
                          // When keyboard is open, add padding for input area + keyboard
                          bottom: isKeyboardOpen ? keyboardHeight + 80 : 80,
                        ),
                        child: ChatWidget(
                          isExpanded: _isChatExpanded,
                          onToggleExpand: () {
                            // Dismiss keyboard when toggling chat
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isChatExpanded = !_isChatExpanded;
                            });
                          },
                          onUnreadCountChanged: (count) {
                            setState(() {
                              _unreadCount = count;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Input area - positioned at the bottom, above keyboard
              Positioned(
                left: 0,
                right: 0,
                bottom: isKeyboardOpen ? keyboardHeight : 0,
                child: SafeArea(
                  top: false,
                  child: ChatInputWidget(
                    isExpanded: _isChatExpanded,
                    unreadCount: _unreadCount,
                    onToggleExpand: () {
                      setState(() {
                        _isChatExpanded = !_isChatExpanded;
                        if (_isChatExpanded) {
                          _unreadCount = 0;
                        }
                      });
                    },
                  ),
                ),
              ),

              // Overlays
              if (game.gamePhase == GamePhase.result)
                GameResultOverlay(game: game),
              // Role Reveal Modal
              if (shouldShowRoleModal && !_roleRevealed)
                RoleRevealModal(
                  role: game.myRoleEnum!,
                  onDismiss: () {
                    setState(() {
                      _roleRevealed = true;
                      _shownRole = game.myRoleEnum;
                      _lastDayCount = game.dayCount;
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
