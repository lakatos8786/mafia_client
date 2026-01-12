import 'game_enums.dart';

class NightSelectionEvent {
  final GameRole? role;
  final String? targetId;
  final String? actorNickname;

  NightSelectionEvent({this.role, this.targetId, this.actorNickname});

  factory NightSelectionEvent.fromJson(Map<String, dynamic> json) {
    return NightSelectionEvent(
      role: GameRole.fromString(json[ProtocolKey.role]?.toString()),
      targetId: json[ProtocolKey.targetId]?.toString(),
      actorNickname: json[ProtocolKey.actorNickname]?.toString(),
    );
  }
}

class PhaseChangeEvent {
  final GamePhase phase;
  final int dayCount;

  PhaseChangeEvent({required this.phase, required this.dayCount});

  factory PhaseChangeEvent.fromJson(Map<String, dynamic> json) {
    return PhaseChangeEvent(
      phase: GamePhase.fromString(json[ProtocolKey.phase]?.toString() ?? ''),
      dayCount: json[ProtocolKey.dayCount] as int? ?? 1,
    );
  }
}

class ChatMessageEvent {
  final String sender;
  final String message;
  final ChatMessageType type;

  ChatMessageEvent({
    required this.sender,
    required this.message,
    required this.type,
  });

  factory ChatMessageEvent.fromJson(Map<String, dynamic> json) {
    return ChatMessageEvent(
      sender: json[ProtocolKey.sender]?.toString() ?? '',
      message: json[ProtocolKey.message]?.toString() ?? '',
      type: ChatMessageType.values.firstWhere(
        (e) => e.name == json[ProtocolKey.type],
        orElse: () => ChatMessageType.general,
      ),
    );
  }
}
