import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_enums.dart';
import '../widgets/day_night_background.dart';
import '../widgets/game_header.dart';
import '../widgets/player_grid.dart';
import '../widgets/chat_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Show role modal when game starts or role changes
    final shouldShowRoleModal =
        game.myRoleEnum != null &&
        game.gamePhase != GamePhase.waiting &&
        game.gamePhase != GamePhase.result &&
        (!_roleRevealed ||
            _shownRole != game.myRoleEnum ||
            _lastDayCount != game.dayCount && game.dayCount == 1);

    // Calculate chat height - when keyboard is open, use remaining space
    final baseChatHeight = _isChatExpanded ? screenHeight * 0.7 : 160.0;
    // When keyboard is open, adjust chat height to fill available space above keyboard
    final chatHeight = bottomInset > 0
        ? (screenHeight - bottomInset).clamp(200.0, screenHeight * 0.7)
        : baseChatHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              // Main content layer
              Column(
                children: [
                  // --- Custom Header Area ---
                  const GameHeader(),

                  // Skip Vote & Role Actions
                  const ActionButtons(),

                  // Game Area
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: bottomInset > 0 ? 0 : 160,
                      ),
                      child: PlayerGrid(),
                    ),
                  ),
                ],
              ),

              // Expandable Chat Layer with smooth keyboard animation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  height: chatHeight,
                  margin: EdgeInsets.only(bottom: bottomInset),
                  child: ChatWidget(
                    isExpanded: _isChatExpanded || bottomInset > 0,
                    onToggleExpand: () {
                      if (bottomInset > 0) {
                        // If keyboard is open, close it first
                        FocusScope.of(context).unfocus();
                      } else {
                        setState(() {
                          _isChatExpanded = !_isChatExpanded;
                        });
                      }
                    },
                  ),
                ),
              ),

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
