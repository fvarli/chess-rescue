import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/episode.dart';
import 'package:chess_rescue/core/models/episode_library.dart';

void main() {
  group('EpisodeLibrary taxonomy', () {
    test('exposes exactly 6 episodes in canonical order', () {
      expect(EpisodeLibrary.all, hasLength(6));
      expect(EpisodeLibrary.all.map((e) => e.number).toList(), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
    });

    test('kind allocation matches the plan', () {
      expect(EpisodeLibrary.ep1.kind, EpisodeKind.canonical);
      expect(EpisodeLibrary.ep2.kind, EpisodeKind.canonical);
      expect(EpisodeLibrary.ep3.kind, EpisodeKind.canonical);
      expect(EpisodeLibrary.ep4.kind, EpisodeKind.master);
      expect(EpisodeLibrary.ep5.kind, EpisodeKind.endless);
      expect(EpisodeLibrary.ep6.kind, EpisodeKind.canonical);
    });

    test('episode ids are unique', () {
      final ids = EpisodeLibrary.all.map((e) => e.id).toSet();
      expect(ids.length, 6);
    });

    test(
      'canonical episodes cover all 14 canonical+expansion+ep6 puzzles, disjoint',
      () {
        final canonicalEps = [
          EpisodeLibrary.ep1,
          EpisodeLibrary.ep2,
          EpisodeLibrary.ep3,
          EpisodeLibrary.ep6,
        ];
        final union = <String>{};
        for (final ep in canonicalEps) {
          for (final id in ep.canonicalPuzzleIds) {
            expect(union.add(id), isTrue, reason: 'disjoint check: $id');
          }
        }
        expect(union, {
          'p1-knight-rescue',
          'p2-take-the-checker',
          'p3-block-the-file',
          'p4-seal-the-diagonal',
          'p5-win-the-queen',
          'a4-the-breakaway',
          'b1-the-martyr',
          'b3-remove-the-defender',
          'b4-the-cross-check',
          'e6p1-first-pin',
          'e6p2-diagonal-pin',
          'e6p3-pin-via-rank',
          'e6p4-cross-pin',
          'e6p5-pin-and-threat',
        });
      },
    );

    test('ep4 master pool is exactly {p1, p5, b1} — 3 puzzles', () {
      expect(EpisodeLibrary.ep4.canonicalPuzzleIds, [
        'p1-knight-rescue',
        'p5-win-the-queen',
        'b1-the-martyr',
      ]);
      expect(EpisodeLibrary.ep4.puzzleCount, 3);
    });

    test('ep5 endless has no canonical pool but reports puzzleCount of 5', () {
      expect(EpisodeLibrary.ep5.canonicalPuzzleIds, isEmpty);
      expect(EpisodeLibrary.ep5.puzzleCount, 5);
    });

    test('unlock chain: ep4, ep5, ep6 all gate on ep3 completion', () {
      expect(EpisodeLibrary.ep1.unlockRequirementId, isNull);
      expect(EpisodeLibrary.ep2.unlockRequirementId, EpisodeLibrary.ep1.id);
      expect(EpisodeLibrary.ep3.unlockRequirementId, EpisodeLibrary.ep2.id);
      expect(EpisodeLibrary.ep4.unlockRequirementId, EpisodeLibrary.ep3.id);
      expect(EpisodeLibrary.ep5.unlockRequirementId, EpisodeLibrary.ep3.id);
      expect(EpisodeLibrary.ep6.unlockRequirementId, EpisodeLibrary.ep3.id);
    });

    test('ep6 is canonical with 5 pin-defense puzzles', () {
      expect(EpisodeLibrary.ep6.kind, EpisodeKind.canonical);
      expect(EpisodeLibrary.ep6.canonicalPuzzleIds, hasLength(5));
      expect(EpisodeLibrary.ep6.puzzleCount, 5);
    });
  });

  group('EpisodeLibrary helpers', () {
    test('byId returns the matching episode or null', () {
      expect(EpisodeLibrary.byId(EpisodeLibrary.ep2.id), EpisodeLibrary.ep2);
      expect(EpisodeLibrary.byId('nonexistent'), isNull);
    });

    test('nextAfter walks the list and returns null past ep6', () {
      expect(EpisodeLibrary.nextAfter(EpisodeLibrary.ep1), EpisodeLibrary.ep2);
      expect(EpisodeLibrary.nextAfter(EpisodeLibrary.ep5), EpisodeLibrary.ep6);
      expect(EpisodeLibrary.nextAfter(EpisodeLibrary.ep6), isNull);
    });

    test('first returns ep1', () {
      expect(EpisodeLibrary.first, EpisodeLibrary.ep1);
    });
  });
}
