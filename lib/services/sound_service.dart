import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Define sound keys
  static const String sfxClick = 'sounds/click.mp3';
  static const String sfxVote = 'sounds/vote.mp3';
  static const String sfxDay = 'sounds/day_start.mp3';
  static const String sfxNight = 'sounds/night_start.mp3';
  static const String sfxWin = 'sounds/win.mp3';
  static const String sfxLoss = 'sounds/lose.mp3';

  Future<void> play(String assetPath) async {
    try {
      // Setup for low latency if possible, or just play
      // Note: for web/desktop, simple play is usually enough
      await _player
          .stop(); // Stop previous SFX to avoid overlap clutter? Or allow overlap?
      // For short SFX, overlap is better, but single player instance might cut off.
      // Let's create a new player for OneShot sounds if we want overlap,
      // but to keep it simple and CPU friendly, we'll try generic play.

      // Actually, standard AudioPlayer practice for SFX is to just play.
      // .play(AssetSource(...))

      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Ignore errors if file is missing (common during dev)
      print('Sound Error ($assetPath): $e');
    }
  }

  Future<void> playClick() async => play(sfxClick);
  Future<void> playVote() async => play(sfxVote);
  Future<void> playDayStart() async => play(sfxDay);
  Future<void> playNightStart() async => play(sfxNight);
  Future<void> playWin() async => play(sfxWin);
  Future<void> playLose() async => play(sfxLoss);
}
