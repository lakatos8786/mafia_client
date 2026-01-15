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
      final event = item['event'] as String;
      final callback = item['callback'];

      // Clean up any existing listener for this event on the new socket before adding
      _socket?.off(event);

      if (event == 'connect') {
        _socket?.on('connect', (_) => (callback as SocketVoidCallback)());
      } else if (event == 'disconnect') {
        _socket?.onDisconnect((_) => (callback as SocketVoidCallback)());
      } else if (event == 'connect_error') {
        _socket?.onConnectError(callback as SocketDataCallback);
      } else if (event == 'error') {
        _socket?.onError(callback as SocketDataCallback);
      } else {
        _socket?.on(event, callback as SocketDataCallback);
      }
    }
    // We intentionally do NOT clear _pendingListeners here so they
    // persist across future re-initializations.
  }

  /// Connect to the server
  void connect() {
    _socket?.connect();
  }

  /// Disconnect from the server
  void disconnect() {
    _socket?.disconnect();
  }

  /// Dispose socket resources
  void dispose() {
    _socket?.dispose();
    _socket = null;
  }

  /// Register event listener
  void on(String event, SocketDataCallback callback) {
    // Record for re-initialization survival
    _pendingListeners.removeWhere((item) => item['event'] == event);
    _pendingListeners.add({'event': event, 'callback': callback});

    // Apply immediate if socket exists
    _socket?.on(event, callback);
  }

  /// Register connection event
  void onConnect(SocketVoidCallback callback) {
    _pendingListeners.removeWhere((item) => item['event'] == 'connect');
    _pendingListeners.add({'event': 'connect', 'callback': callback});
    _socket?.on('connect', (_) => callback());
  }

  /// Register disconnect event
  void onDisconnect(SocketVoidCallback callback) {
    _pendingListeners.removeWhere((item) => item['event'] == 'disconnect');
    _pendingListeners.add({'event': 'disconnect', 'callback': callback});
    _socket?.onDisconnect((_) => callback());
  }

  /// Register connection error event
  void onConnectError(SocketDataCallback callback) {
    _pendingListeners.removeWhere((item) => item['event'] == 'connect_error');
    _pendingListeners.add({'event': 'connect_error', 'callback': callback});
    _socket?.onConnectError(callback);
  }

  /// Register general error event
  void onError(SocketDataCallback callback) {
    _pendingListeners.removeWhere((item) => item['event'] == 'error');
    _pendingListeners.add({'event': 'error', 'callback': callback});
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
