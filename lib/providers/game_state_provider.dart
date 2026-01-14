import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../models/event_models.dart';
import '../../services/error_handler.dart';
import 'connection_provider.dart';

import '../../models/game_settings.dart';

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
    );
  }
}

final gameStateProvider = gameStateNotifierProvider;

@Riverpod(keepAlive: true)
class GameStateNotifier extends _$GameStateNotifier {
  @override
  GameState build() {
    // We don't watch connectionNotifierProvider to avoid rebuilding on every connection status change
    // Instead we just access the socket service
    final socket = ref.read(connectionProvider.notifier).socketService;

    // Listeners are set up once

    // Room events
    socket.on(SocketEvent.roomCreated, (roomId) {
      state = state.copyWith(roomId: roomId, isAdmin: true);
    });

    socket.on(SocketEvent.joinedRoom, (roomId) {
      state = state.copyWith(roomId: roomId, isAdmin: false);
    });

    socket.on(SocketEvent.playerUpdate, (data) {
      try {
        if (data is List) {
          final players = data
              .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
              .toList();

          final myId = ref.read(connectionProvider.notifier).socketId;
          final myRole = _deriveMyRole(players, myId);

          state = state.copyWith(players: players, myRole: myRole);
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError('player_update', e, stackTrace);
      }
    });

    socket.on(SocketEvent.updateSettings, (data) {
      try {
        if (data is Map) {
          state = state.copyWith(
            gameSettings: GameSettings.fromMap(Map<String, dynamic>.from(data)),
          );
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError('update_settings', e, stackTrace);
      }
    });

    socket.on(SocketEvent.roleCounts, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid role counts data format');
        }
        final event = RoleCountsEvent.fromJson(data);
        state = state.copyWith(roleCounts: event.roleCounts);
      } catch (e, stackTrace) {
        ErrorHandler.logError('role_counts', e, stackTrace);
      }
    });

    socket.on(SocketEvent.roleAssigned, (data) {
      final role = GameRole.fromString(data.toString());
      state = state.copyWith(myRole: role);
    });

    // Game flow events
    socket.on(SocketEvent.startGame, (_) {
      state = state.copyWith(
        gamePhase: GamePhase.day,
        dayCount: 1,
        gameLog: [],
        timerRemaining: 0,
        timerTotal: 0,
        isUnlimited: false,
      );
    });

    socket.on(SocketEvent.phaseChange, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid phase change data format');
        }
        final event = PhaseChangeEvent.fromJson(data);

        // If phase returns to lobby, do NOT reset automatically.
        // Let the user click the button in GameResultOverlay.
        if (event.phase == GamePhase.waiting) {
          // returnToLobby(); // Disabled auto-return
          return; // Ignore this update so we stay in Result phase
        }

        state = state.copyWith(
          gamePhase: event.phase,
          dayCount: event.dayCount,
          isUnlimited: false, // Reset on phase change
        );
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
        state = state.copyWith(
          winner: event.winner?.label ?? '알 수 없음',
          gamePhase: GamePhase.result,
          endGamePlayers: event.players.map((e) => Player.fromMap(e)).toList(),
          gameOverTime: DateTime.now(),
        );
      } catch (e, stackTrace) {
        ErrorHandler.logError('game_over', e, stackTrace);
      }
    });

    socket.on(SocketEvent.timerTick, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid timer tick data format');
        }
        final event = TimerTickEvent.fromJson(data);
        state = state.copyWith(
          timerRemaining: event.remaining,
          timerTotal: event.total,
          isUnlimited: event.isUnlimited,
        );
      } catch (e, stackTrace) {
        ErrorHandler.logError('timer_tick', e, stackTrace);
      }
    });

    ref.onDispose(() {
      // Clean up listeners?
      // Since SocketService doesn't expose clean off(), we assume app lifecycle manages this
      // or we rely on socket disconnect.
      // If we strictly needed to, we would access socket.socket.off(...)
    });

    return const GameState();
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

    // Preserve connection and room info
    final currentRoomId = state.roomId;
    final currentIsAdmin = state.isAdmin;
    final currentPlayers =
        state.players; // Keep players list as we are still in the room

    // Reset game-specific state but keep room info
    state = GameState(
      roomId: currentRoomId,
      isAdmin: currentIsAdmin,
      players: currentPlayers,
      gamePhase: GamePhase.waiting,
      dayCount: 1,
      // all other fields default to initial values
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
