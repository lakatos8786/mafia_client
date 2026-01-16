import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../widgets/particle_background.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/noir_design.dart';
import '../theme/app_strings.dart';
import '../widgets/custom_snackbar.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../utils/responsive_utils.dart';
import '../widgets/common/noir_button.dart';
import '../widgets/common/noir_card.dart';
import '../widgets/common/noir_badge.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final myId = ref.watch(connectionProvider.notifier).socketId;

    return Scaffold(
      backgroundColor: NoirColors.backgroundBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '방 번호: ${gameState.roomId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: NoirColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: NoirColors.textSecondary),
            onPressed: () {
              if (gameState.roomId != null) {
                Clipboard.setData(ClipboardData(text: gameState.roomId!));
                CustomSnackBar.show(context, '복사됨: ${gameState.roomId}');
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ParticleBackground(phase: GamePhase.day),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUtils.spacing(context, 100)),
                  FadeInDown(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 24),
                      ),
                      child: Text(
                        '플레이어 대기 중...',
                        style: GoogleFonts.gowunDodum(
                          color: NoirColors.textPrimary,
                          fontSize: ResponsiveUtils.fontSize(context, 18),
                          letterSpacing: ResponsiveUtils.spacing(context, 4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 20),
                      ),
                      itemCount: gameState.players.length,
                      itemBuilder: (context, index) {
                        final player = gameState.players[index];
                        final isMe = player.id == myId;

                        return FadeInLeft(
                          delay: Duration(milliseconds: 100 * index),
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveUtils.spacing(context, 12),
                            ),
                            child: NoirCard(
                              variant: isMe
                                  ? NoirCardVariant.light
                                  : NoirCardVariant.base,
                              elevation: NoirCardElevation.subtle,
                              hasCrimsonGlow: isMe,
                              hasCrimsonBorder: isMe,
                              padding: ResponsiveUtils.padding(context, 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isMe
                                          ? '${player.nickname} (나)'
                                          : player.nickname,
                                      style: GoogleFonts.gowunDodum(
                                        color: NoirColors.textPrimary,
                                        fontSize: ResponsiveUtils.fontSize(
                                          context,
                                          16,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (player.isHost)
                                    NoirBadge(
                                      text: '방장',
                                      type: NoirBadgeType.crimson,
                                      icon: Icons.stars,
                                    ),
                                  if (gameState.isAdmin && !isMe)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: NoirColors.crimson,
                                        size: ResponsiveUtils.iconSize(
                                          context,
                                          20,
                                        ),
                                      ),
                                      onPressed: () => _showKickConfirmation(
                                        context,
                                        ref,
                                        player,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 16)),
                  _buildSettingsSection(context, ref, gameState, myId),
                  SizedBox(height: ResponsiveUtils.spacing(context, 32)),
                  // Start Button
                  if (gameState.roomId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Builder(
                        builder: (context) {
                          final isHost = gameState.players.any(
                            (p) => p.id == myId && p.isHost,
                          );
                          if (isHost) {
                            return Center(
                              child: NoirButton(
                                text: AppStrings.startGame,
                                onPressed: () {
                                  ref.read(actionProvider.notifier).startGame();
                                },
                                style: NoirButtonStyle.primary,
                                fullWidth: true,
                              ),
                            );
                          } else {
                            return Center(
                              child: NoirBadge(
                                text: AppStrings.waitingForHost,
                                type: NoirBadgeType.info,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showKickConfirmation(
    BuildContext context,
    WidgetRef ref,
    Player target,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NoirColors.backgroundRaised,
          title: Text(
            '플레이어 강퇴',
            style: GoogleFonts.gowunDodum(color: NoirColors.textPrimary),
          ),
          content: Text(
            '${target.nickname}님을 강퇴하시겠습니까?',
            style: GoogleFonts.gowunDodum(color: NoirColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: GoogleFonts.gowunDodum(color: NoirColors.textTertiary),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(actionProvider.notifier).kickPlayer(target.id);
                Navigator.of(context).pop();
              },
              child: Text(
                '강퇴',
                style: GoogleFonts.gowunDodum(
                  color: NoirColors.crimson,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoirDesign.radiusLarge),
            side: BorderSide(color: NoirColors.border),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    GameState gameState,
    String? myId,
  ) {
    final isHost = gameState.players.any((p) => p.id == myId && p.isHost);
    final GameSettings settings = gameState.gameSettings;

    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.padding(context, 20),
        ),
        padding: EdgeInsets.all(ResponsiveUtils.padding(context, 16)),
        decoration: BoxDecoration(
          color: NoirColors.surface,
          borderRadius: BorderRadius.circular(NoirDesign.radiusLarge),
          border: Border.all(color: NoirColors.border),
          boxShadow: NoirShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: NoirColors.textSecondary,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, 10)),
                Text(
                  '방 규칙 설정 ${isHost ? '(관리자)' : ''}',
                  style: GoogleFonts.gowunDodum(
                    color: NoirColors.textPrimary,
                    fontSize: ResponsiveUtils.fontSize(
                      context,
                      19,
                    ), // Increased from 18
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, 20)),
            // Time Section
            _buildSectionHeader('🕒 시간 설정'),
            const SizedBox(height: 16),
            _buildSettingRow(
              '낮 시간',
              settings.dayDuration == 0 ? '무제한' : '${settings.dayDuration}초',
              isHost,
              settings.dayDuration.toDouble(),
              0,
              180,
              settings.dayDuration == 0,
              (val) {
                ref
                    .read(actionProvider.notifier)
                    .updateSettings(
                      settings.copyWith(dayDuration: val.toInt()),
                    );
              },
              (unlimited) {
                ref
                    .read(actionProvider.notifier)
                    .updateSettings(
                      settings.copyWith(dayDuration: unlimited ? 0 : 60),
                    );
              },
              defaultValue: '60초',
            ),
            const SizedBox(height: 12),
            _buildSettingRow(
              '밤 시간',
              settings.nightDuration == 0
                  ? '무제한'
                  : '${settings.nightDuration}초',
              isHost,
              settings.nightDuration.toDouble(),
              0,
              120,
              settings.nightDuration == 0,
              (val) {
                ref
                    .read(actionProvider.notifier)
                    .updateSettings(
                      settings.copyWith(nightDuration: val.toInt()),
                    );
              },
              (unlimited) {
                ref
                    .read(actionProvider.notifier)
                    .updateSettings(
                      settings.copyWith(nightDuration: unlimited ? 0 : 30),
                    );
              },
              defaultValue: '30초',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.white12, height: 1),
            ),
            // Role Section
            _buildSectionHeader('👥 직업 구성'),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final playerCount = gameState.players.length;
                final isAuto = settings.mafiaCount == null;

                // Auto role count prediction (mirroring server index.js)
                final autoCounts = _getAutoRoleCounts(playerCount);

                final totalManualRoles =
                    (settings.mafiaCount ?? 0) +
                    (settings.policeCount ?? 0) +
                    (settings.doctorCount ?? 0);
                final canIncrease = totalManualRoles < playerCount;

                return Column(
                  children: [
                    if (isHost)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            const Text(
                              '자동 직업 배정',
                              style: TextStyle(
                                color: NoirColors.textTertiary,
                                fontSize: 13,
                              ),
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
                                      CustomSnackBar.show(
                                        context,
                                        '참여 인원수를 초과할 수 없습니다.',
                                      );
                                      return;
                                    }
                                    ref
                                        .read(actionProvider.notifier)
                                        .updateSettings(
                                          settings.copyWith(
                                            mafiaCount: val
                                                ? null
                                                : autoCounts['mafia'],
                                            policeCount: val
                                                ? null
                                                : autoCounts['police'],
                                            doctorCount: val
                                                ? null
                                                : autoCounts['doctor'],
                                            clearMafia: val,
                                            clearPolice: val,
                                            clearDoctor: val,
                                          ),
                                        );
                                  },
                                  activeThumbColor: NoirColors.crimson,
                                  activeTrackColor: NoirColors.crimson
                                      .withValues(alpha: 0.3),
                                  inactiveThumbColor: NoirColors.textSecondary,
                                  inactiveTrackColor: NoirColors.border,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: ResponsiveUtils.spacing(context, 8),
                      runSpacing: ResponsiveUtils.spacing(context, 12),
                      children: [
                        _buildRoleCounter(
                          context,
                          '🕶️ 마피아',
                          settings.mafiaCount,
                          isHost,
                          canIncrease,
                          autoCounts['mafia']!,
                          isAuto, // Pass isAuto to disable if global auto is on
                          (val) {
                            ref
                                .read(actionProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(
                                    mafiaCount: val,
                                    clearMafia: val == null,
                                  ),
                                );
                          },
                        ),
                        _buildRoleCounter(
                          context,
                          '🚨 경찰',
                          settings.policeCount,
                          isHost,
                          canIncrease,
                          autoCounts['police']!,
                          isAuto, // Pass isAuto to disable if global auto is on
                          (val) {
                            ref
                                .read(actionProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(
                                    policeCount: val,
                                    clearPolice: val == null,
                                  ),
                                );
                          },
                        ),
                        _buildRoleCounter(
                          context,
                          '💉 의사',
                          settings.doctorCount,
                          isHost,
                          canIncrease,
                          autoCounts['doctor']!,
                          isAuto, // Pass isAuto to disable if global auto is on
                          (val) {
                            ref
                                .read(actionProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(
                                    doctorCount: val,
                                    clearDoctor: val == null,
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getAutoRoleCounts(int playerCount) {
    int mafia = 1;
    int police = 1;
    int doctor = 1;

    if (playerCount < 5) {
      if (playerCount == 1) {
        mafia = 1;
        police = 0;
        doctor = 0;
      } else if (playerCount == 2) {
        mafia = 1;
        police = 0;
        doctor = 0;
      } else if (playerCount == 3) {
        mafia = 1;
        police = 1;
        doctor = 0;
      } else if (playerCount == 4) {
        mafia = 1;
        police = 1;
        doctor = 1;
      }
    } else {
      if (playerCount == 5) {
        mafia = 1;
      } else if (playerCount >= 6 && playerCount <= 8) {
        mafia = 2;
      } else if (playerCount >= 9 && playerCount <= 12) {
        mafia = 3;
      } else if (playerCount >= 13) {
        // High level balance (following server pattern)
        mafia = (playerCount / 4).floor();
      }
    }
    return {'mafia': mafia, 'police': police, 'doctor': doctor};
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) {
        return Text(
          title,
          style: GoogleFonts.gowunDodum(
            color: Colors.white70,
            fontSize: ResponsiveUtils.fontSize(
              context,
              16,
            ), // Increased from 15
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        );
      },
    );
  }

  Widget _buildSettingRow(
    String label,
    String valueText,
    bool isHost,
    double value,
    double min,
    double max,
    bool isUnlimited,
    ValueChanged<double> onChanged,
    ValueChanged<bool> onToggleUnlimited, {
    String? defaultValue,
  }) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (defaultValue != null) ...[
                          SizedBox(width: ResponsiveUtils.spacing(context, 6)),
                          Text(
                            '(기본 $defaultValue)',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: ResponsiveUtils.fontSize(context, 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isHost) ...[
                      SizedBox(height: ResponsiveUtils.spacing(context, 3)),
                      Row(
                        children: [
                          Text(
                            '무제한',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: ResponsiveUtils.fontSize(context, 11),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            height: 24,
                            width: 40,
                            child: Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isUnlimited,
                                onChanged: onToggleUnlimited,
                                activeThumbColor: NoirColors.crimson,
                                activeTrackColor: NoirColors.crimson.withValues(
                                  alpha: 0.3,
                                ),
                                inactiveThumbColor: NoirColors.textTertiary,
                                inactiveTrackColor: NoirColors.borderDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.padding(context, 8),
                    vertical: ResponsiveUtils.padding(context, 3),
                  ),
                  decoration: BoxDecoration(
                    color: isUnlimited
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    valueText,
                    style: TextStyle(
                      color: isUnlimited ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.fontSize(context, 15),
                    ),
                  ),
                ),
              ],
            ),
            if (isHost)
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: isUnlimited
                      ? SliderComponentShape.noThumb
                      : const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: isUnlimited
                      ? SliderComponentShape.noOverlay
                      : const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: isUnlimited
                      ? NoirColors.borderDim
                      : NoirColors.crimson,
                  inactiveTrackColor: NoirColors.borderDim,
                  thumbColor: NoirColors.crimson,
                  overlayColor: NoirColors.crimson.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: isUnlimited ? max : value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: max > min ? (max - min) ~/ 10 : null,
                  onChanged: isUnlimited ? null : onChanged,
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildRoleCounter(
    BuildContext context,
    String label,
    int? count,
    bool isHost,
    bool canIncrease,
    int predictedCount,
    bool isGlobalAuto,
    ValueChanged<int?> onChanged,
  ) {
    final int currentCount = count ?? predictedCount;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(context, 14),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isHost) const SizedBox(height: 12),
        if (isHost)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMinibutton(
                '-',
                isGlobalAuto
                    ? null
                    : () {
                        if (currentCount > 0) onChanged(currentCount - 1);
                      },
              ),
              Container(
                width: ResponsiveUtils.iconSize(context, 32),
                alignment: Alignment.center,
                child: Text(
                  currentCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isGlobalAuto ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                  ),
                ),
              ),
              _buildMinibutton(
                '+',
                isGlobalAuto
                    ? null
                    : () {
                        if (!canIncrease) {
                          CustomSnackBar.show(context, '참여 인원수를 초과할 수 없습니다.');
                          return;
                        }
                        onChanged(currentCount + 1);
                      },
              ),
            ],
          )
        else
          Container(
            margin: EdgeInsets.only(top: ResponsiveUtils.spacing(context, 6)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.padding(context, 10),
              vertical: ResponsiveUtils.padding(context, 5),
            ),
            decoration: BoxDecoration(
              color: isGlobalAuto
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isGlobalAuto ? '자동 ($currentCount)' : currentCount.toString(),
              style: TextStyle(
                color: isGlobalAuto ? Colors.white38 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.fontSize(context, 15),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMinibutton(String label, VoidCallback? onPressed) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: onPressed,
          child: Opacity(
            opacity: onPressed == null ? 0.3 : 1.0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.padding(context, 6),
                vertical: ResponsiveUtils.padding(context, 3),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
