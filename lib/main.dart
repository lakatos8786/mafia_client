import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/login_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';
import 'models/game_enums.dart';
import 'theme/app_colors.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Preload Google Fonts to prevent text rendering issues
  await GoogleFonts.pendingFonts([GoogleFonts.gowunDodum()]);

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
          scaffoldBackgroundColor: AppColors.backgroundMain,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.deadRed,
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
        scrollBehavior: NeonScrollBehavior(),
      ),
    );
  }
}

class NeonScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: AppColors.primary,
      child: child,
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 20),
              Text(
                "서버에 접속 중입니다...",
                style: GoogleFonts.gowunDodum(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "서버가 절전 모드에서 깨어나는 데\n최대 1분 정도 소요될 수 있습니다.",
                textAlign: TextAlign.center,
                style: GoogleFonts.gowunDodum(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Check if joined
    final isJoined = game.players.any((p) => p.id == game.socket.id);

    if (!isJoined) {
      return LoginScreen();
    }

    if (game.gamePhase == GamePhase.waiting) {
      return LobbyScreen();
    } else {
      return GameScreen();
    }
  }
}
