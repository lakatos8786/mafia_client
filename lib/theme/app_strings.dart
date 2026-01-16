/// Centralized system messages and UI strings for the Mafia game.
/// This makes localization and message consistency easier to manage.
class AppStrings {
  // Game Start
  static const String gameStarted = '당신의 역할이 부여되었습니다. 정체를 숨기세요.';

  // Phase Changes
  static const String dayStarted = '동이 텄습니다. 마피아를 찾아내세요!';
  static const String nightStarted = '밤이 찾아왔습니다. 어둠 속에서 누군가 움직입니다...';

  // Vote Results
  static const String voteSkipped = '시민들은 아무도 처형하지 않기로 했습니다.';
  static const String voteTie = '투표가 동률입니다. 아무도 처형되지 않았습니다.';
  static const String voteTimeout = '시간이 종료되었습니다. 아무도 처형되지 않았습니다.';

  // Night Results
  static const String nightKill = '어젯밤, 누군가 차가운 시체로 발견되었습니다...';
  static const String nightPeace = '평화로운 밤이었습니다.';
  static const String doctorSaved = '당신의 치료가 누군가의 생명을 구했습니다!';
  static const String doctorHealNone = '아무도 치료하지 않았습니다.';

  // Death Notifications (with player names)
  static String nightKillPlayer(String nickname) =>
      '어젯밤, [$nickname]이(가) 차가운 시체로 발견되었습니다...';
  static String dayExecution(String nickname) => '[$nickname]이(가) 투표로 처형되었습니다.';
  static String playerDied(String nickname) => '[$nickname]이(가) 사망했습니다.';

  // Investigation Results
  static String investigationMafia(String nickname) =>
      '[$nickname]의 정체는... 마피아입니다!';
  static String investigationClear(String nickname) =>
      '[$nickname]은(는) 마피아가 아닙니다.';
  static const String investigationNone = '아무도 조사하지 않아 단서를 얻지 못했습니다.';

  // Game Over
  static const String mafiaWin = '마피아가 도시를 장악했습니다!';
  static const String citizenWin = '시민들이 마피아를 모두 처단했습니다!';

  // Connection
  static const String connecting = '서버에 접속 중입니다...';
  static const String connectionColdStart =
      '서버가 절전 모드에서 깨어나는 데\n최대 1분 정도 소요될 수 있습니다.';
  static const String disconnected = '서버와 연결이 끊어졌습니다.';
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
  static const String newGameDivider = '─ 새 게임 시작 ─';

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
  static const String enterRoomCode = '방 코드를 입력해주세요';
  static const String invalidRoomCode = '방 코드는 6자리 숫자입니다';
  static const String errorCreateRoom = '방 생성 중 오류가 발생했습니다';
  static const String errorJoinRoom = '방 참여 중 오류가 발생했습니다';
  static const String titleMafia = '마피아';
  static const String titleOnline = '온라인';
  static const String labelNickname = '닉네임 (1-10자)';
  static const String labelRoomCode = '방 코드 (6자리)';
  static const String btnCreateRoom = '방 만들기';
  static const String btnJoinRoom = '방 참여하기';
}
