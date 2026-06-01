import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/episode_library.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/familiarity/familiar_cue.dart';
import 'package:chess_rescue/features/familiarity/familiarity_first_seen_overlay.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/game_state.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: child,
  );
}

// Inside testWidgets the fake clock won't fire Future.delayed unless the
// tester pumps. Drive the controller through its internal _commitMove
// awaits via tester.pump(duration).
Future<void> _solveCurrent(WidgetTester tester, GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final r = g.currentPuzzle.rescueTo;
  g.handleSquare(t.file, t.rank);
  await tester.pump();
  g.handleSquare(r.file, r.rank);
  // _commitMove awaits MotionTokens.commitWindUp + pieceSlide; pump well
  // past both to land on the rescued state.
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RescueScreen — Familiarity integration (PR 3)', () {
    testWidgets(
      'fresh install + first rescue (no prior solves): no FamiliarCue, '
      'no FamiliarityFirstSeenOverlay',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump();

        // Solve to reach rescued state.
        await _solveCurrent(tester, game);
        await tester.pump(const Duration(milliseconds: 100));

        // First-ever rescue → snapshot was false at _loadPuzzle.
        expect(find.byType(FamiliarCue), findsNothing);
        expect(find.byType(FamiliarityFirstSeenOverlay), findsNothing);
        final fresh = await ProgressStore.create();
        expect(fresh.hasSeenFirstFamiliarityHint, isFalse);
      },
    );

    testWidgets('pre-seeded store: fresh RescueScreen for a previously-solved '
        'canonical → FamiliarCue appears on rescued + overlay fires once', (
      tester,
    ) async {
      // Pre-seed every ep1 canonical id, so the controller's restore
      // logic lands on the last puzzle and that puzzle is already in
      // store.completedIds — snapshot true.
      SharedPreferences.setMockInitialValues({
        'flutter.cr_completed_ids': <String>[
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
        ],
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      expect(game.wasPreviouslySolvedAtStart, isTrue);

      await tester.pumpWidget(
        _wrap(RescueScreen(store: store, controller: game)),
      );
      await tester.pump();
      // In the danger state, the cue is NOT yet visible (only on rescued).
      expect(find.byType(FamiliarCue), findsNothing);

      // Solve to reach the rescued state.
      await _solveCurrent(tester, game);
      // Let the controller listener fire and the overlay mount.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 280));

      // Bare cue is now visible in the layout column.
      expect(find.byType(FamiliarCue), findsOneWidget);
      // First-recognition overlay fired (first time per device).
      expect(find.byType(FamiliarityFirstSeenOverlay), findsOneWidget);
      // The persistent flag is now set.
      final fresh = await ProgressStore.create();
      expect(fresh.hasSeenFirstFamiliarityHint, isTrue);
    });

    testWidgets(
      'pre-seeded store + first-recognition flag already true: bare cue '
      'still appears on rescued, but overlay does NOT re-fire',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': <String>[
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
          ],
          'flutter.cr_familiarity_first_seen_hint_seen': true,
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);

        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump();
        await _solveCurrent(tester, game);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 280));

        // Bare cue still visible.
        expect(find.byType(FamiliarCue), findsOneWidget);
        // Overlay does NOT re-fire — single-fire history honoured.
        expect(find.byType(FamiliarityFirstSeenOverlay), findsNothing);
      },
    );

    testWidgets(
      'FamiliarCue is gated on rescued: NOT visible during the danger '
      'state of a previously-solved puzzle',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': <String>[
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
          ],
          'flutter.cr_familiarity_first_seen_hint_seen': true,
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        expect(game.state, GameState.danger);

        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump();

        // Danger state → cue is suppressed.
        expect(find.byType(FamiliarCue), findsNothing);
      },
    );

    testWidgets(
      'Endless mode with familiar canonical: cue + overlay fire on the '
      'rescued screen — covers the cross-mode path through store.completedIds',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': <String>[
            'p1-knight-rescue',
            'p2-take-the-checker',
            'p3-block-the-file',
            'p4-seal-the-diagonal',
            'p5-win-the-queen',
            'a4-the-breakaway',
            'b1-the-martyr',
            'b3-remove-the-defender',
            'b4-the-cross-check',
          ],
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store, episode: EpisodeLibrary.ep5);
        expect(game.wasPreviouslySolvedAtStart, isTrue);

        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump();
        await _solveCurrent(tester, game);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 280));

        expect(find.byType(FamiliarCue), findsOneWidget);
        expect(find.byType(FamiliarityFirstSeenOverlay), findsOneWidget);
      },
    );
  });
}
