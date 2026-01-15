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

    // Apply pending listeners
    for (final item in _pendingListeners) {
      final event = item['event'] as String;
      final callback = item['callback'];
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
    _pendingListeners.clear();
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
    if (_socket != null) {
      _socket!.on(event, callback);
    } else {
      _pendingListeners.add({'event': event, 'callback': callback});
    }
  }

  /// Register connection event
  void onConnect(SocketVoidCallback callback) {
    if (_socket != null) {
      _socket!.on('connect', (_) => callback());
    } else {
      _pendingListeners.add({'event': 'connect', 'callback': callback});
    }
  }

  /// Register disconnect event
  void onDisconnect(SocketVoidCallback callback) {
    if (_socket != null) {
      _socket!.onDisconnect((_) => callback());
    } else {
      _pendingListeners.add({'event': 'disconnect', 'callback': callback});
    }
  }

  /// Register connection error event
  void onConnectError(SocketDataCallback callback) {
    if (_socket != null) {
      _socket!.onConnectError(callback);
    } else {
      _pendingListeners.add({'event': 'connect_error', 'callback': callback});
    }
  }

  /// Register general error event
  void onError(SocketDataCallback callback) {
    if (_socket != null) {
      _socket!.onError(callback);
    } else {
      _pendingListeners.add({'event': 'error', 'callback': callback});
    }
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
