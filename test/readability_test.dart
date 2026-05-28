import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/core/models/variation.dart';

void main() {
  group('readabilityScore — base templates', () {
    test('all 5 base templates are readable', () {
      for (final t in PuzzleLibrary.templates) {
        final s = readabilityScore(t.puzzle);
        expect(s.passed, isTrue, reason: '${t.puzzle.id}: ${s.notes}');
      }
    });
  });

  group('readabilityScore — mirror variants', () {
    test('all 5 mirror variants are readable', () {
      for (final t in PuzzleLibrary.templates) {
        final v = t.toPuzzle(Variation.mirror);
        final s = readabilityScore(v);
        expect(s.passed, isTrue, reason: '${v.id}: ${s.notes}');
      }
    });
  });

  group('readabilityScore — bad puzzle fails', () {
    test('jammed 2x2 with an unrelated rescue fails', () {
      // Everything crammed into a 2x2 corner; rescue lands on an empty,
      // unrelated square; no dark attacker near/aligned with the king.
      const bad = Puzzle(
        id: 'bad',
        title: 'Bad',
        statusText: '',
        pieces: [
          Piece(
            id: 'wK',
            type: PieceType.king,
            color: PieceColor.light,
            file: 0,
            rank: 0,
          ),
          Piece(
            id: 'wN',
            type: PieceType.knight,
            color: PieceColor.light,
            file: 1,
            rank: 0,
          ),
          Piece(
            id: 'wP',
            type: PieceType.pawn,
            color: PieceColor.light,
            file: 0,
            rank: 1,
          ),
        ],
        tappableSquare: Square(1, 0),
        legalMoves: [Square(2, 2), Square(3, 1)],
        rescueTo: Square(2, 2), // empty, unrelated to any danger
        rescueNotation: '',
        dangerHint: '',
        failureHint: '',
        successExplanation: '',
        threatenedKing: Square(0, 0),
      );
      final s = readabilityScore(bad);
      expect(s.passed, isFalse);
      expect(s.visualBalance, isFalse); // jammed into a 2x2
      expect(s.rescueClarity, isFalse); // rescue does nothing visible
      expect(s.threatVisibility, isFalse); // no dark attacker
      expect(s.notes, isNotEmpty);
    });
  });
}
