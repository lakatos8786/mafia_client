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

part 'action_provider.g.dart';

class ActionState {
  final Map<String, int> votes;
  final Map<String, String> voters;
  final Map<String, String> nightSelections;
  final Map<String, String> nightActionActors;
  final List<ChatMessage> messages;

  const ActionState({
    this.votes = const {},
    this.voters = const {},
    this.nightSelections = const {},
    this.nightActionActors = const {},
    this.messages = const [],
  });

  ActionState copyWith({
    Map<String, int>? votes,
    Map<String, String>? voters,
    Map<String, String>? nightSelections,
    Map<String, String>? nightActionActors,
    List<ChatMessage>? messages,
  }) {
    return ActionState(
      votes: votes ?? this.votes,
      voters: voters ?? this.voters,
      nightSelections: nightSelections ?? this.nightSelections,
      nightActionActors: nightActionActors ?? this.nightActionActors,
      messages: messages ?? this.messages,
    );
  }
}

@Riverpod(keepAlive: true)
class ActionNotifier extends _$ActionNotifier {
  @override
  ActionState build() {
    final socket = ref.read(connectionProvider.notifier).socketService;

    // Listeners
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

        if (phase != GamePhase.waiting) {
          // Special check for Doctor: if night ended and no heal action, show message
          // But skip this message on the first night (day 1)
          if (phase == GamePhase.day) {
            final myRole = ref.read(gameStateProvider).myRole;
            final dayCount = ref.read(gameStateProvider).dayCount;
            if (myRole == GameRole.doctor && dayCount > 1) {
              final mySelection = state.nightSelections[GameRole.doctor.name];
              // If selection is null or 'skip', validation implies no effective heal
              // But usually 'skip' is explicit. If null, it means timeout/no selection.
              // User asked for "when time passes without selection" mainly, but 'skip' implies same result visually if we want consistent feedback.
              if (mySelection == null || mySelection == GameAction.skip) {
                _addSystemMessage(AppStrings.doctorHealNone);
              }
            }
          }

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

    socket.on(SocketEvent.voteResult, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid vote result data format');
        }
        final event = VoteResultEvent.fromJson(data);

        // If someone was eliminated, show specific message
        if (event.eliminatedNickname != null &&
            event.eliminatedNickname!.isNotEmpty) {
          _addSystemMessage(AppStrings.dayExecution(event.eliminatedNickname!));
        } else if (event.message.isNotEmpty) {
          // Otherwise show generic message (skip/tie)
          _addSystemMessage(event.message);
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError('vote_result', e, stackTrace);
      }
    });

    socket.on(SocketEvent.playerEliminated, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid player eliminated data format');
        }

        // Debug logging
        print('🔍 playerEliminated raw data: $data');

        final event = PlayerEliminatedEvent.fromJson(data);

        print('🔍 Parsed event:');
        print('  - playerId: "${event.playerId}"');
        print('  - playerNickname: "${event.playerNickname}"');
        print('  - reason: "${event.reason}"');

        // Get nickname from game state if not provided
        String nickname = event.playerNickname;
        if (nickname.isEmpty) {
          final players = ref.read(gameStateProvider).players;
          final player = players.firstWhere(
            (p) => p.id == event.playerId,
            orElse: () =>
                Player(id: '', nickname: '알 수 없는 플레이어', isAlive: false),
          );
          nickname = player.nickname;
          print('🔍 Retrieved nickname from game state: "$nickname"');
        }

        // Normalize reason (support both Korean and English)
        final normalizedReason = event.reason.toLowerCase().trim();

        // Show death message based on reason
        if (normalizedReason == 'vote' ||
            normalizedReason == '투표' ||
            normalizedReason == 'voted' ||
            normalizedReason == 'day') {
          print('✅ Using dayExecution message');
          _addSystemMessage(AppStrings.dayExecution(nickname));
        } else if (normalizedReason == 'night' ||
            normalizedReason == '밤' ||
            normalizedReason == 'killed' ||
            normalizedReason == 'mafia') {
          print('✅ Using nightKillPlayer message');
          _addSystemMessage(AppStrings.nightKillPlayer(nickname));
        } else {
          print(
            '⚠️ Using generic playerDied message (reason: "${event.reason}")',
          );
          _addSystemMessage(AppStrings.playerDied(nickname));
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError('player_eliminated', e, stackTrace);
      }
    });

    socket.on(SocketEvent.voteUpdate, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid vote update data format');
        }
        final event = VoteUpdateEvent.fromJson(data);
        state = state.copyWith(votes: event.votes, voters: event.voters);
      } catch (e, stackTrace) {
        ErrorHandler.logError('vote_update', e, stackTrace);
      }
    });

    socket.on(SocketEvent.nightSelectionUpdate, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid night selection data format');
        }
        final event = NightSelectionEvent.fromJson(data);
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
    });

    socket.on(SocketEvent.investigationResult, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid investigation result data format');
        }
        final event = InvestigationResultEvent.fromJson(data);

        // Need player list to resolve nickname
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
      } catch (e, stackTrace) {
        ErrorHandler.logError('night_result', e, stackTrace);
      }
    });

    socket.on(SocketEvent.chatMessage, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid chat message data format');
        }
        final event = ChatMessageEvent.fromJson(data);

        // Determine ownership
        final socketId = ref.read(connectionProvider.notifier).socketId;

        // We need 'my nickname' to compare with sender.
        // GameState has players list, we can find ourselves.
        final players = ref.read(gameStateProvider).players;
        String myNickname = '';
        try {
          if (socketId != null && players.isNotEmpty) {
            final me = players.firstWhere((p) => p.id == socketId);
            myNickname = me.nickname;
          }
        } catch (_) {
          // Player might not be found if joining or error
        }

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

        // Also add to game log in GameState
        ref.read(gameStateProvider.notifier).addGameLogEntry('chat', {
          'sender': event.sender,
          'message': event.message,
          'type': event.type.name,
        });
      } catch (e, stackTrace) {
        ErrorHandler.logError('chat_message', e, stackTrace);
      }
    });

    ref.onDispose(() {
      // Cleanup listeners if needed
    });

    return const ActionState();
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

      if (currentSelection == targetId) {
        newSelections.remove(roleKey);
        newActors.remove(roleKey);
      } else {
        newSelections[roleKey] = targetId;
        final players = ref.read(gameStateProvider).players;
        final myId = ref.read(connectionProvider.notifier).socketId;
        final me = players.firstWhere(
          (p) => p.id == myId,
          orElse: () => Player(id: '', nickname: '', isAlive: false),
        );
        newActors[roleKey] = me.nickname;
      }

      state = state.copyWith(
        nightSelections: newSelections,
        nightActionActors: newActors,
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

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
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

  return voters.entries
      .where((entry) => entry.value == GameAction.skip)
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
  final nightSelections = ref.watch(
    actionProvider.select((s) => s.nightSelections),
  );
  return nightSelections[GameRole.mafia.name] == GameAction.skip;
}

@riverpod
String mafiaSkipButtonText(Ref ref) {
  final nightActionActors = ref.watch(
    actionProvider.select((s) => s.nightActionActors),
  );
  final isSkip = ref.watch(isMafiaSkipProvider);
  final actor = nightActionActors[GameRole.mafia.name] ?? '';
  return isSkip ? '킬 건너뛰기 ($actor)' : '킬 건너뛰기';
}

final actionProvider = actionNotifierProvider;
