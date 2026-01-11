import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Player {
  final String id;
  final String nickname;
  final dynamic role; // 'MAFIA', 'DOCTOR', 'POLICE', 'CITIZEN' or null
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
      role: map['role'],
      isAlive: map['isAlive'],
      isHost: map['isHost'] ?? false,
    );
  }
}

class GameProvider with ChangeNotifier {
  late IO.Socket _socket;
  List<Player> _players = [];
  String _gameState = '대기중'; // 대기중, 낮, 밤
  int _dayCount = 1;
  String? _myRole;
  final List<Map<String, dynamic>> _messages = [];
  Map<String, int> _votes = {};
  Map<String, String> _voters = {}; // { voterId: targetId }
  final Map<String, String> _nightSelections =
      {}; // { '마피아': 'id', '의사': 'id', ... }
  final Map<String, String> _nightActionActors = {}; // { '마피아': 'nickname' }
  String? _myId;
  String? _errorMessage;
  String? _roomId;
  String? _winner;
  List<Player> _endGamePlayers = [];
  DateTime? _gameOverTime;

  List<Player> get players => _players;
  String get gameState => _gameState;
  int get dayCount => _dayCount;
  String? get myRole => _myRole;
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

  IO.Socket get socket => _socket;

  GameProvider() {
    _initSocket();
  }

  // static const String serverUrl =
  //     'http://localhost:3000'; // Local testing
  static const String serverUrl =
      'https://mafia-server-py70.onrender.com'; // Remote

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

    _socket.on('game_start', (data) {
      try {
        if (data is Map) {
          _gameState = '낮';
          _dayCount = 1;
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

    _socket.on('role_assigned', (role) {
      _myRole = role;
      _winner = null;
      _endGamePlayers = [];
      _messages.add({'sender': '시스템', 'message': '새로운 게임이 시작되었습니다!'});
      notifyListeners();
    });

    _socket.on('player_eliminated', (data) {
      // Handle player elimination event to update specific player status
      // This ensures the client knows who died immediately
      try {
        if (data is Map) {
          final deadId = data['id'];
          final index = _players.indexWhere((p) => p.id == deadId);
          if (index != -1) {
            final old = _players[index];
            _players[index] = Player(
              id: old.id,
              nickname: old.nickname,
              role: old.role,
              isAlive: false, // Mark as dead
              isHost: old.isHost,
            );
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error in player_eliminated: $e');
      }
    });
    });

    _socket.on('phase_change', (data) {
      try {
        if (data is Map) {
          _gameState = data['phase']?.toString() ?? _gameState;
          _dayCount = data['dayCount'] as int? ?? _dayCount;
          _votes.clear(); // Clear votes on phase change
          _voters.clear(); // Clear voters on phase change
          _nightSelections.clear(); // Clear night selections on phase change
          _nightActionActors.clear();
          notifyListeners();
        }
      } catch (e) {
        print('Error in phase_change: $e');
      }
    });

    _socket.on('night_selection_update', (data) {
      try {
        if (data is Map) {
          final role = data['role']?.toString();
          final targetId = data['targetId']?.toString();
          final actorNickname = data['actorNickname']?.toString();
          if (role != null && targetId != null) {
            _nightSelections[role] = targetId;
            if (actorNickname != null) {
              _nightActionActors[role] = actorNickname;
            }
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error in night_selection_update: $e');
      }
    });

    _socket.on('investigation_result', (data) {
      try {
        if (data is Map) {
          final targetNickname = data['targetNickname']?.toString() ?? '알 수 없음';
          final isMafia = data['isMafia'] as bool? ?? false;
          final resultText = isMafia ? '마피아입니다.' : '마피아가 아닙니다.';
          _messages.add({
            'sender': '시스템',
            'message': '조사 결과: [$targetNickname]님은 $resultText',
            'isSystem': true,
          });
          notifyListeners();
        }
      } catch (e) {
        print('Error in investigation_result: $e');
      }
    });

    _socket.on('vote_update', (data) {
      print('Received vote_update: $data'); // DEBUG LOG
      try {
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);

          if (mapData['votes'] != null) {
            _votes = Map<String, int>.from(mapData['votes']);
          } else {
            // Legacy support / check
            if (!mapData.containsKey('votes') &&
                !mapData.containsKey('voters')) {
              print('Handling as legacy vote map');
              _votes = Map<String, int>.from(mapData);
            }
          }

          if (mapData['voters'] != null) {
            _voters = Map<String, String>.from(mapData['voters']);
            print('Updated voters map: $_voters');
          } else {
            print('No voters data found in payload');
          }

          notifyListeners();
        } else {
          print('vote_update data is not a Map: $data');
        }
      } catch (e) {
        print('Error in vote_update: $e');
      }
    });

    _socket.on('chat_message', (data) {
      try {
        if (data is Map) {
          _messages.add(Map<String, dynamic>.from(data));
          notifyListeners();
        }
      } catch (e) {
        print('Error in chat_message: $e');
      }
    });

    _socket.on('player_eliminated', (data) {
      // Find player and mark dead locally or wait for player_update?
      // Server usually sends player_update if roster changes, but here we just update status
      // We might need to refetch or update local list manually if not sent.
      // But let's assume server sends updates or we process this.
      final id = data['id'];
      final index = _players.indexWhere((p) => p.id == id);
      if (index != -1) {
        // Create new player object to refresh UI
        // Assuming we just receive notification, but we rely on next update or local mod
        // Ideally server sends player_update often.
        // For now let's hope server uses player_update or we trigger it.
        // Wait, server code sends phase_change and such, but maybe not player list every time.
        // Let's manually update availability.
        // Actually server code I wrote does NOT emit player_update on elimination in `processDayResults`.
        // I should fix server or handle it here.
        // Let's handle it here for now.
        // Wait, I am just fixing the game_over part below.
      }
    });

    _socket.on('game_over', (data) {
      try {
        if (data is Map) {
          final mappedData = Map<String, dynamic>.from(data);
          _gameState = '결과';
          _winner = mappedData['winner']?.toString();
          if (mappedData['players'] is List) {
            _endGamePlayers = (mappedData['players'] as List)
                .map((e) => Player.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          }
          _gameOverTime = DateTime.now();
          _messages.add({'sender': '시스템', 'message': '게임 종료! 승자: $_winner'});
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

    _socket.on('error', (msg) {
      _errorMessage = msg;
      notifyListeners();
      Future.delayed(Duration(seconds: 3), () {
        _errorMessage = null;
        notifyListeners();
      });
    });
  }

  void joinRoom(String nickname, String roomId) {
    print('Joining room $roomId as $nickname');
    _socket.emit('join_room', {'nickname': nickname, 'roomId': roomId});
  }

  void createRoom(String nickname) {
    print('Creating room as $nickname');
    _socket.emit('create_room', nickname);
  }

  void startGame() {
    _socket.emit('start_game');
  }

  void vote(String targetId) {
    _socket.emit('vote', targetId);
  }

  void nightAction(String action, String targetId) {
    _socket.emit('night_action', {'action': action, 'targetId': targetId});
  }

  void sendMessage(String msg) {
    _socket.emit('chat_message', msg);
  }

  void returnToLobby() {
    _gameState = '대기중';
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
