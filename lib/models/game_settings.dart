import '../models/game_enums.dart';

class GameSettings {
  final int dayDuration;
  final int nightDuration;
  final int? mafiaCount;
  final int? policeCount;
  final int? doctorCount;

  const GameSettings({
    this.dayDuration = 60,
    this.nightDuration = 30,
    this.mafiaCount,
    this.policeCount,
    this.doctorCount,
  });

  factory GameSettings.fromMap(Map<String, dynamic> map) {
    return GameSettings(
      dayDuration: (map[ProtocolKey.dayDuration] as num?)?.toInt() ?? 60,
      nightDuration: (map[ProtocolKey.nightDuration] as num?)?.toInt() ?? 30,
      mafiaCount: (map[ProtocolKey.mafiaCount] as num?)?.toInt(),
      policeCount: (map[ProtocolKey.policeCount] as num?)?.toInt(),
      doctorCount: (map[ProtocolKey.doctorCount] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ProtocolKey.dayDuration: dayDuration,
      ProtocolKey.nightDuration: nightDuration,
      ProtocolKey.mafiaCount: mafiaCount,
      ProtocolKey.policeCount: policeCount,
      ProtocolKey.doctorCount: doctorCount,
    };
  }

  GameSettings copyWith({
    int? dayDuration,
    int? nightDuration,
    int? mafiaCount,
    int? policeCount,
    int? doctorCount,
    bool clearMafia = false,
    bool clearPolice = false,
    bool clearDoctor = false,
  }) {
    return GameSettings(
      dayDuration: dayDuration ?? this.dayDuration,
      nightDuration: nightDuration ?? this.nightDuration,
      mafiaCount: clearMafia ? null : (mafiaCount ?? this.mafiaCount),
      policeCount: clearPolice ? null : (policeCount ?? this.policeCount),
      doctorCount: clearDoctor ? null : (doctorCount ?? this.doctorCount),
    );
  }

  @override
  String toString() {
    return 'GameSettings(day: $dayDuration, night: $nightDuration, mafia: $mafiaCount, police: $policeCount, doctor: $doctorCount)';
  }
}
