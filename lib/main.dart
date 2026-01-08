import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/login_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: MaterialApp(
        title: '마피아 온라인',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.grey[900],
          primaryColor: Colors.redAccent,
        ),
        home: ScreenRouter(),
      ),
    );
  }
}

class ScreenRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Initial connection might take a moment, show spinner?
    if (game.socket.id == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if joined
    final isJoined = game.players.any((p) => p.id == game.socket.id);

    if (!isJoined) {
      return LoginScreen();
    }

    if (game.gameState == '대기중') {
      return LobbyScreen();
    } else {
      return GameScreen();
    }
  }
}
