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
  final String? judgementTarget;
  final String? judgementTargetNickname;
  final Map<String, String> judgementVotes;
  final int yesCount;
  final int noCount;
  final List<ChatMessage> messages;

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
      archiveMessages();
      _addSystemMessage(AppStrings.gameStarted);
    });

    socket.on(SocketEvent.roleAssigned, (_) {
      // Role assigned is now handled by GameStateProvider and specific ActionState logic
    });

    socket.on(SocketEvent.phaseChange, (data) {
      if (data is Map) {
        final phase = GamePhase.fromString(data['phase']?.toString() ?? '');
        final dayCount = int.tryParse(data['dayCount']?.toString() ?? '1') ?? 1;

        if (phase != GamePhase.waiting) {
          // Announcement first
          if (phase == GamePhase.day) {
            _addSystemMessage(AppStrings.dayAnnouncement(dayCount));

            final myRole = ref.read(gameStateProvider).myRole;
            // Special check for Doctor: if day started and no heal action previously, show message
            if (myRole == GameRole.doctor && dayCount > 1) {
              final mySelection = state.nightSelections[GameRole.doctor.name];
              // If selection is null or 'skip', validation implies no effective heal
              // But usually 'skip' is explicit. If null, it means timeout/no selection.
              // User asked for "when time passes without selection" mainly, but 'skip' implies same result visually if we want consistent feedback.
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

            // Only show night action instructions to alive players
            final socketId = ref.read(connectionProvider.notifier).socketId;
            final players = ref.read(gameStateProvider).players;
            final me = players.firstWhere(
              (p) => p.id == socketId,
              orElse: () => Player(id: '', nickname: '', isAlive: false),
            );

            if (me.isAlive) {
              final myRole = ref.read(gameStateProvider).myRole;
              // Sequential instructions for active roles
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
    });

    socket.on(SocketEvent.judgementStarted, (data) {
      if (data is Map) {
        state = state.copyWith(
          judgementTarget: data['targetId']?.toString(),
          judgementTargetNickname: data['nickname']?.toString(),
          judgementVotes: {},
          yesCount: 0,
          noCount: 0,
        );
      }
    });

    socket.on(SocketEvent.judgementUpdate, (data) {
      if (data is Map) {
        state = state.copyWith(
          yesCount: int.tryParse(data['yesCount']?.toString() ?? '0') ?? 0,
          noCount: int.tryParse(data['noCount']?.toString() ?? '0') ?? 0,
          judgementVotes: Map<String, String>.from(data['voters'] ?? {}),
        );
      }
    });

    socket.on(SocketEvent.judgementResult, (data) {
      if (data is Map) {
        final result = data['result']?.toString();
        final nickname = data['nickname']?.toString() ?? '?';
        if (result == 'executed') {
          _addSystemMessage(AppStrings.judgementExecuted(nickname));
        } else {
          _addSystemMessage(AppStrings.judgementSaved(nickname));
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
    });

    socket.on(SocketEvent.playerEliminated, (data) {
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
              AppStrings.playerEliminated(
                nickname,
                AppStrings.reasonDisconnect,
              ),
            );
          } else {
            _addSystemMessage(AppStrings.playerEliminated(nickname, reason));
          }
        }
      } catch (e) {
        // Fallback or silent
      }
    });

    socket.on(SocketEvent.playerDisconnected, (data) {
      if (data != null) {
        _addSystemMessage(AppStrings.disconnected(data.toString()));
      }
    });

    socket.on(SocketEvent.playerReconnected, (data) {
      if (data != null) {
        _addSystemMessage(AppStrings.reconnected(data.toString()));
      }
    });

    socket.on(SocketEvent.reconnectFailed, (data) {
      if (data != null) {
        _addSystemMessage(AppStrings.reconnectFailed(data.toString()));
      }
    });

    socket.on(SocketEvent.voteUpdate, (data) {
      try {
        if (data is! Map<String, dynamic>) {
          throw FormatException('Invalid vote update data format');
        }
        final event = VoteUpdateEvent.fromJson(data);

        // Always update votes/voters regardless of phase.
        // During day, it's public. During night, server only sends this to Mafia members.
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
        // doctor_saved 메시지 제거: 게임 밸런스를 위해 의사는 치료 성공 여부를 알 수 없음
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

    socket.on(SocketEvent.stateSync, (data) {
      if (data is Map) {
        final jVotes = Map<String, String>.from(data['judgementVotes'] ?? {});
        state = state.copyWith(
          votes: Map<String, int>.from(data[ProtocolKey.votes] ?? {}),
          voters: Map<String, String>.from(data[ProtocolKey.voters] ?? {}),
          judgementTarget: data['judgementTarget']?.toString(),
          judgementVotes: jVotes,
          yesCount: jVotes.values.where((v) => v == 'yes').length,
          noCount: jVotes.values.where((v) => v == 'no').length,
        );
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
