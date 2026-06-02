import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/core/models/variation.dart';

void main() {
  group('transformSquare (mirror)', () {
    test('flips file, preserves rank', () {
      expect(
        transformSquare(const Square(0, 3), Variation.mirror),
        const Square(7, 3),
      );
      expect(
        transformSquare(const Square(4, 3), Variation.mirror),
        const Square(3, 3),
      );
      expect(
        transformSquare(const Square(6, 0), Variation.mirror),
        const Square(1, 0),
      );
    });

    test('identity is a no-op', () {
      expect(
        transformSquare(const Square(4, 3), Variation.identity),
        const Square(4, 3),
      );
    });
  });

  group('applyVariation', () {
    test('identity returns the same instance (all stays byte-identical)', () {
      final base = PuzzleLibrary.templates.first.puzzle;
      expect(identical(PuzzleLibrary.templates.first.toPuzzle(), base), isTrue);
    });

    test('mirror id encodes the variation', () {
      final v = PuzzleLibrary.templates.first.toPuzzle(Variation.mirror);
      expect(v.id, 'p1-knight-rescue#mirror');
    });

    test('mirror preserves piece ids and count', () {
      final base = PuzzleLibrary.templates.first.puzzle;
      final v = PuzzleLibrary.templates.first.toPuzzle(Variation.mirror);
      expect(v.pieces.length, base.pieces.length);
      expect(
        v.pieces.map((p) => p.id).toSet(),
        base.pieces.map((p) => p.id).toSet(),
      );
    });

    test('mirror flips the rescuing knight (e4 -> d4, f6 -> c6)', () {
      final v = PuzzleLibrary.templates.first.toPuzzle(Variation.mirror);
      expect(v.tappableSquare, const Square(3, 3)); // e4 -> d4
      expect(v.rescueTo, const Square(2, 5)); // f6 -> c6
      expect(v.rescueTo, isIn(v.legalMoves));
    });

    test('every base template is itself valid', () {
      for (final t in PuzzleLibrary.templates) {
        final r = validatePuzzle(t.puzzle);
        expect(r.isValid, isTrue, reason: '${t.puzzle.id}: ${r.errors}');
      }
    });

    test('all 5 mirror variants are valid', () {
      for (final t in PuzzleLibrary.templates) {
        final v = t.toPuzzle(Variation.mirror);
        final r = validatePuzzle(v);
        expect(r.isValid, isTrue, reason: '${v.id}: ${r.errors}');
      }
    });

    test('mirror is an involution (mirror twice == identity geometry)', () {
      final base = PuzzleLibrary.templates.first.puzzle;
      final twice = applyVariation(
        applyVariation(base, Variation.mirror),
        Variation.mirror,
      );
      expect(twice.tappableSquare, base.tappableSquare);
      expect(twice.rescueTo, base.rescueTo);
      expect(twice.threatenedKing, base.threatenedKing);
    });

    test('Sprint V1 — CC2 mirror flips the bishop (c4 → f4, f7 → c7)', () {
      final t = PuzzleLibrary.expansionTemplates.firstWhere(
        (t) => t.puzzle.id == 'cc2-bishop-captures-shield',
      );
      final v = t.toPuzzle(Variation.mirror);
      expect(v.id, 'cc2-bishop-captures-shield#mirror');
      expect(v.tappableSquare, const Square(5, 3)); // c4 → f4
      expect(v.rescueTo, const Square(2, 6)); // f7 → c7
      expect(v.threatenedKing, const Square(1, 0)); // g1 → b1
      expect(v.rescueTo, isIn(v.legalMoves));
      expect(v.pieces.length, t.puzzle.pieces.length);
      expect(
        v.pieces.map((p) => p.id).toSet(),
        t.puzzle.pieces.map((p) => p.id).toSet(),
      );
      // Every mirrored piece is on-board.
      for (final p in v.pieces) {
        expect(p.file, inInclusiveRange(0, 7), reason: p.id);
        expect(p.rank, inInclusiveRange(0, 7), reason: p.id);
      }
    });

    test('Sprint V1 — CAM1 mirror flips the knight (g4 → b4, h2 → a2)', () {
      final t = PuzzleLibrary.expansionTemplates.firstWhere(
        (t) => t.puzzle.id == 'cam1-knight-takes-bishop',
      );
      final v = t.toPuzzle(Variation.mirror);
      expect(v.id, 'cam1-knight-takes-bishop#mirror');
      expect(v.tappableSquare, const Square(1, 3)); // g4 → b4
      expect(v.rescueTo, const Square(0, 1)); // h2 → a2
      expect(v.threatenedKing, const Square(1, 0)); // g1 → b1
      expect(v.rescueTo, isIn(v.legalMoves));
      expect(v.pieces.length, t.puzzle.pieces.length);
      expect(
        v.pieces.map((p) => p.id).toSet(),
        t.puzzle.pieces.map((p) => p.id).toSet(),
      );
      for (final p in v.pieces) {
        expect(p.file, inInclusiveRange(0, 7), reason: p.id);
        expect(p.rank, inInclusiveRange(0, 7), reason: p.id);
      }
    });

    test('Sprint V1 — CC2 and CAM1 are valid + readable base AND mirror', () {
      for (final id in const [
        'cc2-bishop-captures-shield',
        'cam1-knight-takes-bishop',
      ]) {
        final t = PuzzleLibrary.expansionTemplates.firstWhere(
          (t) => t.puzzle.id == id,
        );
        final base = validatePuzzle(t.puzzle);
        expect(base.isValid, isTrue, reason: '$id base: ${base.errors}');
        final mirror = t.toPuzzle(Variation.mirror);
        final mirrorR = validatePuzzle(mirror);
        expect(
          mirrorR.isValid,
          isTrue,
          reason: '$id mirror: ${mirrorR.errors}',
        );
      }
    });
  });

  group('validatePuzzle', () {
    test('flags rescueTo not in legalMoves', () {
      const broken = Puzzle(
        id: 'broken',
        title: 'Broken',
        statusText: '',
        pieces: [
          Piece(
            id: 'wK',
            type: PieceType.king,
            color: PieceColor.light,
            file: 6,
            rank: 0,
          ),
          Piece(
            id: 'wN',
            type: PieceType.knight,
            color: PieceColor.light,
            file: 4,
            rank: 3,
          ),
        ],
        tappableSquare: Square(4, 3),
        legalMoves: [Square(5, 5)],
        rescueTo: Square(3, 5), // NOT in legalMoves
        rescueNotation: '',
        dangerHint: '',
        failureHint: '',
        successExplanation: '',
        threatenedKing: Square(6, 0),
      );
      final r = validatePuzzle(broken);
      expect(r.isValid, isFalse);
      expect(r.errors, contains('rescueTo is not in legalMoves'));
    });

    test('flags out-of-bounds and duplicate squares', () {
      const broken = Puzzle(
        id: 'broken2',
        title: 'Broken2',
        statusText: '',
        pieces: [
          Piece(
            id: 'wK',
            type: PieceType.king,
            color: PieceColor.light,
            file: 6,
            rank: 0,
          ),
          Piece(
            id: 'dup',
            type: PieceType.pawn,
            color: PieceColor.light,
            file: 6,
            rank: 0,
          ),
          Piece(
            id: 'oob',
            type: PieceType.pawn,
            color: PieceColor.light,
            file: 9,
            rank: 0,
          ),
        ],
        tappableSquare: Square(6, 0),
        legalMoves: [Square(5, 0)],
        rescueTo: Square(5, 0),
        rescueNotation: '',
        dangerHint: '',
        failureHint: '',
        successExplanation: '',
        threatenedKing: Square(6, 0),
      );
      final r = validatePuzzle(broken);
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('out of bounds')), isTrue);
      expect(r.errors.any((e) => e.contains('duplicate')), isTrue);
    });
  });
}
