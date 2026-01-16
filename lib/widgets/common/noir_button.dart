import 'package:flutter/material.dart';
import '../../theme/noir_design.dart';

/// Noir Button Styles
enum NoirButtonStyle {
  primary, // Crimson background + white text
  secondary, // Transparent background + crimson border + crimson text
  ghost, // Transparent background + gray text
}

/// Noir Button Widget
///
/// A button component with three distinct styles optimized for the noir theme.
///
/// Example:
/// ```dart
/// NoirButton(
///   text: 'Start Game',
///   style: NoirButtonStyle.primary,
///   onPressed: () => startGame(),
/// )
/// ```
class NoirButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final NoirButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const NoirButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = NoirButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  Color get _backgroundColor {
    switch (style) {
      case NoirButtonStyle.primary:
        return NoirColors.crimson;
      case NoirButtonStyle.secondary:
      case NoirButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (style) {
      case NoirButtonStyle.primary:
        return NoirColors.textPrimary;
      case NoirButtonStyle.secondary:
        return NoirColors.crimson;
      case NoirButtonStyle.ghost:
        return NoirColors.textSecondary;
    }
  }

  BorderSide? get _borderSide {
    if (style == NoirButtonStyle.secondary) {
      return NoirBorders.crimson;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle =
        ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: NoirDesign.paddingXLarge,
            vertical: NoirDesign.paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoirDesign.radiusMedium),
            side: _borderSide ?? BorderSide.none,
          ),
          disabledBackgroundColor: _backgroundColor.withValues(alpha: 0.3),
          disabledForegroundColor: _foregroundColor.withValues(alpha: 0.3),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              if (style == NoirButtonStyle.primary) {
                return NoirColors.crimsonBright.withValues(alpha: 0.1);
              }
              return _foregroundColor.withValues(alpha: 0.05);
            }
            if (states.contains(WidgetState.pressed)) {
              return _foregroundColor.withValues(alpha: 0.1);
            }
            return null;
          }),
          elevation: WidgetStateProperty.all(0),
        );

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: NoirDesign.spacingMedium),
              ],
              Text(
                text,
                style: NoirTypography.button.copyWith(color: _foregroundColor),
              ),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
