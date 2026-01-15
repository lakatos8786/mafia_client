import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A service to handle persistent local storage.
/// Currently used for storing the unique device/player ID to support session reconnection.
class StorageService {
  static const String _playerUuidKey = 'player_uuid';
  static const Uuid _uuid = Uuid();

  /// Gets the unique player UUID from storage, or creates a new one if it doesn't exist.
  static Future<String> getOrPlayerUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_playerUuidKey);

    if (uuid == null) {
      uuid = _uuid.v4();
      await prefs.setString(_playerUuidKey, uuid);
    }

    return uuid;
  }
}
