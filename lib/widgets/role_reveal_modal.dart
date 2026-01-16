import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/game_enums.dart';
import '../theme/app_strings.dart';

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
    return Material(
      color: Colors.black.withValues(alpha: 0.95),
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
                          style: GoogleFonts.gowunDodum(
                            fontSize: isCompact ? 14 : 18,
                            color: Colors.white.withValues(alpha: 0.5),
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
                              colors: _getRoleGradient(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                blurRadius: isCompact ? 30 : 50,
                                spreadRadius: isCompact ? 1 : 2,
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
                          style: GoogleFonts.gowunDodum(
                            fontSize: isCompact ? 32 : 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 12,
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
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            _getRoleDescription(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.gowunDodum(
                              fontSize: isCompact ? 14 : 16,
                              color: Colors.white.withValues(alpha: 0.9),
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
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 36 : 48,
                              vertical: isCompact ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppStrings.confirm,
                            style: GoogleFonts.gowunDodum(
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

  List<Color> _getRoleGradient() {
    return [
      Colors.white.withValues(alpha: 0.1),
      Colors.white.withValues(alpha: 0.05),
    ];
  }

  String _getRoleEmoji() {
    switch (role) {
      case GameRole.mafia:
        return '🕶️'; // Sunglasses - cool and mysterious
      case GameRole.doctor:
        return '💉'; // Syringe
      case GameRole.police:
        return '🚨'; // Police siren
      case GameRole.citizen:
        return '👤'; // Person silhouette
    }
  }

  String _getRoleDescription() {
    switch (role) {
      case GameRole.mafia:
        return '밤마다 한 명을 제거할 수 있습니다.\n동료 마피아와 협력하여 시민을 속이세요.';
      case GameRole.doctor:
        return '밤마다 한 명을 치료할 수 있습니다.\n마피아의 타겟을 맞추면 생명을 구할 수 있습니다.';
      case GameRole.police:
        return '밤마다 한 명을 조사할 수 있습니다.\n마피아인지 아닌지 확인하고 시민들을 이끄세요.';
      case GameRole.citizen:
        return '특별한 능력은 없지만 투표의 힘이 있습니다.\n토론을 통해 마피아를 찾아내세요.';
    }
  }
}
