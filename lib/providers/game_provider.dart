import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/game_enums.dart';

class Player {
  final String id;
  final String nickname;
  final GameRole? role; // Updated to strict Enum
  final bool isAlive;
  final bool isHost;

  Player({
    required this.id,
    required this.nickname,
    this.role,
    required this.isAlive,
    this.isHost = false,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      nickname: map['nickname'],
      role: GameRole.fromString(map['role']),
      isAlive: map['isAlive'],
      isHost: map['isHost'] ?? false,
    );
  }
}

class GameProvider with ChangeNotifier {
  late IO.Socket _socket;
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

  List<Player> get players => _players;
  // UI expects String, so return label
  String get gameState => _gameState.label;
  GamePhase get gamePhase => _gameState;
  int get dayCount => _dayCount;
  // UI expects String?, so return label
  String? get myRole => _myRole?.label;
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
    return voters.entries.where((entry) => entry.value == 'skip').map((entry) {
      final voter = players.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Player(id: 'unknown', nickname: '?', isAlive: true),
      );
      return voter.nickname;
    }).toList();
  }

  bool get iVotedSkip => voters[socket.id] == 'skip';

  bool get isMafiaSkip => nightSelections['마피아'] == 'skip';
  String get mafiaSkipButtonText {
    final actor = nightActionActors['마피아'] ?? '';
    return isMafiaSkip ? '킬 건너뛰기 ($actor)' : '킬 건너뛰기';
  }

  IO.Socket get socket => _socket;

  GameProvider() {
    _initSocket();
  }

  static const String serverUrl = 'https://mafia-server-py70.onrender.com';

  Map<String, int> _roleCounts = {};

  Map<String, int> get roleCounts => _roleCounts;

  void _initSocket() {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected');
      _myId = _socket.id;
      notifyListeners();
    });

    _socket.on('room_created', (roomId) {
      _roomId = roomId;
      notifyListeners();
    });

    _socket.on('joined_room', (roomId) {
      _roomId = roomId;
      notifyListeners();
    });

    _socket.on('role_counts', (data) {
      print('Received role counts: $data');
      if (data is Map) {
        _roleCounts = Map<String, int>.from(data);
        notifyListeners();
      }
    });

    _socket.on('player_update', (data) {
      try {
        if (data is List) {
          _players = data
              .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          notifyListeners();
        }
      } catch (e) {
        print('Error in player_update: $e');
      }
    });

import '../services/sound_service.dart';

// ... (existing imports)

// ... (inside GameProvider)

    _socket.on('game_start', (data) {
      try {
        if (data is Map) {
          _gameState = GamePhase.day; // Enum
          _dayCount = 1;
          SoundService().playDayStart(); // SFX
          if (data['players'] is List) {
            _players = (data['players'] as List)
                .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          }
          notifyListeners();
        }
      } catch (e) {
        print('Error in game_start: $e');
      }
    });

    // ...

    _socket.on('phase_change', (data) {
      try {
        if (data is Map) {
          if (data['phase'] != null) {
            final nextPhase = GamePhase.fromString(data['phase']);
            if (nextPhase != _gameState) {
              if (nextPhase == GamePhase.day) SoundService().playDayStart();
              if (nextPhase == GamePhase.night) SoundService().playNightStart();
            }
            _gameState = nextPhase;
          }
          _dayCount = data['dayCount'] as int? ?? _dayCount;
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

    // ...

    _socket.on('game_over', (data) {
      try {
        if (data is Map) {
          final mappedData = Map<String, dynamic>.from(data);
          _gameState = GamePhase.result;
          _winner = mappedData['winner']?.toString();
          if (mappedData['players'] is List) {
            _endGamePlayers = (mappedData['players'] as List)
                .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          }
          _gameOverTime = DateTime.now();
          _messages.add({'sender': '시스템', 'message': '게임 종료! 승자: $_winner'});
          
          // Play Win/Lose Sound
          final isMafiaWin = _winner == '마피아';
          final myTeamIsMafia = _myRole == GameRole.mafia;
          // Citizens win if !isMafiaWin
          
          if ((isMafiaWin && myTeamIsMafia) || (!isMafiaWin && !myTeamIsMafia)) {
             SoundService().playWin();
          } else {
             SoundService().playLose();
          }

          notifyListeners();

          // Trigger rebuild after 2 seconds to show "Tap to return" text
          Future.delayed(Duration(seconds: 2), () {
            notifyListeners();
          });
        }
      } catch (e) {
        print('Error in game_over: $e');
      }
    });

    // ...

  void vote(String targetId) {
    if (_gameState == GamePhase.day && _myRole != null && _players.firstWhere((p) => p.id == _socket.id).isAlive) {
       SoundService().playVote();
       _socket.emit('vote', targetId);
    }
  }

  void nightAction(String action, String targetId) {
    _socket.emit('night_action', {'action': action, 'targetId': targetId});
  }

  void sendMessage(String msg) {
    _socket.emit('chat_message', msg);
  }

  void returnToLobby() {
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
}
