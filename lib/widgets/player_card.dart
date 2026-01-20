import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_state_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_styles.dart';
import '../utils/responsive_utils.dart';

/// 플레이어 개별 정보를 표시하는 카드 위젯
/// 성능 최적화를 위해 RepaintBoundary와 const 서브 위젯을 사용합니다.
class PlayerCard extends ConsumerWidget {
  final Player player;
  final bool isMe;
  final bool isMyVoteTarget;
  final List<String> selectionTargets;
  final VoidCallback onTap;
  final int voteCount;
  final String votersList;
  final bool showMafiaIndicator;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isMe,
    required this.isMyVoteTarget,
    required this.selectionTargets,
    required this.onTap,
    this.voteCount = 0,
    this.votersList = '',
    this.showMafiaIndicator = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final isSelected = selectionTargets.isNotEmpty || isMyVoteTarget;
    final identityColor = AppColors.getIdentityColor(player.nickname);

    // Border 및 Gradient 설정을 위한 헬퍼 변수
    final borderColor = _getBorderColor(theme, gameTheme, isSelected);
    final gradientColors = _getGradientColors(
      theme,
      gameTheme,
      isSelected,
      identityColor,
    );
    final isPoliceSelected = selectionTargets.contains(GameRole.police.name);
    final isMafiaSelected = selectionTargets.contains(GameRole.mafia.name);
    final isDoctorSelected = selectionTargets.contains(GameRole.doctor.name);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                border: Border.all(
                  color: isSelected
                      ? (isPoliceSelected
                            ? AppColors.police
                            : (isMafiaSelected
                                  ? gameTheme.mafiaRef
                                  : (isDoctorSelected
                                        ? gameTheme.doctorRef
                                        : borderColor)))
                      : identityColor.withValues(alpha: 0.6),
                  width: isSelected ? (isPoliceSelected ? 4.0 : 3.0) : 1.5,
                ),
                boxShadow: player.isAlive
                    ? AppDecorations.neonGlow(
                        isSelected
                            ? borderColor
                            : identityColor.withValues(alpha: 0.4),
                      )
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected && player.isAlive) ...[
                    _SelectedGlow(color: borderColor),
                    if (isPoliceSelected) const _PoliceLightEffect(),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.padding(context, 10),
                      vertical: ResponsiveUtils.padding(context, 8),
                    ),
                    child: _PlayerCardContent(
                      player: player,
                      isMe: isMe,
                      identityColor: identityColor,
                      voteCount: voteCount,
                      votersList: votersList,
                      gamePhase: gamePhase,
                    ),
                  ),
                  if (!player.isAlive)
                    _DeadOverlay(deadColor: gameTheme.deadRef),
                  if (showMafiaIndicator)
                    _MafiaIndicator(mafiaColor: gameTheme.mafiaRef),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(
    ThemeData theme,
    GameThemeExtension gameTheme,
    bool isSelected,
  ) {
    if (!player.isAlive) return gameTheme.deadRef.withValues(alpha: 0.3);
    if (!isSelected) return theme.colorScheme.onSurface.withValues(alpha: 0.12);

    if (isMyVoteTarget) return gameTheme.voteRef;
    if (selectionTargets.contains(GameRole.mafia.name)) {
      return gameTheme.mafiaRef;
    }
    if (selectionTargets.contains(GameRole.doctor.name)) {
      return gameTheme.doctorRef;
    }
    if (selectionTargets.contains(GameRole.police.name)) {
      return AppColors.police;
    }

    return theme.colorScheme.secondary;
  }

  List<Color> _getGradientColors(
    ThemeData theme,
    GameThemeExtension gameTheme,
    bool isSelected,
    Color identityColor,
  ) {
    if (!player.isAlive) {
      return [
        theme.colorScheme.surface.withValues(alpha: 0.8),
        theme.colorScheme.surface.withValues(alpha: 0.8),
      ];
    }

    if (isSelected) {
      Color startColor;
      if (isMyVoteTarget) {
        startColor = gameTheme.voteRef;
      } else if (selectionTargets.contains(GameRole.mafia.name)) {
        startColor = gameTheme.mafiaDarkRef;
      } else if (selectionTargets.contains(GameRole.doctor.name)) {
        startColor = gameTheme.doctorDarkRef;
      } else {
        startColor = gameTheme.policeDarkRef;
      }
      return [startColor.withValues(alpha: 0.6), Colors.transparent];
    }

    return [
      identityColor.withValues(alpha: 0.25),
      theme.colorScheme.surface.withValues(alpha: 0.85),
    ];
  }
}

