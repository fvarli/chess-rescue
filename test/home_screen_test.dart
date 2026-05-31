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

  group('HomeScreen (P2)', () {
    testWidgets(
      'renders king hero + title + tagline + mission card + CTA for a returning player',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_lifetime_saved': 12,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        // King hero is present (identity layer).
        expect(find.byKey(const ValueKey('home-king-hero')), findsOneWidget);

        // Title + new active tagline.
        expect(find.text('Chess Rescue'), findsOneWidget);
        expect(
          find.text('Your king is in danger.\nFind the rescue.'),
          findsOneWidget,
        );

        // Mission-briefing progress card.
        expect(find.text('RESCUE MISSION'), findsOneWidget);
        expect(find.text('Current run'), findsOneWidget);
        expect(find.text('Rescue 1 / 5'), findsOneWidget);
        expect(find.text('Total rescues: 12'), findsOneWidget);

        // Returning CTA carries the rescue verb.
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
      // Lifetime starts at 0 — no fake content claimed.
      expect(find.text('Total rescues: 0'), findsOneWidget);
    });

    testWidgets(
      'session counter reflects ProgressStore.puzzleIndex on cold start',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_puzzle_index': 2, // third puzzle of the run
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();
        expect(find.text('Rescue 3 / 5'), findsOneWidget);
      },
    );

    testWidgets('tapping the CTA pushes RescueScreen', (tester) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      // Pre-tap: rescue-screen content is not on screen.
      expect(find.text('Save the king.'), findsNothing);

      await tester.tap(find.text('Continue rescue  ↦'));
      // Pump the navigation transition (Material default ~300 ms).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // RescueScreen's danger headline is now visible.
      expect(find.text('Save the king.'), findsOneWidget);
    });
  });

  group('HomeScreen localization', () {
    testWidgets('Turkish locale renders Home strings in Turkish', (
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
      expect(find.text('KURTARMA GÖREVİ'), findsOneWidget);
      expect(find.text('Mevcut seri'), findsOneWidget);
      expect(find.text('Kurtarış 1 / 5'), findsOneWidget);
      expect(find.text('Toplam kurtarış: 0'), findsOneWidget);
      expect(find.text('Kurtarışa devam et  ↦'), findsOneWidget);
    });

    testWidgets('Spanish locale renders Home strings in Spanish', (
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
      expect(find.text('MISIÓN DE RESCATE'), findsOneWidget);
      expect(find.text('Racha actual'), findsOneWidget);
      expect(find.text('Rescate 1 / 5'), findsOneWidget);
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
