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
import '../providers/ui_provider.dart';

/// 게임 중 액션 버튼(투표 건너뛰기 등)을 관리하는 위젯
class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));
    final socketId = ref.watch(connectionProvider.notifier).socketId;

    final isAlive = ref.watch(
      gameStateProvider.select(
        (s) => s.players.any((p) => p.id == socketId && p.isAlive),
      ),
    );

    // Filter button should be available even for dead players
    // but only in phases where it's not automatically ignored anyway
    final showFilterOnly =
        !isAlive &&
        (gamePhase == GamePhase.day ||
            gamePhase == GamePhase.night ||
            gamePhase == GamePhase.lastWord);

    return RepaintBoundary(
      child: Column(
        children: [
          if (isAlive) ...[
            if (gamePhase == GamePhase.day) const _SkipVoteRow(),
            if (gamePhase == GamePhase.night && myRole == GameRole.mafia)
              const _MafiaSkipRow(),
            if (gamePhase == GamePhase.night && myRole != GameRole.mafia)
              const _FilterOnlyRow(),
            if (gamePhase == GamePhase.lastWord) const _LastWordRow(),
          ] else if (showFilterOnly) ...[
            const _FilterOnlyRow(),
          ],
        ],
      ),
    );
  }
}

class _FilterOnlyRow extends StatelessWidget {
  const _FilterOnlyRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_SurvivorFilterToggle()],
      ),
    );
  }
}

class _LastWordRow extends ConsumerWidget {
  const _LastWordRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final judgementTarget = ref.watch(
      actionNotifierProvider.select((s) => s.judgementTarget),
    );
    final socketId = ref.watch(connectionProvider.notifier).socketId;

    // Only show for the suspect who is speaking
    if (judgementTarget != socketId) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _ActionButton(
            label: AppStrings.endLastWord,
            onPressed: () =>
                ref.read(actionNotifierProvider.notifier).endLastWord(),
            isHighlighted: false,
            highlightColor: Colors.white,
            normalColor: AppColors.grey700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '변론이 끝나면 버튼을 눌러주세요.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          const _SurvivorFilterToggle(),
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
    final skipVotes = ref.watch(
      actionProvider.select((s) => s.votes[GameAction.skip] ?? 0),
    );
    final skipVoterNicknames = ref.watch(skipVoterNicknamesProvider);
    final iVotedSkip = ref.watch(iVotedSkipProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _ActionButton(
            label: AppStrings.skipVote,
            onPressed: () =>
                ref.read(actionProvider.notifier).vote(GameAction.skip),
            isHighlighted: iVotedSkip,
            highlightColor: gameTheme.policeRef,
            normalColor: AppColors.grey700,
          ),
          if (skipVotes > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '건너뛰기 투표: $skipVotes (${skipVoterNicknames.join(", ")})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.fontSize(context, 11),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          const Spacer(),
          const _SurvivorFilterToggle(),
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
    final mafiaSkipActor = ref.watch(mafiaSkipActorNicknameProvider);
    final mafiaSkipVotes = ref.watch(
      actionProvider.select((s) => s.votes[GameAction.skip] ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
          if (mafiaSkipVotes > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '킬 건너뛰기: $mafiaSkipVotes ($mafiaSkipActor)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.fontSize(context, 11),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          const Spacer(),
          const _SurvivorFilterToggle(),
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
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SurvivorFilterToggle extends ConsumerWidget {
  const _SurvivorFilterToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSurvivorsOnly = ref.watch(showSurvivorsOnlyProvider);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        ref.read(showSurvivorsOnlyProvider.notifier).state = !showSurvivorsOnly;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: showSurvivorsOnly
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: showSurvivorsOnly
                ? AppColors.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: showSurvivorsOnly
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Text(
          showSurvivorsOnly ? '생존자만' : '모두 보기',
          style: theme.textTheme.bodySmall?.copyWith(
            color: showSurvivorsOnly ? AppColors.primary : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.fontSize(context, 11),
          ),
        ),
      ),
    );
  }
}
