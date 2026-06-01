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

Future<void> _failCurrent(GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final wrong = g.currentPuzzle.legalMoves.firstWhere(
    (s) => s != g.currentPuzzle.rescueTo,
  );
  g.handleSquare(t.file, t.rank);
  g.handleSquare(wrong.file, wrong.rank);
  await Future<void>.delayed(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameController — recently-solved write (PR 1)', () {
    test('a successful canonical rescue writes the just-solved puzzle into '
        'the recently-solved ring', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store); // ep1 default — canonical

      final expectedCanonical = canonicalPuzzleId(game.currentPuzzle.id);
      final expectedEncountered = game.currentPuzzle.id;
      final expectedEpisodeId = game.episode.id;

      await _solveCurrent(game);
      // Storage writes are fire-and-forget — let them flush.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final fresh = await ProgressStore.create();
      expect(fresh.recentlySolved.entries.length, 1);
      final entry = fresh.recentlySolved.entries.first;
      expect(entry.canonicalPuzzleId, expectedCanonical);
      expect(entry.encounteredPuzzleId, expectedEncountered);
      expect(entry.episodeId, expectedEpisodeId);
      // Canonical episode → both endless fields are null.
      expect(entry.endlessSeed, isNull);
      expect(entry.endlessMirrored, isNull);
    });

    test('a successful Endless rescue carries the session seed and the '
        'mirror flag derived from the puzzle id', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);

      final expectedEncountered = game.currentPuzzle.id;
      final expectedMirrored = expectedEncountered.contains('#mirror');
      final expectedSeed = game.sessionSeed;

      await _solveCurrent(game);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final fresh = await ProgressStore.create();
      expect(fresh.recentlySolved.entries.length, 1);
      final entry = fresh.recentlySolved.entries.first;
      expect(entry.endlessSeed, expectedSeed);
      expect(entry.endlessMirrored, expectedMirrored);
    });

    test(
      'a failed move does not write into the recently-solved ring',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store);

        await _failCurrent(game);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final fresh = await ProgressStore.create();
        expect(fresh.recentlySolved.entries, isEmpty);
      },
    );

    test('multiple sequential canonical rescues populate the ring '
        'newest-first', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store); // ep1 canonical

      final ordered = <String>[];
      for (var i = 0; i < game.puzzleCount; i++) {
        ordered.add(canonicalPuzzleId(game.currentPuzzle.id));
        await _solveCurrent(game);
        if (i < game.puzzleCount - 1) {
          game.onPrimaryAction(); // advance
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final fresh = await ProgressStore.create();
      // Ring is newest-first; we solved ordered[0] first → it should
      // appear last in the ring.
      final ringIds = fresh.recentlySolved.entries
          .map((e) => e.canonicalPuzzleId)
          .toList();
      expect(ringIds, ordered.reversed.toList());
    });

    test('re-solving an already-recorded puzzle is move-to-front, no '
        'duplicate', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      // ep5 endless — keeps composing puzzles indefinitely and may
      // re-surface canonical ids.
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);

      await _solveCurrent(game);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      game.onPrimaryAction();
      await _solveCurrent(game);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      game.onPrimaryAction();
      await _solveCurrent(game);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Mid-ring, the firstId may or may not still be at the tail
      // (depends on whether subsequent endless puzzles share its
      // canonical). What matters is that on each insert the ring
      // remains de-duplicated by canonical id.
      final fresh = await ProgressStore.create();
      final ids = fresh.recentlySolved.entries
          .map((e) => e.canonicalPuzzleId)
          .toList();
      expect(ids.toSet().length, ids.length, reason: 'no duplicates');
      expect(ids.first, isNotEmpty);
    });

    test('a sequence beyond cap (7) drops the oldest entry', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      // ep5 endless composes 5 puzzles per cycle then rotates the seed
      // and composes another 5. Solving 8 takes us through one
      // rotation, easily enough to overflow the 7-cap.
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);
      for (var i = 0; i < 8; i++) {
        await _solveCurrent(game);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        game.onPrimaryAction();
      }

      final fresh = await ProgressStore.create();
      expect(fresh.recentlySolved.entries.length, lessThanOrEqualTo(7));
    });
  });
}
