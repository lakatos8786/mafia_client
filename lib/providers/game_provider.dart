import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/game_enums.dart';
import '../models/player.dart';
import '../models/event_models.dart';

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

  String? _myId;
  String? _errorMessage;
  String? _roomId;
  String? _winner;
  List<Player> _endGamePlayers = [];
  DateTime? _gameOverTime;

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

  bool get canReturnToLobby {
    if (_gameOverTime == null) return true;
    return DateTime.now().difference(_gameOverTime!).inSeconds >= 2;
  }

  // --- UI Helpers ---
  List<String> get skipVoterNicknames {
    return voters.entries.where((entry) => entry.value == GameAction.skip).map((
      entry,
    ) {
      final voter = players.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Player(id: 'unknown', nickname: '?', isAlive: true),
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

  GameProvider() {
    _initSocket();
  }

  // DEBUG LOGGING
  @override
  void notifyListeners() {
    // print('GameProvider: notifyListeners() called. State: ${_gameState.label}, Role: ${_myRole?.label}');
    super.notifyListeners();
  }

  static const String serverUrl = 'https://mafia-server-py70.onrender.com';

  void _initSocket() {
    print('Initializing socket connection to $serverUrl');
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    // --- Socket Listeners ---
    _socket.on(SocketEvent.CONNECTION, (_) {
      print('DEBUG: Connected to server: ${_socket.id}');
      _myId = _socket.id;
      _errorMessage = null;
      notifyListeners();
    });

    _socket.on(SocketEvent.ROOM_CREATED, (roomId) {
      print('Event: room_created -> $roomId');
      _roomId = roomId;
      _isAdmin = true;
      notifyListeners();
    });

    _socket.on(SocketEvent.JOINED_ROOM, (roomId) {
      print('Event: joined_room -> $roomId');
      _roomId = roomId;
      _isAdmin = false;
      notifyListeners();
    });

    _socket.on(SocketEvent.PLAYER_UPDATE, (data) {
      print('Event: player_update -> $data');
      try {
        if (data is List) {
          _players = data
              .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          _myRole = _deriveMyRole(); // Update my role
          notifyListeners();
        }
      } catch (e) {
        print('Error in player_update: $e');
      }
    });

    _socket.on(SocketEvent.ROLE_COUNTS, (data) {
      print('Event: role_counts -> $data');
      if (data is Map) {
        _roleCounts = Map<String, int>.from(data);
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.ROLE_ASSIGNED, (data) {
      print('Event: role_assigned -> $data');
      _myRole = GameRole.fromString(data.toString());
      notifyListeners();
    });

    _socket.on(SocketEvent.START_GAME, (_) {
      print('Event: start_game');
      _gameState = GamePhase.day;
      _dayCount = 1;
      _votes.clear();
      _voters.clear();
      _nightSelections.clear();
      _nightActionActors.clear();
      _messages.clear();

      // System Message
      _messages.add({
        'sender': SystemConstant.sender,
        'message': '게임이 시작되었습니다! 역할을 확인하세요.',
        'type': ChatMessageType.system.name,
        'isSystem': true,
      });

      notifyListeners();
    });

    _socket.on(SocketEvent.PHASE_CHANGE, (data) {
      print('Event: phase_change -> $data');
      try {
        if (data is Map) {
          final event = PhaseChangeEvent.fromJson(
            Map<String, dynamic>.from(data),
          );
          _gameState = event.phase;
          _dayCount = event.dayCount;

          // System Message
          _messages.add({
            'sender': SystemConstant.sender,
            'message': '${_gameState.label}이 되었습니다.',
            'type': ChatMessageType.system.name,
            'isSystem': true,
          });

          _votes.clear();
          _voters.clear();
          _nightSelections.clear();
          _nightActionActors.clear();
          notifyListeners();
        }
      } catch (e) {
        print('Error in phase_change: $e');
      }
    });

    // Add logic for investigation result display
    _socket.on(SocketEvent.INVESTIGATION_RESULT, (data) {
      if (data is Map) {
        final targetNickname = _players
            .firstWhere(
              (p) => p.id == data[ProtocolKey.targetId],
              orElse: () => Player(id: '', nickname: '알 수 없음', isAlive: false),
            )
            .nickname;
        final role = GameRole.fromString(
          data[ProtocolKey.role],
        ); // "mafia" or "citizen" etc
        final isMafia = role == GameRole.mafia;

        _messages.add({
          'sender': SystemConstant.sender,
          'message':
              '조사 결과, $targetNickname님은 ${isMafia ? "마피아입니다!" : "마피아가 아닙니다."}',
          'type': ChatMessageType.system.name,
          'isSystem': true,
        });
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.NIGHT_RESULT, (data) {
      if (data is Map && data[ProtocolKey.message] != null) {
        _messages.add({
          'sender': SystemConstant.sender,
          'message': data[ProtocolKey.message],
          'type': ChatMessageType.system.name,
          'isSystem': true,
        });
        notifyListeners();
      }
    });

    _socket.on(SocketEvent.GAME_OVER, (data) {
      print('Event: game_over -> $data');
      try {
        if (data is Map) {
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
          _messages.add({
            'sender': SystemConstant.sender,
            'message': '게임 종료! 승자: $_winner',
            'type': ChatMessageType.system.name,
            'isSystem': true,
          });

          notifyListeners();

          Future.delayed(Duration(seconds: 2), () {
            notifyListeners();
          });
        }
      } catch (e) {
        print('Error in game_over: $e');
      }
    });

    _socket.on(SocketEvent.CHAT_MESSAGE, (data) {
      print('Event: chat_message -> $data');
      try {
        if (data is Map) {
          final event = ChatMessageEvent.fromJson(
            Map<String, dynamic>.from(data),
          );
          _messages.add({
            'sender': event.sender,
            'message': event.message,
            'type': event.type.name,
          });
          notifyListeners();
        }
      } catch (e) {
        print('Error in chat_message: $e');
      }
    });

    _socket.on(SocketEvent.VOTE_UPDATE, (data) {
      print('Event: vote_update -> $data');
      try {
        if (data is Map) {
          _votes = Map<String, int>.from(data[ProtocolKey.votes] ?? {});
          _voters = Map<String, String>.from(data[ProtocolKey.voters] ?? {});
          notifyListeners();
        }
      } catch (e) {
        print('Error in vote_update: $e');
      }
    });

    _socket.on(SocketEvent.NIGHT_SELECTION_UPDATE, (data) {
      // print('Event: night_selection_update -> $data');
      try {
        if (data is Map) {
          final event = NightSelectionEvent.fromJson(
            Map<String, dynamic>.from(data),
          );

          if (event.role != null) {
            if (event.targetId != null) {
              _nightSelections[event.role!.name] = event.targetId!;
            }
            if (event.actorNickname != null) {
              _nightActionActors[event.role!.name] = event.actorNickname!;
            }
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error in night_selection_update: $e');
      }
    });

    _socket.onDisconnect((_) {
      print('Event: Disconnected');
      _errorMessage = '서버와 연결이 끊어졌습니다.';
      notifyListeners();
    });

    _socket.onConnectError((data) {
      print('Event: Connect Error -> $data');
      _errorMessage = '서버 연결 실패: $data';
      notifyListeners();
    });

    _socket.onError((data) {
      print('Socket Error: $data');
      _errorMessage = '오류 발생: $data';
      notifyListeners();
    });
  } // End of _initSocket

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
      _socket.emit(SocketEvent.vote, targetId);
    }
  }

  void nightAction(String action, String targetId) {
    if (_gameState == GamePhase.night) {
      print('Night Action: $action -> $targetId');
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
}
