import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/game_enums.dart';
import '../theme/app_colors.dart';

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
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Semantics(
          label: '당신의 역할은 ${role.label}입니다',
          child: Center(
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
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _getRoleGradient(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getRoleColor().withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _getRoleIcon(),
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      role.label,
                      style: GoogleFonts.gowunDodum(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: _getRoleColor().withOpacity(0.8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _getRoleDescription(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.gowunDodum(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: ElevatedButton(
                      onPressed: onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRoleColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: _getRoleColor().withOpacity(0.5),
                      ),
                      child: Text(
                        '확인',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 18,
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
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (role) {
      case GameRole.mafia:
        return AppColors.mafiaRed;
      case GameRole.doctor:
        return AppColors.doctorGreen;
      case GameRole.police:
        return AppColors.policeBlue;
      case GameRole.citizen:
        return AppColors.citizenLink;
    }
  }

  List<Color> _getRoleGradient() {
    switch (role) {
      case GameRole.mafia:
        return [AppColors.mafiaRed, AppColors.mafiaRedDark];
      case GameRole.doctor:
        return [AppColors.doctorGreen, AppColors.doctorGreenDark];
      case GameRole.police:
        return [AppColors.policeBlue, AppColors.policeBlueDark];
      case GameRole.citizen:
        return [AppColors.citizenLink, const Color(0xFF475569)];
    }
  }

  IconData _getRoleIcon() {
    switch (role) {
      case GameRole.mafia:
        return Icons.theater_comedy; // Mask icon - represents deception
      case GameRole.doctor:
        return Icons.medical_services;
      case GameRole.police:
        return Icons.local_police; // Shield with star
      case GameRole.citizen:
        return Icons.person;
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
