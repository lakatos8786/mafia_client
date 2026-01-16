import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/connection_provider.dart';
import 'providers/game_state_provider.dart';
import 'screens/login_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';
import 'models/game_enums.dart';
import 'theme/noir_design.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'theme/app_strings.dart';

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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '마피아 온라인',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      home: const ScreenRouter(),
      scrollBehavior: NeonScrollBehavior(),
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
      color: NoirColors.crimson,
      child: child,
    );
  }
}

class ScreenRouter extends ConsumerWidget {
  const ScreenRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketId = ref.watch(connectionProvider.notifier).socketId;
    final gameState = ref.watch(gameStateProvider);

    // Initial connection might take a moment, show spinner?
    // We check socketService initialization in ConnectionNotifier.
    // Assuming socketId is null until connected.
    if (!ref.watch(connectionProvider).isConnected && socketId == null) {
      // Assuming 'isConnected' or similar state.
      // Or just check socketId.
      // But checking ConnectionState is better.
      // connectionProvider exposes ConnectionState.
      // ConnectionState has ... ? I need to check ConnectionState class.
      // I'll stick to socketId for now which was used before.

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: NoirColors.crimson),
              SizedBox(height: 20),
              Text(
                AppStrings.connecting,
                style: GoogleFonts.gowunDodum(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppStrings.connectionColdStart,
                textAlign: TextAlign.center,
                style: GoogleFonts.gowunDodum(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Check if joined
    final isJoined = gameState.players.any((p) => p.id == socketId);

    if (!isJoined) {
      return const LoginScreen();
    }

    if (gameState.gamePhase == GamePhase.waiting) {
      return const LobbyScreen();
    } else {
      return const GameScreen();
    }
  }
}
