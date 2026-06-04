import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';
import 'package:chess_rescue/core/models/signature_entry.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/features/rescue_game/widgets/saved_badge.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

// Developer Reset Surface — verifies the full wipe across all 16 persisted
// keys (tests 1–5) and the in-screen long-press → confirm → reset → pop
// flow on RescueScreen (test 6). All paths reuse `ProgressStore.clear()` and
// `GameController.resetProgress()`; this test file is a regression net for
// either method silently growing a new key or skipping a domain.

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: child,
  );
}

SignatureEntry _signatureFor(String canonicalId, {String? episodeId}) {
  return SignatureEntry(
    canonicalPuzzleId: canonicalId,
    encounteredPuzzleId: canonicalId,
    episodeId: episodeId ?? 'ep1',
    adoptedAt: DateTime.parse('2026-01-15T12:00:00Z'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressStore.clear() — per-domain wipe coverage', () {
    test('(1) clears completedIds', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.save(
        sessionSeed: 7,
        puzzleIndex: 3,
        completedIds: {'p1-knight-rescue', 'p2-take-the-checker'},
      );
      await s1.addCompletedId('p3-block-the-file');
      expect((await ProgressStore.create()).completedIds, isNotEmpty);

      await s1.clear();

      final reloaded = await ProgressStore.create();
      expect(reloaded.completedIds, isEmpty);
      expect(reloaded.sessionSeed, 0);
      expect(reloaded.puzzleIndex, 0);
    });

    test('(2) clears intro + onboarding flags', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.setIntroSeen();
      await s1.setOnboardingSeen();
      expect((await ProgressStore.create()).introSeen, isTrue);
      expect((await ProgressStore.create()).onboardingSeen, isTrue);

      await s1.clear();

      final reloaded = await ProgressStore.create();
      expect(reloaded.introSeen, isFalse);
      expect(reloaded.onboardingSeen, isFalse);
    });

    test(
      '(3) clears signatures + recently-solved + bookmark-hint + tab-pulse',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s1 = await ProgressStore.create();
        await s1.addSignature(_signatureFor('p1-knight-rescue'));
        await s1.addSignature(_signatureFor('b1-the-martyr', episodeId: 'ep3'));
        await s1.recordRecentlySolved(
          RecentlySolvedEntry(
            canonicalPuzzleId: 'p2-take-the-checker',
            encounteredPuzzleId: 'p2-take-the-checker',
            episodeId: 'ep2',
            solvedAt: DateTime.parse('2026-02-01T09:00:00Z'),
          ),
        );
        await s1.markSignaturesFirstBookmarkHintSeen();
        await s1.markSignaturesTabPulseSeen();
        // Sanity precondition.
        final pre = await ProgressStore.create();
        expect(pre.signatures, hasLength(2));
        expect(pre.recentlySolved.entries, hasLength(1));
        expect(pre.hasSeenSignaturesTabPulse, isTrue);

        await s1.clear();

        final reloaded = await ProgressStore.create();
        expect(reloaded.signatures, isEmpty);
        expect(reloaded.recentlySolved.entries, isEmpty);
        expect(reloaded.hasSeenSignaturesTabPulse, isFalse);
        // The first-bookmark hint flag has no public getter; verify via the
        // raw SharedPreferences read instead.
        final sp = await SharedPreferences.getInstance();
        expect(
          sp.containsKey('cr_signatures_first_bookmark_hint_seen'),
          isFalse,
        );
      },
    );

    test('(4) clears familiarity hint flag', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.markFirstFamiliarityHintSeen();
      expect(
        (await ProgressStore.create()).hasSeenFirstFamiliarityHint,
        isTrue,
      );

      await s1.clear();

      expect(
        (await ProgressStore.create()).hasSeenFirstFamiliarityHint,
        isFalse,
      );
    });

    test(
      '(5) clears episode id + episode seeds + best endless streak + records + lang + lifetime',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s1 = await ProgressStore.create();
        await s1.setCurrentEpisodeId('ep3');
        await s1.setEpisodeSeed('ep5', 42);
        await s1.setEpisodeSeed('ep1', 7);
        await s1.updateBestEndlessStreak(11);
        await s1.addUnlockedRecord('firstRescue');
        await s1.addUnlockedRecord('familiarGround');
        await s1.setLanguageMode('tr');
        await s1.incrementLifetimeSaved();
        await s1.incrementLifetimeSaved();
        // Sanity preconditions.
        final pre = await ProgressStore.create();
        expect(pre.currentEpisodeId, 'ep3');
        expect(pre.seedFor('ep5'), 42);
        expect(pre.bestEndlessStreak, 11);
        expect(pre.unlockedRecords, isNotEmpty);
        expect(pre.languageMode, 'tr');
        expect(pre.lifetimeSaved, 2);

        await s1.clear();

        final reloaded = await ProgressStore.create();
        expect(reloaded.currentEpisodeId, isNull);
        expect(reloaded.episodeSeeds, isEmpty);
        expect(reloaded.bestEndlessStreak, 0);
        expect(reloaded.unlockedRecords, isEmpty);
        expect(reloaded.languageMode, 'system');
        expect(reloaded.lifetimeSaved, 0);
      },
    );
  });

  group('RescueScreen — developer reset long-press flow', () {
    testWidgets('(6a) confirm path — long-press → Reset → wipes store + resets controller', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_onboarding_seen': true,
        'flutter.cr_intro_seen': true,
        'flutter.cr_completed_ids': <String>['p1-knight-rescue'],
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      // Mount RescueScreen directly. (`Navigator.maybePop()` inside
      // `_confirmAndReset` is a no-op when there's no route below — this is
      // fine; we verify the reset behavior, not the pop target.)
      await tester.pumpWidget(
        _wrap(RescueScreen(store: store, controller: game)),
      );
      await tester.pump();

      // SavedBadge should be present in the rescue screen header.
      final badge = find.byType(SavedBadge);
      expect(badge, findsOneWidget);
      expect(game.isOnboarding, isFalse,
          reason: 'pre-condition: returning player');

      // Long-press → confirmation dialog appears.
      await tester.longPress(badge);
      // Pump enough for showDialog to mount.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Reset all progress?'), findsOneWidget);
      // Disambiguate: RescueScreen has its own per-puzzle "Reset" footer
      // button, so plain `find.text('Reset')` matches two widgets. Scope to
      // the dialog.
      final dialogResetBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Reset'),
      );
      final dialogCancelBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      );
      expect(dialogCancelBtn, findsOneWidget);
      expect(dialogResetBtn, findsOneWidget);

      // Confirm — `_confirmAndReset` awaits resetProgress (which awaits
      // store.clear) and then maybePops. Pump the dialog dismissal +
      // resetProgress future chain.
      await tester.tap(dialogResetBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      // Dialog has dismissed.
      expect(find.text('Reset all progress?'), findsNothing);

      // In-memory controller state is back to first-run.
      expect(game.isOnboarding, isTrue,
          reason: 'after reset, controller should re-enter onboarding');

      // Disk is wiped — completedIds + intro + onboarding flags gone.
      final reloaded = await ProgressStore.create();
      expect(reloaded.completedIds, isEmpty);
      expect(reloaded.introSeen, isFalse);
      expect(reloaded.onboardingSeen, isFalse);
    });

    testWidgets('(6b) cancel path — dialog dismisses, store unchanged', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_onboarding_seen': true,
        'flutter.cr_intro_seen': true,
        'flutter.cr_completed_ids': <String>['p1-knight-rescue'],
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      await tester.pumpWidget(
        _wrap(RescueScreen(store: store, controller: game)),
      );
      await tester.pump();

      await tester.longPress(find.byType(SavedBadge));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Reset all progress?'), findsOneWidget);

      // Cancel — dialog dismisses, screen stays mounted.
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Reset all progress?'), findsNothing);
      expect(
        find.byType(SavedBadge),
        findsOneWidget,
        reason: 'RescueScreen should still be mounted after cancel',
      );

      // Store untouched.
      final reloaded = await ProgressStore.create();
      expect(reloaded.completedIds, contains('p1-knight-rescue'));
      expect(reloaded.introSeen, isTrue);
      expect(reloaded.onboardingSeen, isTrue);
      // Controller state untouched.
      expect(game.isOnboarding, isFalse);
    });
  });
}
