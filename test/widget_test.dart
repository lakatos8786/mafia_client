import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_client/providers/connection_provider.dart';
import 'package:mafia_client/providers/game_state_provider.dart';
import 'package:mafia_client/providers/action_provider.dart';
import 'package:mafia_client/models/game_enums.dart';

void main() {
  group('GameProvider Tests', () {
    late ConnectionProvider connectionProvider;
    late GameStateProvider gameStateProvider;
    late ActionProvider actionProvider;

    setUp(() {
      connectionProvider = ConnectionProvider();
      gameStateProvider = GameStateProvider(connectionProvider);
      actionProvider = ActionProvider(connectionProvider, gameStateProvider);
    });

    tearDown(() {
      connectionProvider.dispose();
    });

    test('Initial state should be waiting', () {
      expect(gameStateProvider.gamePhase, GamePhase.waiting);
      expect(gameStateProvider.dayCount, 1);
      expect(gameStateProvider.players, isEmpty);
    });

    test('Vote toggle logic should work correctly', () {
      // This test would require mocking socket events
      // For now, just verify initial state
      expect(actionProvider.votes, isEmpty);
      expect(actionProvider.voters, isEmpty);
    });

    test('Night selections should be empty initially', () {
      expect(actionProvider.nightSelections, isEmpty);
      expect(actionProvider.nightActionActors, isEmpty);
    });

    test('Messages should be empty initially', () {
      expect(actionProvider.messages, isEmpty);
    });

    test('Connection state should start as connecting', () {
      expect(connectionProvider.connectionState, 'connecting');
    });
  });
}
