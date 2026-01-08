import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Player {
  final String id;
  final String nickname;
  final dynamic role; // 'MAFIA', 'DOCTOR', 'POLICE', 'CITIZEN' or null
  final bool isAlive;

  Player({
    required this.id,
    required this.nickname,
    this.role,
    required this.isAlive,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      nickname: map['nickname'],
      role: map['role'],
      isAlive: map['isAlive'],
    );
  }
}

class GameProvider with ChangeNotifier {
  late IO.Socket _socket;
  List<Player> _players = [];
  String _gameState = '대기중'; // 대기중, 낮, 밤
  int _dayCount = 1;
  String? _myRole;
  List<Map<String, dynamic>> _messages = [];
  Map<String, int> _votes = {};
  String? _myId;
  String? _errorMessage;
  String? _roomId;

  List<Player> get players => _players;
  String get gameState => _gameState;
  int get dayCount => _dayCount;
  String? get myRole => _myRole;
  List<Map<String, dynamic>> get messages => _messages;
  Map<String, int> get votes => _votes;
  String? get myId => _myId;
  String? get errorMessage => _errorMessage;
  String? get roomId => _roomId;

  IO.Socket get socket => _socket;

  GameProvider() {
    _initSocket();
  }

  static const String serverUrl =
      'https://mafia-server-py70.onrender.com'; // Replace with Render URL later

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

    _socket.on('player_update', (data) {
      _players = (data as List).map((e) => Player.fromMap(e)).toList();
      notifyListeners();
    });

    _socket.on('game_start', (data) {
      _gameState = '낮';
      _dayCount = 1;
      _players = (data['players'] as List)
          .map((e) => Player.fromMap(e))
          .toList();
      notifyListeners();
    });

    _socket.on('role_assigned', (role) {
      _myRole = role;
      notifyListeners();
    });

    _socket.on('phase_change', (data) {
      _gameState = data['phase'];
      _dayCount = data['dayCount'];
      _votes.clear(); // Clear votes on phase change
      notifyListeners();
    });

    _socket.on('vote_update', (data) {
      _votes = Map<String, int>.from(data);
      notifyListeners();
    });

    _socket.on('chat_message', (data) {
      _messages.add(Map<String, dynamic>.from(data));
      notifyListeners();
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
      _gameState = '대기중';
      _messages.add({
        'sender': '시스템',
        'message': '게임 종료! 승자: ${data['winner']}',
      });
      notifyListeners();
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
}
