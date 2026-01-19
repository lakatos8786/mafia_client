import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import '../providers/game_state_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import 'role_reveal_modal.dart';
import 'neon_toast.dart';

/// 게임 정보를 표시하는 Bottom Sheet
class GameInfoBottomSheet extends ConsumerWidget {
  const GameInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 성능 최적화: 필요한 데이터만 선택적으로 구독
    final gameState = ref.watch(gameStateProvider);
    final myId = ref.watch(connectionProvider.notifier).socketId;
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;

    // 내 플레이어 정보 찾기
    final myPlayer = gameState.players.where((p) => p.id == myId).firstOrNull;
    final isAlive = myPlayer?.isAlive ?? true;

    // 생존자 수 계산
    final aliveCount = gameState.players.where((p) => p.isAlive).length;

    // ResponsiveUtils 스케일 팩터 캐싱
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    // 공통 텍스트 스타일 정의 (성능 최적화)
    final TextStyle headerStyle = GoogleFonts.ibmPlexSansKr(
      fontSize: 20 * scaleFactor,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(
          alpha: 0.98,
        ), // 블러 대신 높은 불투명도 사용
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 드래그 핸들 (고정)
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더 (고정)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🎮 게임 정보', style: headerStyle),
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
            child: RepaintBoundary(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 게임 현황 섹션
                  _GameStatusSection(
                    gameState: gameState,
                    aliveCount: aliveCount,
                    scaleFactor: scaleFactor,
                    gameTheme: gameTheme,
                  ),

                  const SizedBox(height: 24),

                  // 내 정보 섹션
                  _MyInfoSection(
                    myNickname: myPlayer?.nickname ?? '알 수 없음',
                    myRole: gameState.myRole,
                    isAlive: isAlive,
                    scaleFactor: scaleFactor,
                    gameTheme: gameTheme,
                    gamePhase: gameState.gamePhase,
                  ),

                  const SizedBox(height: 24),

                  // 마피아 팀 섹션
                  if (gameState.myRole == GameRole.mafia) ...[
                    _MafiaTeamSection(
                      players: gameState.players,
                      scaleFactor: scaleFactor,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 방 번호 섹션
                  _RoomIdSection(
                    roomId: gameState.roomId,
                    scaleFactor: scaleFactor,
                  ),

                  const SizedBox(height: 24),

                  // 게임 설정 섹션
                  _GameSettingsSection(
                    gameSettings: gameState.gameSettings,
                    scaleFactor: scaleFactor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 공통 위젯
class _SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final double scaleFactor;

  const _SectionWrapper({
    required this.title,
    required this.child,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: 16 * scaleFactor,
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
}

/// 정보 행 공통 위젯
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double scaleFactor;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.scaleFactor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: 14 * scaleFactor,
            color: Colors.white54,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.ibmPlexSansKr(
                fontSize: 14 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ],
    );
  }
}

/// 1. 게임 현황 섹션
class _GameStatusSection extends StatelessWidget {
  final GameState gameState;
  final int aliveCount;
  final double scaleFactor;
  final GameThemeExtension gameTheme;

  const _GameStatusSection({
    required this.gameState,
    required this.aliveCount,
    required this.scaleFactor,
    required this.gameTheme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      title: '📊 게임 현황',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glass(opacity: 0.05, borderRadius: 12),
        child: Column(
          children: [
            _InfoRow(
              label: '진행',
              value: '${gameState.gamePhase.label} ${gameState.dayCount}일차',
              valueColor: gameState.gamePhase == GamePhase.day
                  ? Colors.orangeAccent
                  : AppColors.nightAccent,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: '전체 인원',
              value: '${gameState.players.length}명',
              valueColor: Colors.white,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: '생존자',
              value: '$aliveCount명',
              valueColor: Colors.greenAccent,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: '사망자',
              value: '${gameState.players.length - aliveCount}명',
              valueColor: AppColors.dead,
              scaleFactor: scaleFactor,
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
                    fontSize: 13 * scaleFactor,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildRoleCountsGrid(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCountsGrid(BuildContext context) {
    final Map<String, int> roleCounts = gameState.roleCounts;
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildRoleCountItem(
          GameRole.mafia.label,
          roleCounts[GameRole.mafia.name] ?? 0,
          gameTheme.mafiaRef,
        ),
        _buildRoleCountItem(
          GameRole.doctor.label,
          roleCounts[GameRole.doctor.name] ?? 0,
          gameTheme.doctorRef,
        ),
        _buildRoleCountItem(
          GameRole.police.label,
          roleCounts[GameRole.police.name] ?? 0,
          gameTheme.policeRef,
        ),
        _buildRoleCountItem(
          GameRole.citizen.label,
          roleCounts[GameRole.citizen.name] ?? 0,
          gameTheme.citizenRef,
        ),
        _buildRoleCountItem(
          GameRole.madman.label,
          roleCounts[GameRole.madman.name] ?? 0,
          gameTheme.madmanRef,
        ),
        _buildRoleCountItem(
          GameRole.politician.label,
          roleCounts[GameRole.politician.name] ?? 0,
          gameTheme.politicianRef,
        ),
        _buildRoleCountItem(
          GameRole.soldier.label,
          roleCounts[GameRole.soldier.name] ?? 0,
          gameTheme.soldierRef,
        ),
      ],
    );
  }

  Widget _buildRoleCountItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: 12 * scaleFactor,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: GoogleFonts.ibmPlexSansKr(
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 2. 내 정보 섹션
class _MyInfoSection extends StatelessWidget {
  final String myNickname;
  final GameRole? myRole;
  final bool isAlive;
  final double scaleFactor;
  final GameThemeExtension gameTheme;
  final GamePhase gamePhase;

  const _MyInfoSection({
    required this.myNickname,
    required this.myRole,
    required this.isAlive,
    required this.scaleFactor,
    required this.gameTheme,
    required this.gamePhase,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      title: '👤 내 정보',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glass(opacity: 0.05, borderRadius: 12),
        child: Column(
          children: [
            _InfoRow(
              label: '닉네임',
              value: myNickname,
              valueColor: Colors.white,
              scaleFactor: scaleFactor,
            ),
            if (gamePhase != GamePhase.waiting && myRole != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                label: '직업',
                value: '${_getRoleEmoji(myRole!)} ${myRole!.label}',
                valueColor: gameTheme.getRoleColor(myRole),
                scaleFactor: scaleFactor,
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => RoleRevealModal(
                        role: myRole!,
                        onDismiss: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: gameTheme
                          .getRoleColor(myRole)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: gameTheme
                            .getRoleColor(myRole)
                            .withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 16 * scaleFactor,
                      color: gameTheme
                          .getRoleColor(myRole)
                          .withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              label: '상태',
              value: isAlive ? '생존' : '사망',
              valueColor: isAlive ? Colors.greenAccent : AppColors.dead,
              scaleFactor: scaleFactor,
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
      case GameRole.madman:
        return '🤡';
      case GameRole.politician:
        return '🏛️';
      case GameRole.soldier:
        return '🎖️';
    }
  }
}

/// 3. 마피아 팀 섹션
class _MafiaTeamSection extends StatelessWidget {
  final List<Player> players;
  final double scaleFactor;

  const _MafiaTeamSection({required this.players, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    final mafiaPlayers = players
        .where((p) => p.role == GameRole.mafia)
        .toList();

    return _SectionWrapper(
      title: '👥 마피아 팀',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glass(opacity: 0.05, borderRadius: 12),
        child: Column(
          children: mafiaPlayers
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InfoRow(
                    label: p.nickname,
                    value: p.isAlive ? '생존' : '사망',
                    valueColor: p.isAlive ? Colors.greenAccent : AppColors.dead,
                    scaleFactor: scaleFactor,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// 4. 방 번호 섹션
class _RoomIdSection extends StatelessWidget {
  final String? roomId;
  final double scaleFactor;

  const _RoomIdSection({required this.roomId, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      title: '🔑 방 번호',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: AppDecorations.glass(
          opacity: 0.1,
          borderRadius: 12,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              roomId ?? '알 수 없음',
              style: GoogleFonts.ibmPlexSansKr(
                fontSize: 18 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.copy,
                color: AppColors.primary,
                size: 20 * scaleFactor,
              ),
              onPressed: () {
                if (roomId != null) {
                  Clipboard.setData(ClipboardData(text: roomId!));
                  NeonToast.show(context, '복사됨: $roomId');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. 게임 설정 섹션
class _GameSettingsSection extends StatelessWidget {
  final GameSettings gameSettings;
  final double scaleFactor;

  const _GameSettingsSection({
    required this.gameSettings,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      title: '⚙️ 게임 설정',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glass(opacity: 0.05, borderRadius: 12),
        child: Column(
          children: [
            _InfoRow(
              label: '낮 시간',
              value: _formatTime(gameSettings.dayDuration),
              valueColor: Colors.white70,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: '밤 시간',
              value: _formatTime(gameSettings.nightDuration),
              valueColor: Colors.white70,
              scaleFactor: scaleFactor,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '무제한';
    if (seconds >= 60) {
      final int m = seconds ~/ 60;
      final int leftS = seconds % 60;
      if (leftS == 0) return '$m분';
      return '$m분 $leftS초';
    }
    return '$seconds초';
  }
}
