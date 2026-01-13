import 'package:flutter/foundation.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../models/event_models.dart';
import '../services/error_handler.dart';
import '../theme/app_strings.dart';
import 'connection_provider.dart';
import 'game_state_provider.dart';

/// Manages player actions (voting, night actions, chat)
/// Separated from game state for better organization
class ActionProvider with ChangeNotifier {
  final ConnectionProvider _connectionProvider;
  final GameStateProvider _gameStateProvider;

  // Vote state
  Map<String, int> _votes = {};
  Map<String, String> _voters = {};

  // Night action state
  final Map<String, String> _nightSelections = {};
  final Map<String, String> _nightActionActors = {};

  // Chat state
  final List<Map<String, dynamic>> _messages = [];

  // Getters
  Map<String, int> get votes => _votes;
  Map<String, String> get voters => _voters;
  Map<String, String> get nightSelections => _nightSelections;
  Map<String, String> get nightActionActors => _nightActionActors;
  List<Map<String, dynamic>> get messages => _messages;

  // UI Helpers
  List<String> get skipVoterNicknames {
    return voters.entries.where((entry) => entry.value == GameAction.skip).map((
      entry,
    ) {
      final voter = _gameStateProvider.players.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Player(id: 'unknown', nickname: '알 수 없음', isAlive: true),
      );
      return voter.nickname;
    }).toList();
  }

  bool get iVotedSkip =>
      voters[_connectionProvider.socketId] == GameAction.skip;

  bool get isMafiaSkip =>
      nightSelections[GameRole.mafia.name] == GameAction.skip;

  String get mafiaSkipButtonText {
    final actor = nightActionActors[GameRole.mafia.name] ?? '';
    return isMafiaSkip ? '킬 건너뛰기 ($actor)' : '킬 건너뛰기';
  }

  ActionProvider(this._connectionProvider, this._gameStateProvider) {
    _setupListeners();
  }

  void _setupListeners() {
    final socket = _connectionProvider.socketService;

    // Game Flow Events (for System Messages & Data Reset)
    socket.on(SocketEvent.startGame, (_) {
      _addSystemMessage(AppStrings.gameStarted);
      resetAllData();
    });

    socket.on(SocketEvent.phaseChange, (data) {
      if (data is Map) {
        final phase = GamePhase.fromString(data['phase']?.toString() ?? '');
        final phaseMsg = phase == GamePhase.day
            ? AppStrings.dayStarted
            : AppStrings.nightStarted;

        // Only show message if not returning to lobby (which handles its own reset)
        if (phase != GamePhase.waiting) {
          _addSystemMessage(phaseMsg);
          resetTurnData();
        }
      }
    });

    socket.on(SocketEvent.gameOver, (data) {
      if (data is Map) {
        final winnerRole = GameRole.fromString(data['winner']?.toString());
        final winMsg = winnerRole == GameRole.mafia
            ? AppStrings.mafiaWin
            : AppStrings.citizenWin;
        _addSystemMessage(winMsg);
      }
    });

    // Vote events
    socket.on(SocketEvent.voteUpdate, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid vote update data format');
        }
        final event = VoteUpdateEvent.fromJson(data);
        _votes = event.votes;
        _voters = event.voters;
        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('vote_update', e, stackTrace);
      }
    });

    // Night action events
    socket.on(SocketEvent.nightSelectionUpdate, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid night selection data format');
        }
        final event = NightSelectionEvent.fromJson(data);
        if (event.role != null) {
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
      } catch (e, stackTrace) {
        ErrorHandler.logError('night_selection', e, stackTrace);
      }
    });

    socket.on(SocketEvent.investigationResult, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid investigation result data format');
        }
        final event = InvestigationResultEvent.fromJson(data);
        final targetNick = _gameStateProvider.players
            .firstWhere(
              (p) => p.id == event.targetId,
              orElse: () => Player(id: '', nickname: '?', isAlive: true),
            )
            .nickname;

        final resultMsg = event.role == GameRole.mafia
            ? AppStrings.investigationMafia(targetNick)
            : AppStrings.investigationClear(targetNick);
        _addSystemMessage(resultMsg);
        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('investigation_result', e, stackTrace);
      }
    });

    socket.on(SocketEvent.nightResult, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid night result data format');
        }
        final event = NightResultEvent.fromJson(data);
        if (event.message.isNotEmpty) {
          _addSystemMessage(event.message);
        }
        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('night_result', e, stackTrace);
      }
    });

    // Chat events
    socket.on(SocketEvent.chatMessage, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid chat message data format');
        }
        final event = ChatMessageEvent.fromJson(data);
        _messages.add({
          'sender': event.sender,
          'message': event.message,
          'type': event.type.name,
          'isSystem': event.sender == SystemConstant.sender,
        });

        _gameStateProvider.addGameLogEntry('chat', {
          'sender': event.sender,
          'message': event.message,
          'type': event.type.name,
        });

        notifyListeners();
      } catch (e, stackTrace) {
        ErrorHandler.logError('chat_message', e, stackTrace);
      }
    });
  }

  // Actions
  void vote(String targetId) {
    if (_gameStateProvider.gamePhase == GamePhase.day &&
        _connectionProvider.socketId != null) {
      debugPrint('Voting for: $targetId');

      final myId = _connectionProvider.socketId!;
      final previousVote = _voters[myId];

      // Toggle logic
      if (previousVote == targetId) {
        _voters.remove(myId);
        // previousVote is non-null here due to equality check
        final count = _votes[previousVote!];
        if (count != null) {
          _votes[previousVote] = count - 1;
          if (_votes[previousVote]! <= 0) _votes.remove(previousVote);
        }
      } else {
        if (previousVote != null) {
          final count = _votes[previousVote];
          if (count != null) {
            _votes[previousVote] = count - 1;
            if (_votes[previousVote]! <= 0) _votes.remove(previousVote);
          }
        }
        _voters[myId] = targetId;
        _votes[targetId] = (_votes[targetId] ?? 0) + 1;
      }

      notifyListeners();
      _connectionProvider.socketService.emit(SocketEvent.vote, targetId);
    }
  }

  void nightAction(String action, String targetId) {
    if (_gameStateProvider.gamePhase == GamePhase.night &&
        _gameStateProvider.myRoleEnum != null) {
      debugPrint('Night Action: $action -> $targetId');

      final roleKey = _gameStateProvider.myRoleEnum!.name;
      final currentSelection = _nightSelections[roleKey];

      if (currentSelection == targetId) {
        _nightSelections.remove(roleKey);
        _nightActionActors.remove(roleKey);
      } else {
        _nightSelections[roleKey] = targetId;
        final me = _gameStateProvider.players.firstWhere(
          (p) => p.id == _connectionProvider.socketId,
          orElse: () => Player(id: '', nickname: '', isAlive: false),
        );
        _nightActionActors[roleKey] = me.nickname;
      }

      notifyListeners();

      _connectionProvider.socketService.emit(SocketEvent.nightAction, {
        ProtocolKey.action: action,
        ProtocolKey.targetId: targetId,
      });
    }
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    _connectionProvider.socketService.emit(SocketEvent.chatMessage, message);
  }

  void resetTurnData() {
    _votes.clear();
    _voters.clear();
    _nightSelections.clear();
    _nightActionActors.clear();
    notifyListeners();
  }

  void resetAllData() {
    _votes.clear();
    _voters.clear();
    _nightSelections.clear();
    _nightActionActors.clear();
    _messages.clear();
    notifyListeners();
  }

  void _addSystemMessage(String msg) {
    _messages.add({
      'sender': SystemConstant.sender,
      'message': msg,
      'type': ChatMessageType.system.name,
      'isSystem': true,
    });
    // Only log if we have a valid socket connection
    if (_connectionProvider.socketId != null) {
      _gameStateProvider.addGameLogEntry('system', {'message': msg});
    }
  }
}
