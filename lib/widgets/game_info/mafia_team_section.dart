import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_enums.dart';
import '../../providers/game_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
import 'game_info_common.dart';

class MafiaTeamSection extends ConsumerWidget {
  const MafiaTeamSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));

    // If not mafia, render nothing (efficiently)
    if (myRole != GameRole.mafia) {
      return const SizedBox.shrink();
    }

    // Only fetch mafia players if we are mafia
    final mafiaPlayers = ref.watch(
      gameStateProvider.select(
        (s) => s.players.where((p) => p.role == GameRole.mafia).toList(),
      ),
    );

    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    return Column(
      children: [
        SectionWrapper(
          title: '👥 마피아 팀',
          scaleFactor: scaleFactor,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: mafiaPlayers
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InfoRow(
                        label: p.nickname,
                        value: p.isAlive ? '생존' : '사망',
                        valueColor: p.isAlive
                            ? Colors.greenAccent
                            : AppColors.dead,
                        scaleFactor: scaleFactor,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        // Add spacing below this section because it's distinct
        const SizedBox(height: 24),
      ],
    );
  }
}
