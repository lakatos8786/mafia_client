import 'package:flutter/material.dart';
import 'game_enums.dart';

/// Type-safe chat message model
/// Replaces `Map<String, dynamic>` for better code quality
class ChatMessage {
  final String sender;
  final String message;
  final ChatMessageType type;
  final bool isMine;
  final bool isSystem;

  const ChatMessage({
    required this.sender,
    required this.message,
    this.type = ChatMessageType.general,
    this.isSystem = false,
    this.isMine = false,
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
        return const Color(0xFF4B5563); // Grey 600 - More visible than Grey 800
      case ChatMessageType.mafia:
        return const Color(
          0xFFE94560,
        ); // Use AppColors.mafiaRed - Much brighter
      case ChatMessageType.general:
      default:
        return const Color(
          0xFF475569,
        ); // Slate 600 - Better visibility against dark background
    }
  }

  Color get textColor {
    switch (type) {
      case ChatMessageType.dead:
        return Colors.grey[400]!;
      default:
        return Colors.white;
    }
  }
}
