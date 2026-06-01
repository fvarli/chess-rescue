import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/signatures/signature_lookup.dart';

void main() {
  group('resolvePuzzleFor', () {
    test('canonical id returns the canonical puzzle (no mirror suffix)', () {
      final puzzle = resolvePuzzleFor('p1-knight-rescue');
      expect(puzzle, isNotNull);
      expect(puzzle!.id, 'p1-knight-rescue');
    });

    test('mirror id returns the mirrored puzzle (file-flipped)', () {
      final canonical = resolvePuzzleFor('p1-knight-rescue');
      final mirrored = resolvePuzzleFor('p1-knight-rescue#mirror');
      expect(mirrored, isNotNull);
      expect(mirrored!.id, 'p1-knight-rescue#mirror');
      // The mirror is a horizontal flip: any piece's file should be at
      // (7 - original.file). Pick the king from each and verify.
      final canonicalKing = canonical!.pieces.firstWhere((p) => p.id == 'wK');
      final mirroredKing = mirrored.pieces.firstWhere((p) => p.id == 'wK');
      expect(mirroredKing.file, 7 - canonicalKing.file);
      expect(mirroredKing.rank, canonicalKing.rank);
    });

    test('all 9 canonical puzzle ids resolve', () {
      const ids = <String>[
        'p1-knight-rescue',
        'p2-take-the-checker',
        'p3-block-the-file',
        'p4-seal-the-diagonal',
        'p5-win-the-queen',
        'a4-the-breakaway',
        'b1-the-martyr',
        'b3-remove-the-defender',
        'b4-the-cross-check',
      ];
      for (final id in ids) {
        expect(resolvePuzzleFor(id), isNotNull, reason: id);
        expect(resolvePuzzleFor('$id#mirror'), isNotNull, reason: '$id#mirror');
      }
    });

    test('unknown id returns null (defensive)', () {
      expect(resolvePuzzleFor('not-a-real-puzzle'), isNull);
      expect(resolvePuzzleFor('not-a-real#mirror'), isNull);
    });
  });

  group('localizedPuzzleTitle', () {
    test('returns the authored title for each canonical id', () {
      expect(localizedPuzzleTitle('p1-knight-rescue'), 'Knight rescue');
      expect(localizedPuzzleTitle('p2-take-the-checker'), 'Take the checker');
      expect(localizedPuzzleTitle('p3-block-the-file'), 'Block the file');
      expect(localizedPuzzleTitle('p4-seal-the-diagonal'), 'Seal the diagonal');
      expect(localizedPuzzleTitle('p5-win-the-queen'), 'Win the queen');
      expect(localizedPuzzleTitle('a4-the-breakaway'), 'The breakaway');
      expect(localizedPuzzleTitle('b1-the-martyr'), 'The martyr');
      expect(
        localizedPuzzleTitle('b3-remove-the-defender'),
        'Remove the defender',
      );
      expect(localizedPuzzleTitle('b4-the-cross-check'), 'The cross-check');
    });

    test('unknown id falls back to the id itself (no crash)', () {
      expect(localizedPuzzleTitle('not-a-real-puzzle'), 'not-a-real-puzzle');
    });
  });
}
