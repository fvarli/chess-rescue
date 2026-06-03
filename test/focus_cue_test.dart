import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/core/theme/motion.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

// Rescue-piece discoverability experiment: the focus cue must paint on the
// tappable square whenever the player is in a danger state with no selection
// — both during onboarding (loud range) and after onboarding (damped ambient
// range) — and must NOT paint during selection / rescued / failed states.

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: child,
  );
}

const _focusCueKey = ValueKey('focus-cue');

/// Reads the live opacity of the focus cue's AnimatedOpacity. Returns null if
/// the cue isn't currently in the tree (which is itself a valid "absent"
/// signal for the rescued / failed assertions).
double? _focusCueOpacity(WidgetTester tester) {
  final cue = find.byKey(_focusCueKey);
  if (cue.evaluate().isEmpty) return null;
  final opacity = tester.widget<AnimatedOpacity>(
    find.descendant(of: cue, matching: find.byType(AnimatedOpacity)),
  );
  return opacity.opacity;
}

Future<void> _solveCurrent(WidgetTester tester, GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final r = g.currentPuzzle.rescueTo;
  g.handleSquare(t.file, t.rank);
  await tester.pump();
  g.handleSquare(r.file, r.rank);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Focus cue — discoverability invariants', () {
    testWidgets(
      '(a) onboarding (fresh install): cue visible at opening danger state',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        // One settle frame past the AnimatedOpacity fade-in.
        await tester.pump(const Duration(milliseconds: 250));

        expect(game.isOnboarding, isTrue);
        expect(_focusCueOpacity(tester), greaterThan(0.99));
      },
    );

    testWidgets(
      '(b) post-onboarding (onboardingSeen=true): cue STILL visible at danger',
      (tester) async {
        // Pre-flip the onboarding flag — simulates a returning player.
        SharedPreferences.setMockInitialValues({
          'flutter.cr_onboarding_seen': true,
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump(const Duration(milliseconds: 250));

        expect(game.isOnboarding, isFalse);
        // The ambient cue still paints — discoverability is no longer
        // restricted to the player's lifetime first puzzle.
        expect(_focusCueOpacity(tester), greaterThan(0.99));
      },
    );

    testWidgets(
      '(c) cue fades out when the player selects the tappable piece',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_onboarding_seen': true,
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(_focusCueOpacity(tester), greaterThan(0.99));

        // Select the tappable piece — visibility gate should drop.
        final t = game.currentPuzzle.tappableSquare;
        game.handleSquare(t.file, t.rank);
        // Pump past the focusCueFade (200ms).
        await tester.pump(const Duration(milliseconds: 250));

        final after = _focusCueOpacity(tester);
        expect(
          after,
          isNotNull,
          reason: 'cue should remain in the tree but at zero opacity',
        );
        expect(after, lessThan(0.01));
      },
    );

    testWidgets('(d) cue is absent / invisible in rescued state', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_onboarding_seen': true,
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      await tester.pumpWidget(
        _wrap(RescueScreen(store: store, controller: game)),
      );
      await tester.pump(const Duration(milliseconds: 250));

      await _solveCurrent(tester, game);

      final after = _focusCueOpacity(tester);
      // Either out of tree, or in-tree at zero opacity — both are valid.
      if (after != null) {
        expect(
          after,
          lessThan(0.01),
          reason: 'rescued state must not surface the focus cue',
        );
      }
    });

    testWidgets('(e) cue is absent / invisible in failed state', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_onboarding_seen': true,
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      await tester.pumpWidget(
        _wrap(RescueScreen(store: store, controller: game)),
      );
      await tester.pump(const Duration(milliseconds: 250));

      // Play a wrong move: tap the tappable piece, then tap a NON-rescue
      // legal destination.
      final p = game.currentPuzzle;
      final wrong = p.legalMoves.firstWhere((s) => s != p.rescueTo);
      game.handleSquare(p.tappableSquare.file, p.tappableSquare.rank);
      await tester.pump();
      game.handleSquare(wrong.file, wrong.rank);
      // Pump through the failure animation window.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 400));

      final after = _focusCueOpacity(tester);
      if (after != null) {
        expect(
          after,
          lessThan(0.01),
          reason: 'failed state must not surface the focus cue',
        );
      }
    });
  });

  group('Focus cue — loudness asymmetry (the experiment\'s point)', () {
    test(
      'ambient alpha range is strictly quieter than the onboarding range',
      () {
        // Audit recommendation: the ambient cue must be perceptually quieter
        // than the onboarding cue. The simplest invariant that captures it:
        // both endpoints of the ambient range sit below their onboarding
        // counterparts. (The exact peak alpha is intentionally tunable —
        // playtest is the gate for absolute loudness.)
        expect(
          MotionTokens.focusCueAmbientAlphaMin,
          lessThan(MotionTokens.focusCueAlphaMin),
        );
        expect(
          MotionTokens.focusCueAmbientAlphaMax,
          lessThan(MotionTokens.focusCueAlphaMax),
        );
      },
    );
  });
}
