import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/action_provider.dart';
import '../theme/app_strings.dart';
import '../theme/noir_design.dart';
import '../utils/responsive_utils.dart';
import '../providers/game_state_provider.dart';
import '../models/game_enums.dart';
import 'common/noir_bubble.dart';

class ChatWidget extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ChatWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int _unreadCount = 0;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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
    }
  }

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      ref.read(actionProvider.notifier).sendMessage(_msgController.text);
      _msgController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(actionProvider.select((s) => s.messages));
    final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
    final isNight = gamePhase == GamePhase.night;

    // Use ref.listen...

    return Column(
      children: [
        // Chat Area with Glassmorphism
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: widget.onToggleExpand, // Tap background to toggle
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isNight
                        ? NoirColors.surface.withValues(
                            alpha: widget.isExpanded ? 0.95 : 0.8,
                          )
                        : Colors.white.withValues(
                            alpha: widget.isExpanded ? 0.95 : 0.8,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isNight ? NoirColors.border : NoirColors.borderDim,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        controller: _scrollController,
                        reverse: true, // Standard Chat Behavior
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          // REVERSED INDEX mapping for standard chat feel
                          final reversedIndex = messages.length - 1 - index;
                          final msg = messages[reversedIndex];

                          final bool isLegacy = msg.isLegacy;
                          final bool isMe = msg.isMine;

                          Widget content;
                          if (msg.isSystem) {
                            content = NoirBubble(
                              message: msg.message,
                              style: NoirBubbleStyle.system,
                              isLegacy: isLegacy,
                            );
                          } else {
                            content = NoirBubble(
                              message: msg.message,
                              sender: msg.sender,
                              isMe: isMe,
                              isLegacy: isLegacy,
                              style: NoirBubbleStyle.player,
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isLegacy ? 4 : 8,
                            ),
                            child: Opacity(
                              opacity: isLegacy ? 0.4 : 1.0,
                              child: content,
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
                            color: isNight
                                ? NoirColors.textTertiary.withValues(alpha: 0.4)
                                : NoirColors.borderBright.withValues(
                                    alpha: 0.4,
                                  ),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Input Area
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Expand Toggle Button with unread badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isNight
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
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
                            color: isNight ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Unread badge
                  if (_unreadCount > 0 && !widget.isExpanded)
                    Positioned(
                      top: -4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isNight
                              ? NoirColors.textPrimary
                              : NoirColors.backgroundDeep,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          style: GoogleFonts.gowunDodum(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isNight ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isNight ? NoirColors.surface : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isNight ? NoirColors.border : NoirColors.borderDim,
                    ),
                  ),
                  child: TextField(
                    controller: _msgController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
                    style: TextStyle(
                      color: isNight
                          ? NoirColors.textPrimary
                          : NoirColors.backgroundDeep,
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.chatHint,
                      hintStyle: TextStyle(
                        color: isNight
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.4),
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),
                      filled: false, // handled by container
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTapDown: (_) => _sendMessage(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomPaint(painter: SendPainter(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Icon mapping is now handled by AppDesign and MafiaBubble
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
