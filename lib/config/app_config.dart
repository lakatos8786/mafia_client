/// Application configuration constants
class AppConfig {
  /// Server URL for Socket.IO connection
  /// Change this for different environments (development, staging, production)
  static const String serverUrl = 'https://mafia-server-py70.onrender.com';

  /// Connection settings
  static const int connectionTimeoutMs = 10000;
  static const int reconnectionAttempts = 3;

  /// Game settings
  static const int gameOverDelaySeconds = 2;
  static const int dayTimerSeconds = 120;
  static const int nightTimerSeconds = 60;
}
