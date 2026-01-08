import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mafia_client/providers/game_provider.dart';
import 'package:mafia_client/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Mafia title smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Wait for all animations and frames to settle.
    await tester.pumpAndSettle();

    // Verify that the Mafia title is present.
    expect(find.text('마피아 온라인'), findsOneWidget);
    expect(find.text('게임 참가'), findsOneWidget);
  });
}
