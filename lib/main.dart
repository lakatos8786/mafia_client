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
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Slate
          primaryColor: const Color(0xFFF43F5E), // Neon Crimson
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF43F5E), // Neon Crimson
            secondary: Color(0xFF0EA5E9), // Cyber Blue
            surface: Color(0xFF1E293B), // Deep Slate
            error: Color(0xFFFF1744),
          ),
          textTheme: GoogleFonts.gowunDodumTextTheme(ThemeData.dark().textTheme)
              .copyWith(
                displayLarge: GoogleFonts.gowunDodum(
                  color: Colors.white,
                  fontWeight: FontWeight.w900, // Extra Bold
                  letterSpacing: 2.0,
                ),
                headlineMedium: GoogleFonts.gowunDodum(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                bodyLarge: GoogleFonts.gowunDodum(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
        home: const ScreenRouter(),
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
