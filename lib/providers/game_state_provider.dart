import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../models/event_models.dart';
import '../../services/error_handler.dart';
import 'connection_provider.dart';

import '../../models/game_settings.dart';

import '../../services/socket_service.dart';

part 'game_state_provider.g.dart';

class GameState {
  final List<Player> players;
  final GamePhase gamePhase;
  final int dayCount;
  final GameRole? myRole;
  final String? roomId;
  final bool isAdmin;
  final Map<String, int> roleCounts;
  final int timerRemaining;
  final int timerTotal;
  final String? winner;
  final List<Player> endGamePlayers;
  final DateTime? gameOverTime;
  final List<Map<String, dynamic>> gameLog;
  final GameSettings gameSettings;
  final bool isUnlimited;
  final dynamic errorMessage;
  final DateTime? lastErrorTime;

  const GameState({
    this.players = const [],
    this.gamePhase = GamePhase.waiting,
    this.dayCount = 1,
    this.myRole,
    this.roomId,
    this.isAdmin = false,
    this.roleCounts = const {},
    this.timerRemaining = 0,
    this.timerTotal = 0,
    this.winner,
    this.endGamePlayers = const [],
    this.gameOverTime,
    this.gameLog = const [],
    this.gameSettings = const GameSettings(),
    this.isUnlimited = false,
    this.errorMessage,
    this.lastErrorTime,
  });

  // Custom getters
  String get gameStateLabel => gamePhase.label;
  double get timerProgress =>
      timerTotal > 0 ? timerRemaining / timerTotal : 0.0;

  bool get canReturnToLobby {
    if (gameOverTime == null) return true;
    return DateTime.now().difference(gameOverTime!).inSeconds >= 2;
  }

  List<String> get roleCountDisplayStrings {
    return roleCounts.entries.map((e) {
      final role = GameRole.fromString(e.key);
      String emoji = '';
      switch (role) {
        case GameRole.mafia:
          emoji = '🕶️ ';
          break;
        case GameRole.doctor:
          emoji = '💉 ';
          break;
        case GameRole.police:
          emoji = '🚨 ';
          break;
        case GameRole.citizen:
          emoji = '👤 ';
          break;
        case GameRole.madman:
          emoji = '🤡 ';
          break;
        case GameRole.politician:
          emoji = '🏛️ ';
          break;
        case GameRole.soldier:
          emoji = '🎖️ ';
          break;
        default:
          break;
      }
      final label = role?.label ?? e.key;
      return '$emoji$label ${e.value}';
    }).toList();
  }

  // Compact version for single-row header (emoji + number only)
  List<String> get roleCountCompact {
    return roleCounts.entries.map((e) {
      final role = GameRole.fromString(e.key);
      String emoji = '';
      switch (role) {
        case GameRole.mafia:
          emoji = '🕶️';
          break;
        case GameRole.doctor:
          emoji = '💉';
          break;
        case GameRole.police:
          emoji = '🚨';
          break;
        case GameRole.citizen:
          emoji = '👤';
          break;
        case GameRole.madman:
          emoji = '🤡';
          break;
        case GameRole.politician:
          emoji = '🏛️';
          break;
        case GameRole.soldier:
          emoji = '🎖️';
          break;
        default:
          break;
      }
      return '$emoji${e.value}';
    }).toList();
  }

  GameState copyWith({
    List<Player>? players,
    GamePhase? gamePhase,
    int? dayCount,
    GameRole? myRole,
    String? roomId,
    bool? isAdmin,
    Map<String, int>? roleCounts,
    int? timerRemaining,
    int? timerTotal,
    String? winner,
    List<Player>? endGamePlayers,
    DateTime? gameOverTime,
    List<Map<String, dynamic>>? gameLog,
    GameSettings? gameSettings,
    bool? isUnlimited,
    dynamic errorMessage,
    DateTime? lastErrorTime,
  }) {
    return GameState(
      players: players ?? this.players,
      gamePhase: gamePhase ?? this.gamePhase,
      dayCount: dayCount ?? this.dayCount,
      myRole: myRole ?? this.myRole,
      roomId: roomId ?? this.roomId,
      isAdmin: isAdmin ?? this.isAdmin,
      roleCounts: roleCounts ?? this.roleCounts,
      timerRemaining: timerRemaining ?? this.timerRemaining,
      timerTotal: timerTotal ?? this.timerTotal,
      winner: winner ?? this.winner,
      endGamePlayers: endGamePlayers ?? this.endGamePlayers,
      gameOverTime: gameOverTime ?? this.gameOverTime,
      gameLog: gameLog ?? this.gameLog,
      gameSettings: gameSettings ?? this.gameSettings,
      isUnlimited: isUnlimited ?? this.isUnlimited,
      errorMessage: errorMessage ?? this.errorMessage,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
    );
  }
}

