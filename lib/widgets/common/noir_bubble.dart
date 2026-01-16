import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/noir_design.dart';
import '../../utils/responsive_utils.dart';

/// Noir Bubble Styles
enum NoirBubbleStyle {
  player, // Player chat message
  system, // System notification
}

/// Noir Chat Bubble Widget
///
/// A chat bubble component with Noir design system styling.
///
/// Example:
/// ```dart
/// NoirBubble(
///   message: 'Hello!',
///   sender: 'Player1',
///   isMe: false,
///   style: NoirBubbleStyle.player,
/// )
/// ```
class NoirBubble extends StatelessWidget {
  final String message;
  final String? sender;
  final bool isMe;
  final bool isLegacy;
  final NoirBubbleStyle style;
  final Color? color;

  const NoirBubble({
    super.key,
    required this.message,
    this.sender,
    this.isMe = false,
    this.isLegacy = false,
    this.style = NoirBubbleStyle.player,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (style == NoirBubbleStyle.system) {
      return _buildSystemBubble(context);
    }
    return _buildPlayerBubble(context);
  }

  Widget _buildSystemBubble(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NoirDesign.paddingMedium,
          vertical: NoirDesign.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: color ?? NoirColors.surfaceDark,
          borderRadius: BorderRadius.circular(NoirDesign.radiusMedium),
          border: Border.all(color: NoirColors.border, width: 0.5),
          boxShadow: NoirShadows.subtle,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForMessage(message),
              color: NoirColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: NoirDesign.spacingMedium),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.gowunDodum(
                  color: NoirColors.textPrimary,
                  fontSize: ResponsiveUtils.fontSize(
                    context,
                    isLegacy ? 12 : 14,
                  ),
                  fontWeight: isLegacy ? FontWeight.normal : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBubble(BuildContext context) {
    final bubbleColor =
        color ?? (isMe ? NoirColors.surfaceLight : NoirColors.surfaceDark);

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe && sender != null && !isLegacy)
          Padding(
            padding: const EdgeInsets.only(
              left: NoirDesign.paddingSmall / 2,
              bottom: 2,
            ),
            child: Text(
              sender!,
              style: GoogleFonts.gowunDodum(
                color: NoirColors.textTertiary,
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NoirDesign.paddingMedium,
              vertical: NoirDesign.paddingSmall + 2,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(NoirDesign.radiusMedium),
                topRight: const Radius.circular(NoirDesign.radiusMedium),
                bottomLeft: Radius.circular(
                  isMe ? NoirDesign.radiusMedium : NoirDesign.radiusSmall / 2,
                ),
                bottomRight: Radius.circular(
                  isMe ? NoirDesign.radiusSmall / 2 : NoirDesign.radiusMedium,
                ),
              ),
              border: Border.all(color: NoirColors.border, width: 0.5),
              boxShadow: NoirShadows.subtle,
            ),
            child: Text(
              message,
              style: GoogleFonts.gowunDodum(
                color: NoirColors.textPrimary,
                fontSize: ResponsiveUtils.fontSize(context, isLegacy ? 13 : 16),
                height: 1.4,
                fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get icon based on message content
  IconData _getIconForMessage(String message) {
    if (message.contains('게임') || message.contains('시작')) {
      return Icons.play_circle_outline;
    } else if (message.contains('투표') || message.contains('처형')) {
      return Icons.how_to_vote;
    } else if (message.contains('밤') || message.contains('낮')) {
      return Icons.brightness_4;
    } else if (message.contains('승리') || message.contains('패배')) {
      return Icons.emoji_events;
    } else if (message.contains('사망') || message.contains('죽었')) {
      return Icons.cancel;
    } else {
      return Icons.info_outline;
    }
  }
}
