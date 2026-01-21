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
import '../models/player.dart';
import '../utils/responsive_utils.dart';
import '../widgets/lobby/lobby_settings_sheet.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(gameStateProvider.select((s) => s.roomId));
    final isAdmin = ref.watch(gameStateProvider.select((s) => s.isAdmin));
    final players = ref.watch(gameStateProvider.select((s) => s.players));
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
        title: GestureDetector(
          onTap: () {
            if (roomId != null) {
              Clipboard.setData(ClipboardData(text: roomId));
              NeonToast.show(context, '복사됨: $roomId');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '방 번호: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                roomId ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.copy, color: AppColors.mafiaRed, size: 18),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsBottomSheet(context, ref, myId),
            tooltip: '방 설정',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: Stack(children: [ParticleBackground(phase: GamePhase.day)]),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          RepaintBoundary(
            child: Stack(
              children: [
                Positioned(
                  bottom: -100,
                  left: -50,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                      // Use simpler shadow for better performance
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 80,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(
                              height: ResponsiveUtils.spacing(context, 50),
                            ),
                            FadeInDown(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.padding(
                                    context,
                                    24,
                                  ),
                                ),
                                child: Text(
                                  '플레이어 대기 중...',
                                  style: GoogleFonts.ibmPlexSansKr(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      18,
                                    ),
                                    letterSpacing: ResponsiveUtils.spacing(
                                      context,
                                      4,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveUtils.spacing(context, 24),
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: FadeIn(
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
                                SizedBox(
                                  width: ResponsiveUtils.spacing(context, 8),
                                ),
                                Text(
                                  '참가자',
                                  style: GoogleFonts.ibmPlexSansKr(
                                    color: Colors.white70,
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      14,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.spacing(context, 6),
                                ),
                                Text(
                                  '${players.length}',
                                  style: GoogleFonts.ibmPlexSansKr(
                                    color: AppColors.primary,
                                    fontSize: ResponsiveUtils.fontSize(
                                      context,
                                      14,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      SliverList.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final isMe = player.id == myId;

                          final alphaScale = player.atLobby ? 1.0 : 0.5;

                          return FadeInLeft(
                            delay: Duration(milliseconds: 100 * index),
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: ResponsiveUtils.spacing(context, 10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.padding(
                                  context,
                                  20,
                                ),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary.withValues(
                                          alpha: 0.2 * alphaScale,
                                        )
                                      : Colors.white.withValues(
                                          alpha: 0.08 * alphaScale,
                                        ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isMe
                                        ? AppColors.primary.withValues(
                                            alpha: 0.4 * alphaScale,
                                          )
                                        : Colors.white.withValues(
                                            alpha: 0.1 * alphaScale,
                                          ),
                                    width: isMe ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isMe
                                          ? AppColors.primary.withValues(
                                              alpha: alphaScale,
                                            )
                                          : Colors.white.withValues(
                                              alpha: 0.12 * alphaScale,
                                            ),
                                      foregroundColor: Colors.white.withValues(
                                        alpha: alphaScale,
                                      ),
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
                                          fontSize: ResponsiveUtils.fontSize(
                                            context,
                                            16,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          color:
                                              (player.isAlive
                                                      ? Colors.white
                                                      : Colors.grey)
                                                  .withValues(
                                                    alpha: alphaScale,
                                                  ),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.1 * alphaScale,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.24 * alphaScale,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          '결과 확인 중...',
                                          style: GoogleFonts.ibmPlexSansKr(
                                            fontSize: ResponsiveUtils.fontSize(
                                              context,
                                              12,
                                            ),
                                            color: Colors.white.withValues(
                                              alpha: 0.54 * alphaScale,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (player.isHost)
                                      Tooltip(
                                        message: '방장',
                                        child: Text(
                                          '👑',
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.fontSize(
                                              context,
                                              20,
                                            ),
                                            color: Colors.white.withValues(
                                              alpha: alphaScale,
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
                                          color: AppColors.accentYellow
                                              .withValues(alpha: alphaScale),
                                          size: 18,
                                        ),
                                      ),
                                    if (isAdmin && !isMe)
                                      IconButton(
                                        icon: Icon(
                                          Icons.logout,
                                          color: AppColors.mafiaRed.withValues(
                                            alpha: alphaScale,
                                          ),
                                          size: 18,
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
                FadeInUp(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveUtils.padding(context, 24),
                      ResponsiveUtils.padding(context, 16),
                      ResponsiveUtils.padding(context, 24),
                      ResponsiveUtils.padding(context, 32),
                    ),
                    child: _buildStartButton(context, ref, myId),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, String? myId) {
    if (ref.read(gameStateProvider).roomId == null) {
      return const SizedBox.shrink();
    }

    final players = ref.watch(gameStateProvider.select((s) => s.players));
    final isHost = players.any((p) => p.id == myId && p.isHost);
    if (isHost) {
      final anyoneReviewing = players.any((p) => !p.atLobby);

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

  void _showSettingsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String? myId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LobbySettingsSheet(myId: myId),
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
}
