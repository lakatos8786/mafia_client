import 'package:flutter/foundation.dart';
import '../services/socket_service.dart';
import '../services/error_handler.dart';
import '../config/app_config.dart';

/// Manages socket connection state and lifecycle
/// Separated from game logic for better testability
class ConnectionProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();

  // Connection state
  String _connectionState =
      'connecting'; // connecting, connected, reconnecting, disconnected, error
  String? _errorMessage;

  // Getters
  String get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  SocketService get socketService => _socketService;
  String? get socketId => _socketService.id;
  bool get isConnected => _socketService.isConnected;

  ConnectionProvider() {
    _initSocket();
  }

  void _initSocket() {
    debugPrint('Initializing socket connection to ${AppConfig.serverUrl}');
    _socketService.initialize();
    _setupConnectionListeners();
    _socketService.connect();
  }

  void _setupConnectionListeners() {
    _socketService.on('connect', (_) {
      debugPrint('DEBUG: Connected to server: ${_socketService.id}');
      _errorMessage = null;
      _connectionState = 'connected';
      notifyListeners();
    });

    _socketService.on('disconnect', (_) {
      _connectionState = 'disconnected';
      _errorMessage = '서버와 연결이 끊어졌습니다.';
      notifyListeners();
    });

    _socketService.on('reconnect_attempt', (attemptNumber) {
      _connectionState = 'reconnecting';
      _errorMessage =
          '재연결 시도 중... ($attemptNumber/${AppConfig.reconnectionAttempts})';
      notifyListeners();
    });

    _socketService.on('reconnect', (_) {
      _connectionState = 'connected';
      _errorMessage = null;
      notifyListeners();
    });

    _socketService.on('reconnect_failed', (_) {
      _connectionState = 'error';
      _errorMessage = '재연결 실패. 앱을 다시 시작해 주세요.';
      notifyListeners();
    });

    _socketService.onConnectError((data) {
      _connectionState = 'error';
      _errorMessage = ErrorHandler.handleError('socket_connection', data);
      notifyListeners();
    });

    _socketService.onError((data) {
      _errorMessage = ErrorHandler.handleError('socket_error', data);
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _socketService.dispose();
    super.dispose();
  }
}
