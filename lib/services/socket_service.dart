import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';

/// Callback types for event handling
typedef SocketVoidCallback = void Function();
typedef SocketDataCallback = void Function(dynamic data);

/// Service class responsible for Socket.IO connection management
/// Separates socket logic from game state management
class SocketService {
  io.Socket? _socket;
  final List<Map<String, dynamic>> _pendingListeners = [];

  io.Socket? get socket => _socket;

  /// Initialize and connect to the server
  void initialize(String uuid) {
    if (_socket != null) {
      _socket?.dispose();
    }
    _socket = io.io(AppConfig.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': AppConfig.reconnectionAttempts,
      'reconnectionDelay': AppConfig.reconnectionDelayMs,
      'reconnectionDelayMax': AppConfig.reconnectionDelayMaxMs,
      'timeout': AppConfig.connectionTimeoutMs,
      'query': {'uuid': uuid},
    });

    // Apply/Re-apply all registered listeners to the new socket instance
    for (final item in _pendingListeners) {
      final type = item['type'] as String;
      final event = item['event'] as String?;
      final callback = item['callback'];

      if (type == 'connect') {
        _socket?.on('connect', (_) => (callback as SocketVoidCallback)());
      } else if (type == 'disconnect') {
        _socket?.onDisconnect((_) => (callback as SocketVoidCallback)());
      } else if (type == 'connect_error') {
        _socket?.onConnectError(callback as SocketDataCallback);
      } else if (type == 'error') {
        _socket?.onError(callback as SocketDataCallback);
      } else if (type == 'regular' && event != null) {
        _socket?.on(event, callback as SocketDataCallback);
      }
    }
  }

  /// Connect to the server
  void connect() {
    _socket?.connect();
  }

  /// Disconnect from the server
  void disconnect() {
    _socket?.disconnect();
  }

  /// Remove event listener
  void off(String event, [dynamic callback]) {
    _pendingListeners.removeWhere(
      (item) =>
          item['type'] == 'regular' &&
          item['event'] == event &&
          (callback == null || item['callback'] == callback),
    );
    _socket?.off(event, callback);
  }

  /// Dispose socket resources
  void dispose() {
    _socket?.dispose();
    _socket = null;
  }

  /// Register event listener
  void on(String event, SocketDataCallback callback) {
    // Prevent duplicate registration of the same callback instance
    final isDuplicate = _pendingListeners.any(
      (item) =>
          item['type'] == 'regular' &&
          item['event'] == event &&
          item['callback'] == callback,
    );
    if (isDuplicate) return;

    // Record for re-initialization survival
    _pendingListeners.add({
      'type': 'regular',
      'event': event,
      'callback': callback,
    });

    // Apply immediate if socket exists
    _socket?.on(event, callback);
  }

  /// Register connection event
  void onConnect(SocketVoidCallback callback) {
    final isDuplicate = _pendingListeners.any(
      (item) => item['type'] == 'connect' && item['callback'] == callback,
    );
    if (isDuplicate) return;

    _pendingListeners.add({'type': 'connect', 'callback': callback});
    _socket?.on('connect', (_) => callback());
  }

  /// Register disconnect event
  void onDisconnect(SocketVoidCallback callback) {
    final isDuplicate = _pendingListeners.any(
      (item) => item['type'] == 'disconnect' && item['callback'] == callback,
    );
    if (isDuplicate) return;

    _pendingListeners.add({'type': 'disconnect', 'callback': callback});
    _socket?.onDisconnect((_) => callback());
  }

  /// Register connection error event
  void onConnectError(SocketDataCallback callback) {
    final isDuplicate = _pendingListeners.any(
      (item) => item['type'] == 'connect_error' && item['callback'] == callback,
    );
    if (isDuplicate) return;

    _pendingListeners.add({'type': 'connect_error', 'callback': callback});
    _socket?.onConnectError(callback);
  }

  /// Register general error event
  void onError(SocketDataCallback callback) {
    final isDuplicate = _pendingListeners.any(
      (item) => item['type'] == 'error' && item['callback'] == callback,
    );
    if (isDuplicate) return;

    _pendingListeners.add({'type': 'error', 'callback': callback});
    _socket?.onError(callback);
  }

  /// Emit event to server
  void emit(String event, [dynamic data]) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    }
  }

  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  /// Get socket ID
  String? get id => _socket?.id;
}
