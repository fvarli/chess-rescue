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

  group('HomeScreen (P1)', () {
    testWidgets(
      'renders title + tagline + progress card + CTA for a returning player',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_lifetime_saved': 12,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        // Title + tagline (reusing appTitle + introTitle).
        expect(find.text('Chess Rescue'), findsOneWidget);
        expect(find.text('One move saves the king.'), findsOneWidget);

        // Progress card.
        expect(find.text('CURRENT RUN'), findsOneWidget);
        expect(find.text('Rescue 1 / 5'), findsOneWidget);
        expect(find.text('Total rescues: 12'), findsOneWidget);

        // Returning CTA.
        expect(find.text('Continue  ↦'), findsOneWidget);
        expect(find.text('Start  ↦'), findsNothing);
      },
    );

    testWidgets('first-time player sees the Start CTA, not Continue', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(find.text('Start  ↦'), findsOneWidget);
      expect(find.text('Continue  ↦'), findsNothing);
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

      await tester.tap(find.text('Continue  ↦'));
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

      expect(find.text('Tek hamle şahı kurtarır.'), findsOneWidget);
      expect(find.text('MEVCUT SERI'), findsOneWidget);
      expect(find.text('Kurtarış 1 / 5'), findsOneWidget);
      expect(find.text('Toplam kurtarış: 0'), findsOneWidget);
      expect(find.text('Devam et  ↦'), findsOneWidget);
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

      expect(find.text('Un movimiento salva al rey.'), findsOneWidget);
      expect(find.text('RACHA ACTUAL'), findsOneWidget);
      expect(find.text('Rescate 1 / 5'), findsOneWidget);
      expect(find.text('Rescates totales: 0'), findsOneWidget);
      expect(find.text('Continuar  ↦'), findsOneWidget);
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
