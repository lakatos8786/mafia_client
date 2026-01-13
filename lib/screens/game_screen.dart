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
      // Let Flutter handle keyboard resize
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: DayNightBackground(
          phase: game.gamePhase,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main content in a Column - Flutter will resize this when keyboard opens
              SafeArea(
                child: Column(
                  children: [
                    // Header - always visible
                    const GameHeader(),

                    // Action buttons - hide when keyboard is open to save space
                    if (!isKeyboardOpen) const ActionButtons(),

                    // Player Grid - hide when keyboard open or chat expanded
                    if (!isKeyboardOpen && !_isChatExpanded)
                      Expanded(flex: 2, child: PlayerGrid()),

                    // Chat messages area - expands when keyboard is open
                    Expanded(
                      flex: isKeyboardOpen ? 1 : (_isChatExpanded ? 3 : 1),
                      child: ChatWidget(
                        isExpanded: _isChatExpanded || isKeyboardOpen,
                        onToggleExpand: () {
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

                    // Chat input - at bottom, pushed up by keyboard automatically
                    ChatInputWidget(
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
                  ],
                ),
              ),

              // Overlays
              if (game.gamePhase == GamePhase.result)
                GameResultOverlay(game: game),

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
