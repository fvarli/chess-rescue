import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/main.dart';

/// Pumps the app with the given prefs, drives Home to push RescueScreen, and
/// programmatically pops with `result` to simulate a finale (`true`) or a
/// system-back (`null`) return.
Future<void> _pumpAndPopWith({
  required WidgetTester tester,
  required Map<String, Object> prefs,
  required bool? result,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(prefs);
  final store = await ProgressStore.create();
  await tester.pumpWidget(ChessRescueApp(store: store));
  await tester.pump();

  // Tap CTA → Home pushes RescueScreen (now awaiting a bool? result).
  await tester.tap(find.text('Continue rescue  ↦'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  // Pop the just-pushed route with the requested result.
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  navigator.pop<bool>(result);
  // Two pumps: one to deliver the result to the awaiter, one for setState.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P3.1 — auto-focus on episode completion', () {
    testWidgets('completing Ep1 returns Home focused on Ep2', (tester) async {
      await _pumpAndPopWith(
        tester: tester,
        prefs: {
          'flutter.cr_intro_seen': true,
          // Pre-condition: ep1 fully completed in completedIds, so pop(true)
          // landing on Home with _focused == ep1 → auto-focus moves to ep2.
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
          ],
          'flutter.cr_current_episode_id': 'ep1-strike-back',
        },
        result: true,
      );
      expect(find.text('EPISODE 2 · END THE THREAT'), findsOneWidget);
    });

    testWidgets('completing Ep2 returns Home focused on Ep3', (tester) async {
      await _pumpAndPopWith(
        tester: tester,
        prefs: {
          'flutter.cr_intro_seen': true,
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
            'p2-take-the-checker',
            'p5-win-the-queen',
            'b3-remove-the-defender',
          ],
          'flutter.cr_current_episode_id': 'ep2-end-the-threat',
        },
        result: true,
      );
      expect(find.text('EPISODE 3 · HOLD THE LINE'), findsOneWidget);
    });

    testWidgets(
      'completing Ep3 focuses Ep4 and shows trilogy-complete snackbar',
      (tester) async {
        await _pumpAndPopWith(
          tester: tester,
          prefs: {
            'flutter.cr_intro_seen': true,
            'flutter.cr_completed_ids': [
              'p1-knight-rescue',
              'a4-the-breakaway',
              'b4-the-cross-check',
              'p2-take-the-checker',
              'p5-win-the-queen',
              'b3-remove-the-defender',
              'p3-block-the-file',
              'p4-seal-the-diagonal',
              'b1-the-martyr',
            ],
            'flutter.cr_current_episode_id': 'ep3-hold-the-line',
          },
          result: true,
        );
        expect(find.text('EPISODE 4 · THE OTHER SIDE'), findsOneWidget);
        expect(
          find.text('Trilogy complete. Master and Endless unlocked.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('completing Ep4 (master) returns Home focused on Ep5', (
      tester,
    ) async {
      await _pumpAndPopWith(
        tester: tester,
        prefs: {
          'flutter.cr_intro_seen': true,
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
            'p2-take-the-checker',
            'p5-win-the-queen',
            'b3-remove-the-defender',
            'p3-block-the-file',
            'p4-seal-the-diagonal',
            'b1-the-martyr',
          ],
          'flutter.cr_current_episode_id': 'ep4-the-other-side',
        },
        result: true,
      );
      expect(find.text('EPISODE 5 · ENDLESS RESCUE'), findsOneWidget);
    });
  });

  group('P3.1 — completion snackbar', () {
    testWidgets(
      'standard episodeCompleteToast renders for non-trilogy completion',
      (tester) async {
        await _pumpAndPopWith(
          tester: tester,
          prefs: {
            'flutter.cr_intro_seen': true,
            'flutter.cr_completed_ids': [
              'p1-knight-rescue',
              'a4-the-breakaway',
              'b4-the-cross-check',
            ],
            'flutter.cr_current_episode_id': 'ep1-strike-back',
          },
          result: true,
        );
        expect(
          find.text('Episode complete. Next rescue unlocked.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'system-back pop (result null) shows NO snackbar and no auto-focus',
      (tester) async {
        await _pumpAndPopWith(
          tester: tester,
          prefs: {
            'flutter.cr_intro_seen': true,
            'flutter.cr_completed_ids': [
              'p1-knight-rescue',
              'a4-the-breakaway',
              'b4-the-cross-check',
            ],
            'flutter.cr_current_episode_id': 'ep1-strike-back',
          },
          result: null,
        );
        // Focus stays on ep1, no completion snackbar.
        expect(find.text('EPISODE 1 · STRIKE BACK'), findsOneWidget);
        expect(
          find.text('Episode complete. Next rescue unlocked.'),
          findsNothing,
        );
        expect(
          find.text('Trilogy complete. Master and Endless unlocked.'),
          findsNothing,
        );
      },
    );
  });

  group('P3.1 — persistence', () {
    testWidgets(
      'cr_current_episode_id persists to next episode after completion',
      (tester) async {
        await _pumpAndPopWith(
          tester: tester,
          prefs: {
            'flutter.cr_intro_seen': true,
            'flutter.cr_completed_ids': [
              'p1-knight-rescue',
              'a4-the-breakaway',
              'b4-the-cross-check',
            ],
            'flutter.cr_current_episode_id': 'ep1-strike-back',
          },
          result: true,
        );
        // The async setCurrentEpisodeId fire-and-forget needs a microtask
        // flush before the fresh store read.
        await tester.pump(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(fresh.currentEpisodeId, 'ep2-end-the-threat');
      },
    );
  });
}
