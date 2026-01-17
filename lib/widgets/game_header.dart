import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_styles.dart';
import '../utils/responsive_utils.dart';
import 'phase_timer.dart';
import 'role_reveal_modal.dart';

/// 게임 상태 및 생존 현황을 표시하는 상단 헤더
class GameHeader extends ConsumerStatefulWidget {
  const GameHeader({super.key});

  @override
  ConsumerState<GameHeader> createState() => _GameHeaderState();
}

class _GameHeaderState extends ConsumerState<GameHeader> {
  bool _isRoleVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isRoleVisible = false);
      }
    });
  }

  void _onRoleTap() {
    final myRole = ref.read(gameStateProvider.select((s) => s.myRole));
    setState(() => _isRoleVisible = true);
    _startHideTimer();

    if (myRole != null) {
      showDialog(
        context: context,
        builder: (context) => RoleRevealModal(
          role: myRole,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final dayCount = ref.watch(gameStateProvider.select((s) => s.dayCount));
    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));
    final roleCounts = ref.watch(gameStateProvider.select((s) => s.roleCounts));
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.paddingM,
          right: AppSpacing.paddingM,
          top: MediaQuery.of(context).padding.top + AppSpacing.paddingS,
          bottom: AppSpacing.paddingS,
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
                if (myRole != null)
                  Flexible(
                    child: _MyRoleBadge(
                      myRole: myRole,
                      isRoleVisible: _isRoleVisible,
                      onTap: _onRoleTap,
                      gameTheme: gameTheme,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _RoleCounts(roleCounts: roleCounts, gameTheme: gameTheme),
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
    final accentColor = gamePhase == GamePhase.day
        ? Colors.orangeAccent
        : AppColors.nightAccent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: AppDecorations.glass(
            opacity: 0.1,
            borderRadius: 20,
            border: Border.all(color: accentColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                gamePhase == GamePhase.day
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: accentColor,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
              const SizedBox(width: 8),
              Text(
                '${gamePhase.label} $dayCount일차',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const PhaseTimer(),
      ],
    );
  }
}

class _MyRoleBadge extends StatelessWidget {
  final GameRole myRole;
  final bool isRoleVisible;
  final VoidCallback onTap;
  final GameThemeExtension gameTheme;

  const _MyRoleBadge({
    required this.myRole,
    required this.isRoleVisible,
    required this.onTap,
    required this.gameTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = isRoleVisible
        ? gameTheme.getRoleColor(myRole)
        : AppColors.grey600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: roleColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isRoleVisible ? _getRoleEmoji(myRole) : '❓',
              style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 16)),
            ),
            const SizedBox(width: 6),
            Text(
              isRoleVisible ? myRole.label : '직업 확인',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(
                color: roleColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleEmoji(GameRole role) {
    switch (role) {
      case GameRole.mafia:
        return '🕶️';
      case GameRole.doctor:
        return '💉';
      case GameRole.police:
        return '🚨';
      case GameRole.citizen:
        return '👤';
    }
  }
}

class _RoleCounts extends StatelessWidget {
  final Map<String, int> roleCounts;
  final GameThemeExtension gameTheme;

  const _RoleCounts({required this.roleCounts, required this.gameTheme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _RoleCountItem(
          label: GameRole.mafia.label,
          count: roleCounts[GameRole.mafia.name] ?? 0,
          color: gameTheme.mafiaRef,
        ),
        _RoleCountItem(
          label: GameRole.doctor.label,
          count: roleCounts[GameRole.doctor.name] ?? 0,
          color: gameTheme.doctorRef,
        ),
        _RoleCountItem(
          label: GameRole.police.label,
          count: roleCounts[GameRole.police.name] ?? 0,
          color: gameTheme.policeRef,
        ),
        _RoleCountItem(
          label: GameRole.citizen.label,
          count: roleCounts[GameRole.citizen.name] ?? 0,
          color: gameTheme.citizenRef,
        ),
      ],
    );
  }
}

class _RoleCountItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _RoleCountItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: ResponsiveUtils.fontSize(context, 10),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RoomCodeBadge extends StatelessWidget {
  final String roomId;
  const _RoomCodeBadge({required this.roomId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: roomId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복사됨: $roomId'),
            behavior: SnackBarBehavior.floating,
            width: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: AppDecorations.glass(
          opacity: 0.1,
          borderRadius: 8,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔑',
              style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 16)),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 6),
              Text(
                roomId,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
