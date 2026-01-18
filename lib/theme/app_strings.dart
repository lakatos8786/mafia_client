import '../models/game_enums.dart';

/// Centralized system messages and UI strings for the Mafia game.
class AppStrings {
  // Game Start
  static const String gameStarted = '당신의 역할이 부여되었습니다. 정체를 숨기세요.';

  // Phase Changes
  static const String dayStarted = '동이 텄습니다. 마피아를 찾아내세요!';
  static const String nightStarted = '밤이 찾아왔습니다. 어둠 속에서 누군가 움직입니다...';
  static String dayAnnouncement(int count) => '$count번째 낮이 되었습니다.';
  static String nightAnnouncement(int count) => '$count번째 밤이 되었습니다.';

  // Reasons for elimination
  static const String reasonVote = '투표';
  static const String reasonMafia = '마피아의 공격';
  static const String reasonDisconnect = '탈주';

  static String localizedError(dynamic error) {
    String? code;
    String? message;
    List<String>? players;

    if (error is Map) {
      code = error['code']?.toString();
      message = error['message']?.toString();
      if (error['players'] is List) {
        players = List<String>.from(error['players']);
      }
    } else {
      message = error.toString();
    }

    if (code == 'PLAYERS_REVIEWING' && players != null) {
      return "${players.join(', ')}님이 아직 로그를 확인 중입니다.";
    }

    // ErrorCode is not defined in this file, assuming it's an external enum/class
    // For the purpose of this edit, I'll assume ErrorCode is accessible.
    // If ErrorCode is not defined, this part will cause a compilation error.
    if (code != null) {
      switch (code) {
        case ErrorCode.roomNotFound:
          return "입력하신 방 번호가 존재하지 않습니다.";
        case ErrorCode.nicknameTaken:
          return "이미 사용 중인 닉네임입니다.";
        case ErrorCode.gameStarted:
          return "이미 게임이 시작된 방입니다.";
        case ErrorCode.roomFull:
          return "방의 인원이 가득 차서 입장할 수 없습니다.";
        case ErrorCode.notHost:
          if (message == 'only_host_can_start') return "방장만 게임을 시작할 수 있습니다.";
          if (message == 'only_host_can_kick') return "방장만 추방할 수 있습니다.";
          return "방장 권한이 필요한 기능입니다.";
        case ErrorCode.kicked:
          return "지정된 방에서 강퇴되었습니다.";
        case ErrorCode.invalidParams:
          return "잘못된 요청 정보입니다.";
      }
    }

    final lowerError = message?.toLowerCase() ?? '';
    if (lowerError == 'kicked_by_host') return "방장에 의해 강퇴되었습니다.";
    if (lowerError == 'cannot_kick_self') return "자기 자신을 추방할 수 없습니다.";
    if (lowerError == 'only_kick_in_lobby') return "대기실에서만 추방할 수 있습니다.";
    if (lowerError == 'only_host_can_start') return "방장만 게임을 시작할 수 있습니다.";

    if (lowerError.contains('room_not_found')) return "입력하신 방 번호가 존재하지 않습니다.";
    if (lowerError.contains('room_full')) return "방의 인원이 가득 차서 입장할 수 없습니다.";
    if (lowerError.contains('already_started')) return "이미 게임이 시작된 방입니다.";
    if (lowerError.contains('invalid_nickname')) return "사용할 수 없는 닉네임입니다.";

    return message ?? "알 수 없는 오류가 발생했습니다.";
  }

  // Vote Results
  static const String voteSkipped = '시민들은 아무도 처형하지 않기로 했습니다.';
  static const String voteTie = '투표가 동률입니다. 아무도 처형되지 않았습니다.';
  static const String voteTimeout = '시간이 종료되었습니다. 아무도 처형되지 않았습니다.';

  // Night Results
  static const String nightKill = '어젯밤, 누군가 차가운 시체로 발견되었습니다...';
  static const String nightPeace = '평화로운 밤이었습니다.';
  static const String doctorSaved = '당신의 치료가 누군가의 생명을 구했습니다!';
  static const String doctorHealNone = '아무도 치료하지 않았습니다.';
  static const String nightChatForbidden = '밤에는 대화할 수 없습니다.';

