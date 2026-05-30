import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressStore introSeen', () {
    test('defaults to false and is independent of onboardingSeen', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.introSeen, isFalse);
      expect(s.onboardingSeen, isFalse);
    });

    test('setIntroSeen persists; onboardingSeen untouched', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.setIntroSeen();
      final s2 = await ProgressStore.create();
      expect(s2.introSeen, isTrue);
      expect(s2.onboardingSeen, isFalse); // intro must not flip onboarding
    });

    test('clear() removes the intro flag', () async {
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final s = await ProgressStore.create();
      expect(s.introSeen, isTrue);
      await s.clear();
      final s2 = await ProgressStore.create();
      expect(s2.introSeen, isFalse);
    });
  });

  group('GameController showIntro', () {
    test('store with introSeen false → showIntro true', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameController(store: await ProgressStore.create());
      expect(game.showIntro, isTrue);
    });

    test('store with introSeen true → showIntro false', () async {
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final game = GameController(store: await ProgressStore.create());
      expect(game.showIntro, isFalse);
    });

    test('no store (harness/degraded) → showIntro false', () {
      final game = GameController();
      expect(game.showIntro, isFalse);
    });

    test(
      'dismissIntro hides intro, persists, leaves puzzle state intact',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        final stateBefore = game.state;
        final puzzleBefore = game.puzzleNumber;
        final savedBefore = game.completedCount;

        game.dismissIntro();

        expect(game.showIntro, isFalse);
        expect(game.state, stateBefore); // danger cold open unchanged
        expect(game.puzzleNumber, puzzleBefore);
        expect(game.completedCount, savedBefore);

        await Future<void>.delayed(const Duration(milliseconds: 10));
        final reloaded = await ProgressStore.create();
        expect(reloaded.introSeen, isTrue);
        expect(reloaded.onboardingSeen, isFalse); // focus cue still armed
      },
    );

    test('resetProgress re-arms the intro (store present)', () async {
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final game = GameController(store: await ProgressStore.create());
      expect(game.showIntro, isFalse);
      await game.resetProgress();
      expect(game.showIntro, isTrue);
    });
  });

  group('IntroOverlay in RescueScreen', () {
    testWidgets('shows on first run, dismisses to the danger cold open', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: RescueScreen(store: store),
        ),
      );
      await tester.pump();

      expect(find.text('One move saves the king.'), findsOneWidget);
      expect(find.text('Start rescue'), findsOneWidget);

      await tester.tap(find.text('Start rescue'));
      await tester.pump(); // begin cross-fade
      await tester.pump(const Duration(milliseconds: 700)); // finish switcher

      expect(find.text('Start rescue'), findsNothing);
      expect(find.text('Save the king.'), findsOneWidget); // danger cold open
    });

    testWidgets('returning user (introSeen true) never sees the intro', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: RescueScreen(store: store),
        ),
      );
      await tester.pump();

      expect(find.text('Start rescue'), findsNothing);
      expect(find.text('Save the king.'), findsOneWidget);
    });
  });
}
