import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import 'role_reveal_modal.dart';

/// 게임 정보를 표시하는 Bottom Sheet
class GameInfoBottomSheet extends ConsumerWidget {
  const GameInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final myId = ref.watch(connectionProvider.notifier).socketId;
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;

    // 내 플레이어 정보 찾기
    final myPlayer = gameState.players.where((p) => p.id == myId).firstOrNull;
    final myNickname = myPlayer?.nickname ?? '알 수 없음';
    final isAlive = myPlayer?.isAlive ?? true;

    // 생존자 수 계산
    final aliveCount = gameState.players.where((p) => p.isAlive).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎮 게임 정보',
                      style: GoogleFonts.ibmPlexSansKr(
                        fontSize: ResponsiveUtils.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // 스크롤 가능한 컨텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 게임 현황 섹션 (1순위)
                      _buildSection(
                        context,
                        '📊 게임 현황',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.glass(
                            opacity: 0.05,
                            borderRadius: 12,
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                context,
                                '진행',
                                '${gameState.gamePhase.label} ${gameState.dayCount}일차',
                                gameState.gamePhase == GamePhase.day
                                    ? Colors.orangeAccent
                                    : AppColors.nightAccent,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                '전체 인원',
                                '${gameState.players.length}명',
                                Colors.white,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                '생존자',
                                '$aliveCount명',
                                Colors.greenAccent,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                '사망자',
                                '${gameState.players.length - aliveCount}명',
                                AppColors.dead,
                              ),
                              if (gameState.roleCounts.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white12, height: 1),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '게임 시작 시 직업 구성',
                                    style: GoogleFonts.ibmPlexSansKr(
                                      fontSize: ResponsiveUtils.fontSize(
                                        context,
                                        13,
                                      ),
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildRoleCountsGrid(
                                  context,
                                  gameState.roleCounts,
                                  gameTheme,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 내 정보 섹션 (2순위)
                      _buildSection(
                        context,
                        '👤 내 정보',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.glass(
                            opacity: 0.05,
                            borderRadius: 12,
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                context,
                                '닉네임',
                                myNickname,
                                Colors.white,
                              ),
                              const SizedBox(height: 12),
                              if (gameState.gamePhase != GamePhase.waiting &&
                                  gameState.myRole != null) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '직업',
                                      style: GoogleFonts.ibmPlexSansKr(
                                        fontSize: ResponsiveUtils.fontSize(
                                          context,
                                          14,
                                        ),
                                        color: Colors.white54,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${_getRoleEmoji(gameState.myRole!)} ${gameState.myRole!.label}',
                                          style: GoogleFonts.ibmPlexSansKr(
                                            fontSize: ResponsiveUtils.fontSize(
                                              context,
                                              14,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            color: gameTheme.getRoleColor(
                                              gameState.myRole,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  RoleRevealModal(
                                                    role: gameState.myRole!,
                                                    onDismiss: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                  ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: gameTheme
                                                  .getRoleColor(
                                                    gameState.myRole,
                                                  )
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: gameTheme
                                                    .getRoleColor(
                                                      gameState.myRole,
                                                    )
                                                    .withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.info_outline,
                                              size: ResponsiveUtils.iconSize(
                                                context,
                                                16,
                                              ),
                                              color: gameTheme
                                                  .getRoleColor(
                                                    gameState.myRole,
                                                  )
                                                  .withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              _buildInfoRow(
                                context,
                                '상태',
                                isAlive ? '생존' : '사망',
                                isAlive ? Colors.greenAccent : AppColors.dead,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 방 번호 섹션 (3순위)
                      _buildSection(
                        context,
                        '🔑 방 번호',
                        child: GestureDetector(
                          onTap: () {
                            if (gameState.roomId != null) {
                              Clipboard.setData(
                                ClipboardData(text: gameState.roomId!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('복사됨: ${gameState.roomId}'),
                                  behavior: SnackBarBehavior.floating,
                                  width: 200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppDecorations.glass(
                              opacity: 0.1,
                              borderRadius: 12,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  gameState.roomId ?? '알 수 없음',
                                  style: GoogleFonts.ibmPlexSansKr(
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      18,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Icon(
                                  Icons.copy,
                                  color: AppColors.primary,
                                  size: ResponsiveUtils.iconSize(context, 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 게임 설정 섹션 (4순위)
                      _buildSection(
                        context,
                        '⚙️ 게임 설정',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.glass(
                            opacity: 0.05,
                            borderRadius: 12,
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                context,
                                '낮 시간',
                                gameState.gameSettings.dayDuration == 0
                                    ? '무제한'
                                    : '${gameState.gameSettings.dayDuration}초',
                                Colors.white70,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                '밤 시간',
                                gameState.gameSettings.nightDuration == 0
                                    ? '무제한'
                                    : '${gameState.gameSettings.nightDuration}초',
                                Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: ResponsiveUtils.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: ResponsiveUtils.fontSize(context, 14),
            color: Colors.white54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: ResponsiveUtils.fontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCountsGrid(
    BuildContext context,
    Map<String, int> roleCounts,
    GameThemeExtension gameTheme,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildRoleCountItem(
          context,
          GameRole.mafia.label,
          roleCounts[GameRole.mafia.name] ?? 0,
          gameTheme.mafiaRef,
        ),
        _buildRoleCountItem(
          context,
          GameRole.doctor.label,
          roleCounts[GameRole.doctor.name] ?? 0,
          gameTheme.doctorRef,
        ),
        _buildRoleCountItem(
          context,
          GameRole.police.label,
          roleCounts[GameRole.police.name] ?? 0,
          gameTheme.policeRef,
        ),
        _buildRoleCountItem(
          context,
          GameRole.citizen.label,
          roleCounts[GameRole.citizen.name] ?? 0,
          gameTheme.citizenRef,
        ),
      ],
    );
  }

  Widget _buildRoleCountItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: ResponsiveUtils.fontSize(context, 12),
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: ResponsiveUtils.fontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
