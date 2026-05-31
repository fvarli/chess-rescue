import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/episode_library.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/session_composer.dart';
import 'package:chess_rescue/core/models/variation.dart';

void main() {
  group('SessionComposer.composeEpisode — canonical', () {
    test('seed 0 returns the authored episode pool in canonical order', () {
      final puzzles = SessionComposer.composeEpisode(
        episode: EpisodeLibrary.ep1,
        templates: PuzzleLibrary.templates,
        expansion: PuzzleLibrary.expansionTemplates,
        seed: 0,
      );
      expect(puzzles.map((p) => p.id).toList(), [
        'p1-knight-rescue',
        'a4-the-breakaway',
        'b4-the-cross-check',
      ]);
    });

    test(
      'seed >= 1 may mirror but never includes puzzles outside the episode',
      () {
        const validBases = {
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
        };
        for (var seed = 1; seed <= 6; seed++) {
          final puzzles = SessionComposer.composeEpisode(
            episode: EpisodeLibrary.ep1,
            templates: PuzzleLibrary.templates,
            expansion: PuzzleLibrary.expansionTemplates,
            seed: seed,
          );
          expect(puzzles, hasLength(3));
          for (final p in puzzles) {
            expect(
              validBases,
              contains(canonicalPuzzleId(p.id)),
              reason: 'seed $seed produced out-of-episode puzzle ${p.id}',
            );
          }
        }
      },
    );

    test('canonical session length matches episode.puzzleCount', () {
      for (final ep in [
        EpisodeLibrary.ep1,
        EpisodeLibrary.ep2,
        EpisodeLibrary.ep3,
      ]) {
        final puzzles = SessionComposer.composeEpisode(
          episode: ep,
          templates: PuzzleLibrary.templates,
          expansion: PuzzleLibrary.expansionTemplates,
          seed: 0,
        );
        expect(
          puzzles,
          hasLength(ep.puzzleCount),
          reason: '${ep.id} should produce ${ep.puzzleCount} puzzles',
        );
      }
    });
  });

  group('SessionComposer.composeEpisode — master (ep4)', () {
    test('returns exactly 3 mirror puzzles with bases {p1, p5, b1}', () {
      for (var seed = 0; seed <= 4; seed++) {
        final puzzles = SessionComposer.composeEpisode(
          episode: EpisodeLibrary.ep4,
          templates: PuzzleLibrary.templates,
          expansion: PuzzleLibrary.expansionTemplates,
          seed: seed,
        );
        expect(puzzles, hasLength(3));
        for (final p in puzzles) {
          expect(
            p.id,
            endsWith('#mirror'),
            reason: 'seed $seed master puzzle ${p.id} should be a mirror',
          );
        }
        expect(puzzles.map((p) => canonicalPuzzleId(p.id)).toSet(), {
          'p1-knight-rescue',
          'p5-win-the-queen',
          'b1-the-martyr',
        });
      }
    });
  });

  group('SessionComposer.composeEpisode — endless (ep5)', () {
    test('returns 5 puzzles drawn from the full pool', () {
      final puzzles = SessionComposer.composeEpisode(
        episode: EpisodeLibrary.ep5,
        templates: PuzzleLibrary.templates,
        expansion: PuzzleLibrary.expansionTemplates,
        seed: 1,
      );
      expect(puzzles, hasLength(5));
    });

    test('consecutive seeds produce different compositions', () {
      final s1 = SessionComposer.composeEpisode(
        episode: EpisodeLibrary.ep5,
        templates: PuzzleLibrary.templates,
        expansion: PuzzleLibrary.expansionTemplates,
        seed: 1,
      );
      final s2 = SessionComposer.composeEpisode(
        episode: EpisodeLibrary.ep5,
        templates: PuzzleLibrary.templates,
        expansion: PuzzleLibrary.expansionTemplates,
        seed: 2,
      );
      expect(
        s1.map((p) => p.id).toList(),
        isNot(equals(s2.map((p) => p.id).toList())),
      );
    });
  });
}
