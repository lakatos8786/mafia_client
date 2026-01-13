import 'package:flutter/material.dart';

import '../models/game_enums.dart';
import '../models/player.dart';
import '../models/event_models.dart';
import '../theme/app_strings.dart';
import '../config/app_config.dart';
import '../services/error_handler.dart';
import '../services/socket_service.dart';

// Player class moved to models/player.dart

class GameProvider with ChangeNotifier {
  late IO.Socket _socket;

  // State Variables
  List<Player> _players = [];
  GamePhase _gameState = GamePhase.waiting;
  int _dayCount = 1;
  GameRole? _myRole;
  final List<Map<String, dynamic>> _messages = [];
  Map<String, int> _votes = {};
  Map<String, String> _voters = {}; // { voterId: targetId }
  final Map<String, String> _nightSelections = {};
  final Map<String, String> _nightActionActors = {};

  bool _isAdmin = false;
  String? _myId;
  String? _errorMessage;
  String? _roomId;
  String? _winner;
  List<Player> _endGamePlayers = [];
  DateTime? _gameOverTime;

  // Timer state
  int _timerRemaining = 0;
  int _timerTotal = 0;

  // Loading states
  bool _isLoading = false;

  // Connection state
  String _connectionState =
      'connecting'; // connecting, connected, reconnecting, disconnected, error

  // Game log
  final List<Map<String, dynamic>> _gameLog = [];

  // Getters
  List<Player> get players => _players;
  String get gameState => _gameState.label;
  GamePhase get gamePhase => _gameState;
  int get dayCount => _dayCount;
  String? get myRole => _myRole?.label; // Deprecated: Use myRoleEnum for logic
  GameRole? get myRoleEnum => _myRole;
  List<Map<String, dynamic>> get messages => _messages;
  Map<String, int> get votes => _votes;
  Map<String, String> get voters => _voters;
  Map<String, String> get nightSelections => _nightSelections;
  Map<String, String> get nightActionActors => _nightActionActors;
  String? get myId => _myId;
  String? get errorMessage => _errorMessage;
  String? get roomId => _roomId;
  String? get winner => _winner;
  List<Player> get endGamePlayers => _endGamePlayers;
  bool get isAdmin => _isAdmin;
  int get timerRemaining => _timerRemaining;
  int get timerTotal => _timerTotal;
  bool get isLoading => _isLoading;
  String get connectionState => _connectionState;
  List<Map<String, dynamic>> get gameLog => _gameLog;

  // Timer progress (0.0 to 1.0)
  double get timerProgress =>
      _timerTotal > 0 ? _timerRemaining / _timerTotal : 0.0;

  bool get canReturnToLobby {
    if (_gameOverTime == null) return true;
    return DateTime.now().difference(_gameOverTime!).inSeconds >=
        AppConfig.gameOverDelaySeconds;
  }

