import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_state_provider.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';

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
  int _lastMessageCount = 0;

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

  void _updateUnreadCount(
    List<ChatMessage> messages,
    String socketId,
    List<Player> players,
  ) {
    // Only update unread count when chat is collapsed and new messages arrive
    if (!widget.isExpanded && messages.length > _lastMessageCount) {
      // Count only messages from others (not from me)
      int newUnreadCount = 0;

      // Get my nickname for comparison (assuming players list has it)
      // Note: players is List<Player> usually.
      // We need to access players from gameState.
      // But passing players here is cleaner.

      // Check new messages (from _lastMessageCount to current length)
      for (int i = _lastMessageCount; i < messages.length; i++) {
        final msg = messages[i];
        if (!msg.isMine) {
          newUnreadCount++;
        }
      }

      setState(() {
        _unreadCount += newUnreadCount;
      });
    }
    _lastMessageCount = messages.length;
  }

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      ref.read(actionProvider.notifier).sendMessage(_msgController.text);
      _msgController.clear();
      // Keep keyboard open after sending
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final actionState = ref.watch(actionProvider);
    final socketId = ref.watch(connectionProvider.notifier).socketId ?? '';

    // Update unread count based on message changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnreadCount(actionState.messages, socketId, gameState.players);
    });

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
                    color: Colors.black.withValues(
                      alpha: widget.isExpanded ? 0.7 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        controller: _scrollController,
                        reverse: true, // Standard Chat Behavior
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: actionState.messages.length,
                        itemBuilder: (context, index) {
                          // REVERSED INDEX mapping for standard chat feel
                          final reversedIndex =
                              actionState.messages.length - 1 - index;
                          final msg = actionState.messages[reversedIndex];

                          final isMe = msg.isMine;

                          if (msg.isSystem) {
                            final text = msg.message;
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
                                        color: AppColors.accentYellow
                                            .withValues(alpha: 0.4),
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

                          Color bubbleColor = msg.bubbleColor;
                          Color textColor = msg.textColor;
                          Color nameColor = Colors.white70;

                          if (msg.type == ChatMessageType.dead) {
                            nameColor = Colors.grey;
                          } else if (msg.type == ChatMessageType.mafia) {
                            nameColor = AppColors.primary;
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
                                      msg.sender,
                                      style: TextStyle(
                                        color: nameColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
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
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      msg.message,
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
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          style: GoogleFonts.gowunDodum(
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
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
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
                    onTapOutside: (event) {
                      // Do nothing to prevent focus loss on button tap
                      // focusNode.unfocus() is default, we override it.
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
                      colors: [AppColors.primary, AppColors.votePillEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
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
        ),
      ],
    );
  }

  IconData _getSystemMessageIcon(String text) {
    if (text.contains('마피아') && text.contains('승리') || text.contains('장악')) {
      return Icons.theater_comedy; // Mask icon - represents mafia
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
