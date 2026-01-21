import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_enums.dart';
import '../../models/game_settings.dart';
import '../../providers/action_provider.dart';
import '../../providers/game_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../neon_toast.dart';
import '../role_reveal_modal.dart';

/// 로비 설정 시트
///
/// [Optimization]
/// 1. Fixed Height Modal (No DraggableScrollableSheet) for smooth scrolling.
/// 2. ClampingScrollPhysics + cacheExtent for performance.
/// 3. Granular state watching to minimize rebuilds.
class LobbySettingsSheet extends ConsumerWidget {
  final String? myId;

  const LobbySettingsSheet({super.key, required this.myId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only necessary high-level state
    // We do NOT watch players here to avoid full sheet rebuild on join/leave.
    // Child sections will watch what they need.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetHeight = screenHeight * 0.8; // 80% screen height

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark, // Opaque for performance
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildHeader(context, ref),
          ),
          const Divider(color: Colors.white12, height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // [Optimization] Stable physics for desktop/web
              physics: const ClampingScrollPhysics(),
              cacheExtent: 500,
              children: [
                _buildSectionHeader(context, '🕒 시간 설정'),
                const SizedBox(height: 20),
                TimeSettingsSection(myId: myId),

                const SizedBox(height: 40),

                _buildSectionHeader(context, '👥 직업 구성'),
                const SizedBox(height: 20),
                RoleSettingsSection(myId: myId),

                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    // Only watch isHost for the title
    final isHost = ref.watch(
      gameStateProvider.select(
        (s) => s.players.any((p) => p.id == myId && p.isHost),
      ),
    );

    return Row(
      children: [
        Icon(
          Icons.settings,
          color: AppColors.primary,
          size: ResponsiveUtils.iconSize(context, 20),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 10)),
        Text(
          '방 규칙 설정 ${isHost ? '(관리자)' : ''}',
          style: GoogleFonts.ibmPlexSansKr(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(context, 19),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexSansKr(
          color: AppColors.textSecondary,
          fontSize: ResponsiveUtils.fontSize(context, 14),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TimeSettingsSection extends ConsumerWidget {
  final String? myId;

  const TimeSettingsSection({super.key, required this.myId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameStateProvider.select((s) => s.gameSettings));
    final isHost = ref.watch(
      gameStateProvider.select(
        (s) => s.players.any((p) => p.id == myId && p.isHost),
      ),
    );

    return Column(
      children: [
        OptimizedSliderRow(
          label: '낮 시간',
          value: settings.dayDuration.toDouble(),
          min: 0,
          max: 600,
          step: 30,
          isHost: isHost,
          isUnlimited: settings.dayDuration == 0,
          valueText: settings.dayDuration == 0
              ? '무제한'
              : '${settings.dayDuration}초',
          defaultValue: '4분',
          onChangeEnd: (val) {
            ref
                .read(actionProvider.notifier)
                .updateSettings(settings.copyWith(dayDuration: val.toInt()));
          },
          onUnlimitedChanged: (unlimited) {
            ref
                .read(actionProvider.notifier)
                .updateSettings(
                  settings.copyWith(dayDuration: unlimited ? 0 : 240),
                );
          },
        ),
        const SizedBox(height: 20),
        OptimizedSliderRow(
          label: '밤 시간',
          value: settings.nightDuration.toDouble(),
          min: 0,
          max: 120,
          step: 10,
          isHost: isHost,
          isUnlimited: settings.nightDuration == 0,
          valueText: settings.nightDuration == 0
              ? '무제한'
              : '${settings.nightDuration}초',
          defaultValue: '40초',
          onChangeEnd: (val) {
            ref
                .read(actionProvider.notifier)
                .updateSettings(settings.copyWith(nightDuration: val.toInt()));
          },
          onUnlimitedChanged: (unlimited) {
            ref
                .read(actionProvider.notifier)
                .updateSettings(
                  settings.copyWith(nightDuration: unlimited ? 0 : 40),
                );
          },
        ),
      ],
    );
  }
}

class OptimizedSliderRow extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final bool isHost;
  final bool isUnlimited;
  final String valueText;
  final String? defaultValue;
  final ValueChanged<double> onChangeEnd;
  final ValueChanged<bool> onUnlimitedChanged;

  const OptimizedSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.isHost,
    required this.isUnlimited,
    required this.valueText,
    this.defaultValue,
    required this.onChangeEnd,
    required this.onUnlimitedChanged,
  });

  @override
  State<OptimizedSliderRow> createState() => _OptimizedSliderRowState();
}

class _OptimizedSliderRowState extends State<OptimizedSliderRow> {
  late double _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant OptimizedSliderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _localValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.ibmPlexSansKr(
                color: Colors.white70,
                fontSize: ResponsiveUtils.fontSize(context, 16),
              ),
            ),
            Row(
              children: [
                if (widget.defaultValue != null) ...[
                  Text(
                    '기본: ${widget.defaultValue}',
                    style: GoogleFonts.ibmPlexSansKr(
                      color: Colors.white30,
                      fontSize: ResponsiveUtils.fontSize(context, 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  widget.isUnlimited
                      ? '무제한'
                      : '${_localValue.toInt()}초', // Use local value for display
                  style: GoogleFonts.ibmPlexSansKr(
                    color: AppColors.primary,
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.isHost) ...[
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white10,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _localValue,
                    min: widget.min,
                    max: widget.max,
                    divisions: (widget.max - widget.min) ~/ widget.step,
                    onChanged: widget.isUnlimited
                        ? null
                        : (val) {
                            setState(() {
                              _localValue = val;
                            });
                          },
                    onChangeEnd: (val) {
                      widget.onChangeEnd(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Checkbox(
                    value: widget.isUnlimited,
                    onChanged: (val) => widget.onUnlimitedChanged(val ?? false),
                    activeColor: AppColors.primary,
                    checkColor: AppColors.backgroundMain,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  GestureDetector(
                    onTap: () => widget.onUnlimitedChanged(!widget.isUnlimited),
                    child: Text(
                      '무제한',
                      style: GoogleFonts.ibmPlexSansKr(
                        color: widget.isUnlimited
                            ? Colors.white
                            : Colors.white38,
                        fontSize: ResponsiveUtils.fontSize(context, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ] else
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor:
                  (widget.value - widget.min) / (widget.max - widget.min),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class RoleSettingsSection extends ConsumerWidget {
  final String? myId;

  const RoleSettingsSection({super.key, required this.myId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameStateProvider.select((s) => s.gameSettings));
    final playersLength = ref.watch(
      gameStateProvider.select((s) => s.players.length),
    ); // Only watch length!
    final isHost = ref.watch(
      gameStateProvider.select(
        (s) => s.players.any((p) => p.id == myId && p.isHost),
      ),
    );

    final isAuto = settings.mafiaCount == null;
    final autoCounts = _getAutoRoleCounts(playersLength);

    final totalManualRoles =
        (settings.mafiaCount ?? 0) +
        (settings.policeCount ?? 0) +
        (settings.doctorCount ?? 0) +
        (settings.madmanCount ?? 0) +
        (settings.politicianCount ?? 0) +
        (settings.soldierCount ?? 0);
    final canIncrease = totalManualRoles < playersLength;

    return Column(
      children: [
        if (isHost)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                const Text(
                  '자동 직업 배정',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 24,
                  width: 40,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: isAuto,
                      onChanged: (val) {
                        if (!val && !canIncrease) {
                          NeonToast.show(context, '참여 인원수를 초과할 수 없습니다.');
                          return;
                        }
                        ref
                            .read(actionProvider.notifier)
                            .updateSettings(
                              settings.copyWith(
                                mafiaCount: val ? null : autoCounts['mafia'],
                                policeCount: val ? null : autoCounts['police'],
                                doctorCount: val ? null : autoCounts['doctor'],
                                madmanCount: val ? null : autoCounts['madman'],
                                politicianCount: val
                                    ? null
                                    : autoCounts['politician'],
                                soldierCount: val
                                    ? null
                                    : autoCounts['soldier'],
                                clearMafia: val,
                                clearPolice: val,
                                clearDoctor: val,
                                clearMadman: val,
                                clearPolitician: val,
                                clearSoldier: val,
                              ),
                            );
                      },
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(
                        alpha: 0.3,
                      ),
                      inactiveThumbColor: Colors.white38,
                      inactiveTrackColor: Colors.white10,
                    ),
                  ),
                ),
              ],
            ),
          ),

        _buildRoleCounter(
          context,
          ref,
          GameRole.mafia,
          settings.mafiaCount,
          autoCounts['mafia']!,
          isAuto,
          isHost,
          canIncrease,
          playersLength,
          settings,
        ),
        _buildRoleCounter(
          context,
          ref,
          GameRole.police,
          settings.policeCount,
          autoCounts['police']!,
          isAuto,
          isHost,
          canIncrease,
          playersLength,
          settings,
        ),
        _buildRoleCounter(
          context,
          ref,
          GameRole.doctor,
          settings.doctorCount,
          autoCounts['doctor']!,
          isAuto,
          isHost,
          canIncrease,
          playersLength,
          settings,
        ),
        _buildRoleCounter(
          context,
          ref,
          GameRole.soldier,
          settings.soldierCount,
          autoCounts['soldier']!,
          isAuto,
          isHost,
          canIncrease,
          playersLength,
          settings,
        ),
        _buildRoleCounter(
          context,
          ref,
          GameRole.politician,
          settings.politicianCount,
          autoCounts['politician']!,
          isAuto,
          isHost,
          canIncrease,
          playersLength,
          settings,
        ),
        _buildRoleCounter(
          context,
          ref,
          GameRole.madman,
          settings.madmanCount,
          autoCounts['madman']!,
          isAuto,
          isHost,
          canIncrease,
          playersLength,
          settings,
        ),
      ],
    );
  }

  Widget _buildRoleCounter(
    BuildContext context,
    WidgetRef ref,
    GameRole role,
    int? manualCount,
    int autoCount,
    bool isAuto,
    bool isHost,
    bool canIncrease,
    int totalPlayers,
    GameSettings settings,
  ) {
    final count = isAuto ? autoCount : (manualCount ?? 0);
    // Determine color based on role
    Color roleColor;
    switch (role) {
      case GameRole.mafia:
        roleColor = AppColors.mafia;
        break;
      case GameRole.police:
        roleColor = AppColors.police;
        break;
      case GameRole.doctor:
        roleColor = AppColors.doctor;
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
      default:
        roleColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Text(role.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      role.label,
                      style: GoogleFonts.ibmPlexSansKr(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.fontSize(context, 16),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Role Reveal',
                          barrierColor: Colors.black.withValues(alpha: 0.8),
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => RoleRevealModal(
                            role: role,
                            onDismiss: () => Navigator.of(context).pop(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.info_outline,
                          color: roleColor.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  isAuto ? '자동 배정' : '수동 설정',
                  style: GoogleFonts.ibmPlexSansKr(
                    color: Colors.white38,
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
          if (isHost && !isAuto)
            // Custom Increment/Decrement implementation to ensure visibility
            Row(
              children: [
                _buildCounterButton(
                  text: '-',
                  onTap: count > 0
                      ? () => _updateRoleCount(ref, role, count - 1, settings)
                      : null,
                  color: roleColor,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$count',
                    style: GoogleFonts.ibmPlexSansKr(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildCounterButton(
                  text: '+',
                  onTap: canIncrease
                      ? () => _updateRoleCount(ref, role, count + 1, settings)
                      : null,
                  color: roleColor,
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count명',
                style: GoogleFonts.ibmPlexSansKr(
                  color: isAuto ? Colors.white54 : roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required String text,
    required VoidCallback? onTap,
    required Color color,
  }) {
    final isDisabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDisabled ? Colors.white10 : color.withValues(alpha: 0.5),
            ),
            color: isDisabled
                ? Colors.transparent
                : color.withValues(alpha: 0.1),
          ),
          child: Text(
            text,
            style: GoogleFonts.ibmPlexSansKr(
              color: isDisabled ? Colors.white30 : color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _updateRoleCount(
    WidgetRef ref,
    GameRole role,
    int newCount,
    GameSettings settings,
  ) {
    GameSettings newSettings = settings;
    switch (role) {
      case GameRole.mafia:
        newSettings = settings.copyWith(mafiaCount: newCount);
        break;
      case GameRole.police:
        newSettings = settings.copyWith(policeCount: newCount);
        break;
      case GameRole.doctor:
        newSettings = settings.copyWith(doctorCount: newCount);
        break;
      case GameRole.madman:
        newSettings = settings.copyWith(madmanCount: newCount);
        break;
      case GameRole.politician:
        newSettings = settings.copyWith(politicianCount: newCount);
        break;
      case GameRole.soldier:
        newSettings = settings.copyWith(soldierCount: newCount);
        break;
      default:
        break;
    }
    ref.read(actionProvider.notifier).updateSettings(newSettings);
  }

  Map<String, int> _getAutoRoleCounts(int playerCount) {
    int mafia = 0;
    int madman = 0;
    int police = 0;
    int doctor = 0;
    int politician = 0;
    int soldier = 0;

    // 1. Mafia Team Distribution
    if (playerCount <= 5) {
      mafia = 1; // 1~5명: 마1
    } else if (playerCount <= 8) {
      mafia = 2; // 6~8명: 마2
    } else if (playerCount <= 11) {
      mafia = 2; // 9~11명: 마2, 미1
      madman = 1;
    } else if (playerCount <= 14) {
      mafia = 3; // 12~14명: 마3, 미1
      madman = 1;
    } else if (playerCount <= 17) {
      mafia = 4; // 15~17명: 마4, 미1
      madman = 1;
    } else if (playerCount <= 22) {
      mafia = 4; // 18~22명: 5명 (마4, 미1)
      madman = 1;
    } else if (playerCount <= 26) {
      mafia = 5; // 23~26명: 6명 (마5, 미1)
      madman = 1;
    } else if (playerCount <= 30) {
      mafia = 6; // 27~30명: 7명 (마6, 미1)
      madman = 1;
    } else {
      // 31명 이상: 마피아 팀(마피아+광인) 비율을 약 25%~28%로 유지
      // 마피아 = 인원/4, 광인 = 1
      // 예: 32명 -> 마8+광1=9명 (28.1%), 40명 -> 마10+광1=11명 (27.5%)
      mafia = playerCount ~/ 4;
      madman = 1;
    }

    // 2. Citizen Team Distribution (Strictly per User Table)

    // Police: 4+
    if (playerCount >= 4) {
      police = 1;
    }

    // Doctor: 6+
    if (playerCount >= 6) {
      doctor = 1;
    }

    // Soldier: 8, 9, and 11+ (EXCLUDED at 10)
    if ((playerCount >= 8 && playerCount <= 9) || playerCount >= 11) {
      soldier = 1;
    }

    // Politician: 10+
    if (playerCount >= 10) {
      politician = 1;
    }

    return {
      'mafia': mafia,
      'police': police,
      'doctor': doctor,
      'madman': madman,
      'politician': politician,
      'soldier': soldier,
    };
  }
}
