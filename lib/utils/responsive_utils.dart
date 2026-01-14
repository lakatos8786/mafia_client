import 'package:flutter/material.dart';

/// Responsive utility class for calculating sizes based on screen dimensions
class ResponsiveUtils {
  /// Get a scale factor based on screen width
  /// Returns 1.0 for normal screens, scales down for smaller screens
  static double getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Base width for scale factor 1.0
    const baseWidth = 400.0;

    if (width >= baseWidth) {
      return 1.0;
    } else if (width >= 320) {
      // Scale between 0.75 and 1.0 for widths 320-400
      return 0.75 + (width - 320) / (baseWidth - 320) * 0.25;
    } else {
      // Minimum scale factor for very small screens
      return 0.7;
    }
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    final scale = getScaleFactor(context);
    final scaledSize = baseSize * scale;

    // Ensure minimum readability
    return scaledSize.clamp(baseSize * 0.7, baseSize);
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    final scale = getScaleFactor(context);
    final scaledSize = baseSize * scale;

    // Clamp between 70% and 100% of base size
    return scaledSize.clamp(baseSize * 0.7, baseSize);
  }

  /// Get responsive padding
  static double padding(BuildContext context, double basePadding) {
    final scale = getScaleFactor(context);
    final scaledPadding = basePadding * scale;

    // Clamp between 60% and 100% of base padding
    return scaledPadding.clamp(basePadding * 0.6, basePadding);
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    final scale = getScaleFactor(context);
    final scaledSpacing = baseSpacing * scale;

    // Clamp between 50% and 100% of base spacing
    return scaledSpacing.clamp(baseSpacing * 0.5, baseSpacing);
  }

  /// Check if screen is compact (small height or landscape on small device)
  static bool isCompactScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return (size.height < 600) ||
        (size.height < 480 && orientation == Orientation.landscape);
  }

  /// Get vertical padding adjustment for compact screens
  static double verticalPadding(BuildContext context, double basePadding) {
    if (isCompactScreen(context)) {
      return basePadding * 0.4; // 40% of base for compact screens
    }
    return padding(context, basePadding);
  }

  /// Get horizontal padding adjustment
  static double horizontalPadding(BuildContext context, double basePadding) {
    return padding(context, basePadding);
  }
}
