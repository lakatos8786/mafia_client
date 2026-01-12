class GameAction {
  static const String skip = 'skip';
}

class NightAction {
  static const String kill = 'kill';
  static const String heal = 'heal';
  static const String investigate = 'investigate';
}

class SocketEvent {
  static const String connection = 'connection';
  static const String disconnect = 'disconnect';
  static const String createRoom = 'create_room';
  static const String roomCreated = 'room_created';
  static const String joinRoom = 'join_room';
  static const String joinedRoom = 'joined_room';
  static const String playerUpdate = 'player_update';
  static const String error = 'error';
  static const String startGame = 'start_game';
  static const String roleAssigned = 'role_assigned';
  static const String roleCounts = 'role_counts';
  static const String phaseChange = 'phase_change';
  static const String vote = 'vote';
  static const String voteUpdate = 'vote_update';
  static const String voteResult = 'vote_result';
  static const String playerEliminated = 'player_eliminated';
  static const String nightAction = 'night_action';
  static const String nightSelectionUpdate = 'night_selection_update';
  static const String nightResult = 'night_result';
  static const String investigationResult = 'investigation_result';
  static const String chatMessage = 'chat_message';
  static const String gameOver = 'game_over';
  static const String timerTick = 'timer_tick';
}

class SystemConstant {
  static const String sender = '시스템';
}

class ProtocolKey {
  static const String roomId = 'roomId';
  static const String nickname = 'nickname';
  static const String targetId = 'targetId';
  static const String role = 'role';
  static const String action = 'action';
  static const String message = 'message';
  static const String sender = 'sender';
  static const String type = 'type';
  static const String votes = 'votes';
  static const String voters = 'voters';
  static const String result = 'result';
  static const String winner = 'winner';
  static const String players = 'players';
  static const String id = 'id';
  static const String reason = 'reason';
  static const String dayCount = 'dayCount';
  static const String isSystem = 'isSystem';
  static const String isAlive = 'isAlive';
  static const String isHost = 'isHost';
  static const String actorNickname = 'actorNickname';
  static const String targetNickname = 'targetNickname';
  static const String errorMessage = 'errorMessage';
  static const String phase = 'phase';
}

enum GameRole {
  mafia,
  doctor,
  police,
  citizen;

  static GameRole? fromString(String? val) {
    if (val == null || val.isEmpty) return null;

    // 1. Normalize input (lowercase, trim)
    final normalized = val.trim().toLowerCase();

    // 2. Try matching standard English Enum names (e.g. 'mafia', 'doctor')
    for (final role in GameRole.values) {
      if (role.name.toLowerCase() == normalized) return role;
    }

    // 3. Fallback for Korean keys or variations
    switch (normalized) {
      case '마피아':
      case 'mafia':
        return GameRole.mafia;
      case '의사':
      case 'doctor':
        return GameRole.doctor;
      case '경찰':
      case 'police':
        return GameRole.police;
      case '시민':
      case 'citizen':
        return GameRole.citizen;
      default:
        return null;
    }
  }

  // Display string (Korean)
  String get label {
    switch (this) {
      case GameRole.mafia:
        return '마피아';
      case GameRole.doctor:
        return '의사';
      case GameRole.police:
        return '경찰';
      case GameRole.citizen:
        return '시민';
    }
  }

  // Protocol string (for socket emit)
  String get id => name; // Returns 'mafia', 'doctor' etc. directly
}

enum GamePhase {
  day,
  night,
  waiting,
  result;

  static GamePhase fromString(String val) {
    final normalized = val.trim().toLowerCase();

    try {
      return GamePhase.values.byName(normalized);
    } catch (_) {
      switch (normalized) {
        case '낮':
          return GamePhase.day;
        case '밤':
          return GamePhase.night;
        case '결과':
          return GamePhase.result;
        default:
          return GamePhase.waiting;
      }
    }
  }

  String get label {
    switch (this) {
      case GamePhase.day:
        return '낮';
      case GamePhase.night:
        return '밤';
      case GamePhase.result:
        return '결과';
      case GamePhase.waiting:
        return '대기중';
    }
  }
}

enum ChatMessageType {
  general,
  dead,
  mafia,
  system;

  static ChatMessageType fromString(String? val) {
    if (val == null) return ChatMessageType.general;
    try {
      return ChatMessageType.values.byName(val.toLowerCase());
    } catch (_) {
      return ChatMessageType.general;
    }
  }
}
