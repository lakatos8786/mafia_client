import 'dart:ui';
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
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../widgets/neon_toast.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../utils/responsive_utils.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final myId = ref.watch(connectionProvider.notifier).socketId;

    // Listen for server errors
    ref.listen(gameStateProvider.select((s) => s.lastErrorTime), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        final errorMsg = ref.read(gameStateProvider).errorMessage;
        if (errorMsg != null) {
          NeonToast.show(context, AppStrings.localizedError(errorMsg));
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '방 번호: ${gameState.roomId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.mafiaRed),
            onPressed: () {
              if (gameState.roomId != null) {
                Clipboard.setData(ClipboardData(text: gameState.roomId!));
                NeonToast.show(context, '복사됨: ${gameState.roomId}');
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
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 150,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUtils.spacing(context, 50)),
                  FadeInDown(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 24),
                      ),
                      child: Text(
                        '플레이어 대기 중...',
                        style: GoogleFonts.ibmPlexSansKr(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: ResponsiveUtils.fontSize(
                            context,
                            18,
                          ), // Increased from 16
                          letterSpacing: ResponsiveUtils.spacing(context, 4),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 24)),
                  FadeIn(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.padding(context, 24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.white70,
                            size: ResponsiveUtils.iconSize(context, 16),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                          Text(
                            '참가자',
                            style: GoogleFonts.ibmPlexSansKr(
                              color: Colors.white70,
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing(context, 6)),
                          Text(
                            '${gameState.players.length}',
                            style: GoogleFonts.ibmPlexSansKr(
                              color: AppColors.primary,
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: ResponsiveUtils.spacing(context, 120),
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
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
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: ResponsiveUtils.spacing(context, 10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Opacity(
                                  opacity: player.atLobby ? 1.0 : 0.5,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.padding(
                                        context,
                                        16,
                                      ),
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppColors.primary.withValues(
                                              alpha: 0.2,
                                            )
                                          : Colors.white.withValues(
                                              alpha: 0.05,
                                            ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isMe
                                            ? AppColors.primary.withValues(
                                                alpha: 0.6,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                        width: isMe ? 1.5 : 1.0,
                                      ),
                                      boxShadow: isMe
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 15,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: isMe
                                              ? AppColors.primary
                                              : Colors.white12,
                                          foregroundColor: Colors.white,
                                          child: const Icon(Icons.person),
                                        ),
                                        SizedBox(
                                          width: ResponsiveUtils.spacing(
                                            context,
                                            12,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            player.nickname,
                                            style: GoogleFonts.ibmPlexSansKr(
                                              fontSize:
                                                  ResponsiveUtils.fontSize(
                                                    context,
                                                    16,
                                                  ), // Increased from 15
                                              fontWeight: FontWeight.bold,
                                              color: player.isAlive
                                                  ? Colors.white
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        if (!player.atLobby)
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: ResponsiveUtils.spacing(
                                                context,
                                                8,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            child: Text(
                                              '결과 확인 중...',
                                              style: GoogleFonts.ibmPlexSansKr(
                                                fontSize:
                                                    ResponsiveUtils.fontSize(
                                                      context,
                                                      12,
                                                    ), // Increased from 10
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                        if (player.isHost)
                                          Tooltip(
                                            message: '방장',
                                            child: Text(
                                              '👑',
                                              style: TextStyle(
                                                fontSize:
                                                    ResponsiveUtils.fontSize(
                                                      context,
                                                      20,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        if (isMe)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: ResponsiveUtils.spacing(
                                                context,
                                                8,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.star,
                                              color: AppColors.accentYellow,
                                              size: ResponsiveUtils.iconSize(
                                                context,
                                                18,
                                              ),
                                            ),
                                          ),
                                        if (gameState.isAdmin && !isMe)
                                          IconButton(
                                            icon: Icon(
                                              Icons.logout,
                                              color: AppColors.mafiaRed,
                                              size: ResponsiveUtils.iconSize(
                                                context,
                                                18,
                                              ),
                                            ),
                                            onPressed: () {
                                              _showKickConfirmation(
                                                context,
                                                ref,
                                                player,
                                              );
                                            },
                                            tooltip: '강퇴',
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                  _buildSettingsSection(context, ref, gameState, myId),

                  FadeInUp(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveUtils.padding(context, 24),
                        ResponsiveUtils.padding(context, 24),
                        ResponsiveUtils.padding(context, 24),
                        ResponsiveUtils.padding(context, 32), // 하단 여백 추가
                      ),
                      child: _buildStartButton(context, ref, gameState, myId),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    WidgetRef ref,
    GameState gameState,
    String? myId,
  ) {
    if (gameState.roomId == null) return const SizedBox.shrink();

    final isHost = gameState.players.any((p) => p.id == myId && p.isHost);
    if (isHost) {
      final anyoneReviewing = gameState.players.any((p) => !p.atLobby);

      return Column(
        children: [
          if (anyoneReviewing)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '일부 플레이어가 아직 결과를 확인 중입니다.',
                style: GoogleFonts.ibmPlexSansKr(
                  color: AppColors.mafiaRed.withValues(alpha: 0.8),
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: ResponsiveUtils.iconSize(context, 50),
            child: ElevatedButton(
              onPressed: anyoneReviewing
                  ? null
                  : () => ref.read(actionProvider.notifier).startGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white24,
                elevation: anyoneReviewing ? 0 : 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                AppStrings.startGame,
                style: GoogleFonts.ibmPlexSansKr(
                  fontSize: ResponsiveUtils.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  letterSpacing: ResponsiveUtils.spacing(context, 2),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(ResponsiveUtils.padding(context, 10)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          AppStrings.waitingForHost,
          style: GoogleFonts.ibmPlexSansKr(
            color: Colors.white54,
            fontSize: ResponsiveUtils.fontSize(context, 14),
            letterSpacing: ResponsiveUtils.spacing(context, 1.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
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
          backgroundColor: AppColors.backgroundDark,
          title: Text(
            '플레이어 강퇴',
            style: GoogleFonts.ibmPlexSansKr(color: Colors.white),
          ),
          content: Text(
            '${target.nickname}님을 강퇴하시겠습니까?',
            style: GoogleFonts.ibmPlexSansKr(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: GoogleFonts.ibmPlexSansKr(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(actionProvider.notifier).kickPlayer(target.id);
                Navigator.of(context).pop();
              },
              child: Text(
                '강퇴',
                style: GoogleFonts.ibmPlexSansKr(color: AppColors.mafiaRed),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.white10),
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
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            _buildSectionHeader(context, '🕒 시간 설정'),
            SizedBox(height: ResponsiveUtils.spacing(context, 20)),
            _buildSettingRow(
              context,
              ref,
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
            SizedBox(height: ResponsiveUtils.spacing(context, 20)),
            _buildSettingRow(
              context,
              ref,
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
            const Divider(color: Colors.white12, height: 40),
            // Role Section
            _buildSectionHeader(context, '👥 직업 구성'),
            SizedBox(height: ResponsiveUtils.spacing(context, 20)),
            () {
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
                              color: Colors.white70,
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
                                    NeonToast.show(
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
                  Column(
                    children: [
                      _buildRoleCounter(
                        context,
                        '🕶️ 마피아',
                        settings.mafiaCount,
                        isHost,
                        canIncrease,
                        autoCounts['mafia']!,
                        isAuto,
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
                      SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                      _buildRoleCounter(
                        context,
                        '🚨 경찰',
                        settings.policeCount,
                        isHost,
                        canIncrease,
                        autoCounts['police']!,
                        isAuto,
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
                      SizedBox(height: ResponsiveUtils.spacing(context, 12)),
                      _buildRoleCounter(
                        context,
                        '💉 의사',
                        settings.doctorCount,
                        isHost,
                        canIncrease,
                        autoCounts['doctor']!,
                        isAuto,
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
            }(),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexSansKr(
        color: Colors.white70,
        fontSize: ResponsiveUtils.fontSize(context, 16),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    WidgetRef ref,
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
    return _SettingSlider(
      label: label,
      value: value,
      min: min,
      max: max,
      isUnlimited: isUnlimited,
      isHost: isHost,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onToggleUnlimited: onToggleUnlimited,
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

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(context, 15),
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, 12)),
        if (isHost)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMinibutton(
                context,
                '-',
                isGlobalAuto
                    ? null
                    : () {
                        if (currentCount > 0) onChanged(currentCount - 1);
                      },
              ),
              Container(
                width: ResponsiveUtils.iconSize(context, 40),
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
                context,
                '+',
                isGlobalAuto
                    ? null
                    : () {
                        if (!canIncrease) {
                          NeonToast.show(context, '참여 인원수를 초과할 수 없습니다.');
                          return;
                        }
                        onChanged(currentCount + 1);
                      },
              ),
            ],
          )
        else
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.padding(context, 12),
              vertical: ResponsiveUtils.padding(context, 6),
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

  Widget _buildMinibutton(
    BuildContext context,
    String label,
    VoidCallback? onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.3 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.padding(context, 10),
            vertical: ResponsiveUtils.padding(context, 5),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
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
  }
}

class _SettingSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final bool isUnlimited;
  final bool isHost;
  final String? defaultValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool> onToggleUnlimited;

  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.isUnlimited,
    required this.isHost,
    this.defaultValue,
    required this.onChanged,
    required this.onToggleUnlimited,
  });

  @override
  State<_SettingSlider> createState() => _SettingSliderState();
}

class _SettingSliderState extends State<_SettingSlider> {
  late double _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(_SettingSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 값이 변경되었을 때만 로컬 값을 동기화 (예: 다른 플레이어가 변경)
    if (oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueText = widget.isUnlimited
        ? '무제한'
        : _localValue == 0
        ? '무제한'
        : '${_localValue.toInt()}초';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ),
                    if (widget.defaultValue != null) ...[
                      SizedBox(width: ResponsiveUtils.spacing(context, 8)),
                      Text(
                        '(기본 ${widget.defaultValue})',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.isHost) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, 6)),
                  Row(
                    children: [
                      Text(
                        '무제한',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 24,
                        width: 40,
                        child: Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: widget.isUnlimited,
                            onChanged: widget.onToggleUnlimited,
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
                ],
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.padding(context, 8),
                vertical: ResponsiveUtils.padding(context, 3),
              ),
              decoration: BoxDecoration(
                color: widget.isUnlimited
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueText,
                style: TextStyle(
                  color: widget.isUnlimited ? Colors.white38 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.fontSize(context, 15),
                ),
              ),
            ),
          ],
        ),
        if (widget.isHost) ...[
          SizedBox(height: ResponsiveUtils.spacing(context, 12)),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: widget.isUnlimited
                  ? SliderComponentShape.noThumb
                  : const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: widget.isUnlimited
                  ? SliderComponentShape.noOverlay
                  : const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: widget.isUnlimited
                  ? Colors.white10
                  : AppColors.primary,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: widget.isUnlimited
                  ? widget.max
                  : _localValue.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              divisions: widget.max > widget.min
                  ? (widget.max - widget.min) ~/ 10
                  : null,
              onChanged: widget.isUnlimited
                  ? null
                  : (val) {
                      setState(() {
                        _localValue = val;
                      });
                    },
              onChangeEnd: (val) {
                widget.onChanged(val);
              },
            ),
          ),
        ] else
          const SizedBox(height: 10),
      ],
    );
  }
}
