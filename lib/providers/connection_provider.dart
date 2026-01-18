import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/socket_service.dart';
import '../../services/error_handler.dart';
import '../../config/app_config.dart';
import '../services/storage_service.dart';

part 'connection_provider.g.dart';

class ConnectionState {
  final String status;
  final String? error;

  const ConnectionState({this.status = 'connecting', this.error});

  ConnectionState copyWith({String? status, String? error}) {
    return ConnectionState(status: status ?? this.status, error: error);
  }

  bool get isConnected => status == 'connected';
}

@Riverpod(keepAlive: true)
class ConnectionNotifier extends _$ConnectionNotifier {
  final SocketService _socketService = SocketService();

  SocketService get socketService => _socketService;
  String? get socketId => _socketService.id;

  @override
  ConnectionState build() {
    // Initialize socket on build
    _initSocket();

    // Dispose socket when provider is disposed
    ref.onDispose(() {
      _socketService.disconnect();
      _socketService.dispose();
    });

    return const ConnectionState();
  }

  void _initSocket() async {
    developer.log('Initializing socket connection to ${AppConfig.serverUrl}');
    try {
      final uuid = await StorageService.getOrPlayerUuid();
      _socketService.initialize(uuid);
      _setupConnectionListeners();
      _socketService.connect();
    } catch (e, stackTrace) {
      ErrorHandler.logError('socket_init', e, stackTrace);
      state = state.copyWith(status: 'error', error: '초기화 실패');
    }
  }

  void _setupConnectionListeners() {
    _socketService.onConnect(_onConnect);
    _socketService.onDisconnect(_onDisconnect);
    _socketService.on('reconnect_attempt', _onReconnectAttempt);
    _socketService.on('reconnect', _onReconnect);
    _socketService.on('reconnect_failed', _onReconnectFailed);
    _socketService.onConnectError(_onConnectError);
    _socketService.onError(_onSocketError);
  }

  void _onConnect() {
    developer.log('DEBUG: Connected to server: ${_socketService.id}');
    state = state.copyWith(status: 'connected', error: null);
  }

  void _onDisconnect() {
    state = state.copyWith(status: 'disconnected', error: '서버와 연결이 끊어졌습니다.');
  }

  void _onReconnectAttempt(dynamic attemptNumber) {
    state = state.copyWith(
      status: 'reconnecting',
      error: '재연결 시도 중... ($attemptNumber/${AppConfig.reconnectionAttempts})',
    );
  }

  void _onReconnect(dynamic _) {
    state = state.copyWith(status: 'connected', error: null);
  }

  void _onReconnectFailed(dynamic _) {
    state = state.copyWith(status: 'error', error: '재연결 실패. 앱을 다시 시작해 주세요.');
  }

  void _onConnectError(dynamic data) {
    final errorMsg = ErrorHandler.handleError('socket_connection', data);
    state = state.copyWith(status: 'error', error: errorMsg);
  }

  void _onSocketError(dynamic data) {
    final errorMsg = ErrorHandler.handleError('socket_error', data);
    state = state.copyWith(error: errorMsg);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final connectionProvider = connectionNotifierProvider;
