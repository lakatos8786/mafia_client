import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../models/chat_message.dart';
import '../../models/event_models.dart';
import '../../services/error_handler.dart';
import '../../theme/app_strings.dart';
import '../../models/game_settings.dart';

import 'connection_provider.dart';
import 'game_state_provider.dart';
import '../../services/socket_service.dart';

part 'action_provider.g.dart';

class ActionState {
  final Map<String, int> votes;
  final Map<String, String> voters;
  final Map<String, String> nightSelections;
  final Map<String, String> nightActionActors;
  final String? judgementTarget;
  final String? judgementTargetNickname;
  final Map<String, String> judgementVotes;
  final int yesCount;
  final int noCount;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? judgementResultData;

  const ActionState({
    this.votes = const {},
    this.voters = const {},
    this.nightSelections = const {},
    this.nightActionActors = const {},
    this.judgementTarget,
    this.judgementTargetNickname,
    this.judgementVotes = const {},
    this.yesCount = 0,
    this.noCount = 0,
    this.messages = const [],
    this.judgementResultData,
  });

  ActionState copyWith({
    Map<String, int>? votes,
    Map<String, String>? voters,
    Map<String, String>? nightSelections,
    Map<String, String>? nightActionActors,
    String? judgementTarget,
    String? judgementTargetNickname,
    Map<String, String>? judgementVotes,
    int? yesCount,
    int? noCount,
    List<ChatMessage>? messages,
    Map<String, dynamic>? judgementResultData,
    bool clearJudgementResult = false,
  }) {
    return ActionState(
      votes: votes ?? this.votes,
      voters: voters ?? this.voters,
      nightSelections: nightSelections ?? this.nightSelections,
      nightActionActors: nightActionActors ?? this.nightActionActors,
      judgementTarget: judgementTarget ?? this.judgementTarget,
      judgementTargetNickname:
          judgementTargetNickname ?? this.judgementTargetNickname,
      judgementVotes: judgementVotes ?? this.judgementVotes,
      yesCount: yesCount ?? this.yesCount,
      noCount: noCount ?? this.noCount,
      messages: messages ?? this.messages,
      judgementResultData: clearJudgementResult
          ? null
          : (judgementResultData ?? this.judgementResultData),
    );
  }
}

@Riverpod(keepAlive: true)
class ActionNotifier extends _$ActionNotifier {
  @override
  ActionState build() {
    final socket = ref.read(connectionProvider.notifier).socketService;

    // Register all listeners
    _setupListeners(socket);

    ref.onDispose(() {
      _cleanupListeners(socket);
    });

    return const ActionState();
  }

  void _setupListeners(SocketService socket) {
    socket.on(SocketEvent.startGame, _onStartGame);
    socket.on(SocketEvent.phaseChange, _onPhaseChange);
    socket.on(SocketEvent.judgementStarted, _onJudgementStarted);
    socket.on(SocketEvent.judgementUpdate, _onJudgementUpdate);
    socket.on(SocketEvent.judgementResult, _onJudgementResult);
    socket.on(SocketEvent.gameOver, _onGameOver);
    socket.on(SocketEvent.voteResult, _onVoteResult);
    socket.on(SocketEvent.playerEliminated, _onPlayerEliminated);
    socket.on(SocketEvent.playerDisconnected, _onPlayerDisconnected);
    socket.on(SocketEvent.playerReconnected, _onPlayerReconnected);
    socket.on(SocketEvent.reconnectFailed, _onReconnectFailed);
    socket.on(SocketEvent.voteUpdate, _onVoteUpdate);
    socket.on(SocketEvent.nightSelectionUpdate, _onNightSelectionUpdate);
    socket.on(SocketEvent.investigationResult, _onInvestigationResult);
    socket.on(SocketEvent.nightResult, _onNightResult);
    socket.on(SocketEvent.chatMessage, _onChatMessage);
    socket.on(SocketEvent.stateSync, _onStateSync);
  }