  // --- UI Helpers ---
  List<String> get skipVoterNicknames {
    return voters.entries.where((entry) => entry.value == GameAction.skip).map((
      entry,
    ) {
      final voter = players.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Player(id: 'unknown', nickname: '알 수 없음', isAlive: true),
      );
      return voter.nickname;
    }).toList();
  }

  bool get iVotedSkip => voters[socket.id] == GameAction.skip;

  bool get isMafiaSkip =>
      nightSelections[GameRole.mafia.name] == GameAction.skip;
  String get mafiaSkipButtonText {
    final actor = nightActionActors[GameRole.mafia.name] ?? '';
    return isMafiaSkip ? '킬 건너뛰기 ($actor)' : '킬 건너뛰기';
  }

  IO.Socket get socket => _socket;

  Map<String, int> _roleCounts = {};
  Map<String, int> get roleCounts => _roleCounts;

  /// Returns role counts as "RoleName: Count" in Korean
  List<String> get roleCountDisplayStrings {
    return _roleCounts.entries.map((e) {
      final role = GameRole.fromString(e.key);
      final label = role?.label ?? e.key;
      return '$label ${e.value}';
    }).toList();
  }

  GameProvider() {
    _initSocket();
  }

  void _initSocket() {
    print('Initializing socket connection to ${AppConfig.serverUrl}');
    _socket = IO.io(AppConfig.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': AppConfig.reconnectionAttempts,
      'reconnectionDelay': AppConfig.reconnectionDelayMs,
      'reconnectionDelayMax': AppConfig.reconnectionDelayMaxMs,
      'timeout': AppConfig.connectionTimeoutMs,
    });

    _setupListeners();
    _socket.connect();
  }

  void _setupListeners() {
    _handleConnectionEvents();
    _handleRoomEvents();
    _handleGameFlowEvents();
    _handleActionEvents();
    _handleMessageEvents();
    _handleTimerEvents();
  }

  void _handleConnectionEvents() {
    _socket.on('connect', (_) {
      print('DEBUG: Connected to server: ${_socket.id}');
      _myId = _socket.id;
      _errorMessage = null;
      _connectionState = 'connected';
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _connectionState = 'disconnected';
      _errorMessage = '서버와 연결이 끊어졌습니다.';
      notifyListeners();
    });

    _socket.on('reconnect_attempt', (attemptNumber) {
      _connectionState = 'reconnecting';
      _errorMessage =
          '재연결 시도 중... ($attemptNumber/${AppConfig.reconnectionAttempts})';
      notifyListeners();
    });

    _socket.on('reconnect', (_) {
      _connectionState = 'connected';
      _errorMessage = null;
      notifyListeners();
    });

    _socket.on('reconnect_failed', (_) {
      _connectionState = 'error';
      _errorMessage = '재연결 실패. 앱을 다시 시작해 주세요.';
      notifyListeners();
    });

    _socket.onConnectError((data) {
      _connectionState = 'error';
      _errorMessage = ErrorHandler.handleError('socket_connection', data);
      notifyListeners();
    });

    _socket.onError((data) {
      _errorMessage = ErrorHandler.handleError('socket_error', data);
      notifyListeners();
    });
  }

  void _handleRoomEvents() {
    _socket.on(SocketEvent.roomCreated, (roomId) {
      _roomId = roomId;
      _isAdmin = true;
      notifyListeners();
    });

    _socket.on(SocketEvent.joinedRoom, (roomId) {
      _roomId = roomId;
      _isAdmin = false;
      notifyListeners();
    });

    _socket.on(SocketEvent.playerUpdate, (data) {
      try {
        if (data is List) {
          _players = data
              .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          _myRole = _deriveMyRole();
          notifyListeners();
        }
      } catch (e, stackTrace) {
        _errorMessage = ErrorHandler.handleError(
          'player_update',
          e,
          stackTrace,
        );
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.roleCounts, (data) {
      if (data is Map) {
        try {
          _roleCounts = data.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          );
        } catch (e, stackTrace) {
          _errorMessage = ErrorHandler.handleError(
            'role_counts',
            e,
            stackTrace,
          );
        }
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.roleAssigned, (data) {
      _myRole = GameRole.fromString(data.toString());
      notifyListeners();
    });
  }

  void _handleGameFlowEvents() {
    _socket.on(SocketEvent.startGame, (_) {
      _gameState = GamePhase.day;
      _dayCount = 1;
      _resetGameData();
      _addSystemMessage(AppStrings.gameStarted);
      notifyListeners();
    });

    _socket.on(SocketEvent.phaseChange, (data) {
      try {
        if (data is Map) {
          final event = PhaseChangeEvent.fromJson(
            Map<String, dynamic>.from(data),
          );
          _gameState = event.phase;
          _dayCount = event.dayCount;
          final phaseMsg = _gameState == GamePhase.day
              ? AppStrings.dayStarted
              : AppStrings.nightStarted;
          _addSystemMessage(phaseMsg);
          _resetTurnData();
          notifyListeners();
        }
      } catch (e, stackTrace) {
        _errorMessage = ErrorHandler.handleError('phase_change', e, stackTrace);
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.gameOver, (data) {
      if (data is Map) {
        try {
          final mappedData = Map<String, dynamic>.from(data);
          final winnerRole = GameRole.fromString(
            mappedData[ProtocolKey.winner],
          );
          _winner = winnerRole?.label ?? '알 수 없음';
          _gameState = GamePhase.result;

          if (mappedData[ProtocolKey.players] is List) {
            _endGamePlayers = (mappedData[ProtocolKey.players] as List)
                .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          }
          _gameOverTime = DateTime.now();
          final winMsg = _winner == '마피아'
              ? AppStrings.mafiaWin
              : AppStrings.citizenWin;
          _addSystemMessage(winMsg);
          notifyListeners();
        } catch (e, stackTrace) {
          _errorMessage = ErrorHandler.handleError('game_over', e, stackTrace);
          notifyListeners();
        }
      }
    });
  }

  void _handleActionEvents() {
    _socket.on(SocketEvent.voteUpdate, (data) {
      if (data is Map) {
        _votes = Map<String, int>.from(data[ProtocolKey.votes] ?? {});
        _voters = Map<String, String>.from(data[ProtocolKey.voters] ?? {});
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.nightSelectionUpdate, (data) {
      try {
        if (data is Map) {
          final event = NightSelectionEvent.fromJson(
            Map<String, dynamic>.from(data),
          );
          if (event.role != null) {
            // Handle cancel (null targetId)
            if (event.targetId == null) {
              _nightSelections.remove(event.role!.name);
              _nightActionActors.remove(event.role!.name);
            } else {
              _nightSelections[event.role!.name] = event.targetId!;
              if (event.actorNickname != null) {
                _nightActionActors[event.role!.name] = event.actorNickname!;
              }
            }
            notifyListeners();
          }
        }
      } catch (e, stackTrace) {
        _errorMessage = ErrorHandler.handleError(
          'night_selection',
          e,
          stackTrace,
        );
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.investigationResult, (data) {
      if (data is Map) {
        final targetId = data[ProtocolKey.targetId];
        final role = GameRole.fromString(data[ProtocolKey.role]);
        final targetNick = _players
            .firstWhere(
              (p) => p.id == targetId,
              orElse: () => Player(id: '', nickname: '?', isAlive: true),
            )
            .nickname;

        final resultMsg = role == GameRole.mafia
            ? AppStrings.investigationMafia(targetNick)
            : AppStrings.investigationClear(targetNick);
        _addSystemMessage(resultMsg);
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.nightResult, (data) {
      if (data is Map && data[ProtocolKey.message] != null) {
        _addSystemMessage(data[ProtocolKey.message]);
        notifyListeners();
      }
    });
  }

  void _handleMessageEvents() {
    _socket.on(SocketEvent.chatMessage, (data) {
      try {
        if (data is Map) {
          final event = ChatMessageEvent.fromJson(
            Map<String, dynamic>.from(data),
          );
          _messages.add({
            'sender': event.sender,
            'message': event.message,
            'type': event.type.name,
            'isSystem': event.sender == SystemConstant.sender,
          });

          // Log to game log for replay
          _addGameLogEntry('chat', {
            'sender': event.sender,
            'message': event.message,
            'type': event.type.name,
          });

          notifyListeners();
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError('chat_message', e, stackTrace);
        // Don't show error to user for chat messages, just log it
      }
    });
  }

  void _handleTimerEvents() {
    _socket.on(SocketEvent.timerTick, (data) {
      if (data is Map) {
        _timerRemaining = (data['remaining'] as num?)?.toInt() ?? 0;
        _timerTotal = (data['total'] as num?)?.toInt() ?? 0;
        notifyListeners();
      }
    });
  }

  void _addGameLogEntry(String type, Map<String, dynamic> data) {
    _gameLog.add({
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  // --- Internal Utilities ---
  void _resetGameData() {
    _votes.clear();
    _voters.clear();
    _nightSelections.clear();
    _nightActionActors.clear();
    _messages.clear();
    _timerRemaining = 0;
    _timerTotal = 0;
    _gameLog.clear();
  }

  void _resetTurnData() {
    _votes.clear();
    _voters.clear();
    _nightSelections.clear();
    _nightActionActors.clear();
  }

  void _addSystemMessage(String msg) {
    _messages.add({
      'sender': SystemConstant.sender,
      'message': msg,
      'type': ChatMessageType.system.name,
      'isSystem': true,
    });
    _addGameLogEntry('system', {'message': msg});
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Actions
  void createRoom(String nickname) {
    print('Emitting create_room: $nickname');
    if (_socket.connected) {
      _socket.emit(SocketEvent.createRoom, nickname);
    }
  }

  void joinRoom(String roomId, String nickname) {
    print('Emitting join_room: $nickname, $roomId');
    if (_socket.connected) {
      _socket.emit(SocketEvent.joinRoom, {
        ProtocolKey.roomId: roomId,
        ProtocolKey.nickname: nickname,
      });
    }
  }

  void startGame() {
    print('Emitting start_game');
    if (_socket.connected && _roomId != null) {
      _socket.emit(SocketEvent.startGame);
    }
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    _socket.emit(SocketEvent.chatMessage, message);
  }

  void vote(String targetId) {
    if (_gameState == GamePhase.day && _socket.id != null) {
      print('Voting for: $targetId');

      // Optimistic UI Update - Mirror server logic locally
      final myId = _socket.id!;
      final previousVote = _voters[myId];

      // 1. Toggle (Same Target) -> Unvote
      if (previousVote == targetId) {
        _voters.remove(myId);
        final voteKey = previousVote; // Already non-null due to if condition
        if (voteKey != null && _votes[voteKey] != null) {
          _votes[voteKey] = _votes[voteKey]! - 1;
          if (_votes[voteKey]! <= 0) _votes.remove(voteKey);
        }
      } else {
        // 2. Change Vote (Different Target)
        if (previousVote != null && _votes[previousVote] != null) {
          _votes[previousVote] = _votes[previousVote]! - 1;
          if (_votes[previousVote]! <= 0) _votes.remove(previousVote);
        }
        _voters[myId] = targetId;
        _votes[targetId] = (_votes[targetId] ?? 0) + 1;
      }

      notifyListeners(); // Update UI immediately

      _socket.emit(SocketEvent.vote, targetId);
    }
  }

  void nightAction(String action, String targetId) {
    if (_gameState == GamePhase.night && _myRole != null) {
      print('Night Action: $action -> $targetId');

      // Optimistic UI Update - Toggle logic
      final roleKey = _myRole!.name;
      final currentSelection = _nightSelections[roleKey];

      if (currentSelection == targetId) {
        // Toggle off - same target clicked again
        _nightSelections.remove(roleKey);
        _nightActionActors.remove(roleKey);
      } else {
        // New selection
        _nightSelections[roleKey] = targetId;
        // Find my nickname for actor display
        final me = _players.firstWhere(
          (p) => p.id == _socket.id,
          orElse: () => Player(id: '', nickname: '', isAlive: false),
        );
        _nightActionActors[roleKey] = me.nickname;
      }

      notifyListeners(); // Update UI immediately

      _socket.emit(SocketEvent.nightAction, {
        ProtocolKey.action: action,
        ProtocolKey.targetId: targetId,
      });
    }
  }

  void returnToLobby() {
    print('Returning to lobby (client-side reset)');
    _gameState = GamePhase.waiting;
    _winner = null;
    _endGamePlayers = [];
    _gameOverTime = null;
    _dayCount = 1;
    _votes.clear();
    _voters.clear();
    _messages.clear();
    _myRole = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  GameRole? _deriveMyRole() {
    try {
      final me = _players.firstWhere((p) => p.id == _socket.id);
      return me.role;
    } catch (_) {
      return _myRole; // Keep old role if not found in update
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    _socket.dispose();
    super.dispose();
  }
}
