import 'package:flutter/material.dart';
import '../../theme/noir_design.dart';

/// Noir Card Variants
enum NoirCardVariant {
  dark, // surfaceDark - Dark card
  base, // surface - Base card
  light, // surfaceLight - Light card
}

/// Noir Card Elevation Levels
enum NoirCardElevation {
  none, // No shadow
  subtle, // Subtle shadow
  standard, // Standard shadow
  elevated, // Strong shadow
}

/// Noir Card Widget
///
/// A versatile card component with monochrome styling and optional crimson accents.
///
/// Example:
/// ```dart
/// NoirCard(
///   variant: NoirCardVariant.base,
///   elevation: NoirCardElevation.standard,
///   hasCrimsonGlow: true,
///   child: Text('Selected'),
/// )
/// ```
class NoirCard extends StatelessWidget {
  final Widget child;
  final NoirCardVariant variant;
  final NoirCardElevation elevation;
  final bool hasCrimsonGlow;
  final bool hasCrimsonBorder;
  final double? padding;
  final double? borderRadius;
  final VoidCallback? onTap;

  const NoirCard({
    super.key,
    required this.child,
    this.variant = NoirCardVariant.base,
    this.elevation = NoirCardElevation.standard,
    this.hasCrimsonGlow = false,
    this.hasCrimsonBorder = false,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (variant) {
      case NoirCardVariant.dark:
        return NoirColors.surfaceDark;
      case NoirCardVariant.base:
        return NoirColors.surface;
      case NoirCardVariant.light:
        return NoirColors.surfaceLight;
    }
  }

  List<BoxShadow> get _shadows {
    if (hasCrimsonGlow) return NoirShadows.crimsonGlow;

    switch (elevation) {
      case NoirCardElevation.none:
        return [];
      case NoirCardElevation.subtle:
        return NoirShadows.subtle;
      case NoirCardElevation.standard:
        return NoirShadows.standard;
      case NoirCardElevation.elevated:
        return NoirShadows.elevated;
    }
  }

  Border get _border {
    if (hasCrimsonBorder) {
      return Border.all(color: NoirColors.crimson, width: 1.5);
    }
    return Border.all(color: NoirColors.border, width: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: EdgeInsets.all(padding ?? NoirDesign.paddingLarge),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? NoirDesign.radiusLarge,
        ),
        border: _border,
        boxShadow: _shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
