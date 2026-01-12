enum GameRole {
  mafia,
  doctor,
  police,
  citizen;

  // Converts from server string/Korean string to Enum
  static GameRole? fromString(String? val) {
    if (val == null) return null;
    switch (val) {
      case '마피아':
      case 'MAFIA':
        return GameRole.mafia;
      case '의사':
      case 'DOCTOR':
        return GameRole.doctor;
      case '경찰':
      case 'POLICE':
        return GameRole.police;
      case '시민':
      case 'CITIZEN':
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
  String get id {
    switch (this) {
      case GameRole.mafia:
        return 'mafia';
      case GameRole.doctor:
        return 'doctor';
      case GameRole.police:
        return 'police';
      case GameRole.citizen:
        return 'citizen';
    }
  }
}

enum GamePhase {
  day,
  night,
  waiting,
  result;

  static GamePhase fromString(String val) {
    switch (val) {
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
