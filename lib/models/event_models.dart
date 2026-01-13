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

/// Vote update event with type-safe parsing
class VoteUpdateEvent {
  final Map<String, int> votes;
  final Map<String, String> voters;

  VoteUpdateEvent({required this.votes, required this.voters});

  factory VoteUpdateEvent.fromJson(Map<String, dynamic> json) {
    final votesData = json[ProtocolKey.votes];
    final votersData = json[ProtocolKey.voters];

    return VoteUpdateEvent(
      votes: votesData is Map
          ? Map<String, int>.from(
              votesData.map(
                (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
              ),
            )
          : {},
      voters: votersData is Map
          ? Map<String, String>.from(
              votersData.map(
                (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
              ),
            )
          : {},
    );
  }
}

/// Timer tick event with type-safe parsing
class TimerTickEvent {
  final int remaining;
  final int total;

  TimerTickEvent({required this.remaining, required this.total});

  factory TimerTickEvent.fromJson(Map<String, dynamic> json) {
    return TimerTickEvent(
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Game over event with type-safe parsing
class GameOverEvent {
  final GameRole? winner;
  final List<Map<String, dynamic>> players;

  GameOverEvent({required this.winner, required this.players});

  factory GameOverEvent.fromJson(Map<String, dynamic> json) {
    final winnerStr = json[ProtocolKey.winner]?.toString();
    final playersData = json[ProtocolKey.players];

    return GameOverEvent(
      winner: GameRole.fromString(winnerStr),
      players: playersData is List
          ? playersData
                .map(
                  (e) => e is Map
                      ? Map<String, dynamic>.from(e)
                      : <String, dynamic>{},
                )
                .toList()
          : [],
    );
  }
}

/// Investigation result event with type-safe parsing
class InvestigationResultEvent {
  final String targetId;
  final GameRole? role;

  InvestigationResultEvent({required this.targetId, required this.role});

  factory InvestigationResultEvent.fromJson(Map<String, dynamic> json) {
    return InvestigationResultEvent(
      targetId: json[ProtocolKey.targetId]?.toString() ?? '',
      role: GameRole.fromString(json[ProtocolKey.role]?.toString()),
    );
  }
}

/// Night result event with type-safe parsing
class NightResultEvent {
  final String message;

  NightResultEvent({required this.message});

  factory NightResultEvent.fromJson(Map<String, dynamic> json) {
    return NightResultEvent(
      message: json[ProtocolKey.message]?.toString() ?? '',
    );
  }
}

/// Role counts event with type-safe parsing
class RoleCountsEvent {
  final Map<String, int> roleCounts;

  RoleCountsEvent({required this.roleCounts});

  factory RoleCountsEvent.fromJson(Map<String, dynamic> json) {
    return RoleCountsEvent(
      roleCounts: Map<String, int>.from(
        json.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)),
      ),
    );
  }
}
