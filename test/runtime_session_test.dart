import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/episode_library.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/variation.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/game_state.dart';

/// Solve the controller's current puzzle and await the commit animation window.
Future<void> _solveCurrent(GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final r = g.currentPuzzle.rescueTo;
  g.handleSquare(t.file, t.rank);
  g.handleSquare(r.file, r.rank);
  await Future<void>.delayed(const Duration(milliseconds: 400));
}

/// Solve every puzzle in the controller's session, leaving the controller on
/// the final rescued screen.
Future<void> _solveSession(GameController g) async {
  final count = g.puzzleCount;
  for (var i = 0; i < count; i++) {
    await _solveCurrent(g);
    if (i < count - 1) g.onPrimaryAction();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('canonicalPuzzleId', () {
    test('strips the variation suffix; base maps to itself', () {
      expect(canonicalPuzzleId('p1-knight-rescue#mirror'), 'p1-knight-rescue');
      expect(canonicalPuzzleId('p3-block-the-file'), 'p3-block-the-file');
    });
  });

  group('PuzzleLibrary.session (legacy backward compat)', () {
    test('seed 0 is the canonical authored session', () {
      expect(
        PuzzleLibrary.session(0).map((p) => p.id).toList(),
        PuzzleLibrary.all.map((p) => p.id).toList(),
      );
    });

    test(
      'seed >= 1 is composed: length 5, valid, readable, no back-to-back',
      () {
        for (var seed = 1; seed <= 6; seed++) {
          final s = PuzzleLibrary.session(seed);
          expect(s.length, 5);
          for (final p in s) {
            expect(validatePuzzle(p).isValid, isTrue, reason: p.id);
            expect(readabilityScore(p).passed, isTrue, reason: p.id);
          }
          for (var i = 1; i < s.length; i++) {
            expect(
              canonicalPuzzleId(s[i].id) == canonicalPuzzleId(s[i - 1].id),
              isFalse,
              reason: 'seed $seed back-to-back family',
            );
          }
        }
      },
    );

    test('deterministic for a given seed', () {
      expect(
        PuzzleLibrary.session(4).map((p) => p.id).toList(),
        PuzzleLibrary.session(4).map((p) => p.id).toList(),
      );
    });
  });

  group('GameController episode restore', () {
    test('default episode is ep1 when no override + no persisted id', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      expect(game.episode.id, EpisodeLibrary.ep1.id);
      expect(game.puzzleCount, 3); // ep1 has 3 puzzles
      expect(game.completedCount, 0);
      expect(game.state, GameState.danger);
    });

    test(
      'restores in-episode progress from completedIds for canonical episodes',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': ['p1-knight-rescue'],
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        expect(game.episode.id, EpisodeLibrary.ep1.id);
        expect(game.completedCount, 1);
        // Resumed at puzzle 2 (a4) — first puzzle whose canonical id is NOT
        // in completedIds.
        expect(game.puzzleNumber, 2);
        expect(game.state, GameState.danger);
      },
    );

    test(
      'master episode starts fresh — does NOT inherit completedIds progress',
      () async {
        SharedPreferences.setMockInitialValues({
          // Player has completed p1 (and the whole canonical trilogy implicitly).
          'flutter.cr_completed_ids': ['p1-knight-rescue'],
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store, episode: EpisodeLibrary.ep4);
        expect(game.completedCount, 0);
        expect(game.puzzleNumber, 1);
      },
    );
  });

  group('Canonical episode finale', () {
    test(
      'completing every puzzle reaches the finale state without auto-rotation',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store); // ep1 default

        await _solveSession(game);
        expect(game.allComplete, isTrue);
        expect(game.completedCount, 3);
        expect(game.state, GameState.rescued);
        expect(game.isEpisodeFinale, isTrue);

        // onPrimaryAction is a no-op on a canonical finale — RescueScreen
        // handles the navigator pop on its own footer tap.
        final beforeIndex = game.puzzleNumber;
        game.onPrimaryAction();
        expect(game.isEpisodeFinale, isTrue);
        expect(game.completedCount, 3);
        expect(game.puzzleNumber, beforeIndex);
      },
    );

    test(
      'canonical rescue persists to global completedIds via incremental add',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        await _solveCurrent(game); // rescue p1
        await Future<void>.delayed(const Duration(milliseconds: 50));
        // Re-create store to read back persisted state.
        final fresh = await ProgressStore.create();
        expect(fresh.completedIds, contains('p1-knight-rescue'));
      },
    );
  });

  group('Endless episode rotation + Best Run streak', () {
    test('endless episode rotates seed inline on session completion', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);
      expect(game.sessionSeed, 0);
      expect(game.puzzleCount, 5); // endless session length

      await _solveSession(game);
      expect(game.allComplete, isTrue);
      expect(game.state, GameState.rescued);

      game.onPrimaryAction(); // rotate
      expect(game.sessionSeed, 1);
      expect(game.completedCount, 0);
      expect(game.state, GameState.danger);
    });

    test('endless rescue increments the in-memory streak counter', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);
      expect(game.currentEndlessStreak, 0);
      await _solveCurrent(game);
      expect(game.currentEndlessStreak, 1);
    });
  });

  group('ProgressStore round-trip', () {
    test('save then reload reads back seed/index/completed', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.save(
        sessionSeed: 3,
        puzzleIndex: 2,
        completedIds: {'p2-take-the-checker'},
      );
      final s2 = await ProgressStore.create();
      expect(s2.sessionSeed, 3);
      expect(s2.puzzleIndex, 2);
      expect(s2.completedIds, {'p2-take-the-checker'});
    });

    test(
      'addCompletedId accumulates without overwriting prior entries',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        await s.addCompletedId('p1-knight-rescue');
        await s.addCompletedId('a4-the-breakaway');
        final fresh = await ProgressStore.create();
        expect(fresh.completedIds, {'p1-knight-rescue', 'a4-the-breakaway'});
      },
    );
  });

  group('R1A — controller-side record unlocks', () {
    test(
      'the first rescue persists First Rescue + Strike Back/etc thresholds',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store); // ep1 default
        await _solveCurrent(game); // rescue p1
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(fresh.unlockedRecords, contains('first-rescue'));
      },
    );

    test(
      'completing Ep1 with zero failures writes Unshaken + Strike Back',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store); // ep1, 3 puzzles
        for (var i = 0; i < game.puzzleCount; i++) {
          await _solveCurrent(game);
          if (i < game.puzzleCount - 1) game.onPrimaryAction();
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(fresh.unlockedRecords, contains('first-rescue'));
        expect(fresh.unlockedRecords, contains('ep1-strike-back'));
        expect(
          fresh.unlockedRecords,
          contains('unshaken'),
          reason: 'no failed moves; Unshaken should fire on the finale',
        );
      },
    );

    test(
      'Ep4 (master) finale writes The Other Side via eventOnly hook',
      () async {
        SharedPreferences.setMockInitialValues({
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
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store, episode: EpisodeLibrary.ep4);
        // Solve all 3 ep4 mirrors without failing.
        for (var i = 0; i < game.puzzleCount; i++) {
          await _solveCurrent(game);
          if (i < game.puzzleCount - 1) game.onPrimaryAction();
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(fresh.unlockedRecords, contains('ep4-the-other-side'));
      },
    );

    test(
      'Against the Odds fires on the first rescue AFTER Ep4 is unlocked',
      () async {
        SharedPreferences.setMockInitialValues({
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
          'flutter.cr_unlocked_records':
              '["first-rescue","ep1-strike-back","ep2-end-the-threat","ep3-hold-the-line","ep4-the-other-side"]',
        });
        final store = await ProgressStore.create();
        expect(store.unlockedRecordsSet, contains('ep4-the-other-side'));
        expect(store.unlockedRecordsSet, isNot(contains('against-the-odds')));

        // Enter an endless episode (or any episode) and complete one rescue.
        final game = GameController(store: store, episode: EpisodeLibrary.ep5);
        await _solveCurrent(game);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(fresh.unlockedRecords, contains('against-the-odds'));
      },
    );

    test('failing a move blocks Unshaken on that episode finale', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store); // ep1
      // Fail the first puzzle once.
      final p = game.currentPuzzle;
      final wrong = p.legalMoves.firstWhere((s) => s != p.rescueTo);
      game.handleSquare(p.tappableSquare.file, p.tappableSquare.rank);
      game.handleSquare(wrong.file, wrong.rank);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      // Reset and play through the whole episode cleanly.
      await game.reset();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      for (var i = 0; i < game.puzzleCount; i++) {
        await _solveCurrent(game);
        if (i < game.puzzleCount - 1) game.onPrimaryAction();
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final fresh = await ProgressStore.create();
      expect(fresh.unlockedRecords, contains('ep1-strike-back'));
      expect(
        fresh.unlockedRecords,
        isNot(contains('unshaken')),
        reason: 'the failed move should disqualify Unshaken',
      );
    });

    test(
      'mid-Ep5 streak crossing 3 unlocks Endless Spark in real time',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store, episode: EpisodeLibrary.ep5);
        // Solve three puzzles back-to-back (streak hits 3).
        for (var i = 0; i < 3; i++) {
          await _solveCurrent(game);
          if (i < 2) game.onPrimaryAction();
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(
          fresh.unlockedRecords,
          contains('endless-spark'),
          reason: 'streak peak should trigger Endless Spark immediately',
        );
      },
    );
  });
}