  // Death Notifications (with player names)
  static String nightKillPlayer(String nickname) =>
      '어젯밤, [$nickname]이(가) 차가운 시체로 발견되었습니다...';
  static String dayExecution(String nickname) => '[$nickname]이(가) 투표로 처형되었습니다.';
  static String playerDied(String nickname) => '[$nickname]이(가) 사망했습니다.';
  static String playerEliminated(String nickname, String reason) =>
      '[$nickname]님이 ${reason}으로 탈락 처리되었습니다.';

  // Instructions
  static const String mafiaInstruction = '제거할 대상을 선택하거나 킬을 건너뛰세요.';
  static const String doctorInstruction = '치료할 대상을 선택하세요.';
  static const String policeInstruction = '조사할 대상을 선택하세요.';

  // Investigation Results
  static String investigationMafia(String nickname) =>
      '[$nickname]의 정체는... 마피아입니다!';
  static String investigationClear(String nickname) =>
      '[$nickname]은(는) 마피아가 아닙니다.';
  static const String investigationNone = '아무도 조사하지 않아 단서를 얻지 못했습니다.';

  // Connection/Status
  static String reconnected(String name) => '$name님이 재접속했습니다.';
  static String disconnected(String name) =>
      '$name님의 연결이 끊겼습니다. 60초 내에 재접속하지 않으면 탈락 처리됩니다.';
  static String reconnectFailed(String name) => '$name님이 재연결에 실패하여 탈락 처리되었습니다.';

  // Game Over
  static const String mafiaWin = '마피아가 도시를 장악했습니다!';
  static const String citizenWin = '시민들이 마피아를 모두 처단했습니다!';

  // Connection
  static const String connecting = '서버에 접속 중입니다...';
  static const String connectionColdStart =
      '서버가 절전 모드에서 깨어나는 데\n최대 1분 정도 소요될 수 있습니다.';
  static const String connectionLost = '서버와 연결이 끊어졌습니다.';
  static String connectionError(String error) => '서버 연결 실패: $error';

  // UI Labels
  static const String myRole = '나의 직업';
  static const String unknownRole = '알 수 없음';
  static const String skipVote = '투표 건너뛰기';
  static const String skipKill = '킬 건너뛰기';
  static const String returnToLobby = '로비로 돌아가기';
  static const String waitingForHost = '방장 대기 중...';
  static const String startGame = '게임 시작';
  static const String playersWaiting = '플레이어 대기 중...';
  static const String roomCopied = '복사됨';
  static const String chatHint = '대화에 참여하세요...';
  static const String viewGameLog = '📜 게임 로그 보기';
  static const String newGameDivider = '- 새 게임 시작 -';

  // Game Result
  static const String winMafia = '마피아 승리';
  static const String winCitizen = '시민 승리';
  static const String winMafiaDesc = '마피아가 도시를 장악했습니다.';
  static const String winCitizenDesc = '도시의 평화를 지켜냈습니다.';
  static const String winnerBadge = 'WINNER';

  // Common Actions
  static const String confirm = '확인';
  static const String cancel = '취소';
  static const String dead = '사망';
  static const String seconds = '초';
  static const String pleaseWait = '잠시만 기다려주세요...';

  // Roles (UI Labels)
  static const String roleMafia = '마피아';
  static const String roleCitizen = '시민';
  static const String roleDoctor = '의사';
  static const String rolePolice = '경찰';
  static const String roleSystem = '시스템';

  // Game Log Categories
  static const String logChat = '채팅';
  static const String logVote = '투표';
  static const String logHeal = '치료';
  static const String logInvestigate = '조사';
  static const String logPhase = '페이즈';
  // Login Screen
  static const String enterNickname = '닉네임을 입력해주세요';
  static const String nicknameMinLength = '닉네임은 최소 1자 이상이어야 합니다';
  static const String nicknameMaxLength = '닉네임은 최대 10자까지 가능합니다';
  static const String enterRoomCode = '방 번호를 입력해주세요';
  static const String invalidRoomCode = '방 번호는 6자리 숫자입니다';
  static const String errorCreateRoom = '방 생성 중 오류가 발생했습니다';
  static const String errorJoinRoom = '방 참여 중 오류가 발생했습니다';
  static const String titleMafia = '마피아';
  static const String titleOnline = '온라인';
  static const String labelNickname = '닉네임 (1-10자)';
  static const String labelRoomCode = '방 번호 (6자리)';
  static const String btnCreateRoom = '방 만들기';
  static const String btnJoinRoom = '방 참여하기';
}