class _SelectedGlow extends StatelessWidget {
  final Color color;
  const _SelectedGlow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.15), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _PlayerCardContent extends StatelessWidget {
  final Player player;
  final bool isMe;
  final Color identityColor;
  final int voteCount;
  final String votersList;
  final GamePhase gamePhase;

  const _PlayerCardContent({
    required this.player,
    required this.isMe,
    required this.identityColor,
    required this.voteCount,
    required this.votersList,
    required this.gamePhase,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: player.isConnected
          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 0.6, 0, // Opacity consolidated here
            ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PlayerAvatar(player: player, identityColor: identityColor),
          const SizedBox(height: 10),
          _PlayerNickname(
            player: player,
            isMe: isMe,
            identityColor: identityColor,
          ),
          if (player.role != null &&
              (player.isRevealed || gamePhase == GamePhase.result))
            _RevealedRoleBadge(role: player.role!),
          if (player.isAlive && voteCount > 0)
            _VoteBadge(voteCount: voteCount, votersList: votersList),
        ],
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final Player player;
  final Color identityColor;
  const _PlayerAvatar({required this.player, required this.identityColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: player.isAlive
            ? LinearGradient(
                colors: [identityColor, identityColor.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: player.isAlive ? null : AppColors.grey800,
        boxShadow: player.isAlive ? AppDecorations.neonGlow(identityColor) : [],
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: theme.colorScheme.surface,
        child: Icon(
          player.isAlive
              ? (player.isConnected ? Icons.person : Icons.wifi_off)
              : Icons.close,
          color: player.isAlive
              ? theme.colorScheme.onSurface
              : AppColors.grey600,
          size: ResponsiveUtils.iconSize(context, 24),
        ),
      ),
    );
  }
}

class _PlayerNickname extends StatelessWidget {
  final Player player;
  final bool isMe;
  final Color identityColor;

  const _PlayerNickname({
    required this.player,
    required this.isMe,
    required this.identityColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.nickname + (isMe ? ' (나)' : ''),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
              decoration: player.isAlive ? null : TextDecoration.lineThrough,
              color: player.isAlive ? identityColor : AppColors.textMuted,
              fontSize: ResponsiveUtils.fontSize(context, 16),
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: player.isAlive
                      ? identityColor.withValues(alpha: 0.8)
                      : Colors.black,
                  blurRadius: player.isAlive ? 8 : 2,
                  offset: const Offset(0, 0),
                ),
                Shadow(
                  color: Colors.black.withValues(alpha: 0.9),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
          if (!player.isConnected && player.isAlive)
            Text(
              '연결 끊김',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orangeAccent,
                fontSize: ResponsiveUtils.fontSize(context, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _VoteBadge extends StatelessWidget {
  final int voteCount;
  final String votersList;
  const _VoteBadge({required this.voteCount, required this.votersList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentMagenta, AppColors.votePillEnd],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentMagenta.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            '$voteCount표',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.fontSize(context, 12),
            ),
          ),
        ),
        if (votersList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              votersList,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: ResponsiveUtils.fontSize(context, 11),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _DeadOverlay extends StatelessWidget {
  final Color deadColor;
  const _DeadOverlay({required this.deadColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.overlayBlack50,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💀', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: deadColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.dead,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: ResponsiveUtils.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MafiaIndicator extends StatelessWidget {
  final Color mafiaColor;
  const _MafiaIndicator({required this.mafiaColor});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: mafiaColor.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.people, color: Colors.white, size: 14),
      ),
    );
  }
}

class _PoliceLightEffect extends StatefulWidget {
  const _PoliceLightEffect();

  @override
  State<_PoliceLightEffect> createState() => _PoliceLightEffectState();
}

class _PoliceLightEffectState extends State<_PoliceLightEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned.fill(
          child: Stack(
            children: [
              // Flashing blue on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.policeBlue.withValues(
                          alpha: _animation.value * 0.5,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Flashing red on the right
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.policeRed.withValues(
                          alpha: (1.0 - _animation.value) * 0.5,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Overall pulse border
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  border: Border.all(
                    color: Color.lerp(
                      AppColors.policeBlue,
                      AppColors.policeRed,
                      _animation.value,
                    )!.withValues(alpha: 0.3 * _animation.value),
                    width: 4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RevealedRoleBadge extends StatelessWidget {
  final GameRole role;
  const _RevealedRoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color roleColor = Colors.grey;
    switch (role) {
      case GameRole.mafia:
        roleColor = AppColors.mafia;
        break;
      case GameRole.doctor:
        roleColor = AppColors.doctor;
        break;
      case GameRole.police:
        roleColor = AppColors.police;
        break;
      case GameRole.madman:
        roleColor = AppColors.madman;
        break;
      case GameRole.politician:
        roleColor = AppColors.politician;
        break;
      case GameRole.soldier:
        roleColor = AppColors.soldier;
        break;
      case GameRole.citizen:
        roleColor = AppColors.citizen;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        '${role.emoji} ${role.label}',
        style: TextStyle(
          color: roleColor,
          fontSize: ResponsiveUtils.fontSize(context, 10),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
