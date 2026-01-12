import 'package:flutter/material.dart';
import 'game_enums.dart';

/// Type-safe chat message model
/// Replaces Map<String, dynamic> for better code quality
class ChatMessage {
  final String sender;
  final String message;
  final ChatMessageType type;
  final bool isSystem;

  const ChatMessage({
    required this.sender,
    required this.message,
    this.type = ChatMessageType.general,
    this.isSystem = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
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
  };

  /// Check if this message is from the current user
  bool isFromUser(String? mySocketId, List<dynamic> players) {
    if (sender == mySocketId) return true;
    if (isSystem) return false;

    // Check if sender nickname matches current user
    for (final p in players) {
      if (p is Map && p['id'] == mySocketId && p['nickname'] == sender) {
        return true;
      }
    }
    return false;
  }

  /// Get display color based on message type
  Color get bubbleColor {
    switch (type) {
      case ChatMessageType.dead:
        return Colors.grey[800]!;
      case ChatMessageType.mafia:
        return const Color(0xFF9F1239);
      case ChatMessageType.general:
      default:
        return const Color(0xFF1E293B);
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
