import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: child,
);

// Drive the controller through a complete rescue. Pump times mirror the
// internal _commitMove awaits (commitWindUp 80 ms + pieceSlide 220 ms ≈
// 300 ms before the state lands on rescued).
Future<void> _solveCurrent(WidgetTester tester, GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final r = g.currentPuzzle.rescueTo;
  g.handleSquare(t.file, t.rank);
  await tester.pump();
  g.handleSquare(r.file, r.rank);
  // Pump just past commitWindUp + pieceSlide so the controller has
  // transitioned to rescued state. Total: ~320 ms post-second-tap.
  await tester.pump(const Duration(milliseconds: 320));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RescueScreen — PR-7 rescue ceremony stagger', () {
    testWidgets('"Rescued." is HIDDEN immediately after the rescued transition '
        'and APPEARS only after rescueHeadlineSettleDelay (280 ms)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      await tester.pumpWidget(
        _wrap(RescueScreen(store: store, controller: game)),
      );
      await tester.pump();

      // Drive the rescue. After _solveCurrent the state is rescued but
      // the 280 ms settle delay has just started — the headline must
      // not be present yet.
      await _solveCurrent(tester, game);
      expect(
        find.text('Rescued.'),
        findsNothing,
        reason:
            '"Rescued." must NOT appear in the gating window — board '
            'effects (bloom / arrow / ring) own the moment first.',
      );

      // Pump past the settle delay + a few rebuild frames so the
      // AnimatedSwitcher has time to swap from the empty placeholder
      // to the "Rescued." Text widget. The switcher's
      // rescueHeadlineFade is 320 ms, so we need ~600 ms total margin
      // past the settle delay to be safe.
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text('Rescued.'),
        findsOneWidget,
        reason:
            'after the 280 ms settle delay + the 320 ms fade-in, '
            '"Rescued." should be on screen.',
      );
    });
  });
}