  void _cleanupListeners(SocketService socket) {
    socket.off(SocketEvent.startGame, _onStartGame);
    socket.off(SocketEvent.phaseChange, _onPhaseChange);
    socket.off(SocketEvent.judgementStarted, _onJudgementStarted);
    socket.off(SocketEvent.judgementUpdate, _onJudgementUpdate);
    socket.off(SocketEvent.judgementResult, _onJudgementResult);
    socket.off(SocketEvent.gameOver, _onGameOver);
    socket.off(SocketEvent.voteResult, _onVoteResult);
    socket.off(SocketEvent.playerEliminated, _onPlayerEliminated);
    socket.off(SocketEvent.playerDisconnected, _onPlayerDisconnected);
    socket.off(SocketEvent.playerReconnected, _onPlayerReconnected);
    socket.off(SocketEvent.reconnectFailed, _onReconnectFailed);
    socket.off(SocketEvent.voteUpdate, _onVoteUpdate);
    socket.off(SocketEvent.nightSelectionUpdate, _onNightSelectionUpdate);
    socket.off(SocketEvent.investigationResult, _onInvestigationResult);
    socket.off(SocketEvent.nightResult, _onNightResult);
    socket.off(SocketEvent.chatMessage, _onChatMessage);
    socket.off(SocketEvent.stateSync, _onStateSync);
  }

  void _onStartGame(dynamic _) {
    archiveMessages();
    _addSystemMessage(AppStrings.gameStarted);
    state = state.copyWith(clearJudgementResult: true);
  }

