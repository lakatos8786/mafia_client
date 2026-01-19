import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../utils/responsive_utils.dart';
import 'phase_timer.dart';
import 'game_info_bottom_sheet.dart';

/// 게임 상태 및 생존 현황을 표시하는 상단 헤더
class GameHeader extends ConsumerStatefulWidget {
  const GameHeader({super.key});

  @override
  ConsumerState<GameHeader> createState() => _GameHeaderState();
}

class _GameHeaderState extends ConsumerState<GameHeader> {
  void _showGameInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => const GameInfoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final dayCount = ref.watch(gameStateProvider.select((s) => s.dayCount));
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.only(
          left: ResponsiveUtils.horizontalPadding(context, AppSpacing.paddingM),
          right: ResponsiveUtils.horizontalPadding(
            context,
            AppSpacing.paddingM,
          ),
          top:
              MediaQuery.of(context).padding.top +
              ResponsiveUtils.verticalPadding(context, AppSpacing.paddingS),
          bottom: ResponsiveUtils.verticalPadding(context, AppSpacing.paddingS),
        ),
        decoration: BoxDecoration(
          color: AppColors.overlayBlack50,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _PhaseIndicator(
                    gamePhase: gamePhase,
                    dayCount: dayCount,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showGameInfoSheet(context),
                      borderRadius: BorderRadius.circular(8),
                      splashColor: AppColors.primary.withValues(alpha: 0.2),
                      highlightColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Padding(
                        padding: EdgeInsets.all(
                          ResponsiveUtils.padding(context, 8),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: ResponsiveUtils.iconSize(context, 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseIndicator extends StatelessWidget {
  final GamePhase gamePhase;
  final int dayCount;

  const _PhaseIndicator({required this.gamePhase, required this.dayCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDayStyle =
        gamePhase == GamePhase.day ||
        gamePhase == GamePhase.lastWord ||
        gamePhase == GamePhase.judgement;

    final accentColor = isDayStyle
        ? Colors.orangeAccent
        : AppColors.nightAccent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.padding(context, 10),
              vertical: ResponsiveUtils.padding(context, 5),
            ),
            decoration: AppDecorations.glass(
              opacity: 0.1,
              borderRadius: 20,
              border: Border.all(color: accentColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDayStyle ? Icons.wb_sunny : Icons.nightlight_round,
                  color: accentColor,
                  size: ResponsiveUtils.iconSize(context, 18),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 6)),
                Flexible(
                  child: Text(
                    '${gamePhase.label} $dayCount일차',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      letterSpacing:
                          ResponsiveUtils.getScaleFactor(context) < 0.9
                          ? 0.5
                          : 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 8)),
        const PhaseTimer(),
      ],
    );
  }
}
