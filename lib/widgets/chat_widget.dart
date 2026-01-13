import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

/// Chat widget that displays only the chat message list.
/// The input field is now handled separately by ChatInputWidget.
class ChatWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<int>? onUnreadCountChanged;

  const ChatWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
    this.onUnreadCountChanged,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  int _unreadCount = 0;
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset unread count when chat is expanded
    if (widget.isExpanded && !oldWidget.isExpanded) {
      setState(() {
        _unreadCount = 0;
      });
      widget.onUnreadCountChanged?.call(0);
    }
  }

  void _updateUnreadCount(GameProvider game) {
    // Only update unread count when chat is collapsed and new messages arrive
    if (!widget.isExpanded && game.messages.length > _lastMessageCount) {
      // Count only messages from others (not from me)
      int newUnreadCount = 0;

      // Get my socket ID for comparison
      final mySocketId = game.socket.id;
      final myNickname = game.players
          .where((p) => p.id == mySocketId)
          .map((p) => p.nickname)
          .firstOrNull;

      // Check new messages (from _lastMessageCount to current length)
      for (int i = _lastMessageCount; i < game.messages.length; i++) {
        final msg = game.messages[i];
        final sender = msg['sender'];
        final type = msg['type'];

        // Count message if it's NOT from me
        final isMyMessage =
            sender == mySocketId || (myNickname == sender && type != 'system');

        if (!isMyMessage) {
          newUnreadCount++;
        }
      }

      final updatedUnreadCount = _unreadCount + newUnreadCount;
      setState(() {
        _unreadCount = updatedUnreadCount;
      });
      widget.onUnreadCountChanged?.call(updatedUnreadCount);
    }
    _lastMessageCount = game.messages.length;
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Update unread count based on message changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnreadCount(game);
    });

    return GestureDetector(
      onTap: widget.onToggleExpand, // Tap background to toggle
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: widget.isExpanded ? 0.7 : 0.4,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  controller: _scrollController,
                  reverse: true, // Standard Chat Behavior
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: game.messages.length,
                  itemBuilder: (context, index) {
                    // REVERSED INDEX mapping for standard chat feel
                    final reversedIndex = game.messages.length - 1 - index;
                    final msg = game.messages[reversedIndex];
                    final sender = msg['sender'];
                    final text = msg['message'];
                    final type = msg['type'];

                    // Cache my nickname for comparison (avoids repeated players.any)
                    final myNickname = game.players
                        .where((p) => p.id == game.socket.id)
                        .map((p) => p.nickname)
                        .firstOrNull;
                    final isMe =
                        sender == game.socket.id ||
                        (myNickname == sender && type != 'system');

                    if (msg['isSystem'] == true) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Semantics(
                          label: '시스템 메시지: $text',
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.policeBlue.withValues(
                                      alpha: 0.15,
                                    ),
                                    AppColors.accentYellow.withValues(
                                      alpha: 0.1,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.accentYellow.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getSystemMessageIcon(text),
                                    color: AppColors.accentYellow,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      text,
                                      style: GoogleFonts.gowunDodum(
                                        color: Colors.white.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    Color bubbleColor = isMe
                        ? const Color(0xFFF43F5E)
                        : const Color(0xFF1E293B);
                    Color textColor = Colors.white;
                    Color nameColor = Colors.white70;

                    if (type == 'dead') {
                      bubbleColor = Colors.grey[800]!;
                      textColor = Colors.grey[400]!;
                      nameColor = Colors.grey;
                    } else if (type == 'mafia') {
                      bubbleColor = const Color(0xFF9F1239);
                      nameColor = const Color(0xFFF43F5E);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 2,
                              ),
                              child: Text(
                                sender,
                                style: TextStyle(
                                  color: nameColor,
                                  fontSize: 11,
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
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor.withValues(
                                  alpha: isMe ? 0.9 : 0.8,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe
                                      ? const Radius.circular(16)
                                      : const Radius.circular(2),
                                  bottomRight: isMe
                                      ? const Radius.circular(2)
                                      : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Expand/Collapse Icon Overlay
                Positioned(
                  top: 5,
                  right: 20,
                  child: IgnorePointer(
                    child: Icon(
                      widget.isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.white.withValues(alpha: 0.2),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSystemMessageIcon(String text) {
    if (text.contains('마피아') && text.contains('승리') || text.contains('장악')) {
      return Icons.theater_comedy;
    } else if (text.contains('시민') && text.contains('승리') ||
        text.contains('처단')) {
      return Icons.celebration;
    } else if (text.contains('시체') || text.contains('사망')) {
      return Icons.warning;
    } else if (text.contains('밤') || text.contains('어둠')) {
      return Icons.nightlight_round;
    } else if (text.contains('낮') ||
        text.contains('아침') ||
        text.contains('동이')) {
      return Icons.wb_sunny;
    } else if (text.contains('투표') || text.contains('처형')) {
      return Icons.how_to_vote;
    } else if (text.contains('치료') || text.contains('생명')) {
      return Icons.medical_services;
    } else if (text.contains('조사') || text.contains('정체')) {
      return Icons.search;
    } else if (text.contains('역할') || text.contains('부여')) {
      return Icons.person;
    } else {
      return Icons.info_outline;
    }
  }
}

class ArrowPainter extends CustomPainter {
  final bool isUp;
  final Color color;

  ArrowPainter({required this.isUp, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (isUp) {
      // Chevron Up
      path.moveTo(size.width * 0.2, size.height * 0.65);
      path.lineTo(size.width * 0.5, size.height * 0.35);
      path.lineTo(size.width * 0.8, size.height * 0.65);
    } else {
      // Chevron Down
      path.moveTo(size.width * 0.2, size.height * 0.35);
      path.lineTo(size.width * 0.5, size.height * 0.65);
      path.lineTo(size.width * 0.8, size.height * 0.35);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) =>
      oldDelegate.isUp != isUp || oldDelegate.color != color;
}

class SendPainter extends CustomPainter {
  final Color color;

  SendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth =
          3 // Matching ArrowPainter
      ..style = PaintingStyle
          .stroke // Matching ArrowPainter
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double w = size.width;
    double h = size.height;

    // Chevron Right (>)
    // 1. Top Leftish
    path.moveTo(w * 0.35, h * 0.25);
    // 2. Right Middle (Tip)
    path.lineTo(w * 0.75, h * 0.5);
    // 3. Bottom Leftish
    path.lineTo(w * 0.35, h * 0.75);

    // Do not close path for chevron
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SendPainter oldDelegate) =>
      oldDelegate.color != color;
}
