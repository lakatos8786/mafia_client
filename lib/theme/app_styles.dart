import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전체에서 공통으로 사용되는 디자인 토큰 및 스타일 정의
class AppStyles {
  // 인스턴스화 방지
  AppStyles._();
}

/// 일관된 간격 및 여백을 위한 상수 정의
class AppSpacing {
  static const double borderRadius = 16.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
}

/// 공통적으로 사용되는 그래픽 효과 및 장식 정의
class AppDecorations {
  /// 유리 효과(Glassmorphism)를 위한 배경 장식
  static BoxDecoration glass({
    double opacity = 0.3,
    double borderRadius = AppSpacing.borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: AppColors.glassBorder),
    );
  }

  /// 네온 광원 효과(Shadow) 정의
  static List<BoxShadow> neonGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.5),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ];
  }
}
