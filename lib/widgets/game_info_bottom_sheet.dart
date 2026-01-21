import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_utils.dart';

// Independent Component Imports
import 'game_info/game_status_section.dart';
import 'game_info/my_info_section.dart';
import 'game_info/mafia_team_section.dart';
import 'game_info/room_id_section.dart';
import 'game_info/game_settings_section.dart';

/// 게임 정보를 표시하는 Bottom Sheet
///
/// [Optimization]
/// This widget acts as a pure shell. It does NOT watch any state.
/// All dynamic content is isolated within const child components.
/// This ensures that scrolling and animations are never interrupted by state changes
/// unless the specific visible component needs to update.
class GameInfoBottomSheet extends StatelessWidget {
  const GameInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // ResponsiveUtils 스케일 팩터
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    // 헤더 스타일
    final TextStyle headerStyle = GoogleFonts.ibmPlexSansKr(
      fontSize: 20 * scaleFactor,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    // [Optimization Phase 3]
    // 1. Remove DraggableScrollableSheet to prevent layout thrashing on web.
    // 2. Use fixed height relative to screen (60%).
    // 3. Use ClampingScrollPhysics for stable, non-bouncing scroll.
    // 4. Add cacheExtent to pre-render items.

    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomSheetHeight =
        screenHeight * 0.6; // Fixed height (60% of screen)

    return Container(
      height: bottomSheetHeight,
      decoration: BoxDecoration(
        // [Optimization Phase 2] Opaque background
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
      child: Column(
        children: [
          // 드래그 핸들 (Visual only, since we removed draggable behavior)
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
            child: ListView(
              controller: null, // No need for specific controller unless needed
              padding: const EdgeInsets.all(20),
              // [Optimization Phase 3]
              // ClampingScrollPhysics prevents the "bouncing" effect that can feel erratic on web/desktop.
              // It feels more "solid" and "native" on desktop browsers.
              physics: const ClampingScrollPhysics(),

              // [Optimization Phase 3]
              // Increase draw distance to prevent "pop-in" or flickering when scrolling fast.
              cacheExtent: 500,

              // [Optimization Phase 1] Const children
              children: const [
                // 1. 게임 현황
                GameStatusSection(),

                SizedBox(height: 24),

                // 2. 내 정보
                MyInfoSection(),

                SizedBox(height: 24),

                // 3. 마피아 팀
                MafiaTeamSection(),

                // 4. 방 번호
                RoomIdSection(),

                SizedBox(height: 24),

                // 5. 게임 설정
                GameSettingsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
