import 'package:flutter/material.dart';
import '../../theme/noir_design.dart';

/// Noir Badge Types
enum NoirBadgeType {
  info, // Gray (information)
  crimson, // Crimson (important/selected)
  success, // Green (success)
  warning, // Amber (warning)
}

/// Noir Badge Widget
///
/// A small badge component for displaying status, roles, or counts.
///
/// Example:
/// ```dart
/// NoirBadge(
///   text: 'Host',
///   type: NoirBadgeType.crimson,
///   icon: Icons.stars,
/// )
/// ```
class NoirBadge extends StatelessWidget {
  final String text;
  final NoirBadgeType type;
  final IconData? icon;
  final bool hasGlow;

  const NoirBadge({
    super.key,
    required this.text,
    this.type = NoirBadgeType.info,
    this.icon,
    this.hasGlow = false,
  });

  Color get _backgroundColor {
    switch (type) {
      case NoirBadgeType.info:
        return NoirColors.surfaceLight;
      case NoirBadgeType.crimson:
        return NoirColors.crimson;
      case NoirBadgeType.success:
        return NoirColors.accentSuccess;
      case NoirBadgeType.warning:
        return NoirColors.accentWarning;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case NoirBadgeType.info:
        return NoirColors.textSecondary;
      case NoirBadgeType.crimson:
      case NoirBadgeType.success:
      case NoirBadgeType.warning:
        return NoirColors.textPrimary;
    }
  }

  List<BoxShadow>? get _shadows {
    if (hasGlow && type == NoirBadgeType.crimson) {
      return NoirShadows.crimsonGlow;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NoirDesign.paddingMedium,
        vertical: NoirDesign.paddingSmall - 2,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(NoirDesign.radiusSmall),
        boxShadow: _shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: _foregroundColor),
            const SizedBox(width: NoirDesign.spacingSmall),
          ],
          Text(
            text,
            style: NoirTypography.label.copyWith(
              color: _foregroundColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
