import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_enums.dart';
import 'app_colors.dart';

/// 앱 전체 테마 설정을 관리하는 클래스
class AppTheme {
  /// 다크 모드 테마 정의
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundMain,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.backgroundMain, // High contrast for neon buttons
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.ibmPlexSansKrTextTheme(ThemeData.dark().textTheme)
          .apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
      extensions: [
        const GameThemeExtension(
          mafiaRef: AppColors.mafia,
          mafiaDarkRef: AppColors.mafiaDark,
          doctorRef: AppColors.doctor,
          doctorDarkRef: AppColors.doctorDark,
          policeRef: AppColors.police,
          policeDarkRef: AppColors.policeDark,
          citizenRef: AppColors.citizen,
          citizenDarkRef: AppColors.citizenDark,
          madmanRef: AppColors.madman,
          madmanDarkRef: AppColors.madmanDark,
          politicianRef: AppColors.politician,
          politicianDarkRef: AppColors.politicianDark,
          soldierRef: AppColors.soldier,
          soldierDarkRef: AppColors.soldierDark,
          voteRef: AppColors.voteGold,
          deadRef: AppColors.dead,
        ),
      ],
    );
  }
}

/// 게임 도메인 특화 색상 및 스타일을 테마 시스템에 확장하기 위한Extension
class GameThemeExtension extends ThemeExtension<GameThemeExtension> {
  final Color mafiaRef;
  final Color mafiaDarkRef;
  final Color doctorRef;
  final Color doctorDarkRef;
  final Color policeRef;
  final Color policeDarkRef;
  final Color citizenRef;
  final Color citizenDarkRef;
  final Color madmanRef;
  final Color madmanDarkRef;
  final Color politicianRef;
  final Color politicianDarkRef;
  final Color soldierRef;
  final Color soldierDarkRef;
  final Color voteRef;
  final Color deadRef;

  const GameThemeExtension({
    required this.mafiaRef,
    required this.mafiaDarkRef,
    required this.doctorRef,
    required this.doctorDarkRef,
    required this.policeRef,
    required this.policeDarkRef,
    required this.citizenRef,
    required this.citizenDarkRef,
    required this.madmanRef,
    required this.madmanDarkRef,
    required this.politicianRef,
    required this.politicianDarkRef,
    required this.soldierRef,
    required this.soldierDarkRef,
    required this.voteRef,
    required this.deadRef,
  });

  /// 역할(GameRole)에 따른 기본 색상을 반환합니다.
  Color getRoleColor(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return mafiaRef;
      case GameRole.doctor:
        return doctorRef;
      case GameRole.police:
        return policeRef;
      case GameRole.citizen:
        return citizenRef;
      case GameRole.madman:
        return madmanRef;
      case GameRole.politician:
        return politicianRef;
      case GameRole.soldier:
        return soldierRef;
      default:
        return mafiaRef;
    }
  }

  /// 역할(GameRole)에 따른 어두운 배경용 색상을 반환합니다.
  Color getRoleDarkColor(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return mafiaDarkRef;
      case GameRole.doctor:
        return doctorDarkRef;
      case GameRole.police:
        return policeDarkRef;
      case GameRole.citizen:
        return citizenDarkRef;
      case GameRole.madman:
        return madmanDarkRef;
      case GameRole.politician:
        return politicianDarkRef;
      case GameRole.soldier:
        return soldierDarkRef;
      default:
        return mafiaDarkRef;
    }
  }

  @override
  ThemeExtension<GameThemeExtension> copyWith({
    Color? mafiaRef,
    Color? mafiaDarkRef,
    Color? doctorRef,
    Color? doctorDarkRef,
    Color? policeRef,
    Color? policeDarkRef,
    Color? citizenRef,
    Color? citizenDarkRef,
    Color? madmanRef,
    Color? madmanDarkRef,
    Color? politicianRef,
    Color? politicianDarkRef,
    Color? soldierRef,
    Color? soldierDarkRef,
    Color? voteRef,
    Color? deadRef,
  }) {
    return GameThemeExtension(
      mafiaRef: mafiaRef ?? this.mafiaRef,
      mafiaDarkRef: mafiaDarkRef ?? this.mafiaDarkRef,
      doctorRef: doctorRef ?? this.doctorRef,
      doctorDarkRef: doctorDarkRef ?? this.doctorDarkRef,
      policeRef: policeRef ?? this.policeRef,
      policeDarkRef: policeDarkRef ?? this.policeDarkRef,
      citizenRef: citizenRef ?? this.citizenRef,
      citizenDarkRef: citizenDarkRef ?? this.citizenDarkRef,
      madmanRef: madmanRef ?? this.madmanRef,
      madmanDarkRef: madmanDarkRef ?? this.madmanDarkRef,
      politicianRef: politicianRef ?? this.politicianRef,
      politicianDarkRef: politicianDarkRef ?? this.politicianDarkRef,
      soldierRef: soldierRef ?? this.soldierRef,
      soldierDarkRef: soldierDarkRef ?? this.soldierDarkRef,
      voteRef: voteRef ?? this.voteRef,
      deadRef: deadRef ?? this.deadRef,
    );
  }

  @override
  ThemeExtension<GameThemeExtension> lerp(
    ThemeExtension<GameThemeExtension>? other,
    double t,
  ) {
    if (other is! GameThemeExtension) return this;
    return GameThemeExtension(
      mafiaRef: Color.lerp(mafiaRef, other.mafiaRef, t)!,
      mafiaDarkRef: Color.lerp(mafiaDarkRef, other.mafiaDarkRef, t)!,
      doctorRef: Color.lerp(doctorRef, other.doctorRef, t)!,
      doctorDarkRef: Color.lerp(doctorDarkRef, other.doctorDarkRef, t)!,
      policeRef: Color.lerp(policeRef, other.policeRef, t)!,
      policeDarkRef: Color.lerp(policeDarkRef, other.policeDarkRef, t)!,
      citizenRef: Color.lerp(citizenRef, other.citizenRef, t)!,
      citizenDarkRef: Color.lerp(citizenDarkRef, other.citizenDarkRef, t)!,
      madmanRef: Color.lerp(madmanRef, other.madmanRef, t)!,
      madmanDarkRef: Color.lerp(madmanDarkRef, other.madmanDarkRef, t)!,
      politicianRef: Color.lerp(politicianRef, other.politicianRef, t)!,
      politicianDarkRef: Color.lerp(
        politicianDarkRef,
        other.politicianDarkRef,
        t,
      )!,
      soldierRef: Color.lerp(soldierRef, other.soldierRef, t)!,
      soldierDarkRef: Color.lerp(soldierDarkRef, other.soldierDarkRef, t)!,
      voteRef: Color.lerp(voteRef, other.voteRef, t)!,
      deadRef: Color.lerp(deadRef, other.deadRef, t)!,
    );
  }
}
