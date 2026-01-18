import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/game_enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

class RoleRevealModal extends StatelessWidget {
  final GameRole role;
  final VoidCallback onDismiss;

  const RoleRevealModal({
    super.key,
    required this.role,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameTheme = theme.extension<GameThemeExtension>()!;

    return Material(
      color: AppColors.overlayBlack85,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 600;

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          '당신의 역할',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: isCompact ? 14 : 18,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 15 : 30),
                      ZoomIn(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          width: isCompact ? 100 : 150,
                          height: isCompact ? 100 : 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _getRoleGradient(gameTheme),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getRoleColor(
                                  gameTheme,
                                ).withValues(alpha: 0.5),
                                blurRadius: isCompact ? 20 : 30,
                                spreadRadius: isCompact ? 3 : 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getRoleEmoji(),
                              style: TextStyle(fontSize: isCompact ? 50 : 70),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 15 : 30),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          role.label,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: isCompact ? 32 : 42,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 8,
                            shadows: [
                              Shadow(
                                color: _getRoleColor(
                                  gameTheme,
                                ).withValues(alpha: 0.8),
                                blurRadius: isCompact ? 15 : 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 10 : 20),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 16 : 24,
                            vertical: isCompact ? 12 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.overlayWhite10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Text(
                            _getRoleDescription(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: isCompact ? 14 : 16,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.9,
                              ),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 20 : 40),
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: ElevatedButton(
                          onPressed: onDismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getRoleColor(gameTheme),
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 36 : 48,
                              vertical: isCompact ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: _getRoleColor(
                              gameTheme,
                            ).withValues(alpha: 0.5),
                          ),
                          child: Text(
                            AppStrings.confirm,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: isCompact ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getRoleColor(GameThemeExtension gameTheme) {
    switch (role) {
      case GameRole.mafia:
        return gameTheme.mafiaRef;
      case GameRole.doctor:
        return gameTheme.doctorRef;
      case GameRole.police:
        return gameTheme.policeRef;
      case GameRole.citizen:
        return gameTheme.citizenRef;
      case GameRole.madman:
        return gameTheme.madmanRef;
      case GameRole.politician:
        return gameTheme.politicianRef;
      case GameRole.soldier:
        return gameTheme.soldierRef;
    }
  }

  List<Color> _getRoleGradient(GameThemeExtension gameTheme) {
    switch (role) {
      case GameRole.mafia:
        return [gameTheme.mafiaRef, gameTheme.mafiaDarkRef];
      case GameRole.doctor:
        return [gameTheme.doctorRef, gameTheme.doctorDarkRef];
      case GameRole.police:
        return [gameTheme.policeRef, gameTheme.policeDarkRef];
      case GameRole.citizen:
        return [gameTheme.citizenRef, gameTheme.citizenDarkRef];
      case GameRole.madman:
        return [gameTheme.madmanRef, gameTheme.madmanDarkRef];
      case GameRole.politician:
        return [gameTheme.politicianRef, gameTheme.politicianDarkRef];
      case GameRole.soldier:
        return [gameTheme.soldierRef, gameTheme.soldierDarkRef];
    }
  }

  String _getRoleEmoji() {
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

  String _getRoleDescription() {
    switch (role) {
      case GameRole.mafia:
        return '어둠 속에서 도시를 장악하세요. 밤마다 한 명을 처단하며 시민을 전멸시키면 승리합니다.';
      case GameRole.doctor:
        return '생명의 불꽃을 지키세요. 밤마다 한 명을 치료하며 마피아를 모두 처단하면 승리합니다.';
      case GameRole.police:
        return '진실을 쫓는 감시자입니다. 밤마다 마피아를 조사하며 마피아를 모두 처단하면 승리합니다.';
      case GameRole.citizen:
        return '선량한 시민의 결속을 믿으세요. 낮 투표를 통해 마피아를 모두 처단하면 승리합니다.';
      case GameRole.madman:
        return '혼돈을 즐기는 광인입니다. 경찰 조사에는 시민으로 보이며, 마피아 승리 시 함께 승리합니다.';
      case GameRole.politician:
        return '여론을 지배하는 권력가입니다. 투표로 처형되지 않으며 마피아를 모두 처단하면 승리합니다.';
      case GameRole.soldier:
        return '강인한 정신의 소유자입니다. 마피아의 공격을 1회 견뎌내며 마피아를 모두 처단하면 승리합니다.';
    }
  }
}
