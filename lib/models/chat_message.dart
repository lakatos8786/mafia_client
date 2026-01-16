import 'package:flutter/material.dart';
import 'game_enums.dart';
import '../theme/app_colors.dart';

/// Type-safe chat message model
/// Replaces `Map<String, dynamic>` for better code quality
class ChatMessage {
  final String sender;
  final String message;
  final ChatMessageType type;
  final bool isMine;
  final bool isSystem;
  final bool isLegacy;

  const ChatMessage({
    required this.sender,
    required this.message,
    this.type = ChatMessageType.general,
    this.isSystem = false,
    this.isMine = false,
    this.isLegacy = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, {bool isMine = false}) {
    return ChatMessage(
      sender:
          map[ProtocolKey.sender]?.toString() ??
          map['sender']?.toString() ??
          '',
      message:
          map[ProtocolKey.message]?.toString() ??
          map['message']?.toString() ??
          '',
      type: _parseType(map[ProtocolKey.type] ?? map['type']),
      isSystem: map[ProtocolKey.isSystem] ?? map['isSystem'] ?? false,
      isMine: isMine,
      isLegacy: map[ProtocolKey.isLegacy] ?? map['isLegacy'] ?? false,
    );
  }

  ChatMessage copyWith({
    String? sender,
    String? message,
    ChatMessageType? type,
    bool? isMine,
    bool? isSystem,
    bool? isLegacy,
  }) {
    return ChatMessage(
      sender: sender ?? this.sender,
      message: message ?? this.message,
      type: type ?? this.type,
      isMine: isMine ?? this.isMine,
      isSystem: isSystem ?? this.isSystem,
      isLegacy: isLegacy ?? this.isLegacy,
    );
  }

  static ChatMessageType _parseType(dynamic typeValue) {
    if (typeValue == null) return ChatMessageType.general;
    final typeStr = typeValue.toString();
    return ChatMessageType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => ChatMessageType.general,
    );
  }

  /// Convert to Map for compatibility with existing code
  Map<String, dynamic> toMap() => {
    'sender': sender,
    'message': message,
    'type': type.name,
    'isSystem': isSystem,
    // isMine is local state, usually not sent back to server in this map format,
    // but if needed we could add it. For now keeping it local.
  };

  /// Get display color based on message type
  Color get bubbleColor {
    switch (type) {
      case ChatMessageType.dead:
        return AppColors.grey700;
      case ChatMessageType.mafia:
        return AppColors.mafia;
      case ChatMessageType.general:
      default:
        return AppColors.backgroundLighter;
    }
  }

  Color get textColor {
    switch (type) {
      case ChatMessageType.dead:
        return AppColors.textMuted;
      default:
        return AppColors.textPrimary;
    }
  }
}
