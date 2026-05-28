import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  g.handleSquare(t.file, t.rank); // select the rescuer
  g.handleSquare(r.file, r.rank); // commit the rescue
  await Future<void>.delayed(const Duration(milliseconds: 400));
}

/// Solve a full session, leaving the controller on the final rescued screen.
Future<void> _solveSession(GameController g) async {
  final count = g.puzzleCount;
  for (var i = 0; i < count; i++) {
    await _solveCurrent(g);
    if (i < count - 1) g.onPrimaryAction(); // advance within session
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

  group('PuzzleLibrary.session', () {
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

  group('GameController restore', () {
    test(
      'restores seed, index, and canonical completed from storage',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_session_seed': 2,
          'flutter.cr_puzzle_index': 1,
          'flutter.cr_completed_ids': ['p1-knight-rescue'],
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        expect(game.sessionSeed, 2);
        expect(game.puzzleNumber, 2); // index 1 → "puzzle 2"
        expect(game.completedCount, 1);
        expect(game.state, GameState.danger);
      },
    );
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
  });

  group('session regeneration', () {
    test(
      'completing session 0 rotates to seed 1 with fresh progress',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        expect(game.sessionSeed, 0);

        await _solveSession(game);
        expect(game.allComplete, isTrue);
        expect(game.completedCount, 5);
        expect(game.state, GameState.rescued);

        game.onPrimaryAction(); // "Again" → next curated session
        expect(game.sessionSeed, 1);
        expect(game.completedCount, 0);
        expect(game.state, GameState.danger);
      },
    );

    test('solving a composed session counts canonical families only', () async {
      SharedPreferences.setMockInitialValues({'flutter.cr_session_seed': 1});
      final store = await ProgressStore.create();
      final game = GameController(store: store); // session 1 (has mirrors)
      await _solveSession(game);
      expect(game.completedCount, 5); // 5 distinct families, not 5+mirrors
    });
  });
}
