import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/episode_library.dart';
import 'package:chess_rescue/core/models/variation.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';

Future<void> _solveCurrent(GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final r = g.currentPuzzle.rescueTo;
  g.handleSquare(t.file, t.rank);
  g.handleSquare(r.file, r.rank);
  await Future<void>.delayed(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameController — wasPreviouslySolvedAtStart (PR 3)', () {
    test('fresh install, first puzzle: snapshot is false', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store); // ep1 default
      expect(game.wasPreviouslySolvedAtStart, isFalse);
    });

    test('after solving p1, advancing to the next puzzle: the next puzzle is '
        'still unseen → snapshot is false', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      expect(game.wasPreviouslySolvedAtStart, isFalse);
      await _solveCurrent(game);
      // The just-solved puzzle is still current; snapshot from
      // _loadPuzzle was captured BEFORE the solve.
      expect(game.wasPreviouslySolvedAtStart, isFalse);
      game.onPrimaryAction(); // advance to next
      // The new puzzle is a different canonical id (a4-the-breakaway
      // for ep1's second slot) — never solved.
      expect(game.wasPreviouslySolvedAtStart, isFalse);
    });

    test(
      'cross-session: solving all of ep1 in one controller → fresh '
      'controller for ep1 restores to the last puzzle, snapshot is true',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final first = GameController(store: store);
        // Solve every puzzle in ep1 so all 3 canonical ids land in
        // store.completedIds.
        for (var i = 0; i < first.puzzleCount; i++) {
          await _solveCurrent(first);
          if (i < first.puzzleCount - 1) first.onPrimaryAction();
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        first.dispose();

        final freshStore = await ProgressStore.create();
        expect(freshStore.completedIds.contains('p1-knight-rescue'), isTrue);
        final second = GameController(store: freshStore);
        // The new controller pre-populates _completed from store; the
        // restore logic lands on the last puzzle (all are complete),
        // whose canonical id is also in completedIds, so snapshot = true.
        expect(second.wasPreviouslySolvedAtStart, isTrue);
      },
    );

    test('snapshot is stable across the in-flight rescue commit boundary '
        '(does not flip during the current rescue)', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      // BEFORE solve: snapshot is whatever _loadPuzzle captured (false
      // on fresh install).
      final beforeValue = game.wasPreviouslySolvedAtStart;
      expect(beforeValue, isFalse);
      await _solveCurrent(game);
      // AFTER solve, BEFORE advancing: the same puzzle is still current
      // and the snapshot must NOT have changed even though
      // _completed.add(base) has just run.
      expect(game.wasPreviouslySolvedAtStart, equals(beforeValue));
    });

    test('the canonical-id helper strips #mirror — a previously-solved '
        'canonical reads as familiar regardless of the encountered variant '
        'suffix', () {
      // Direct check of the canonical-id helper that the controller
      // uses on every _loadPuzzle. Ensures the snapshot path treats
      // mirror variants as the same identity.
      expect(canonicalPuzzleId('p1-knight-rescue'), 'p1-knight-rescue');
      expect(canonicalPuzzleId('p1-knight-rescue#mirror'), 'p1-knight-rescue');
      // Confirm the helper feeds into the controller: pre-seed the
      // store with a canonical id and mount a canonical-mode
      // controller — its first puzzle (canonical p1) snapshots true.
      SharedPreferences.setMockInitialValues({
        'flutter.cr_completed_ids': <String>['p1-knight-rescue'],
      });
      // Note: this is a sync block; the outer test would still need to
      // await the store creation. Refactored into a separate explicit
      // test below.
    });

    test('pre-seeded store.completedIds (all ep1 puzzles): canonical-mode '
        "controller's restore logic lands on the last puzzle, which "
        'snapshots true', () async {
      // The constructor's restore step picks the FIRST incomplete
      // puzzle; with all three ep1 ids seeded, it falls through to
      // the last slot. Snapshot is taken at that _loadPuzzle.
      SharedPreferences.setMockInitialValues({
        'flutter.cr_completed_ids': <String>[
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
        ],
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store);
      expect(game.wasPreviouslySolvedAtStart, isTrue);
    });

    test('pre-seeded store.completedIds: Endless-mode controller snapshots '
        'true the moment a familiar canonical id composes — covers the '
        'cross-mode read path through store.completedIds', () async {
      // Seed every canonical id as already completed. SessionComposer's
      // first Endless composition for any seed will draw entirely from
      // the canonical/expansion pool, so the very first puzzle's
      // snapshot must be true.
      SharedPreferences.setMockInitialValues({
        'flutter.cr_completed_ids': <String>[
          'p1-knight-rescue',
          'p2-take-the-checker',
          'p3-block-the-file',
          'p4-seal-the-diagonal',
          'p5-win-the-queen',
          'a4-the-breakaway',
          'b1-the-martyr',
          'b3-remove-the-defender',
          'b4-the-cross-check',
        ],
      });
      final store = await ProgressStore.create();
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);
      // Endless mode does NOT pre-populate _completed from store, but
      // _loadPuzzle's snapshot logic also ORs `store.completedIds`,
      // so the persisted set still gates the cue correctly across
      // modes.
      expect(game.wasPreviouslySolvedAtStart, isTrue);
    });
  });
}
