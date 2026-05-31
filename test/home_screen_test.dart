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

  group('HomeScreen (P3 episode shell)', () {
    testWidgets(
      'renders king hero + title + tagline + episode strip + episode card + CTA',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_lifetime_saved': 12,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        // Identity layer (P2).
        expect(find.byKey(const ValueKey('home-king-hero')), findsOneWidget);
        expect(find.text('Chess Rescue'), findsOneWidget);
        expect(
          find.text('Your king is in danger.\nFind the rescue.'),
          findsOneWidget,
        );

        // Episode strip — 5 chips present (P3 identity layer).
        expect(
          find.byKey(const ValueKey('home-episode-strip')),
          findsOneWidget,
        );
        for (var n = 1; n <= 5; n++) {
          expect(
            find.byKey(ValueKey('home-episode-chip-$n')),
            findsOneWidget,
            reason: 'episode chip $n should render',
          );
        }

        // Episode 1 panel — Strike Back, 3-puzzle pacing.
        expect(find.text('EPISODE 1 · STRIKE BACK'), findsOneWidget);
        expect(find.text('Turn the attack back.'), findsOneWidget);
        expect(find.text('Current run'), findsOneWidget);
        expect(find.text('Rescue 1 / 3'), findsOneWidget);
        expect(find.text('Total rescues: 12'), findsOneWidget);

        // Returning CTA.
        expect(find.text('Continue rescue  ↦'), findsOneWidget);
        expect(find.text('Start rescue  ↦'), findsNothing);
      },
    );

    testWidgets('first-time player sees the Start rescue CTA, not Continue', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(find.text('Start rescue  ↦'), findsOneWidget);
      expect(find.text('Continue rescue  ↦'), findsNothing);
      expect(find.text('Total rescues: 0'), findsOneWidget);
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
        // Ep1 player has done p1 (1 of 3) — resumes at puzzle 2.
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

      await tester.tap(find.text('Continue rescue  ↦'));
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

        // Ep3 should be locked (ep1 not complete).
        await tester.tap(find.byKey(const ValueKey('home-episode-chip-3')));
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
          // ep1 complete → ep2 unlocked
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
          ],
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        // Defaults to ep2 (first non-complete after ep1).
        expect(find.text('EPISODE 2 · END THE THREAT'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('home-episode-chip-1')));
        await tester.pump();

        expect(find.text('EPISODE 1 · STRIKE BACK'), findsOneWidget);
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
        // Clear all 3 canonical episodes so ep5 is unlocked + can be focused.
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

      expect(find.text('Şahın tehlikede.\nKurtarışı bul.'), findsOneWidget);
      expect(find.text('BÖLÜM 1 · KARŞI VUR'), findsOneWidget);
      expect(find.text('Saldırıyı geri çevir.'), findsOneWidget);
      expect(find.text('Mevcut seri'), findsOneWidget);
      expect(find.text('Kurtarış 1 / 3'), findsOneWidget);
      expect(find.text('Toplam kurtarış: 0'), findsOneWidget);
      expect(find.text('Kurtarışa devam et  ↦'), findsOneWidget);
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

      expect(
        find.text('Tu rey está en peligro.\nEncuentra el rescate.'),
        findsOneWidget,
      );
      expect(find.text('EPISODIO 1 · CONTRAATAQUE'), findsOneWidget);
      expect(find.text('Devuelve el ataque.'), findsOneWidget);
      expect(find.text('Racha actual'), findsOneWidget);
      expect(find.text('Rescate 1 / 3'), findsOneWidget);
      expect(find.text('Rescates totales: 0'), findsOneWidget);
      expect(find.text('Continuar rescate  ↦'), findsOneWidget);
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
