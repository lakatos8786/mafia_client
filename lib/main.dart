import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/login_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: MaterialApp(
        title: '마피아 온라인',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Deep Dark Blue
          primaryColor: const Color(0xFFE94560), // Neon Red
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE94560),
            secondary: Color(0xFF0F3460), // Dark Blue
            surface: Color(0xFF16213E), // Slightly Lighter Blue
          ),
          textTheme: GoogleFonts.gowunDodumTextTheme(ThemeData.dark().textTheme)
              .copyWith(
                displayLarge: GoogleFonts.gowunDodum(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                headlineMedium: GoogleFonts.gowunDodum(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        home: ScreenRouter(),
      ),
    );
  }
}

class ScreenRouter extends StatelessWidget {
  const ScreenRouter({super.key});

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
