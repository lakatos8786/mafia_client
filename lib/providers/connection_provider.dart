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
    _socketService.on('connect', (_) {
      developer.log('DEBUG: Connected to server: ${_socketService.id}');
      state = state.copyWith(status: 'connected', error: null);
    });

    _socketService.on('disconnect', (_) {
      state = state.copyWith(status: 'disconnected', error: '서버와 연결이 끊어졌습니다.');
    });

    _socketService.on('reconnect_attempt', (attemptNumber) {
      state = state.copyWith(
        status: 'reconnecting',
        error: '재연결 시도 중... ($attemptNumber/${AppConfig.reconnectionAttempts})',
      );
    });

    _socketService.on('reconnect', (_) {
      state = state.copyWith(status: 'connected', error: null);
    });

    _socketService.on('reconnect_failed', (_) {
      state = state.copyWith(status: 'error', error: '재연결 실패. 앱을 다시 시작해 주세요.');
    });

    _socketService.onConnectError((data) {
      final errorMsg = ErrorHandler.handleError('socket_connection', data);
      state = state.copyWith(status: 'error', error: errorMsg);
    });

    _socketService.onError((data) {
      final errorMsg = ErrorHandler.handleError('socket_error', data);
      state = state.copyWith(error: errorMsg);
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final connectionProvider = connectionNotifierProvider;
