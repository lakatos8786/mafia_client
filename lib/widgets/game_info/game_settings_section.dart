import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_state_provider.dart';
import '../../utils/responsive_utils.dart';
import 'game_info_common.dart';

class GameSettingsSection extends ConsumerWidget {
  const GameSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSettings = ref.watch(
      gameStateProvider.select((s) => s.gameSettings),
    );

    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    // If gameSettings is somehow null (shouldn't be if initialized), handle?
    // State usually has default settings.

    return SectionWrapper(
      title: '⚙️ 게임 설정',
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
              label: '낮 시간',
              value: _formatTime(gameSettings.dayDuration),
              valueColor: Colors.white70,
              scaleFactor: scaleFactor,
            ),
            const SizedBox(height: 12),
            InfoRow(
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
