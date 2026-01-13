import 'package:flutter/foundation.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../services/socket_service.dart';
import 'connection_provider.dart';
import 'game_state_provider.dart';
import 'action_provider.dart';

/// Unified GameProvider that combines all sub-providers
/// Maintains backward compatibility with existing code
/// while providing better separation of concerns
class GameProvider with ChangeNotifier {
  final ConnectionProvider connectionProvider;
  final GameStateProvider gameStateProvider;
  final ActionProvider actionProvider;

  GameProvider({
    required this.connectionProvider,
    required this.gameStateProvider,
    required this.actionProvider,
  }) {
    // Listen to sub-providers and propagate changes
    connectionProvider.addListener(notifyListeners);
    gameStateProvider.addListener(notifyListeners);
    actionProvider.addListener(notifyListeners);
  }

  // ========== Delegated Getters ==========

  // Connection
  String get connectionState => connectionProvider.connectionState;
  String? get errorMessage => connectionProvider.errorMessage;
  SocketService get socket => connectionProvider.socketService;
  String? get myId => connectionProvider.socketId;
  bool get isConnected => connectionProvider.isConnected;

  // Game State
  List<Player> get players => gameStateProvider.players;
  GamePhase get gamePhase => gameStateProvider.gamePhase;
  String get gameState => gameStateProvider.gameState;
  int get dayCount => gameStateProvider.dayCount;
  GameRole? get myRoleEnum => gameStateProvider.myRoleEnum;
  String? get myRole => gameStateProvider.myRole;
  String? get roomId => gameStateProvider.roomId;
  bool get isAdmin => gameStateProvider.isAdmin;
  Map<String, int> get roleCounts => gameStateProvider.roleCounts;
  List<String> get roleCountDisplayStrings =>
      gameStateProvider.roleCountDisplayStrings;
  int get timerRemaining => gameStateProvider.timerRemaining;
  int get timerTotal => gameStateProvider.timerTotal;
  double get timerProgress => gameStateProvider.timerProgress;
  String? get winner => gameStateProvider.winner;
  List<Player> get endGamePlayers => gameStateProvider.endGamePlayers;
  List<Map<String, dynamic>> get gameLog => gameStateProvider.gameLog;
  bool get canReturnToLobby => gameStateProvider.canReturnToLobby;

  // Actions
  Map<String, int> get votes => actionProvider.votes;
  Map<String, String> get voters => actionProvider.voters;
  Map<String, String> get nightSelections => actionProvider.nightSelections;
  Map<String, String> get nightActionActors => actionProvider.nightActionActors;
  List<Map<String, dynamic>> get messages => actionProvider.messages;
  List<String> get skipVoterNicknames => actionProvider.skipVoterNicknames;
  bool get iVotedSkip => actionProvider.iVotedSkip;
  bool get isMafiaSkip => actionProvider.isMafiaSkip;
  String get mafiaSkipButtonText => actionProvider.mafiaSkipButtonText;

  // Loading state (kept for compatibility)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ========== Delegated Actions ==========

  void createRoom(String nickname) {
    debugPrint('Emitting create_room: $nickname');
    socket.emit(SocketEvent.createRoom, nickname);
  }

  void joinRoom(String roomId, String nickname) {
    debugPrint('Emitting join_room: $nickname, $roomId');
    socket.emit(SocketEvent.joinRoom, {
      ProtocolKey.roomId: roomId,
      ProtocolKey.nickname: nickname,
    });
  }

  void startGame() {
    debugPrint('Emitting start_game');
    if (roomId != null) {
      socket.emit(SocketEvent.startGame);
    }
  }

  void vote(String targetId) => actionProvider.vote(targetId);

  void nightAction(String action, String targetId) =>
      actionProvider.nightAction(action, targetId);

  void sendMessage(String message) => actionProvider.sendMessage(message);

  void returnToLobby() {
    gameStateProvider.returnToLobby();
    actionProvider.resetAllData();
  }

  void clearError() => connectionProvider.clearError();

  @override
  void dispose() {
    connectionProvider.removeListener(notifyListeners);
    gameStateProvider.removeListener(notifyListeners);
    actionProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
