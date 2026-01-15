import 'game_enums.dart';

class Player {
  final String id;
  final String nickname;
  final GameRole? role;
  final bool isAlive;
  final bool isHost;
  final bool isConnected;
  final bool atLobby;

  Player({
    required this.id,
    required this.nickname,
    this.role,
    required this.isAlive,
    this.isHost = false,
    this.isConnected = true,
    this.atLobby = true,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id']?.toString() ?? '',
      nickname: map['nickname']?.toString() ?? 'Unknown',
      role: GameRole.fromString(map['role']?.toString()),
      isAlive: map['isAlive'] ?? false,
      isHost: map['isHost'] ?? false,
      isConnected: map['isConnected'] ?? true,
      atLobby: map['atLobby'] ?? true,
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
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      isHost: isHost ?? this.isHost,
      isConnected: isConnected ?? this.isConnected,
      atLobby: atLobby ?? this.atLobby,
    );
  }
}
