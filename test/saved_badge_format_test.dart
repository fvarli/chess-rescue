import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/rescue_game/widgets/saved_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavedBadge — PR-8 SAVED · N format', () {
    testWidgets(
      'renders exact "SAVED · 12" with single spaces around the dot',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: SavedBadge(count: 12, onReset: null)),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(SavedBadge), findsOneWidget);
        // Exact single-space format per the brief.
        expect(find.text('SAVED · 12'), findsOneWidget);
        // Old "{count} SAVED" format must not be present.
        expect(find.text('12 SAVED'), findsNothing);
      },
    );

    testWidgets('renders correctly for count = 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SavedBadge(count: 0, onReset: null)),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('SAVED · 0'), findsOneWidget);
    });

    testWidgets(
      'long-press fires onReset (load-bearing for the dev-reset gesture)',
      (tester) async {
        var resetTaps = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SavedBadge(count: 5, onReset: () => resetTaps += 1),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.longPress(find.byType(SavedBadge));
        await tester.pump();
        expect(resetTaps, 1);
      },
    );

    testWidgets(
      'long-press is inert when onReset is null (release-mode gate)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: SavedBadge(count: 5, onReset: null)),
            ),
          ),
        );
        await tester.pump();
        await tester.longPress(find.byType(SavedBadge));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
