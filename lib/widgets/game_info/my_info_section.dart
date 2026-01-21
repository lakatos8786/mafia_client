import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game_enums.dart';
import '../../providers/game_state_provider.dart';
import '../../providers/connection_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../role_reveal_modal.dart';
import 'game_info_common.dart';

class MyInfoSection extends ConsumerWidget {
  const MyInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch socketId (this rarely changes, but good to be reactive)
    final myId = ref.watch(connectionProvider.notifier).socketId;

    // Granular selection: finding specific properties of my player
    // This avoids rebuilding when other players change
    final myNickname = ref.watch(
      gameStateProvider.select((s) {
        try {
          return s.players.firstWhere((p) => p.id == myId).nickname;
        } catch (_) {
          return '알 수 없음';
        }
      }),
    );

    final isAlive = ref.watch(
      gameStateProvider.select((s) {
        try {
          return s.players.firstWhere((p) => p.id == myId).isAlive;
        } catch (_) {
          return true; // Default to alive if not found (or handle error)
        }
      }),
    );

    final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));

    // We only need to know if we are NOT in waiting phase for role display logic
    // But since myRole is null in waiting phase usually, strictly watching phase might be redundant?
    // The original logic checks: if (gamePhase != GamePhase.waiting && myRole != null)
    // So we do need gamePhase.
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));

    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    // If myId is null (not connected?), handle gracefully
    if (myId == null) return const SizedBox.shrink();

    return SectionWrapper(
      title: '👤 내 정보',
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
              label: '닉네임',
              value: myNickname,
              valueColor: Colors.white,
              scaleFactor: scaleFactor,
            ),
            if (gamePhase != GamePhase.waiting && myRole != null) ...[
              const SizedBox(height: 12),
              InfoRow(
                label: '직업',
                value: '${myRole.emoji} ${myRole.label}',
                valueColor: gameTheme.getRoleColor(myRole),
                scaleFactor: scaleFactor,
                trailing: GestureDetector(
                  onTap: () {
                    // We are inside a bottom sheet (DraggableScrollableSheet maybe?)
                    // Navigator pop might close the sheet if pushed as modal.
                    // The original code did Navigator.of(context).pop() then showDialog.
                    // This closes the info sheet to show role modal.
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => RoleRevealModal(
                        role: myRole,
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
            InfoRow(
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
}
