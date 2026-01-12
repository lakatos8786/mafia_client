import 'game_enums.dart';

class Player {
  final String id;
  final String nickname;
  final GameRole? role;
  final bool isAlive;
  final bool isHost;

  Player({
    required this.id,
    required this.nickname,
    this.role,
    required this.isAlive,
    this.isHost = false,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id']?.toString() ?? '',
      nickname: map['nickname']?.toString() ?? 'Unknown',
      role: GameRole.fromString(map['role']?.toString()),
      isAlive: map['isAlive'] ?? false,
      isHost: map['isHost'] ?? false,
    );
  }
}
