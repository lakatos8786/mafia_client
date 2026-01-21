import '../models/game_enums.dart';

class GameSettings {
  final int dayDuration;
  final int nightDuration;
  final int? mafiaCount;
  final int? policeCount;
  final int? doctorCount;
  final int? madmanCount;
  final int? politicianCount;
  final int? soldierCount;

  const GameSettings({
    this.dayDuration = 240,
    this.nightDuration = 40,
    this.mafiaCount,
    this.policeCount,
    this.doctorCount,
    this.madmanCount,
    this.politicianCount,
    this.soldierCount,
  });

  factory GameSettings.fromMap(Map<String, dynamic> map) {
    return GameSettings(
      dayDuration: (map[ProtocolKey.dayDuration] as num?)?.toInt() ?? 240,
      nightDuration: (map[ProtocolKey.nightDuration] as num?)?.toInt() ?? 40,
      mafiaCount: (map[ProtocolKey.mafiaCount] as num?)?.toInt(),
      policeCount: (map[ProtocolKey.policeCount] as num?)?.toInt(),
      doctorCount: (map[ProtocolKey.doctorCount] as num?)?.toInt(),
      madmanCount: (map[ProtocolKey.madmanCount] as num?)?.toInt(),
      politicianCount: (map[ProtocolKey.politicianCount] as num?)?.toInt(),
      soldierCount: (map[ProtocolKey.soldierCount] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ProtocolKey.dayDuration: dayDuration,
      ProtocolKey.nightDuration: nightDuration,
      ProtocolKey.mafiaCount: mafiaCount,
      ProtocolKey.policeCount: policeCount,
      ProtocolKey.doctorCount: doctorCount,
      ProtocolKey.madmanCount: madmanCount,
      ProtocolKey.politicianCount: politicianCount,
      ProtocolKey.soldierCount: soldierCount,
    };
  }

  GameSettings copyWith({
    int? dayDuration,
    int? nightDuration,
    int? mafiaCount,
    int? policeCount,
    int? doctorCount,
    int? madmanCount,
    int? politicianCount,
    int? soldierCount,
    bool clearMafia = false,
    bool clearPolice = false,
    bool clearDoctor = false,
    bool clearMadman = false,
    bool clearPolitician = false,
    bool clearSoldier = false,
  }) {
    return GameSettings(
      dayDuration: dayDuration ?? this.dayDuration,
      nightDuration: nightDuration ?? this.nightDuration,
      mafiaCount: clearMafia ? null : (mafiaCount ?? this.mafiaCount),
      policeCount: clearPolice ? null : (policeCount ?? this.policeCount),
      doctorCount: clearDoctor ? null : (doctorCount ?? this.doctorCount),
      madmanCount: clearMadman ? null : (madmanCount ?? this.madmanCount),
      politicianCount: clearPolitician
          ? null
          : (politicianCount ?? this.politicianCount),
      soldierCount: clearSoldier ? null : (soldierCount ?? this.soldierCount),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameSettings &&
        other.dayDuration == dayDuration &&
        other.nightDuration == nightDuration &&
        other.mafiaCount == mafiaCount &&
        other.policeCount == policeCount &&
        other.doctorCount == doctorCount &&
        other.madmanCount == madmanCount &&
        other.politicianCount == politicianCount &&
        other.soldierCount == soldierCount;
  }

  @override
  int get hashCode {
    return dayDuration.hashCode ^
        nightDuration.hashCode ^
        mafiaCount.hashCode ^
        policeCount.hashCode ^
        doctorCount.hashCode ^
        madmanCount.hashCode ^
        politicianCount.hashCode ^
        soldierCount.hashCode;
  }

  @override
  String toString() {
    return 'GameSettings(day: $dayDuration, night: $nightDuration, mafia: $mafiaCount, police: $policeCount, doctor: $doctorCount, madman: $madmanCount, politician: $politicianCount, soldier: $soldierCount)';
  }
}