final gameStateProvider = gameStateNotifierProvider;

@Riverpod(keepAlive: true)
class GameStateNotifier extends _$GameStateNotifier {
  @override
  GameState build() {
    final socket = ref.read(connectionProvider.notifier).socketService;

    // Register all listeners
    _setupListeners(socket);

    ref.onDispose(() {
      _cleanupListeners(socket);
    });

    return const GameState();
  }

  void _setupListeners(SocketService socket) {
    socket.on(SocketEvent.roomCreated, _onRoomCreated);
    socket.on(SocketEvent.joinedRoom, _onJoinedRoom);
    socket.on(SocketEvent.playerUpdate, _onPlayerUpdate);
    socket.on(SocketEvent.updateSettings, _onUpdateSettings);
    socket.on(SocketEvent.roleCounts, _onRoleCounts);
    socket.on(SocketEvent.roleAssigned, _onRoleAssigned);
    socket.on(SocketEvent.startGame, _onStartGame);
    socket.on(SocketEvent.phaseChange, _onPhaseChange);
    socket.on(SocketEvent.gameOver, _onGameOver);
    socket.on(SocketEvent.timerTick, _onTimerTick);
    socket.on(SocketEvent.error, _onServerError);
    socket.on(SocketEvent.kicked, _onKicked);
    socket.on(SocketEvent.stateSync, _onStateSync);
  }

  void _cleanupListeners(SocketService socket) {
    socket.off(SocketEvent.roomCreated, _onRoomCreated);
    socket.off(SocketEvent.joinedRoom, _onJoinedRoom);
    socket.off(SocketEvent.playerUpdate, _onPlayerUpdate);
    socket.off(SocketEvent.updateSettings, _onUpdateSettings);
    socket.off(SocketEvent.roleCounts, _onRoleCounts);
    socket.off(SocketEvent.roleAssigned, _onRoleAssigned);
    socket.off(SocketEvent.startGame, _onStartGame);
    socket.off(SocketEvent.phaseChange, _onPhaseChange);
    socket.off(SocketEvent.gameOver, _onGameOver);
    socket.off(SocketEvent.timerTick, _onTimerTick);
    socket.off(SocketEvent.error, _onServerError);
    socket.off(SocketEvent.kicked, _onKicked);
    socket.off(SocketEvent.stateSync, _onStateSync);
  }

  void _onRoomCreated(dynamic roomId) {
    state = GameState(roomId: roomId?.toString(), isAdmin: true);
  }

  void _onJoinedRoom(dynamic roomId) {
    state = GameState(roomId: roomId?.toString(), isAdmin: false);
  }

  void _onPlayerUpdate(dynamic data) {
    try {
      if (data is List) {
        final players = data
            .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
            .toList();

        final myId = ref.read(connectionProvider.notifier).socketId;

        List<Player> sanitizedPlayers = players;
        if (state.gamePhase == GamePhase.waiting) {
          sanitizedPlayers = players
              .map(
                (p) => p.copyWith(isAlive: true, role: null, isRevealed: false),
              )
              .toList();
        }

        final myRole = _deriveMyRole(sanitizedPlayers, myId);
        final isAdmin = sanitizedPlayers.any((p) => p.id == myId && p.isHost);

        state = state.copyWith(
          players: sanitizedPlayers,
          myRole: myRole,
          isAdmin: isAdmin,
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('player_update', e, stackTrace);
    }
  }

  void _onUpdateSettings(dynamic data) {
    try {
      if (data is Map) {
        state = state.copyWith(
          gameSettings: GameSettings.fromMap(Map<String, dynamic>.from(data)),
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('update_settings', e, stackTrace);
    }
  }

  void _onRoleCounts(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid role counts data format');
      }
      final event = RoleCountsEvent.fromJson(Map<String, dynamic>.from(data));
      state = state.copyWith(roleCounts: event.roleCounts);
    } catch (e, stackTrace) {
      ErrorHandler.logError('role_counts', e, stackTrace);
    }
  }

  void _onRoleAssigned(dynamic data) {
    final role = GameRole.fromString(data.toString());
    state = state.copyWith(myRole: role);
  }

  void _onStartGame(dynamic _) {
    state = state.copyWith(
      gamePhase: GamePhase.day,
      dayCount: 1,
      gameLog: [],
      timerRemaining: 0,
      timerTotal: 0,
      isUnlimited: false,
    );
  }

  void _onPhaseChange(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid phase change data format');
      }
      final event = PhaseChangeEvent.fromJson(Map<String, dynamic>.from(data));

      if (event.phase == GamePhase.waiting &&
          state.gamePhase == GamePhase.result) {
        developer.log(
          'Ignoring phase change to lobby (still in result screen)',
        );
        return;
      }

      state = state.copyWith(
        gamePhase: event.phase,
        dayCount: event.dayCount,
        isUnlimited: false,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('phase_change', e, stackTrace);
    }
  }

  void _onGameOver(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid game over data format');
      }
      final event = GameOverEvent.fromJson(Map<String, dynamic>.from(data));
      state = state.copyWith(
        winner: event.winner?.label ?? '알 수 없음',
        gamePhase: GamePhase.result,
        endGamePlayers: event.players
            .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        gameOverTime: DateTime.now(),
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('game_over', e, stackTrace);
    }
  }

