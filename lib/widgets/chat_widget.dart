import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (widget.isExpanded && !oldWidget.isExpanded) {
      setState(() => _unreadCount = 0);
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

    // 메시지 수신 시 읽지 않은 메시지 카운트 업데이트
    ref.listen(actionProvider.select((s) => s.messages), (previous, next) {
      if (!widget.isExpanded) {
        final newMessagesCount = next.length - (previous?.length ?? 0);
        if (newMessagesCount > 0) {
          int addedUnread = 0;
          for (int i = previous?.length ?? 0; i < next.length; i++) {
            if (!next[i].isMine) addedUnread++;
          }
          if (addedUnread > 0) {
            setState(() => _unreadCount += addedUnread);
          }
        }
      }
    });

    return Column(
      children: [
        // 채팅 리스트 영역
        Expanded(
          child: RepaintBoundary(
            child: _ChatListArea(
              isExpanded: widget.isExpanded,
              onToggleExpand: widget.onToggleExpand,
              messages: messages,
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
            unreadCount: _unreadCount,
            onToggleExpand: widget.onToggleExpand,
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
  final ScrollController scrollController;

  const _ChatListArea({
    required this.isExpanded,
    required this.onToggleExpand,
    required this.messages,
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = messages.length - 1 - index;
                    return _ChatMessageItem(message: messages[reversedIndex]);
                  },
                ),
                Positioned(
                  top: 5,
                  right: 20,
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    size: 20,
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

class _ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isExpanded;
  final int unreadCount;
  final VoidCallback onToggleExpand;
  final VoidCallback onSendMessage;

  const _ChatInputArea({
    required this.controller,
    required this.focusNode,
    required this.isExpanded,
    required this.unreadCount,
    required this.onToggleExpand,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          _ExpandToggleButton(
            isExpanded: isExpanded,
            unreadCount: unreadCount,
            onTap: onToggleExpand,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.overlayBlack50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: AppStrings.chatHint,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SendButton(onTap: onSendMessage),
        ],
      ),
    );
  }
}

class _ExpandToggleButton extends StatelessWidget {
  final bool isExpanded;
  final int unreadCount;
  final VoidCallback onTap;

  const _ExpandToggleButton({
    required this.isExpanded,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                isExpanded ? Icons.expand_more : Icons.expand_less,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        if (unreadCount > 0 && !isExpanded)
          Positioned(
            top: -4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppDecorations.neonGlow(
                  theme.colorScheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.votePillEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: AppDecorations.neonGlow(
            AppColors.primary.withValues(alpha: 0.4),
          ),
        ),
        child: const Icon(Icons.send, color: Colors.white, size: 24),
      ),
    );
  }
}
