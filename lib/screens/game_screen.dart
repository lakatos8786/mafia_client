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
      // Use Flutter's built-in keyboard handling
      resizeToAvoidBottomInset: true,
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
              // Main game content - uses Column with chat at bottom
              Column(
                children: [
                  // --- Custom Header Area ---
                  const GameHeader(),

                  // Skip Vote & Role Actions
                  const ActionButtons(),

                  // Game Area - expands to fill available space
                  Expanded(flex: _isChatExpanded ? 1 : 2, child: PlayerGrid()),

                  // Chat area - uses Flexible to adapt to keyboard
                  Flexible(
                    flex: _isChatExpanded ? 3 : 1,
                    child: ChatWidget(
                      isExpanded: _isChatExpanded,
                      onToggleExpand: () {
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

                  // Input area - always at the bottom, above keyboard
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
