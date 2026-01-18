import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/game_state_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/action_provider.dart';
import '../models/chat_message.dart';
import '../theme/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../utils/responsive_utils.dart';

/// 채팅 기능을 관리하는 위젯
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
  int _lastReadCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with all current messages as read
    _lastReadCount = ref.read(actionProvider.select((s) => s.messages)).length;
  }

  @override
  void didUpdateWidget(ChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When expanding, or while expanded and new messages arrive, update read count
    if (widget.isExpanded) {
      final messages = ref.read(actionProvider.select((s) => s.messages));
      if (_lastReadCount != messages.length) {
        _lastReadCount = messages.length;
      }
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      ref.read(actionProvider.notifier).sendMessage(_msgController.text);
      // 포커스가 있는 상태에서 clear() 호출 시 발생하는 전체 선택 잔상을 방지하기 위해
      // 커서 위치를 강제로 초기화합니다.
      _msgController.selection = const TextSelection.collapsed(offset: 0);
      _msgController.clear();
    }
  }

  void _handleToggleExpand() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      return;
    }
    widget.onToggleExpand();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(actionProvider.select((s) => s.messages));

    // Exclude own messages AND system messages from badge count
    int unreadCount = 0;
    final bool isUserLookingAtChat = widget.isExpanded;

    // Safety check if messages were reset
    if (_lastReadCount > messages.length) {
      _lastReadCount = messages.length;
    }

    // Simplified sync logic inside build (using ref.listen for reactive sync)
    ref.listen(actionProvider.select((s) => s.messages), (prev, next) {
      if (isUserLookingAtChat && mounted) {
        setState(() {
          _lastReadCount = next.length;
        });
      }
    });

    if (!isUserLookingAtChat) {
      final messageCount = messages.length;
      final startIdx = _lastReadCount.clamp(0, messageCount);
      for (int i = startIdx; i < messageCount; i++) {
        if (!messages[i].isMine && !messages[i].isSystem) {
          unreadCount++;
        }
      }
    }

    return Column(
      children: [
        // 채팅 리스트 영역
        Expanded(
          child: RepaintBoundary(
            child: _ChatListArea(
              isExpanded: widget.isExpanded,
              onToggleExpand: _handleToggleExpand,
              messages: messages,
              unreadCount: unreadCount,
              scrollController: _scrollController,
            ),
          ),
        ),
        // 입력 영역
        RepaintBoundary(
          child: _ChatInputArea(
            controller: _msgController,
            focusNode: _focusNode,
            isExpanded: widget.isExpanded,
            onToggleExpand: _handleToggleExpand,
            onSendMessage: _sendMessage,
          ),
        ),
      ],
    );
  }
}

class _ChatListArea extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final List<ChatMessage> messages;
  final int unreadCount;
  final ScrollController scrollController;

  const _ChatListArea({
    required this.isExpanded,
    required this.onToggleExpand,
    required this.messages,
    required this.unreadCount,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onToggleExpand,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.overlayBlack50.withValues(
                alpha: isExpanded ? 0.7 : 0.4,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  controller: scrollController,
                  reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = messages.length - 1 - index;
                    return _ChatMessageItem(message: messages[reversedIndex]);
                  },
                ),
                Positioned(
                  top: 5,
                  right: 20,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topRight,
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                        size: 20,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.error.withValues(
                                      alpha: 0.6,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessageItem({required this.message});

  @override
  Widget build(BuildContext context) {
    final isLegacy = message.isLegacy;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLegacy ? 4 : 8),
      child: Opacity(
        opacity: isLegacy ? 0.4 : 1.0,
        child: message.isSystem
            ? _SystemMessage(text: message.message, isLegacy: isLegacy)
            : _UserMessage(message: message),
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final String text;
  final bool isLegacy;
  const _SystemMessage({required this.text, required this.isLegacy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.policeBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentYellow.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(text),
              color: AppColors.accentYellow,
              size: isLegacy ? 12 : 16,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
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

  IconData _getIcon(String text) {
    if (text.contains('마피아')) return Icons.theater_comedy;
    if (text.contains('시민')) return Icons.celebration;
    if (text.contains('사망') || text.contains('시체')) return Icons.warning;
    if (text.contains('밤')) return Icons.nightlight_round;
    if (text.contains('낮') || text.contains('동이')) return Icons.wb_sunny;
    if (text.contains('투표')) return Icons.how_to_vote;
    if (text.contains('치료')) return Icons.medical_services;
    if (text.contains('조사')) return Icons.search;
    return Icons.info_outline;
  }
}

class _UserMessage extends StatelessWidget {
  final ChatMessage message;
  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMine;
    final isLegacy = message.isLegacy;

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe && !isLegacy)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(
              message.sender,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getIdentityColor(message.sender),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.bubbleColor.withValues(alpha: isMe ? 0.95 : 0.9),
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
              border: !isMe
                  ? Border.all(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                    )
                  : null,
              boxShadow: isMe
                  ? AppDecorations.neonGlow(
                      message.bubbleColor.withValues(alpha: 0.3),
                    )
                  : [],
            ),
            child: Text(
              message.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: message.textColor,
                fontSize: ResponsiveUtils.fontSize(context, isLegacy ? 13 : 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatInputArea extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onSendMessage;

  const _ChatInputArea({
    required this.controller,
    required this.focusNode,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gameState = ref.watch(gameStateProvider);
    final actionState = ref.watch(actionProvider);
    final socketId = ref.watch(connectionProvider.notifier).socketId;

    bool isEnabled = true;
    String hintText = AppStrings.chatHint;

    // Check if player is alive
    final isAlive = gameState.players.any((p) => p.id == socketId && p.isAlive);

    final myRole = gameState.myRole;

    if (isAlive) {
      if (gameState.gamePhase == GamePhase.lastWord) {
        if (actionState.judgementTarget != socketId) {
          isEnabled = false;
          hintText = AppStrings.lastWordChatHint;
        }
      } else if (gameState.gamePhase == GamePhase.night) {
        if (myRole != GameRole.mafia) {
          isEnabled = false;
          hintText = AppStrings.nightChatDisabled;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.overlayBlack50
              : AppColors.overlayBlack50.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: isEnabled,
          textInputAction: TextInputAction.send,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isEnabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            border: InputBorder.none,
          ),
          onEditingComplete: onSendMessage,
        ),
      ),
    );
  }
}
