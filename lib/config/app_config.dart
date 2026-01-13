/// Application configuration constants
class AppConfig {
  /// Server URL for Socket.IO connection
  /// Change this for different environments (development, staging, production)
  static const String serverUrl = 'https://mafia-server-py70.onrender.com';

  /// Socket connection settings
  static const int connectionTimeoutMs = 60000; // 60s for cold start handling
  static const int reconnectionAttempts =
      15; // Increased for cold start handling
  static const int reconnectionDelayMs = 2000; // Start with 2s delay
  static const int reconnectionDelayMaxMs =
      30000; // Allow up to 30s for cold starts

  /// Game settings
  static const int gameOverDelaySeconds = 2;
}
