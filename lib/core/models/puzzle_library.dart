import 'piece.dart';
import 'puzzle.dart';
import 'square.dart';

// Curated rescue sequence. Puzzle 1 is the real canonical rescue; puzzles
// 2–5 are handcrafted prototype placeholders (isPrototype: true) that reuse
// the same emotional loop. No engine — every puzzle whitelists its moves and
// has exactly one correct rescue (marked * in comments).
class PuzzleLibrary {
  PuzzleLibrary._();

  static const List<Puzzle> all = [_p1, _p2, _p3, _p4, _p5];

  // ── Puzzle 1 — Knight rescue (REAL). Nf6+ breaks Qg2#.
  // Transcribed from docs/components/primitives.jsx:180-210.
  static const Puzzle _p1 = Puzzle(
    id: 'p1-knight-rescue',
    title: 'Knight rescue',
    statusText: '▮ Active threat · Qg2#',
    pieces: [
      Piece(
        id: 'wK',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
        rank: 0,
      ),
      Piece(
        id: 'wP-f2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 5,
        rank: 1,
      ),
      Piece(
        id: 'wP-g2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ),
      Piece(
        id: 'wP-h2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'wN',
        type: PieceType.knight,
        color: PieceColor.light,
        file: 4,
        rank: 3,
      ),
      Piece(
        id: 'wB',
        type: PieceType.bishop,
        color: PieceColor.light,
        file: 2,
        rank: 0,
      ),
      Piece(
        id: 'wR',
        type: PieceType.rook,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      ),
      Piece(
        id: 'wP-a2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 0,
        rank: 1,
      ),
      Piece(
        id: 'wP-b2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 1,
        rank: 1,
      ),
      Piece(
        id: 'bK',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ),
      Piece(
        id: 'bP-f7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ),
      Piece(
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
      Piece(
        id: 'bQ',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 7,
        rank: 2,
      ),
      Piece(
        id: 'bR',
        type: PieceType.rook,
        color: PieceColor.dark,
        file: 4,
        rank: 6,
      ),
      Piece(
        id: 'bP-a7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 0,
        rank: 6,
      ),
      Piece(
        id: 'bP-b7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 1,
        rank: 6,
      ),
      Piece(
        id: 'bP-c6',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 2,
        rank: 5,
      ),
      Piece(
        id: 'bB',
        type: PieceType.bishop,
        color: PieceColor.dark,
        file: 5,
        rank: 4,
      ),
    ],
    tappableSquare: Square(4, 3), // e4
    legalMoves: [
      Square(5, 5), // f6 *
      Square(3, 5), // d6
      Square(2, 4), // c5
      Square(2, 2), // c3
      Square(3, 1), // d2
      Square(5, 1), // f2
      Square(6, 2), // g3
      Square(6, 4), // g5
    ],
    rescueTo: Square(5, 5), // f6
    rescueNotation: 'Nf6+',
    dangerHint: 'Tap a white piece to see its moves.',
    failureHint: "That move doesn't break the attack. Look for a check.",
    successExplanation: 'KNIGHT TO F6 · CHECK & FORK',
    threatenedKing: Square(6, 0), // g1
  );

  // ── Puzzle 2 — Take the checker (PROTOTYPE). Knight on f3 checks g1; gxf3.
  static const Puzzle _p2 = Puzzle(
    id: 'p2-take-the-checker',
    title: 'Take the checker',
    statusText: '▮ Active threat · Nf3+',
    pieces: [
      Piece(
        id: 'wK',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
        rank: 0,
      ),
      Piece(
        id: 'wP-f2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 5,
        rank: 1,
      ),
      Piece(
        id: 'wP-g2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ),
      Piece(
        id: 'wP-h2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'wR',
        type: PieceType.rook,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      ),
      Piece(
        id: 'bK',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ),
      Piece(
        id: 'bN',
        type: PieceType.knight,
        color: PieceColor.dark,
        file: 5,
        rank: 2,
      ),
      Piece(
        id: 'bQ',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 3,
        rank: 7,
      ),
      Piece(
        id: 'bP-f7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ),
      Piece(
        id: 'bP-g7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 6,
        rank: 6,
      ),
      Piece(
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
    ],
    tappableSquare: Square(6, 1), // g2
    legalMoves: [
      Square(5, 2), // f3 * (captures knight)
      Square(6, 2), // g3
      Square(6, 3), // g4
    ],
    rescueTo: Square(5, 2), // f3
    rescueNotation: 'gxf3',
    dangerHint: 'The checker sits one step away.',
    failureHint: 'The knight still gives check.',
    successExplanation: 'PAWN TAKES F3 · REMOVES THE CHECKER',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── Puzzle 3 — Block the file (PROTOTYPE). Queen on g5 down the open
  // g-file; Ng3 interposes.
  static const Puzzle _p3 = Puzzle(
    id: 'p3-block-the-file',
    title: 'Block the file',
    statusText: '▮ Active threat · Qg1#',
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
        rank: 1,
      ),
      Piece(
        id: 'wP-f2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 5,
        rank: 1,
      ),
      Piece(
        id: 'wP-h2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'wR',
        type: PieceType.rook,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      ),
      Piece(
        id: 'bK',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ),
      Piece(
        id: 'bQ',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 6,
        rank: 4,
      ),
      Piece(
        id: 'bP-f7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ),
      Piece(
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
      Piece(
        id: 'bR',
        type: PieceType.rook,
        color: PieceColor.dark,
        file: 0,
        rank: 7,
      ),
    ],
    tappableSquare: Square(4, 1), // e2
    legalMoves: [
      Square(6, 2), // g3 * (blocks the file)
      Square(2, 2), // c3
      Square(3, 3), // d4
      Square(5, 3), // f4
      Square(2, 0), // c1
    ],
    rescueTo: Square(6, 2), // g3
    rescueNotation: 'Ng3',
    dangerHint: 'Checked straight down the file.',
    failureHint: "That doesn't block the check.",
    successExplanation: 'KNIGHT TO G3 · BLOCKS THE FILE',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── Puzzle 4 — Seal the diagonal (PROTOTYPE). Queen on a7 down the
  // a7–g1 diagonal; Be3 interposes.
  static const Puzzle _p4 = Puzzle(
    id: 'p4-seal-the-diagonal',
    title: 'Seal the diagonal',
    statusText: '▮ Active threat · Qg1#',
    pieces: [
      Piece(
        id: 'wK',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
        rank: 0,
      ),
      Piece(
        id: 'wB',
        type: PieceType.bishop,
        color: PieceColor.light,
        file: 2,
        rank: 0,
      ),
      Piece(
        id: 'wP-g2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ),
      Piece(
        id: 'wP-h2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'wR',
        type: PieceType.rook,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      ),
      Piece(
        id: 'bK',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ),
      Piece(
        id: 'bQ',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 0,
        rank: 6,
      ),
      Piece(
        id: 'bP-f7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ),
      Piece(
        id: 'bP-g7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 6,
        rank: 6,
      ),
      Piece(
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
    ],
    tappableSquare: Square(2, 0), // c1
    legalMoves: [
      Square(4, 2), // e3 * (seals the diagonal)
      Square(3, 1), // d2
      Square(5, 3), // f4
      Square(6, 4), // g5
      Square(1, 1), // b2
      Square(0, 2), // a3
    ],
    rescueTo: Square(4, 2), // e3
    rescueNotation: 'Be3',
    dangerHint: 'The long diagonal is loaded.',
    failureHint: 'The diagonal is still open.',
    successExplanation: 'BISHOP TO E3 · SEALS THE DIAGONAL',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── Puzzle 5 — Win the queen (PROTOTYPE). Queen on h3 threatens Qxg2#;
  // Rxh3 removes the attacker.
  static const Puzzle _p5 = Puzzle(
    id: 'p5-win-the-queen',
    title: 'Win the queen',
    statusText: '▮ Active threat · Qg2#',
    pieces: [
      Piece(
        id: 'wK',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
        rank: 0,
      ),
      Piece(
        id: 'wR',
        type: PieceType.rook,
        color: PieceColor.light,
        file: 5,
        rank: 2,
      ),
      Piece(
        id: 'wP-f2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 5,
        rank: 1,
      ),
      Piece(
        id: 'wP-g2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ),
      Piece(
        id: 'wP-h2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'bK',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ),
      Piece(
        id: 'bQ',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 7,
        rank: 2,
      ),
      Piece(
        id: 'bP-f7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ),
      Piece(
        id: 'bP-g7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 6,
        rank: 6,
      ),
      Piece(
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
    ],
    tappableSquare: Square(5, 2), // f3
    legalMoves: [
      Square(7, 2), // h3 * (captures queen)
      Square(6, 2), // g3
      Square(4, 2), // e3
      Square(5, 3), // f4
      Square(5, 4), // f5
    ],
    rescueTo: Square(7, 2), // h3
    rescueNotation: 'Rxh3',
    dangerHint: 'The attacker is exposed.',
    failureHint: 'The queen still looms.',
    successExplanation: 'ROOK TAKES H3 · WINS THE QUEEN',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );
}