  void _onPhaseChange(dynamic data) {
    try {
      if (data is Map) {
        final phase = GamePhase.fromString(data['phase']?.toString() ?? '');
        final dayCount = int.tryParse(data['dayCount']?.toString() ?? '1') ?? 1;
        final socketId = ref.read(connectionProvider.notifier).socketId;
        final players = ref.read(gameStateProvider).players;
        final myRole = ref.read(gameStateProvider).myRole;

        state = state.copyWith(clearJudgementResult: true);

        if (phase != GamePhase.waiting) {
          if (phase == GamePhase.day) {
            _addSystemMessage(AppStrings.dayAnnouncement(dayCount));

            final me = players.firstWhere(
              (p) => p.id == socketId,
              orElse: () => Player(id: '', nickname: '', isAlive: false),
            );

            if (myRole == GameRole.doctor && dayCount > 1 && me.isAlive) {
              final mySelection = state.nightSelections[GameRole.doctor.name];
              if (mySelection == null || mySelection == GameAction.skip) {
                _addSystemMessage(AppStrings.doctorHealNone);
              }
            }
          } else if (phase == GamePhase.lastWord) {
            final nickname = data['nickname']?.toString() ?? '?';
            _addSystemMessage(AppStrings.lastWordAnnouncement(nickname));
          } else if (phase == GamePhase.judgement) {
            _addSystemMessage(AppStrings.judgementAnnouncement);
          } else if (phase == GamePhase.night) {
            _addSystemMessage(AppStrings.nightAnnouncement(dayCount));

            final me = players.firstWhere(
              (p) => p.id == socketId,
              orElse: () => Player(id: '', nickname: '', isAlive: false),
            );

            if (me.isAlive) {
              if (myRole == GameRole.mafia) {
                _addSystemMessage(AppStrings.mafiaInstruction);
              } else if (myRole == GameRole.doctor) {
                _addSystemMessage(AppStrings.doctorInstruction);
              } else if (myRole == GameRole.police) {
                _addSystemMessage(AppStrings.policeInstruction);
              }
            }
          }

          if (phase == GamePhase.day || phase == GamePhase.night) {
            resetTurnData();
          }
        }
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('phase_change', e, stackTrace);
    }
  }

  void _onJudgementStarted(dynamic data) {
    if (data is Map) {
      state = state.copyWith(
        judgementTarget: data['targetId']?.toString(),
        judgementTargetNickname: data['nickname']?.toString(),
        judgementVotes: {},
        yesCount: 0,
        noCount: 0,
        clearJudgementResult: true,
      );
    }
  }

  void _onJudgementUpdate(dynamic data) {
    if (data is Map) {
      state = state.copyWith(
        yesCount: int.tryParse(data['yesCount']?.toString() ?? '0') ?? 0,
        noCount: int.tryParse(data['noCount']?.toString() ?? '0') ?? 0,
        judgementVotes: Map<String, String>.from(data['voters'] ?? {}),
      );
    }
  }

  void _onJudgementResult(dynamic data) {
    if (data is Map) {
      final result = data['result']?.toString();
      final nickname = data['nickname']?.toString() ?? '?';

      state = state.copyWith(
        judgementResultData: Map<String, dynamic>.from(data),
      );

      if (result == 'executed') {
        _addSystemMessage(AppStrings.judgementExecuted(nickname));
      } else {
        _addSystemMessage(AppStrings.judgementSaved(nickname));
      }
    }
  }

  void _onGameOver(dynamic data) {
    if (data is Map) {
      state = state.copyWith(clearJudgementResult: true);
      final winnerRole = GameRole.fromString(data['winner']?.toString());
      final winMsg = winnerRole == GameRole.mafia
          ? AppStrings.mafiaWin
          : AppStrings.citizenWin;
      _addSystemMessage(winMsg);
    }
  }

  void _onVoteResult(dynamic data) {
    if (data is Map) {
      final result = data['result']?.toString();
      if (result == 'skip') {
        _addSystemMessage(AppStrings.voteSkipped);
      } else if (result == 'tie') {
        _addSystemMessage(AppStrings.voteTie);
      } else if (result == 'immune') {
        final nickname = data['nickname']?.toString() ?? '';
        _addSystemMessage(AppStrings.politicianImmune(nickname));
      }
    }
  }

  void _onPlayerEliminated(dynamic data) {
    try {
      if (data is Map) {
        final event = PlayerEliminatedEvent.fromJson(
          Map<String, dynamic>.from(data),
        );

        final nickname = event.playerNickname;
        final reason = event.reason.toLowerCase();

        if (reason == 'vote') {
          _addSystemMessage(AppStrings.dayExecution(nickname));
        } else if (reason == 'mafia') {
          _addSystemMessage(AppStrings.nightKillPlayer(nickname));
        } else if (reason == 'disconnect') {
          _addSystemMessage(
            AppStrings.playerEliminated(nickname, AppStrings.reasonDisconnect),
          );
        } else {
          _addSystemMessage(AppStrings.playerEliminated(nickname, reason));
        }
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('player_eliminated', e, stackTrace);
    }
  }

  void _onPlayerDisconnected(dynamic data) {
    if (data != null) {
      _addSystemMessage(AppStrings.disconnected(data.toString()));
    }
  }

  void _onPlayerReconnected(dynamic data) {
    if (data != null) {
      _addSystemMessage(AppStrings.reconnected(data.toString()));
    }
  }

  void _onReconnectFailed(dynamic data) {
    if (data != null) {
      _addSystemMessage(AppStrings.reconnectFailed(data.toString()));
    }
  }

  void _onVoteUpdate(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid vote update data format');
      }
      final event = VoteUpdateEvent.fromJson(Map<String, dynamic>.from(data));

      state = state.copyWith(votes: event.votes, voters: event.voters);
    } catch (e, stackTrace) {
      ErrorHandler.logError('vote_update', e, stackTrace);
    }
  }

  void _onNightSelectionUpdate(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid night selection data format');
      }
      final event = NightSelectionEvent.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (event.role != null) {
        final newSelections = Map<String, String>.from(state.nightSelections);
        final newActors = Map<String, String>.from(state.nightActionActors);

        if (event.targetId == null) {
          newSelections.remove(event.role!.name);
          newActors.remove(event.role!.name);
        } else {
          newSelections[event.role!.name] = event.targetId!;
          if (event.actorNickname != null) {
            newActors[event.role!.name] = event.actorNickname!;
          }
        }
        state = state.copyWith(
          nightSelections: newSelections,
          nightActionActors: newActors,
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('night_selection', e, stackTrace);
    }
  }

  void _onInvestigationResult(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid investigation result data format');
      }
      final event = InvestigationResultEvent.fromJson(
        Map<String, dynamic>.from(data),
      );

      final players = ref.read(gameStateProvider).players;

