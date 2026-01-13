import 'package:flutter/foundation.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../models/event_models.dart';
import '../services/error_handler.dart';
import 'connection_provider.dart';

/// Manages core game state (players, phase, roles, timer)
/// Separated from actions and connection for better organization
class GameStateProvider with ChangeNotifier {
  final ConnectionProvider _connectionProvider;

  // Game state
  List<Player> _players = [];
  GamePhase _gamePhase = GamePhase.waiting;
  int _dayCount = 1;
  GameRole? _myRole;
  String? _roomId;
  bool _isAdmin = false;
  Map<String, int> _roleCounts = {};

  // Timer state
  int _timerRemaining = 0;
  int _timerTotal = 0;

  // Game end state
  String? _winner;
  List<Player> _endGamePlayers = [];
  DateTime? _gameOverTime;

  // Game log for replay
  final List<Map<String, dynamic>> _gameLog = [];

  // Getters
  List<Player> get players => _players;
  GamePhase get gamePhase => _gamePhase;
  String get gameState => _gamePhase.label;
  int get dayCount => _dayCount;
  GameRole? get myRoleEnum => _myRole;
  String? get myRole => _myRole?.label;
  String? get roomId => _roomId;
  bool get isAdmin => _isAdmin;
  Map<String, int> get roleCounts => _roleCounts;
  int get timerRemaining => _timerRemaining;
  int get timerTotal => _timerTotal;
  double get timerProgress =>
      _timerTotal > 0 ? _timerRemaining / _timerTotal : 0.0;
  String? get winner => _winner;
  List<Player> get endGamePlayers => _endGamePlayers;
  List<Map<String, dynamic>> get gameLog => _gameLog;
  String? get myId => _connectionProvider.socketId;

  bool get canReturnToLobby {
    if (_gameOverTime == null) return true;
    return DateTime.now().difference(_gameOverTime!).inSeconds >= 2;
  }

  List<String> get roleCountDisplayStrings {
    return _roleCounts.entries.map((e) {
      final role = GameRole.fromString(e.key);
      final label = role?.label ?? e.key;
      return '$label ${e.value}';
    }).toList();
  }

  GameStateProvider(this._connectionProvider) {
    _setupListeners();
  }

  void _setupListeners() {
    final socket = _connectionProvider.socketService;

    // Room events
    socket.on(SocketEvent.roomCreated, (roomId) {
      _roomId = roomId;
      _isAdmin = true;
      notifyListeners();
    });

    socket.on(SocketEvent.joinedRoom, (roomId) {
      _roomId = roomId;
      _isAdmin = false;
      notifyListeners();
    });

    socket.on(SocketEvent.playerUpdate, (data) {
      try {
        if (data is List) {
          _players = data
              .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          _myRole = _deriveMyRole();
          notifyListeners();
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError('player_update', e, stackTrace);
      }
    });

    socket.on(SocketEvent.roleCounts, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid role counts data format');
        }
        final event = RoleCountsEvent.fromJson(data);
        _roleCounts = event.roleCounts;
        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('role_counts', e, stackTrace);
      }
    });

    socket.on(SocketEvent.roleAssigned, (data) {
      _myRole = GameRole.fromString(data.toString());
      notifyListeners();
    });

    // Game flow events
    socket.on(SocketEvent.startGame, (_) {
      _gamePhase = GamePhase.day;
      _dayCount = 1;
      _resetGameData();
      notifyListeners();
    });

    socket.on(SocketEvent.phaseChange, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid phase change data format');
        }
        final event = PhaseChangeEvent.fromJson(data);
        _gamePhase = event.phase;
        _dayCount = event.dayCount;

        // If phase returns to lobby, reset state
        if (_gamePhase == GamePhase.waiting) {
          returnToLobby();
          return;
        }

        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('phase_change', e, stackTrace);
      }
    });

    socket.on(SocketEvent.gameOver, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid game over data format');
        }
        final event = GameOverEvent.fromJson(data);
        _winner = event.winner?.label ?? '알 수 없음';
        _gamePhase = GamePhase.result;
        _endGamePlayers = event.players.map((e) => Player.fromMap(e)).toList();
        _gameOverTime = DateTime.now();
        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('game_over', e, stackTrace);
      }
    });

    // Timer events
    socket.on(SocketEvent.timerTick, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid timer tick data format');
        }
        final event = TimerTickEvent.fromJson(data);
        _timerRemaining = event.remaining;
        _timerTotal = event.total;
        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('timer_tick', e, stackTrace);
      }
    });
  }

  void _resetGameData() {
    _gameLog.clear();
    _timerRemaining = 0;
    _timerTotal = 0;
  }

  void addGameLogEntry(String type, Map<String, dynamic> data) {
    _gameLog.add({
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  void returnToLobby() {
    debugPrint('Returning to lobby (client-side reset)');
    _gamePhase = GamePhase.waiting;
    _winner = null;
    _endGamePlayers = [];
    _gameOverTime = null;
    _dayCount = 1;
    _myRole = null;
    notifyListeners();
  }

  GameRole? _deriveMyRole() {
    try {
      final me = _players.firstWhere(
        (p) => p.id == _connectionProvider.socketId,
      );
      return me.role;
    } catch (_) {
      return _myRole;
    }
  }
}
