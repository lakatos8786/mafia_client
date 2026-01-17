import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'game_log_view.dart';
import 'result_player_card.dart';

/// 게임 종료 결과를 표시하는 오버레이
class GameResultOverlay extends ConsumerStatefulWidget {
  const GameResultOverlay({super.key});

  @override
  ConsumerState<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends ConsumerState<GameResultOverlay> {
  bool _showCards = false;
  bool _showGameLog = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showCards = true);
    });

    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;

    final winner = gameState.winner;
    final winnerRole = GameRole.fromString(winner);
    final isMafiaWin = winnerRole == GameRole.mafia;

    // 승자에 따른 메인 컬러 결정
    final mainColor = isMafiaWin ? gameTheme.mafiaRef : gameTheme.doctorRef;

    return Positioned.fill(
      child: RepaintBoundary(
        child: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: Container(
            color: AppColors.overlayBlack50.withValues(alpha: 0.9),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _AmbientGlow(color: mainColor),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxHeight < 600;
                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _WinnerAnnouncement(
                                    isMafiaWin: isMafiaWin,
                                    mainColor: mainColor,
                                    isCompact: isCompact,
                                  ),
                                  SizedBox(height: isCompact ? 10 : 30),
                                  if (_showCards)
                                    _ResultsGrid(
                                      players: gameState.endGamePlayers,
                                      isMafiaWin: isMafiaWin,
                                      mainColor: mainColor,
                                    ),
                                  SizedBox(height: isCompact ? 10 : 20),
                                ],
                              ),
                            ),
                          ),
                          _ActionButtonsArea(
                            canReturn: gameState.canReturnToLobby,
                            mainColor: mainColor,
                            isCompact: isCompact,
                            onReturn: () => ref
                                .read(gameStateProvider.notifier)
                                .returnToLobby(),
                            onShowLog: () =>
                                setState(() => _showGameLog = true),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_showGameLog)
                  GameLogView(
                    gameLog: gameState.gameLog,
                    onClose: () => setState(() => _showGameLog = false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  final Color color;
  const _AmbientGlow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 150,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _WinnerAnnouncement extends StatelessWidget {
  final bool isMafiaWin;
  final Color mainColor;
  final bool isCompact;

  const _WinnerAnnouncement({
    required this.isMafiaWin,
    required this.mainColor,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ZoomIn(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: mainColor, size: isCompact ? 50 : 80),
          const SizedBox(height: 10),
          Text(
            isMafiaWin ? AppStrings.winMafia : AppStrings.winCitizen,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: isCompact ? 32 : 50,
              color: mainColor,
              letterSpacing: 2.0,
              shadows: [Shadow(blurRadius: 15, color: mainColor)],
            ),
          ),
          Text(
            isMafiaWin ? AppStrings.winMafiaDesc : AppStrings.winCitizenDesc,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: isCompact ? 14 : 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  final List<dynamic> players;
  final bool isMafiaWin;
  final Color mainColor;

  const _ResultsGrid({
    required this.players,
    required this.isMafiaWin,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(players.length, (index) {
            final p = players[index];
            bool isPlayerWinner = isMafiaWin
                ? p.role == GameRole.mafia
                : p.role != GameRole.mafia;

            return ResultPlayerCard(
              player: p,
              index: index,
              isWinner: isPlayerWinner,
              mainColor: mainColor,
            );
          }),
        ),
      ),
    );
  }
}

class _ActionButtonsArea extends StatelessWidget {
  final bool canReturn;
  final Color mainColor;
  final bool isCompact;
  final VoidCallback onReturn;
  final VoidCallback onShowLog;

  const _ActionButtonsArea({
    required this.canReturn,
    required this.mainColor,
    required this.isCompact,
    required this.onReturn,
    required this.onShowLog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isCompact ? 10 : 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canReturn)
            Pulse(
              infinite: true,
              child: Text(
                AppStrings.pleaseWait,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            FadeInUp(
              child: ElevatedButton(
                onPressed: onReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 30 : 40,
                    vertical: isCompact ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  shadowColor: mainColor.withValues(alpha: 0.5),
                ),
                child: Text(
                  AppStrings.returnToLobby,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: onShowLog,
              child: Text(
                AppStrings.viewGameLog,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
