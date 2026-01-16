import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// 게임 중 액션 버튼(투표 건너뛰기 등)을 관리하는 위젯
class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final socketId = ref.watch(connectionProvider.notifier).socketId;

    // 플레이어가 살아있는지 확인
    if (!gameState.players.any((p) => p.id == socketId && p.isAlive)) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Column(
        children: [
          if (gameState.gamePhase == GamePhase.day) const _SkipVoteRow(),
          if (gameState.gamePhase == GamePhase.night &&
              gameState.myRole == GameRole.mafia)
            const _MafiaSkipRow(),
        ],
      ),
    );
  }
}

class _SkipVoteRow extends ConsumerWidget {
  const _SkipVoteRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final actionState = ref.watch(actionProvider);
    final skipVoterNicknames = ref.watch(skipVoterNicknamesProvider);
    final iVotedSkip = ref.watch(iVotedSkipProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (actionState.votes[GameAction.skip] != null &&
              actionState.votes[GameAction.skip]! > 0)
            Flexible(
              child: Text(
                '건너뛰기 투표: ${actionState.votes[GameAction.skip]} (${skipVoterNicknames.join(", ")})  ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.fontSize(context, 11),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          _ActionButton(
            label: AppStrings.skipVote,
            onPressed: () =>
                ref.read(actionProvider.notifier).vote(GameAction.skip),
            isHighlighted: iVotedSkip,
            highlightColor: gameTheme.policeRef,
            normalColor: AppColors.grey700,
          ),
        ],
      ),
    );
  }
}

class _MafiaSkipRow extends ConsumerWidget {
  const _MafiaSkipRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final isMafiaSkip = ref.watch(isMafiaSkipProvider);
    final mafiaSkipButtonText = ref.watch(mafiaSkipButtonTextProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ActionButton(
            label: mafiaSkipButtonText,
            onPressed: () => ref
                .read(actionProvider.notifier)
                .nightAction(NightAction.kill, GameAction.skip),
            isHighlighted: isMafiaSkip,
            highlightColor: gameTheme.mafiaRef,
            normalColor: AppColors.greyDark,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isHighlighted;
  final Color highlightColor;
  final Color normalColor;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isHighlighted,
    required this.highlightColor,
    required this.normalColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? highlightColor : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: highlightColor.withValues(alpha: 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
        border: Border.all(
          color: highlightColor.withValues(alpha: 0.8),
          width: 2,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isHighlighted
              ? theme.colorScheme.onPrimary
              : highlightColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.padding(context, 16),
            vertical: ResponsiveUtils.padding(context, 10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: ResponsiveUtils.fontSize(context, 13),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
