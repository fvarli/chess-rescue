import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void useLargePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void useSmallPhoneViewport(WidgetTester tester, {required Size size}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('HomeScreen (v1.2.0 editorial Daily Rescue landing)', () {
    testWidgets(
      'hero block + episode strip + chip card + quiet progress + records line render',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_lifetime_saved': 12,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        // ── Hero block ───────────────────────────────────────────────
        expect(find.text('DAILY RESCUE'), findsOneWidget);
        expect(find.textContaining('A short rescue'), findsOneWidget);
        expect(find.text('A quiet moment.'), findsOneWidget);
        expect(find.text('Begin when ready.'), findsOneWidget);

        // ── Legacy king hero must NOT be present ─────────────────────
        expect(
          find.byKey(const ValueKey('home-king-hero')),
          findsNothing,
          reason: 'v1.2.0 Home is text-hero-only — king hero removed',
        );

        // ── Episode strip (preserved) ────────────────────────────────
        expect(
          find.byKey(const ValueKey('home-episode-card-list')),
          findsOneWidget,
        );
        for (var n = 1; n <= 5; n++) {
          expect(
            find.byKey(ValueKey('home-episode-card-$n')),
            findsOneWidget,
            reason: 'episode chip $n should render',
          );
        }

        // ── Quiet progress block (preserved content, no card frame) ──
        expect(find.text('EPISODE 1 · STRIKE BACK'), findsOneWidget);
        expect(find.text('Current run'), findsOneWidget);
        expect(find.text('Rescue 1 / 3'), findsOneWidget);

        // ── Records quiet line ───────────────────────────────────────
        expect(find.text('RECORDS'), findsOneWidget);

        // ── New single CTA ───────────────────────────────────────────
        expect(find.text('Begin today\'s rescue  ↦'), findsOneWidget);
        expect(find.text('Continue rescue  ↦'), findsNothing);
        expect(find.text('Start rescue  ↦'), findsNothing);
      },
    );

    testWidgets('first-time and returning players see the SAME single CTA', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(find.text('Begin today\'s rescue  ↦'), findsOneWidget);
      expect(find.text('Start rescue  ↦'), findsNothing);
      expect(find.text('Continue rescue  ↦'), findsNothing);
    });

    testWidgets(
      'counter reflects in-episode progress derived from completedIds',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_completed_ids': ['p1-knight-rescue'],
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();
        expect(find.text('Rescue 2 / 3'), findsOneWidget);
      },
    );

    testWidgets('tapping the CTA pushes RescueScreen for the focused episode', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      expect(find.text('Save the king.'), findsNothing);

      await tester.tap(find.text('Begin today\'s rescue  ↦'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Save the king.'), findsOneWidget);
    });

    testWidgets(
      'tapping a locked episode chip shows the unlock hint snackbar',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        await tester.tap(find.byKey(const ValueKey('home-episode-card-3')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('Finish the previous episode to unlock.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping an unlocked sibling chip switches focus to that episode',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
          ],
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(find.text('EPISODE 2 · END THE THREAT'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('home-episode-card-1')));
        await tester.pump();

        expect(find.text('EPISODE 1 · STRIKE BACK'), findsOneWidget);
      },
    );

    testWidgets('renders without overflow on a small phone (360×640)', (
      tester,
    ) async {
      useSmallPhoneViewport(tester, size: const Size(360, 640));
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a very narrow phone (320×568)', (
      tester,
    ) async {
      useSmallPhoneViewport(tester, size: const Size(320, 568));
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('HomeScreen — PR-12 Latest milestone line', () {
    testWidgets(
      'fresh install: Latest milestone line is ABSENT (no unlocks yet)',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('home-latest-milestone-line')),
          findsNothing,
        );
        // The RECORDS line still renders at the bottom.
        expect(find.text('RECORDS'), findsOneWidget);
        expect(find.text('0 / 13'), findsOneWidget);
      },
    );

    testWidgets(
      'with First Rescue unlocked: Latest milestone line names the last unlocked record',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_lifetime_saved': 1,
          'flutter.cr_unlocked_records': '["first-rescue"]',
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('home-latest-milestone-line')),
          findsOneWidget,
        );
        expect(find.text('LATELY'), findsOneWidget);
        // The new line + the records sheet eyebrow both render the title,
        // but Home alone (no sheet open) renders it exactly once.
        expect(find.text('First Rescue'), findsOneWidget);
        expect(find.text('1 / 13'), findsOneWidget);
      },
    );

    testWidgets('insertion-order semantic: the LAST unlocked id wins', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_intro_seen': true,
        'flutter.cr_lifetime_saved': 10,
        'flutter.cr_unlocked_records':
            '["first-rescue","familiar-ground","ep1-strike-back"]',
        'flutter.cr_completed_ids': [
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
        ],
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      // The last id ("ep1-strike-back") title is "Strike Back".
      expect(find.text('Strike Back'), findsOneWidget);
      // Earlier unlocks must NOT be the Lately line (the new sibling
      // widget would otherwise pull them up). The titles still appear
      // inside the RecordsSheet if it's open — we don't open it here.
      expect(find.text('First Rescue'), findsNothing);
      expect(find.text('Familiar Ground'), findsNothing);
    });
  });

  group('HomeScreen — PR-13 Rescued today line', () {
    testWidgets(
      'fresh install: "Rescued today" line is ABSENT (no rescues yet)',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('home-rescued-today-line')),
          findsNothing,
        );
        expect(find.text('Rescued today'), findsNothing);
      },
    );

    testWidgets(
      'seeded recently-solved with today\'s solvedAt: line is PRESENT',
      (tester) async {
        useLargePhoneViewport(tester);
        final now = DateTime.now().toUtc();
        // The ring's JSON shape is `{entries: [...]}`.
        final ring =
            '{"entries":[{'
            '"canonicalPuzzleId":"p1-knight-rescue",'
            '"encounteredPuzzleId":"p1-knight-rescue",'
            '"episodeId":"ep1-strike-back",'
            '"solvedAt":"${now.toIso8601String()}"'
            '}]}';
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_recently_solved': ring,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('home-rescued-today-line')),
          findsOneWidget,
        );
        expect(find.text('Rescued today'), findsOneWidget);
      },
    );

    testWidgets(
      'seeded recently-solved with last-year solvedAt: line is ABSENT',
      (tester) async {
        useLargePhoneViewport(tester);
        final ring =
            '{"entries":[{'
            '"canonicalPuzzleId":"p1-knight-rescue",'
            '"encounteredPuzzleId":"p1-knight-rescue",'
            '"episodeId":"ep1-strike-back",'
            '"solvedAt":"2025-01-01T12:00:00.000Z"'
            '}]}';
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_recently_solved': ring,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(find.text('Rescued today'), findsNothing);
      },
    );
  });

  group('HomeScreen Ep5 Best Run line', () {
    testWidgets('Best run line is suppressed when bestEndlessStreak is 0', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
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
        'flutter.cr_current_episode_id': 'ep5-endless-rescue',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(find.text('EPISODE 5 · ENDLESS RESCUE'), findsOneWidget);
      expect(find.textContaining('Best run'), findsNothing);
    });

    testWidgets(
      'Best run line renders when bestEndlessStreak > 0 and Ep5 is focused',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
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
          'flutter.cr_current_episode_id': 'ep5-endless-rescue',
          'flutter.cr_best_endless_streak': 17,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();
        expect(find.text('Best run: 17'), findsOneWidget);
      },
    );
  });

  group('HomeScreen localization', () {
    testWidgets('Turkish locale renders Home + episode strings in Turkish', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_intro_seen': true,
        'flutter.cr_language_mode': 'tr',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      expect(find.text('GÜNLÜK KURTARIŞ'), findsOneWidget);
      expect(find.text('Sakin bir an.'), findsOneWidget);
      expect(find.text('BÖLÜM 1 · KARŞI VUR'), findsOneWidget);
      expect(find.text('Mevcut seri'), findsOneWidget);
      expect(find.text('Kurtarış 1 / 3'), findsOneWidget);
      expect(find.text('Bugünün kurtarışına başla  ↦'), findsOneWidget);
    });

    testWidgets('Spanish locale renders Home + episode strings in Spanish', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_intro_seen': true,
        'flutter.cr_language_mode': 'es',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      expect(find.text('RESCATE DIARIO'), findsOneWidget);
      expect(find.text('Un momento tranquilo.'), findsOneWidget);
      expect(find.text('EPISODIO 1 · CONTRAATAQUE'), findsOneWidget);
      expect(find.text('Racha actual'), findsOneWidget);
      expect(find.text('Rescate 1 / 3'), findsOneWidget);
      expect(find.text('Comenzar rescate de hoy  ↦'), findsOneWidget);
    });
  });

  group('ProgressStore.lifetimeSaved', () {
    test('default for an empty store is 0', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.lifetimeSaved, 0);
    });

    test('incrementLifetimeSaved round-trips across reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.incrementLifetimeSaved();
      await s1.incrementLifetimeSaved();
      final s2 = await ProgressStore.create();
      expect(s2.lifetimeSaved, 2);
    });

    test('clear() resets lifetimeSaved to 0', () async {
      SharedPreferences.setMockInitialValues({'flutter.cr_lifetime_saved': 17});
      final s = await ProgressStore.create();
      expect(s.lifetimeSaved, 17);
      await s.clear();
      final s2 = await ProgressStore.create();
      expect(s2.lifetimeSaved, 0);
    });
  });
}
