import 'piece.dart';
import 'puzzle.dart';
import 'puzzle_template.dart';
import 'rescue_archetype.dart';
import 'session_composer.dart';
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

  // Phase 19C preview — horizontal-mirror variants of each template (used by
  // the debug gallery and as composer candidates).
  static final List<Puzzle> mirrorVariants = templates
      .map((t) => t.toPuzzle(Variation.mirror))
      .toList(growable: false);

  // The runtime session for a given seed (Phase 21). Seed 0 is the canonical
  // authored session (preserves the onboarding cold open + first impression);
  // seeds >= 1 are deterministic, paced composed sessions (mirror variants).
  static List<Puzzle> session(int seed) => seed == 0
      ? all
      : SessionComposer.compose(templates: templates, seed: seed);

  // ── Phase 22B — Tier-1 expansion families (authored + gated; NOT wired) ──
  // A separate pool of new canonical rescue families. Subjected to the full
  // validation / readability / copy-safety / mirror battery (see
  // test/expansion_families_test.dart) and rendered in the debug gallery, but
  // deliberately kept OUT of `templates` / `all` / `session` / the composer so
  // the 5-puzzle onboarding session and every Phase 21 invariant are preserved.
  // Live wiring is a later phase (22C). See docs/rescue-archetypes.md.
  static const List<PuzzleTemplate> expansionTemplates = [
    PuzzleTemplate(
      archetype: RescueArchetype.counterCheck,
      puzzle: _a4Breakaway,
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.forcedInterposition,
      puzzle: _b1Martyr,
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.removeDefender,
      puzzle: _b3RemoveDefender,
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.counterCheck,
      puzzle: _b4CrossCheck,
    ),
  ];

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

  // ════════════════════════════════════════════════════════════════════
  // Phase 22B — Tier-1 expansion families (in `expansionTemplates`, not the
  // live runtime). Each keeps the king on g1, one clear tension lane, one
  // emotionally obvious rescue + curated decoys. See docs/rescue-archetypes.md.
  // ════════════════════════════════════════════════════════════════════

  // ── A4 — The Breakaway (PROTOTYPE).
  // Archetype: COUNTER-CHECK (escape flavor). A black bishop on a8 has the
  // white knight on d5 in its sights while the black queen sits at the gate on
  // e2. The knight leaps Nf6+ — escaping the bishop's diagonal and checking the
  // black king on g8, so black must answer the check.
  // Why it saves: the hunted piece breaks free and seizes the tempo.
  // Decoys: knight squares that flee but land no blow (e7, c7, b4, f4).
  static const Puzzle _a4Breakaway = Puzzle(
    id: 'a4-the-breakaway',
    title: 'The breakaway',
    statusText: '▮ Hunted at the gate',
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
        file: 3,
        rank: 4,
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
        rank: 1,
      ),
      Piece(
        id: 'bB',
        type: PieceType.bishop,
        color: PieceColor.dark,
        file: 0,
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
    ],
    tappableSquare: Square(3, 4), // d5
    legalMoves: [
      Square(5, 5), // f6 * (checks the king, escapes the bishop)
      Square(4, 6), // e7
      Square(2, 6), // c7
      Square(1, 3), // b4
      Square(5, 3), // f4
    ],
    rescueTo: Square(5, 5), // f6
    rescueNotation: 'Nf6+',
    dangerHint: 'Your knight is cornered and the gate is under fire.',
    failureHint: 'That slips away but strikes nothing. Hit back with a check.',
    successExplanation: 'THE KNIGHT BREAKS FREE',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── B1 — The Martyr (PROTOTYPE).
  // Archetype: FORCED INTERPOSITION (sacrifice). The black queen on a7 checks
  // the king on g1 down the open a7–g1 diagonal. The rook on d1 throws itself
  // in front: Rd4 — undefended, destined to be taken, but the king lives.
  // Why it saves: a body on the line breaks the check; the cost is the point.
  // Decoys: rook moves that don't sit on the diagonal (d2, d3, c1, f1).
  static const Puzzle _b1Martyr = Puzzle(
    id: 'b1-the-martyr',
    title: 'The martyr',
    statusText: '▮ The line is open',
    pieces: [
      Piece(
        id: 'wK',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
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
        file: 3,
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
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
    ],
    tappableSquare: Square(3, 0), // d1
    legalMoves: [
      Square(3, 3), // d4 * (interposes on the diagonal)
      Square(3, 1), // d2
      Square(3, 2), // d3
      Square(2, 0), // c1
      Square(5, 0), // f1
    ],
    rescueTo: Square(3, 3), // d4
    rescueNotation: 'Rd4',
    dangerHint: 'The diagonal is loaded and the king stands bare.',
    failureHint: "That doesn't stand in the way. Throw a body on the line.",
    successExplanation: 'A BODY FOR THE KING',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── B3 — Remove the defender (PROTOTYPE).
  // Archetype: REMOVE THE DEFENDER. The black bishop on c6 guards g2 along the
  // long diagonal; with the knight on g3 covering f1, the queen on h3 threatens
  // Qg2#. The knight on d4 takes the keystone: Nxc6 — and the mate collapses.
  // Why it saves: pull the one piece holding the attack together.
  // Decoys: knight moves that ignore the keystone (e6, f5, b5, c2); f3 is
  // omitted because it would also block the bishop's guard of g2.
  static const Puzzle _b3RemoveDefender = Puzzle(
    id: 'b3-remove-the-defender',
    title: 'Remove the defender',
    statusText: '▮ Held up by one piece',
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
        file: 3,
        rank: 3,
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
        id: 'bB',
        type: PieceType.bishop,
        color: PieceColor.dark,
        file: 2,
        rank: 5,
      ),
      Piece(
        id: 'bN',
        type: PieceType.knight,
        color: PieceColor.dark,
        file: 6,
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
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
    ],
    tappableSquare: Square(3, 3), // d4
    legalMoves: [
      Square(2, 5), // c6 * (captures the keystone bishop)
      Square(4, 5), // e6
      Square(5, 4), // f5
      Square(1, 4), // b5
      Square(2, 1), // c2
    ],
    rescueTo: Square(2, 5), // c6
    rescueNotation: 'Nxc6',
    dangerHint: 'One defender is propping up the whole attack.',
    failureHint: 'The attack still stands. Tear out its support.',
    successExplanation: 'THE PROP IS GONE',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── B4 — The Cross-Check (PROTOTYPE).
  // Archetype: COUNTER-CHECK (cross-check flavor). The black queen on g7 checks
  // the king on g1 down the open g-file. The knight on e5 lands on g6: it
  // blocks the file AND checks the black king on h8 — a check answered with a
  // check.
  // Why it saves: you stop dying and start attacking in the same move.
  // Decoys: knight moves that neither block nor check (c6, d7, c4, f3); plain
  // blocks (g4, g2) are omitted so the cross-check is the only listed escape.
  static const Puzzle _b4CrossCheck = Puzzle(
    id: 'b4-the-cross-check',
    title: 'The cross-check',
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
        rank: 4,
      ),
      Piece(
        id: 'bK',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 7,
        rank: 7,
      ),
      Piece(
        id: 'bQ',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 6,
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
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
    ],
    tappableSquare: Square(4, 4), // e5
    legalMoves: [
      Square(6, 5), // g6 * (blocks the file and checks the king)
      Square(2, 5), // c6
      Square(3, 6), // d7
      Square(2, 3), // c4
      Square(5, 2), // f3
    ],
    rescueTo: Square(6, 5), // g6
    rescueNotation: 'Ng6+',
    dangerHint: "You're in check — but you can answer in kind.",
    failureHint:
        "That doesn't break the check. Answer with a check of your own.",
    successExplanation: 'CHECK MEETS CHECK',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );
}
