import 'dart:math';
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
      // Scale between 0.85 and 1.0 for widths 320-400
      // Increased from 0.75 to 0.85 for better visibility
      return 0.85 + (width - 320) / (baseWidth - 320) * 0.15;
    } else {
      // Minimum scale factor for very small screens
      return 0.8;
    }
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    final scale = getScaleFactor(context);
    final scaledSize = baseSize * scale;

    // Minimum 85% of base size to protect readability
    final limit1 = baseSize * 0.85;
    final limit2 = baseSize;

    // Ensure minimum readability and safe clamp
    return scaledSize.clamp(min(limit1, limit2), max(limit1, limit2));
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    final scale = getScaleFactor(context);
    final scaledSize = baseSize * scale;

    final limit1 = baseSize * 0.7;
    final limit2 = baseSize;

    // Clamp between 70% and 100% of base size safely
    return scaledSize.clamp(min(limit1, limit2), max(limit1, limit2));
  }

  /// Get responsive padding
  static double padding(BuildContext context, double basePadding) {
    final scale = getScaleFactor(context);
    final scaledPadding = basePadding * scale;

    final limit1 = basePadding * 0.6;
    final limit2 = basePadding;

    // Clamp between 60% and 100% of base padding safely
    return scaledPadding.clamp(min(limit1, limit2), max(limit1, limit2));
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    final scale = getScaleFactor(context);
    final scaledSpacing = baseSpacing * scale;

    final limit1 = baseSpacing * 0.5;
    final limit2 = baseSpacing;

    // Clamp between 50% and 100% of base spacing safely
    return scaledSpacing.clamp(min(limit1, limit2), max(limit1, limit2));
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
