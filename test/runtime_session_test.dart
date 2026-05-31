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
}
