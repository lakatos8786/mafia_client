import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../theme/noir_design.dart';
import '../theme/app_strings.dart';
import '../utils/responsive_utils.dart';
import 'phase_timer.dart';
import 'role_reveal_modal.dart';

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
        setState(() {
          _isRoleVisible = false;
        });
      }
    });
  }

  void _onRoleTap() {
    final myRole = ref.read(gameStateProvider.select((s) => s.myRole));

    // Show role for 5 seconds
    setState(() {
      _isRoleVisible = true;
    });
    _startHideTimer();

    // Show role reveal modal
    if (myRole != null) {
      showDialog(
        context: context,
        builder: (context) => RoleRevealModal(
          role: myRole,
          onDismiss: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final dayCount = ref.watch(gameStateProvider.select((s) => s.dayCount));
    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));
    final roleCountCompact = ref.watch(
      gameStateProvider.select((s) => s.roleCountCompact),
    );

    final isNight = gamePhase == GamePhase.night;
    final topPadding = MediaQuery.of(context).padding.top;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.only(
          top: ResponsiveUtils.verticalPadding(context, 10) + topPadding,
          bottom: ResponsiveUtils.verticalPadding(context, 10),
          left: ResponsiveUtils.horizontalPadding(context, 16),
          right: ResponsiveUtils.horizontalPadding(context, 16),
        ),
        decoration: BoxDecoration(
          color: isNight
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row: Phase + Timer and My Role
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Phase + Timer
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.padding(context, 12),
                            vertical: ResponsiveUtils.padding(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: isNight
                                ? NoirColors.surface.withValues(alpha: 0.8)
                                : NoirColors.surfaceLight.withValues(
                                    alpha: 0.6,
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isNight
                                  ? NoirColors.border
                                  : NoirColors.borderDim,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gamePhase == GamePhase.day
                                    ? Icons.wb_sunny
                                    : Icons.nightlight_round,
                                color: isNight
                                    ? NoirColors.textSecondary
                                    : NoirColors.backgroundDeep,
                                size: ResponsiveUtils.iconSize(context, 20),
                              ),
                              SizedBox(
                                width: ResponsiveUtils.spacing(context, 6),
                              ),
                              Flexible(
                                child: Text(
                                  '${gamePhase.label} $dayCount일차',
                                  style: GoogleFonts.gowunDodum(
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      16,
                                    ), // Increased from 14
                                    fontWeight: FontWeight.w900,
                                    color: isNight
                                        ? NoirColors.textPrimary
                                        : NoirColors.backgroundDeep,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                      const PhaseTimer(),
                    ],
                  ),
                ),

                SizedBox(width: ResponsiveUtils.spacing(context, 12)),

                // Right side: My Role Badge (compact)
                Flexible(
                  child: GestureDetector(
                    onTap: _onRoleTap,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey(_isRoleVisible),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.padding(context, 12),
                          vertical: ResponsiveUtils.padding(context, 6),
                        ),
                        decoration: BoxDecoration(
                          color: _isRoleVisible
                              ? _getRoleColor(myRole).withValues(alpha: 0.2)
                              : (isNight
                                    ? NoirColors.surface.withValues(alpha: 0.8)
                                    : NoirColors.surfaceLight.withValues(
                                        alpha: 0.6,
                                      )),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isRoleVisible
                                ? _getRoleColor(myRole).withValues(alpha: 0.4)
                                : (isNight
                                      ? NoirColors.border
                                      : NoirColors.borderDim),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isRoleVisible ? _getRoleEmoji(myRole) : '❓',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 14),
                                fontWeight: FontWeight.w900,
                                color: isNight
                                    ? NoirColors.textPrimary
                                    : NoirColors.backgroundDeep,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveUtils.spacing(context, 6),
                            ),
                            Flexible(
                              child: Text(
                                _isRoleVisible
                                    ? (myRole?.label ?? AppStrings.unknownRole)
                                    : '직업 확인',
                                style: GoogleFonts.gowunDodum(
                                  color: isNight
                                      ? NoirColors.textPrimary
                                      : NoirColors.backgroundDeep,
                                  fontSize: ResponsiveUtils.fontSize(
                                    context,
                                    14,
                                  ), // Increased from 13
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Second row: Role Counts (compact)
            if (roleCountCompact.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveUtils.spacing(context, 8),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.padding(context, 8),
                    vertical: ResponsiveUtils.padding(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: isNight
                        ? NoirColors.surface.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isNight ? NoirColors.border : NoirColors.borderDim,
                      width: 1.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: roleCountCompact.asMap().entries.map((entry) {
                        final index = entry.key;
                        final displayString = entry.value;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: index > 0
                                ? ResponsiveUtils.spacing(context, 6)
                                : 0,
                          ),
                          child: Text(
                            displayString,
                            style: GoogleFonts.gowunDodum(
                              color: isNight
                                  ? NoirColors.textSecondary.withValues(
                                      alpha: 0.8,
                                    )
                                  : NoirColors.borderBright.withValues(
                                      alpha: 0.9,
                                    ),
                              fontSize: ResponsiveUtils.fontSize(
                                context,
                                13,
                              ), // Increased from 12
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return NoirColors.crimson;
      default:
        return NoirColors.textSecondary;
    }
  }

  String _getRoleEmoji(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return '🕶️'; // Sunglasses - cool and mysterious
      case GameRole.doctor:
        return '💉'; // Syringe
      case GameRole.police:
        return '🚨'; // Police siren
      case GameRole.citizen:
        return '👤'; // Person silhouette
      default:
        return '❓'; // Question mark for unknown
    }
  }
}
