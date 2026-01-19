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
  static const String error = 'api_error';
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
  static const String updateSettings = 'update_settings';
  static const String stateSync = 'state_sync';
  static const String kickPlayer = 'kick_player';
  static const String kicked = 'kicked';
  static const String playerReconnected = 'player_reconnected';
  static const String playerDisconnected = 'player_disconnected';
  static const String reconnectFailed = 'reconnect_failed';
  static const String judgementStarted = 'judgement_started';
  static const String judgementVote = 'judgement_vote';
  static const String judgementUpdate = 'judgement_update';
  static const String judgementResult = 'judgement_result';
  static const String endLastWord = 'end_last_word';
}

class ErrorCode {
  static const String roomNotFound = 'ROOM_NOT_FOUND';
  static const String nicknameTaken = 'NICKNAME_TAKEN';
  static const String gameStarted = 'GAME_STARTED';
  static const String roomFull = 'ROOM_FULL';
  static const String notHost = 'NOT_HOST';
  static const String kicked = 'KICKED';
  static const String invalidParams = 'INVALID_PARAMS';
}

class SystemConstant {
  static const String sender = 'System';
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
  static const String settings = 'settings';
  static const String dayDuration = 'dayDuration';
  static const String nightDuration = 'nightDuration';
  static const String mafiaCount = 'mafiaCount';
  static const String policeCount = 'policeCount';
  static const String doctorCount = 'doctorCount';
  static const String madmanCount = 'madmanCount';
  static const String politicianCount = 'politicianCount';
  static const String soldierCount = 'soldierCount';
  static const String isConnected = 'isConnected';
  static const String isRevealed = 'isRevealed';
  static const String isLegacy = 'isLegacy';
}

enum GameRole {
  mafia,
  doctor,
  police,
  citizen,
  madman,
  politician,
  soldier;

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
      case '광인':
      case 'madman':
        return GameRole.madman;
      case '정치인':
      case 'politician':
        return GameRole.politician;
      case '군인':
      case 'soldier':
        return GameRole.soldier;
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
      case GameRole.madman:
        return '광인';
      case GameRole.politician:
        return '정치인';
      case GameRole.soldier:
        return '군인';
    }
  }

  // Emoji for each role
  String get emoji {
    switch (this) {
      case GameRole.mafia:
        return '🕶️';
      case GameRole.doctor:
        return '💉';
      case GameRole.police:
        return '🚨';
      case GameRole.citizen:
        return '👤';
      case GameRole.madman:
        return '🤡';
      case GameRole.politician:
        return '🏛️';
      case GameRole.soldier:
        return '🎖️';
    }
  }

  // Description for each role
  String get description {
    switch (this) {
      case GameRole.mafia:
        return '어둠 속에서 도시를 장악하세요. 밤마다 한 명을 처단하며 시민을 전멸시키면 승리합니다.';
      case GameRole.doctor:
        return '생명의 불꽃을 지키세요. 밤마다 한 명을 치료하며 마피아를 모두 처단하면 승리합니다.';
      case GameRole.police:
        return '진실을 쫓는 감시자입니다. 밤마다 마피아를 조사하며 마피아를 모두 처단하면 승리합니다.';
      case GameRole.citizen:
        return '선량한 시민의 결속을 믿으세요. 낮 투표를 통해 마피아를 모두 처단하면 승리합니다.';
      case GameRole.madman:
        return '혼돈을 즐기는 광인입니다. 경찰 조사에는 시민으로 보이며, 마피아 승리 시 함께 승리합니다.';
      case GameRole.politician:
        return '여론을 지배하는 권력가입니다. 투표로 처형되지 않으며 마피아를 모두 처단하면 승리합니다.';
      case GameRole.soldier:
        return '강인한 정신의 소유자입니다. 마피아의 공격을 1회 견뎌내며 마피아를 모두 처단하면 승리합니다.';
    }
  }

  // Protocol string (for socket emit)
  String get id => name; // Returns 'mafia', 'doctor' etc. directly
}

enum GamePhase {
  day,
  lastWord,
  judgement,
  night,
  waiting,
  result;

  static GamePhase fromString(String val) {
    final normalized = val.trim().toLowerCase();

    try {
      if (normalized == 'lastword') return GamePhase.lastWord;
      return GamePhase.values.byName(normalized);
    } catch (_) {
      switch (normalized) {
        case '낮':
          return GamePhase.day;
        case '최후의변론':
          return GamePhase.lastWord;
        case '찬반투표':
          return GamePhase.judgement;
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
      case GamePhase.lastWord:
        return '최후의 변론';
      case GamePhase.judgement:
        return '찬반 투표';
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
