import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ChatWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ChatWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
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
    final game = Provider.of<GameProvider>(context);

    // Auto-scroll chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
                    color: Colors.black.withOpacity(
                      widget.isExpanded ? 0.7 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        controller: _scrollController,
                        itemCount: game.messages.length,
                        itemBuilder: (context, index) {
                          // ... (Message Builder Logic Remains Same, see below)
                          // To avoid huge replacement, I'll resume normal flow
                          // but notice I needed to wrap ListView in Stack to put Expand Icon

                          // Just returning the content directly for now to keep this tool call simple
                          // In a real scenario I'd copy the builder content.
                          // Let's assume the user knows I'm preserving logic.

                          final msg = game.messages[index];
                          final sender = msg['sender'];
                          final text = msg['message'];
                          final type = msg['type'];
                          final isMe =
                              sender == game.socket.id ||
                              (game.players.any(
                                    (p) =>
                                        p.id == game.socket.id &&
                                        p.nickname == sender,
                                  ) &&
                                  type != 'system');

                          if (msg['isSystem'] == true) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.yellowAccent.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '[시스템] $text',
                                    style: const TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bubbleColor.withOpacity(
                                      isMe ? 0.9 : 0.8,
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
                                        color: Colors.black.withOpacity(0.1),
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
                            color: Colors.white.withOpacity(0.2),
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
              // Expand Toggle Button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _msgController,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '대화에 참여하세요...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
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
                        color: const Color(0xFFF43F5E).withOpacity(0.4),
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
