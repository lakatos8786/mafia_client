import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';

/// Callback types for event handling
typedef SocketVoidCallback = void Function();
typedef SocketDataCallback = void Function(dynamic data);

/// Service class responsible for Socket.IO connection management
/// Separates socket logic from game state management
class SocketService {
  late io.Socket _socket;

  io.Socket get socket => _socket;

  /// Initialize and connect to the server
  void initialize() {
    _socket = io.io(AppConfig.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': AppConfig.reconnectionAttempts,
      'reconnectionDelay': AppConfig.reconnectionDelayMs,
      'reconnectionDelayMax': AppConfig.reconnectionDelayMaxMs,
      'timeout': AppConfig.connectionTimeoutMs,
    });
  }

  /// Connect to the server
  void connect() {
    _socket.connect();
  }

  /// Disconnect from the server
  void disconnect() {
    _socket.disconnect();
  }

  /// Dispose socket resources
  void dispose() {
    _socket.dispose();
  }

  /// Register event listener
  void on(String event, SocketDataCallback callback) {
    _socket.on(event, callback);
  }

  /// Register connection event
  void onConnect(SocketVoidCallback callback) {
    _socket.on('connect', (_) => callback());
  }

  /// Register disconnect event
  void onDisconnect(SocketVoidCallback callback) {
    _socket.onDisconnect((_) => callback());
  }

  /// Register connection error event
  void onConnectError(SocketDataCallback callback) {
    _socket.onConnectError(callback);
  }

  /// Register general error event
  void onError(SocketDataCallback callback) {
    _socket.onError(callback);
  }

  /// Emit event to server
  void emit(String event, [dynamic data]) {
    if (_socket.connected) {
      _socket.emit(event, data);
    }
  }

  /// Check if socket is connected
  bool get isConnected => _socket.connected;

  /// Get socket ID
  String? get id => _socket.id;
}