  void _onTimerTick(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid timer tick data format');
      }
      final event = TimerTickEvent.fromJson(Map<String, dynamic>.from(data));
      state = state.copyWith(
        timerRemaining: event.remaining,
        timerTotal: event.total,
        isUnlimited: event.isUnlimited,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('timer_tick', e, stackTrace);
    }
  }

  void _onServerError(dynamic data) {
    developer.log('Server Error received: $data');
    state = state.copyWith(errorMessage: data, lastErrorTime: DateTime.now());
  }

  void _onKicked(dynamic data) {
    developer.log('Kicked from room: $data');
    state = GameState(errorMessage: data, lastErrorTime: DateTime.now());
  }

  void _onStateSync(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid state sync data format');
      }
      final mappedData = Map<String, dynamic>.from(data);
      developer.log('STATE_SYNC received: $mappedData');

      final playersData = mappedData[ProtocolKey.players] as List;
      List<Player> players = playersData
          .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      final rawPhase = mappedData[ProtocolKey.phase] as String;
      final phase = GamePhase.fromString(rawPhase);

      if (phase == GamePhase.waiting) {
        players = players
            .map((p) => p.copyWith(isAlive: true, role: null))
            .toList();
      }

      final myRole = phase == GamePhase.waiting
          ? null
          : GameRole.fromString(mappedData[ProtocolKey.role]?.toString());

      final myId = ref.read(connectionProvider.notifier).socketId;

      final finalPhase =
          (phase == GamePhase.waiting && state.gamePhase == GamePhase.result)
          ? GamePhase.result
          : phase;

      state = state.copyWith(
        players: players,
        gamePhase: finalPhase,
        dayCount: mappedData[ProtocolKey.dayCount] as int? ?? 1,
        myRole: myRole,
        gameSettings: GameSettings.fromMap(
          Map<String, dynamic>.from(mappedData[ProtocolKey.settings] ?? {}),
        ),
        timerRemaining: mappedData['timerRemaining'] as int? ?? 0,
        timerTotal: mappedData['timerTotal'] as int? ?? 0,
        isUnlimited: mappedData['isUnlimited'] as bool? ?? false,
        isAdmin: players.any((p) => p.id == myId && p.isHost),
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('state_sync', e, stackTrace);
    }
  }

  void addGameLogEntry(String type, Map<String, dynamic> data) {
    final newEntry = {
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
    state = state.copyWith(gameLog: [...state.gameLog, newEntry]);
  }

  void returnToLobby() {
    developer.log('Returning to lobby (client-side reset)');

    ref
        .read(connectionProvider.notifier)
        .socketService
        .emit('return_to_lobby', null);

    final currentRoomId = state.roomId;
    final currentIsAdmin = state.isAdmin;
    final currentPlayers = state.players;
    final currentSettings = state.gameSettings;
    final myId = ref.read(connectionProvider.notifier).socketId;

    state = GameState(
      roomId: currentRoomId,
      isAdmin: currentIsAdmin,
      players: currentPlayers
          .map(
            (p) => p.copyWith(
              isAlive: true,
              role: null,
              isRevealed: false,
              atLobby: p.id == myId,
            ),
          )
          .toList(),
      gameSettings: currentSettings,
      gamePhase: GamePhase.waiting,
      dayCount: 1,
      myRole: null,
    );
  }

  GameRole? _deriveMyRole(List<Player> players, String? myId) {
    try {
      final me = players.firstWhere((p) => p.id == myId);
      return me.role;
    } catch (_) {
      return state.myRole;
    }
  }
}
