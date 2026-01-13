import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';

/// Separate chat input widget that stays fixed at the bottom of the screen.
/// This ensures the input field is always positioned above the keyboard.
class ChatInputWidget extends StatefulWidget {
  final bool isExpanded;
  final int unreadCount;
  final VoidCallback onToggleExpand;

  const ChatInputWidget({
    super.key,
    required this.isExpanded,
    required this.unreadCount,
    required this.onToggleExpand,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _msgController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).sendMessage(_msgController.text);
      _msgController.clear();
      // Keep keyboard open after sending
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add padding at the bottom to account for safe area
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        // Subtle gradient background for visual separation
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
        ),
      ),
      child: Row(
        children: [
          // Expand Toggle Button with unread badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: widget.onToggleExpand,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: 48,
                    height: 48,
                    child: CustomPaint(
                      painter: ArrowPainter(
                        isUp: !widget.isExpanded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Unread badge
              if (widget.unreadCount > 0 && !widget.isExpanded)
                Positioned(
                  top: -4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mafiaRed,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mafiaRed.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _msgController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppStrings.chatHint,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
                onTapOutside: (event) {
                  // Do nothing to prevent focus loss on button tap
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _sendMessage,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(12),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(painter: SendPainter(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
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
      path.moveTo(size.width * 0.2, size.height * 0.65);
      path.lineTo(size.width * 0.5, size.height * 0.35);
      path.lineTo(size.width * 0.8, size.height * 0.65);
    } else {
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
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double w = size.width;
    double h = size.height;

    path.moveTo(w * 0.35, h * 0.25);
    path.lineTo(w * 0.75, h * 0.5);
    path.lineTo(w * 0.35, h * 0.75);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SendPainter oldDelegate) =>
      oldDelegate.color != color;
}
