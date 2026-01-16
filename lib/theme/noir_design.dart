import 'package:flutter/material.dart';

/// Noir Theme Color System
/// Monochrome (Black to White) + Crimson Accent
class NoirColors {
  // === Background Layers (Black → Gray) ===
  static const backgroundDeep = Color(0xFF000000); // Pure black
  static const backgroundBase = Color(0xFF0D0D0D); // Almost black
  static const backgroundRaised = Color(0xFF1A1A1A); // Slightly lighter black

  // === Surface Layers (Dark Gray) ===
  static const surfaceDark = Color(0xFF242424); // Dark surface
  static const surface = Color(0xFF2E2E2E); // Base surface
  static const surfaceLight = Color(0xFF3A3A3A); // Light surface

  // === Borders & Dividers (Mid Gray) ===
  static const borderDim = Color(0xFF404040); // Dim border
  static const border = Color(0xFF4D4D4D); // Default border
  static const borderBright = Color(0xFF666666); // Bright border

  // === Text (Gray → White) ===
  static const textDisabled = Color(0xFF666666); // Disabled (4:1 contrast)
  static const textTertiary = Color(0xFF999999); // Tertiary text (7:1)
  static const textSecondary = Color(0xFFCCCCCC); // Secondary text (12:1)
  static const textPrimary = Color(0xFFFFFFFF); // Primary text (21:1)

  // === Highlights (Light Gray / White) ===
  static const highlight = Color(0xFFE6E6E6); // Highlight
  static const highlightBright = Color(0xFFF5F5F5); // Strong highlight

  // === Crimson Accent (Deadly Red) ===
  static const crimsonDeep = Color(0xFF8B0000); // Deep crimson (dark red)
  static const crimson = Color(0xFFDC143C); // Crimson red (main)
  static const crimsonBright = Color(0xFFFF1744); // Bright crimson

  // === Crimson Variants (By Usage) ===
  static const crimsonDim = Color(0xFF6B0000); // For dark backgrounds
  static const crimsonGlow = Color(0xFFFF4466); // For glow effects

  // === Secondary Accents (If Needed) ===
  static const accentWarning = Color(0xFFFFAA00); // Warning (amber)
  static const accentSuccess = Color(0xFF00CC66); // Success (green)

  // === Day/Night Theme Colors ===
  // Day Theme (Light Mode)
  static const dayBackground = Color(0xFFF5F5F5); // Bright light background
  static const dayText = Color(0xFF000000); // Dark text for readability
  static const daySurface = Color(0xFFFFFFFF); // Pure white surface
  static const daySurfaceVariant = Color(0xFF3A3A3A); // Subtle dark surface
  static const dayBorder = Color(0xFF404040); // Visible borders
  static const dayTextSecondary = Color(0xFF666666); // Secondary text

  // Night Theme (Dark Mode)
  static const nightBackground = Color(0xFF000000); // Pure black background
  static const nightText = Color(0xFFFFFFFF); // Bright text for readability
  static const nightSurface = Color(0xFF2E2E2E); // Dark surface
  static const nightSurfaceVariant = Color(0xFF1A1A1A); // Darker surface
  static const nightBorder = Color(0xFF4D4D4D); // Visible borders
  static const nightTextSecondary = Color(0xFFCCCCCC); // Secondary text
}

/// Noir Shadow System
class NoirShadows {
  // Subtle depth (barely visible)
  static final subtle = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.2),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // Standard depth (cards, etc.)
  static final standard = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.4),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Elevated depth (modals, etc.)
  static final elevated = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.6),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.3),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // Crimson glow (hover/focus)
  static final crimsonGlow = [
    BoxShadow(
      color: NoirColors.crimson.withValues(alpha: 0.4),
      blurRadius: 12,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: NoirColors.crimson.withValues(alpha: 0.2),
      blurRadius: 24,
      spreadRadius: 4,
    ),
  ];

  // Intense crimson glow (selected/active)
  static final crimsonGlowIntense = [
    BoxShadow(
      color: NoirColors.crimsonBright.withValues(alpha: 0.6),
      blurRadius: 16,
      spreadRadius: 3,
    ),
    BoxShadow(
      color: NoirColors.crimson.withValues(alpha: 0.3),
      blurRadius: 32,
      spreadRadius: 6,
    ),
  ];
}

/// Noir Typography System
class NoirTypography {
  // Headers (White)
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: NoirColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: NoirColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: NoirColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // Body (Light Gray)
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: NoirColors.textPrimary,
    height: 1.5,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: NoirColors.textSecondary,
    height: 1.5,
  );

  // Labels (Gray)
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: NoirColors.textTertiary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Button (Uppercase, Bold)
  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.0,
  );

  // Label (Uppercase, Bold)
  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.0,
  );
}

/// Noir Border Styles
class NoirBorders {
  // Subtle border
  static const subtle = BorderSide(color: NoirColors.borderDim, width: 0.5);

  // Default border
  static const standard = BorderSide(color: NoirColors.border, width: 1.0);

  // Bright border
  static const bright = BorderSide(color: NoirColors.borderBright, width: 1.0);

  // Crimson border
  static const crimson = BorderSide(color: NoirColors.crimson, width: 1.5);
}

/// Noir Design Constants
class NoirDesign {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;

  // Spacing
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;
  static const double spacingLarge = 12.0;
  static const double spacingXLarge = 16.0;
}
