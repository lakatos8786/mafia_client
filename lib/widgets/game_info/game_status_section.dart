import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_enums.dart';
import '../../providers/game_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import 'game_info_common.dart';

class GameStatusSection extends ConsumerWidget {
  const GameStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final dayCount = ref.watch(gameStateProvider.select((s) => s.dayCount));
    final playersLength = ref.watch(
      gameStateProvider.select((s) => s.players.length),
    );

    // We need to know alive count, so we need to watch players list,
    // but strictly only for counting alive players.
    // Optimization: logic to count alive players inside select?
    // ref.watch(gameStateProvider.select((s) => s.players.where((p) => p.isAlive).length));
    final aliveCount = ref.watch(
      gameStateProvider.select((s) => s.players.where((p) => p.isAlive).length),
    );

    final roleCounts = ref.watch(gameStateProvider.select((s) => s.roleCounts));

    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    // Calculate dead count
    final deadCount = playersLength - aliveCount;

    return SectionWrapper(
      title: '📊 게임 현황',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            InfoRow(
              label: '진행',
              value: '${gamePhase.label} $dayCount일차',
              valueColor: gamePhase == GamePhase.day
                  ? Colors.orangeAccent
                  : AppColors.nightAccent,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: '전체 인원',
              value: '$playersLength명',
              valueColor: Colors.white,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: '생존자',
              value: '$aliveCount명',
              valueColor: Colors.greenAccent,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: '사망자',
              value: '$deadCount명',
              valueColor: AppColors.dead,
              scaleFactor: scaleFactor,
            ),
            if (roleCounts.isNotEmpty) ...[
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
              _buildRoleCountsGrid(context, roleCounts, gameTheme, scaleFactor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCountsGrid(
    BuildContext context,
    Map<String, int> roleCounts,
    GameThemeExtension gameTheme,
    double scaleFactor,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildRoleCountItem(
          GameRole.mafia.label,
          roleCounts[GameRole.mafia.name] ?? 0,
          gameTheme.mafiaRef,
          scaleFactor,
        ),
        _buildRoleCountItem(
          GameRole.doctor.label,
          roleCounts[GameRole.doctor.name] ?? 0,
          gameTheme.doctorRef,
          scaleFactor,
        ),
        _buildRoleCountItem(
          GameRole.police.label,
          roleCounts[GameRole.police.name] ?? 0,
          gameTheme.policeRef,
          scaleFactor,
        ),
        _buildRoleCountItem(
          GameRole.citizen.label,
          roleCounts[GameRole.citizen.name] ?? 0,
          gameTheme.citizenRef,
          scaleFactor,
        ),
        _buildRoleCountItem(
          GameRole.madman.label,
          roleCounts[GameRole.madman.name] ?? 0,
          gameTheme.madmanRef,
          scaleFactor,
        ),
        _buildRoleCountItem(
          GameRole.politician.label,
          roleCounts[GameRole.politician.name] ?? 0,
          gameTheme.politicianRef,
          scaleFactor,
        ),
        _buildRoleCountItem(
          GameRole.soldier.label,
          roleCounts[GameRole.soldier.name] ?? 0,
          gameTheme.soldierRef,
          scaleFactor,
        ),
      ],
    );
  }

  Widget _buildRoleCountItem(
    String label,
    int count,
    Color color,
    double scaleFactor,
  ) {
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
