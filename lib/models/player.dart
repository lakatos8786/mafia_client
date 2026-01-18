import 'game_enums.dart';

class Player {
  final String id;
  final String nickname;
  final GameRole? role;
  final bool isAlive;
  final bool isHost;
  final bool isConnected;
  final bool atLobby;
  final bool isRevealed;

  Player({
    required this.id,
    required this.nickname,
    this.role,
    required this.isAlive,
    this.isHost = false,
    this.isConnected = true,
    this.atLobby = true,
    this.isRevealed = false,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map[ProtocolKey.id]?.toString() ?? '',
      nickname: map[ProtocolKey.nickname]?.toString() ?? 'Unknown',
      role: GameRole.fromString(map[ProtocolKey.role]?.toString()),
      isAlive: map[ProtocolKey.isAlive] ?? false,
      isHost: map[ProtocolKey.isHost] ?? false,
      isConnected: map[ProtocolKey.isConnected] ?? true,
      atLobby:
          map['atLobby'] ??
          true, // atLobby is usually client-side or simple key
      isRevealed: map[ProtocolKey.isRevealed] ?? false,
    );
  }

  Player copyWith({
    String? id,
    String? nickname,
    GameRole? role,
    bool? isAlive,
    bool? isHost,
    bool? isConnected,
    bool? atLobby,
    bool? isRevealed,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      isHost: isHost ?? this.isHost,
      isConnected: isConnected ?? this.isConnected,
      atLobby: atLobby ?? this.atLobby,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
}
