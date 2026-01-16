import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import 'game_state_provider.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeMode themeMode(Ref ref) {
  final gamePhase = ref.watch(gameStateProvider.select((s) => s.gamePhase));

  switch (gamePhase) {
    case GamePhase.day:
      return ThemeMode.light;
    case GamePhase.night:
    case GamePhase.waiting:
    case GamePhase.result:
      return ThemeMode.dark;
  }
}