      final targetNick = players
          .firstWhere(
            (p) => p.id == event.targetId,
            orElse: () => Player(id: '', nickname: '?', isAlive: true),
          )
          .nickname;

      String resultMsg;
      if (targetNick == '?' || event.targetId.isEmpty) {
        resultMsg = AppStrings.investigationNone;
      } else {
        resultMsg = event.role == GameRole.mafia
            ? AppStrings.investigationMafia(targetNick)
            : AppStrings.investigationClear(targetNick);
      }
      _addSystemMessage(resultMsg);
    } catch (e, stackTrace) {
      ErrorHandler.logError('investigation_result', e, stackTrace);
    }
  }

  void _onNightResult(dynamic data) {
    if (data is Map) {
      final message = data[ProtocolKey.message]?.toString();
      if (message == 'kill') {
        _addSystemMessage(AppStrings.nightKill);
      } else if (message == 'peace') {
        _addSystemMessage(AppStrings.nightPeace);
      } else if (message == 'shield_activated') {
        final nickname = data[ProtocolKey.nickname]?.toString() ?? '';
        _addSystemMessage(AppStrings.soldierShieldActivated(nickname));
      }
    }
  }

  void _onChatMessage(dynamic data) {
    try {
      if (data is! Map) {
        throw FormatException('Invalid chat message data format');
      }
      final mappedData = Map<String, dynamic>.from(data);
      final event = ChatMessageEvent.fromJson(mappedData);

      final socketId = ref.read(connectionProvider.notifier).socketId;
      final players = ref.read(gameStateProvider).players;
      String myNickname = '';
      try {
        if (socketId != null && players.isNotEmpty) {
          final me = players.firstWhere((p) => p.id == socketId);
          myNickname = me.nickname;
        }
      } catch (_) {}

      final bool isMe =
          (socketId != null && event.sender == socketId) ||
          (myNickname.isNotEmpty && event.sender == myNickname);

      final newMsg = ChatMessage.fromMap({
        'sender': event.sender,
        'message': event.message,
        'type': event.type.name,
        'isSystem': event.sender == SystemConstant.sender,
      }, isMine: isMe);

      state = state.copyWith(messages: [...state.messages, newMsg]);

      ref.read(gameStateProvider.notifier).addGameLogEntry('chat', {
        'sender': event.sender,
        'message': event.message,
        'type': event.type.name,
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError('chat_message', e, stackTrace);
    }
  }

  void _onStateSync(dynamic data) {
    if (data is Map) {
      final mappedData = Map<String, dynamic>.from(data);
      final jVotes = Map<String, String>.from(
        mappedData['judgementVotes'] ?? {},
      );
      state = state.copyWith(
        votes: Map<String, int>.from(mappedData[ProtocolKey.votes] ?? {}),
        voters: Map<String, String>.from(mappedData[ProtocolKey.voters] ?? {}),
        judgementTarget: mappedData['judgementTarget']?.toString(),
        judgementVotes: jVotes,
        yesCount: jVotes.values.where((v) => v == 'yes').length,
        noCount: jVotes.values.where((v) => v == 'no').length,
      );
    }
  }

  void vote(String targetId) {
    final gamePhase = ref.read(gameStateProvider).gamePhase;
    final socketId = ref.read(connectionProvider.notifier).socketId;

    if (gamePhase == GamePhase.day && socketId != null) {
      developer.log('Voting for: $targetId');

      final myId = socketId;
      final previousVote = state.voters[myId];

      // Optimistic update
      final newVoters = Map<String, String>.from(state.voters);
      final newVotes = Map<String, int>.from(state.votes);

      if (previousVote == targetId) {
        newVoters.remove(myId);
        final count =
            newVotes[previousVote!] ??
            0; // previousVote is safe here? Yes logic implies it.
        if (count > 0) {
          newVotes[previousVote] = count - 1;
          if (newVotes[previousVote]! <= 0) newVotes.remove(previousVote);
        }
      } else {
        if (previousVote != null) {
          final count = newVotes[previousVote] ?? 0;
          if (count > 0) {
            newVotes[previousVote] = count - 1;
            if (newVotes[previousVote]! <= 0) newVotes.remove(previousVote);
          }
        }
        newVoters[myId] = targetId;
        newVotes[targetId] = (newVotes[targetId] ?? 0) + 1;
      }

      state = state.copyWith(votes: newVotes, voters: newVoters);

      ref
          .read(connectionProvider.notifier)
          .socketService
          .emit(SocketEvent.vote, targetId);
    }
  }

  void nightAction(String action, String targetId) {
    final gamePhase = ref.read(gameStateProvider).gamePhase;
    final myRoleEnum = ref.read(gameStateProvider).myRole;

    if (gamePhase == GamePhase.night && myRoleEnum != null) {
      developer.log('Night Action: $action -> $targetId');

      final roleKey = myRoleEnum.name;
      final currentSelection = state.nightSelections[roleKey];

      final newSelections = Map<String, String>.from(state.nightSelections);
      final newActors = Map<String, String>.from(state.nightActionActors);
      final newVoters = Map<String, String>.from(state.voters);
      final newVotes = Map<String, int>.from(state.votes);

      final myId = ref.read(connectionProvider.notifier).socketId;

      if (currentSelection == targetId) {
        newSelections.remove(roleKey);
        newActors.remove(roleKey);

        // Optimistic update for voters if Mafia
        if (myRoleEnum == GameRole.mafia && myId != null) {
          newVoters.remove(myId);
          newVotes[targetId] = (newVotes[targetId] ?? 1) - 1;
          if (newVotes[targetId]! <= 0) newVotes.remove(targetId);
        }
      } else {
        newSelections[roleKey] = targetId;
        final players = ref.read(gameStateProvider).players;
        final me = players.firstWhere(
          (p) => p.id == myId,
          orElse: () => Player(id: '', nickname: '', isAlive: false),
        );
        newActors[roleKey] = me.nickname;

        // Optimistic update for voters if Mafia
        if (myRoleEnum == GameRole.mafia && myId != null) {
          final previousVote = newVoters[myId];
          if (previousVote != null) {
            newVotes[previousVote] = (newVotes[previousVote] ?? 1) - 1;
            if (newVotes[previousVote]! <= 0) newVotes.remove(previousVote);
          }
          newVoters[myId] = targetId;
          newVotes[targetId] = (newVotes[targetId] ?? 0) + 1;
        }
      }

      state = state.copyWith(
        nightSelections: newSelections,
        nightActionActors: newActors,
        voters: newVoters,
        votes: newVotes,
      );

      ref.read(connectionProvider.notifier).socketService.emit(
        SocketEvent.nightAction,
        {ProtocolKey.action: action, ProtocolKey.targetId: targetId},
      );
    }
  }

  void createRoom(String nickname) {
    developer.log('Emitting create_room: $nickname');
    ref
        .read(connectionProvider.notifier)
        .socketService
        .emit(SocketEvent.createRoom, nickname);
  }

  void joinRoom(String roomId, String nickname) {
    developer.log('Emitting join_room: $nickname, $roomId');
    ref.read(connectionProvider.notifier).socketService.emit(
      SocketEvent.joinRoom,
      {ProtocolKey.roomId: roomId, ProtocolKey.nickname: nickname},
    );
  }

  void startGame() {
    developer.log('Emitting start_game');
    ref
        .read(connectionProvider.notifier)
        .socketService
        .emit(SocketEvent.startGame);
  }

  void updateSettings(GameSettings settings) {
    developer.log('Emitting update_settings: $settings');
    ref
        .read(connectionProvider.notifier)
        .socketService
        .emit(SocketEvent.updateSettings, settings.toMap());
  }

  void kickPlayer(String targetId) {
    developer.log('Emitting kick_player: $targetId');
    ref
        .read(connectionProvider.notifier)
        .socketService
        .emit(SocketEvent.kickPlayer, targetId);
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final gameState = ref.read(gameStateProvider);
    if (gameState.gamePhase == GamePhase.night &&
        gameState.myRole != GameRole.mafia) {
      _addSystemMessage(AppStrings.nightChatForbidden);
      return;
    }

    ref
        .read(connectionProvider.notifier)
        .socketService
        .emit(SocketEvent.chatMessage, message);
  }

  void resetTurnData() {
    state = state.copyWith(
      votes: {},
      voters: {},
      nightSelections: {},
      nightActionActors: {},
      clearJudgementResult: true,
    );
  }

  void sendJudgementVote(String vote) {
    final socket = ref.read(connectionProvider.notifier).socketService;
    socket.emit(SocketEvent.judgementVote, vote);
  }

  void endLastWord() {
    final socket = ref.read(connectionProvider.notifier).socketService;
    socket.emit(SocketEvent.endLastWord);
  }

  void archiveMessages() {
    // 1. Filter out Mafia and Dead messages to prevent clutter/spoilers
    // 2. Map remaining to isLegacy = true
    final legacyMessages = state.messages
        .where(
          (m) =>
              m.type != ChatMessageType.mafia && m.type != ChatMessageType.dead,
        )
        .map((m) => m.copyWith(isLegacy: true))
        .toList();

    // 3. Keep only recent history (last 50) to manage memory
    final trimmedLegacy = legacyMessages.length > 50
        ? legacyMessages.sublist(legacyMessages.length - 50)
        : legacyMessages;

    // 4. Insert "New Game Start" divider
    final divider = ChatMessage(
      sender: SystemConstant.sender,
      message: AppStrings.newGameDivider,
      type: ChatMessageType.system,
      isSystem: true,
      isLegacy: false,
    );

    state = state.copyWith(
      messages: [...trimmedLegacy, divider],
      votes: const {},
      voters: const {},
      nightSelections: const {},
      nightActionActors: const {},
    );
  }

  void resetAllData() {
    state = const ActionState();
  }

  void _addSystemMessage(String msg) {
    final newMsg = ChatMessage(
      sender: SystemConstant.sender,
      message: msg,
      type: ChatMessageType.system,
      isSystem: true,
    );
    state = state.copyWith(messages: [...state.messages, newMsg]);

    // Log
    if (ref.read(connectionProvider).isConnected) {
      ref.read(gameStateProvider.notifier).addGameLogEntry('system', {
        'message': msg,
      });
    }
  }
}

// Derived providers for getters
@riverpod
List<String> skipVoterNicknames(Ref ref) {
  final voters = ref.watch(actionProvider.select((s) => s.voters));
  final players = ref.watch(gameStateProvider.select((s) => s.players));
  final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
  final myRole = ref.watch(gameStateProvider.select((s) => s.myRole));

  return voters.entries
      .where((entry) {
        // During Day, anyone can see skips.
        // During Night, only Mafia can see Mafia-skips.
        if (gamePhase == GamePhase.day) {
          return entry.value == GameAction.skip;
        } else if (gamePhase == GamePhase.night && myRole == GameRole.mafia) {
          return entry.value == GameAction.skip;
        }
        return false;
      })
      .map((entry) {
        final voter = players.firstWhere(
          (p) => p.id == entry.key,
          orElse: () =>
              Player(id: 'unknown', nickname: '알 수 없음', isAlive: true),
        );
        return voter.nickname;
      })
      .toList()
      .cast<String>();
}

@riverpod
bool iVotedSkip(Ref ref) {
  final voters = ref.watch(actionProvider.select((s) => s.voters));
  final myId = ref.watch(connectionProvider.notifier).socketId;
  return voters[myId] == GameAction.skip;
}

@riverpod
bool isMafiaSkip(Ref ref) {
  final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
  if (gamePhase != GamePhase.night) return false;

  final voters = ref.watch(actionProvider.select((s) => s.voters));
  final myId = ref.watch(connectionProvider.notifier).socketId;
  return voters[myId] == GameAction.skip;
}

@riverpod
String mafiaSkipButtonText(Ref ref) {
  return '킬 건너뛰기';
}

@riverpod
String mafiaSkipActorNickname(Ref ref) {
  final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));
  if (gamePhase != GamePhase.night) return '';

  final skipVoters = ref.watch(skipVoterNicknamesProvider);
  return skipVoters.join(', ');
}

final actionProvider = actionNotifierProvider;
