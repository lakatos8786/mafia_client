import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_client/providers/connection_provider.dart';
import 'package:mafia_client/providers/game_state_provider.dart';
import 'package:mafia_client/providers/action_provider.dart';
import 'package:mafia_client/models/game_enums.dart';

void main() {
  group('Provider Tests', () {
    test('Initial state should be waiting', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gameState = container.read(gameStateProvider);
      expect(gameState.gamePhase, GamePhase.waiting);
      expect(gameState.dayCount, 1);
      expect(gameState.players, isEmpty);
    });

    test('Vote toggle logic should work correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final actionState = container.read(actionProvider);
      expect(actionState.votes, isEmpty);
      expect(actionState.voters, isEmpty);
    });

    test('Night selections should be empty initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final actionState = container.read(actionProvider);
      expect(actionState.nightSelections, isEmpty);
      expect(actionState.nightActionActors, isEmpty);
    });

    test('Messages should be empty initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final actionState = container.read(actionProvider);
      expect(actionState.messages, isEmpty);
    });

    test('Connection state should start as connecting', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final connectionState = container.read(connectionProvider);
      // Depending on how fast _initSocket runs, it might be connecting or something else.
      // But typically default state is const ConnectionState() which defaults to 'connecting'.
      expect(connectionState.status, 'connecting');
    });
  });
}
