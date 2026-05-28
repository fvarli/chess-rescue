import 'piece.dart';
import 'puzzle.dart';
import 'puzzle_template.dart';
import 'rescue_archetype.dart';
import 'square.dart';
import 'variation.dart';

// Curated rescue sequence. Puzzle 1 is the real canonical rescue; puzzles
// 2–5 are handcrafted prototype placeholders (isPrototype: true) — board-legal
// and emotionally readable, but not engine-validated. Every puzzle whitelists
// its moves and has exactly one correct rescue (marked * in comments).
//
// Design rubric (see docs/puzzle-design.md): clear danger · one believable
// rescue · 2–5 plausible decoys · concise danger hint · soft failure hint ·
// satisfying success explanation. All five keep the king stationary so the
// danger glow and failure flash stay anchored to a meaningful square.
class PuzzleLibrary {
  PuzzleLibrary._();

  // The archetype-tagged templates (Phase 19A architecture). Each wraps the
  // existing const puzzle; toPuzzle() is identity in 19B (the variation seam
  // for 19C). See docs/replayability-architecture.md.
  static const List<PuzzleTemplate> templates = [
    PuzzleTemplate(archetype: RescueArchetype.counterCheck, puzzle: _p1),
    PuzzleTemplate(
      archetype: RescueArchetype.captureAttackerMinor,
      puzzle: _p2,
    ),
    PuzzleTemplate(archetype: RescueArchetype.blockFile, puzzle: _p3),
    PuzzleTemplate(archetype: RescueArchetype.sealDiagonal, puzzle: _p4),
    PuzzleTemplate(
      archetype: RescueArchetype.captureAttackerHeavy,
      puzzle: _p5,
    ),
  ];

  // The runtime sequence GameController consumes. Identity conversion over the
  // const templates → the same 5 Puzzle instances, same order (behavior-
  // preserving; 19C keeps `all` as identity — variants are not shipped here).
  static final List<Puzzle> all = templates
      .map((t) => t.toPuzzle())
      .toList(growable: false);

  // Phase 19C preview only — horizontal-mirror variants of each template.
  // NOT consumed by the runtime; exposed for tests/inspection and future
  // session composition (19E). See docs/replayability-architecture.md.
  static final List<Puzzle> mirrorVariants = templates
      .map((t) => t.toPuzzle(Variation.mirror))
      .toList(growable: false);

  // ── Puzzle 1 — Knight rescue (REAL).
  // Archetype: COUNTER-CHECK (zwischenzug). Black threatens Qg2#. Instead of
  // defending, white plays Nf6+ — the knight on f6 checks the black king on
  // g8, forcing black to answer the check, so the threatened mate never lands.
  // Why it saves: you seize the initiative by checking back.
  // Decoys: the knight's other forward/side squares — plausible "reposition
  // the knight" tries that ignore the tempo and lose to Qg2#.
  // Transcribed from docs/components/primitives.jsx:180-210; decoys trimmed to
  // a clean set (the original self-capture onto f2 was removed).
  static const Puzzle _p1 = Puzzle(
    id: 'p1-knight-rescue',
    title: 'Knight rescue',
    statusText: '▮ Active threat',
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
      Square(6, 4), // g5
      Square(6, 2), // g3
      Square(2, 4), // c5
      Square(3, 5), // d6
    ],
    rescueTo: Square(5, 5), // f6
    rescueNotation: 'Nf6+',
    dangerHint: 'Tap a white piece to see its moves.',
    failureHint: "That move doesn't break the attack. Look for a check.",
    successExplanation: 'THE KNIGHT STRIKES BACK',
    threatenedKing: Square(6, 0), // g1
  );

  // ── Puzzle 2 — Take the checker (PROTOTYPE).
  // Archetype: CAPTURE THE ATTACKER (minor piece). The black knight on f3
  // checks the king on g1. The humble g2 pawn captures it: gxf3.
  // Why it saves: removing the checker ends the check outright.
  // Decoys: the g-pawn's two pushes (g3, g4) — they advance but leave the
  // knight checking. (Two decoys is the pawn's natural maximum here.)
  static const Puzzle _p2 = Puzzle(
    id: 'p2-take-the-checker',
    title: 'Take the checker',
    statusText: '▮ In check',
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
      Square(5, 2), // f3 * (captures the knight)
      Square(6, 2), // g3
      Square(6, 3), // g4
    ],
    rescueTo: Square(5, 2), // f3
    rescueNotation: 'gxf3',
    dangerHint: 'The checker sits one step away.',
    failureHint: 'The knight still gives check.',
    successExplanation: 'THE CHECKER IS GONE',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── Puzzle 3 — Block the file (PROTOTYPE).
  // Archetype: INTERPOSE ON A FILE. The black queen on g5 checks the king on
  // g1 down the open g-file. The knight on e2 jumps to g3, standing between
  // them: Ng3.
  // Why it saves: a body in the line breaks the check.
  // Decoys: the knight's other squares (c3, d4, f4, c1) — they move but leave
  // the file open.
  static const Puzzle _p3 = Puzzle(
    id: 'p3-block-the-file',
    title: 'Block the file',
    statusText: '▮ Checked on the file',
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
    successExplanation: 'THE FILE IS SEALED',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── Puzzle 4 — Seal the diagonal (PROTOTYPE).
  // Archetype: INTERPOSE ON A DIAGONAL. The black queen on a7 checks the king
  // on g1 along the open a7–g1 diagonal. The bishop on c1 steps to e3, sitting
  // on that diagonal: Be3.
  // Why it saves: the bishop seals the line between queen and king.
  // Decoys: the bishop's other diagonal squares (d2, f4, g5, b2, a3) — d2 is
  // tempting (it's on the way) but stops short of the diagonal.
  static const Puzzle _p4 = Puzzle(
    id: 'p4-seal-the-diagonal',
    title: 'Seal the diagonal',
    statusText: '▮ Checked on the diagonal',
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
    successExplanation: 'THE DIAGONAL IS CLOSED',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── Puzzle 5 — Win the queen (PROTOTYPE).
  // Archetype: CAPTURE THE ATTACKER (the queen) / win tempo. The black queen
  // has crashed the back rank — Qe1+ checks the king on g1 along rank 1 (f1 is
  // empty). The rook on e3 is the only white piece eyeing e1, so Rxe1 captures
  // the checking queen: you escape check and win the queen at once.
  // Why it saves: the single most valuable attacker is removed with check
  // resolved.
  // Decoys: other rook moves (e2, e4, d3, f3) — they reposition but leave the
  // queen giving check.
  static const Puzzle _p5 = Puzzle(
    id: 'p5-win-the-queen',
    title: 'Win the queen',
    statusText: '▮ Checked on the rank',
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
        file: 4,
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
        file: 4,
        rank: 0,
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
    tappableSquare: Square(4, 2), // e3
    legalMoves: [
      Square(4, 0), // e1 * (captures the queen)
      Square(4, 1), // e2
      Square(4, 3), // e4
      Square(3, 2), // d3
      Square(5, 2), // f3
    ],
    rescueTo: Square(4, 0), // e1
    rescueNotation: 'Rxe1',
    dangerHint: 'The queen has crashed the back rank.',
    failureHint: 'The queen still gives check.',
    successExplanation: 'THE QUEEN FALLS',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );
}
