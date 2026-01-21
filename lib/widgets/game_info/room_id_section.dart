import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/game_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../neon_toast.dart';
import 'game_info_common.dart';

class RoomIdSection extends ConsumerWidget {
  const RoomIdSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(gameStateProvider.select((s) => s.roomId));

    // We can fetch scaleFactor here.
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    // If roomId is null, handle gracefully
    final displayRoomId = roomId ?? '알 수 없음';

    return SectionWrapper(
      title: '🔑 방 번호',
      scaleFactor: scaleFactor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayRoomId,
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
                  Clipboard.setData(ClipboardData(text: roomId));
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
