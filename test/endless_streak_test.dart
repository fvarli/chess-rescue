import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/episode_library.dart';
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
  // Pick a legal move that is NOT the rescue.
  final wrong = g.currentPuzzle.legalMoves.firstWhere(
    (s) => s != g.currentPuzzle.rescueTo,
  );
  g.handleSquare(t.file, t.rank);
  g.handleSquare(wrong.file, wrong.rank);
  await Future<void>.delayed(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Endless episode streak', () {
    test('rescues increment the in-memory streak counter', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store, episode: EpisodeLibrary.ep5);
      expect(game.currentEndlessStreak, 0);
      await _solveCurrent(game);
      expect(game.currentEndlessStreak, 1);
      game.onPrimaryAction(); // advance to next
      await _solveCurrent(game);
      expect(game.currentEndlessStreak, 2);
    });

    test(
      'a failed move ends the streak; bestEndlessStreak persists at the max',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store, episode: EpisodeLibrary.ep5);
        await _solveCurrent(game);
        game.onPrimaryAction();
        await _solveCurrent(game);
        game.onPrimaryAction();
        await _solveCurrent(game); // streak = 3
        expect(game.currentEndlessStreak, 3);

        game.onPrimaryAction(); // advance to next puzzle
        await _failCurrent(game); // failure ends streak
        expect(game.currentEndlessStreak, 0);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final fresh = await ProgressStore.create();
        expect(fresh.bestEndlessStreak, 3);
      },
    );

    test('updateBestEndlessStreak takes the max — never decreases', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_best_endless_streak': 7,
      });
      final s = await ProgressStore.create();
      expect(s.bestEndlessStreak, 7);
      await s.updateBestEndlessStreak(5); // lower — should be ignored
      expect(s.bestEndlessStreak, 7);
      await s.updateBestEndlessStreak(10); // higher — should win
      expect(s.bestEndlessStreak, 10);
    });

    test(
      'dispose persists the in-progress streak as a candidate max',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        final game = GameController(store: store, episode: EpisodeLibrary.ep5);
        await _solveCurrent(game);
        game.onPrimaryAction();
        await _solveCurrent(game); // streak = 2

        // Simulate leaving the episode (controller disposed).
        game.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final fresh = await ProgressStore.create();
        expect(fresh.bestEndlessStreak, 2);
      },
    );

    test('canonical episodes do not touch bestEndlessStreak', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final game = GameController(store: store); // ep1 default
      await _solveCurrent(game);
      expect(game.currentEndlessStreak, 0);
      game.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final fresh = await ProgressStore.create();
      expect(fresh.bestEndlessStreak, 0);
    });
  });
}
