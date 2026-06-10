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
    PuzzleTemplate(
      archetype: RescueArchetype.counterCheck,
      puzzle: _p1,
      // Knight's other honest non-checking squares (f2 = own pawn, excluded).
      decoyPool: [Square(2, 2), Square(3, 1)], // c3, d2
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.captureAttackerMinor,
      puzzle: _p2,
      // No decoy pool: the g2 pawn's only moves (g3/g4/gxf3) are already shown.
      // Scenery: cosmetic shelter pawns; a7 is empty + off every line (knight
      // check has no slider lane).
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-a7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 0,
          rank: 6,
        ),
      ],
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.blockFile,
      puzzle: _p3,
      // No decoy pool: the e2 knight's only unshown square is g1 (own king).
      // Scenery: shelter pawns; a7 is empty + off the g-file lane.
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-a7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 0,
          rank: 6,
        ),
      ],
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.sealDiagonal,
      puzzle: _p4,
      decoyPool: [Square(7, 5)], // h6 (on the c1–h6 diagonal, doesn't seal)
      // Scenery: shelter pawns; b7 is empty + off the a7–g1 diagonal (b6 is on it).
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-b7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 1,
          rank: 6,
        ),
      ],
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.captureAttackerHeavy,
      puzzle: _p5,
      // The rook only resolves on e1 (capture); f1 is unreachable, so every
      // other rook square is an honest decoy.
      decoyPool: [
        Square(4, 4), // e5
        Square(4, 5), // e6
        Square(2, 2), // c3
        Square(6, 2), // g3
        Square(7, 2), // h3
        Square(1, 2), // b3
      ],
      // Scenery: shelter pawns; a7 is empty + off the rank-1 lane.
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-a7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 0,
          rank: 6,
        ),
      ],
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

  // The runtime session for a given seed (Phase 21 / Phase 22C). Seed 0 is the
  // canonical authored session (preserves the onboarding cold open + first
  // impression) — a hard lock. Seeds >= 1 are deterministic, paced composed
  // sessions drawing from the canonical backbone plus the expansion families
  // (canonical-anchored: opener + finale locked, <= 2 expansion middles).
  static List<Puzzle> session(int seed) => seed == 0
      ? all
      : SessionComposer.compose(
          templates: templates,
          expansion: expansionTemplates,
          seed: seed,
        );

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
      decoyPool: [Square(1, 5), Square(2, 2)], // b6, c3 (e7 excluded — see _a4)
      // Scenery: shelter pawns; a7 is empty + off the a8→d5 bishop line (b7/c6).
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-a7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 0,
          rank: 6,
        ),
      ],
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.forcedInterposition,
      puzzle: _b1Martyr,
      // Only d4 interposes on the diagonal; every other rook square is honest.
      decoyPool: [
        Square(3, 4), // d5
        Square(3, 5), // d6
        Square(0, 0), // a1
        Square(1, 0), // b1
        Square(4, 0), // e1
      ],
      // Scenery: shelter pawns; b7 is empty + off the a7–g1 diagonal.
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-b7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 1,
          rank: 6,
        ),
      ],
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.removeDefender,
      puzzle: _b3RemoveDefender,
      decoyPool: [
        Square(1, 2),
        Square(4, 1),
      ], // b3, e2 (f3 excluded — blocks guard)
      // Scenery: shelter pawns; a6 is empty + off the c6→g2 guard diagonal.
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-a6',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 0,
          rank: 5,
        ),
      ],
    ),
    PuzzleTemplate(
      archetype: RescueArchetype.counterCheck,
      puzzle: _b4CrossCheck,
      decoyPool: [Square(3, 2)], // d3 (g4 excluded — blocks the file)
      // Scenery: shelter pawns; a7 is empty + off the g-file lane.
      removableScenery: ['bP-f7', 'bP-h7'],
      sceneryPool: [
        Piece(
          id: 'bP-a7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 0,
          rank: 6,
        ),
      ],
    ),
    // ── Sprint V1 — CC2 (counterCheck). Bxf7+: the c4 bishop captures the f7
    // shield pawn and checks the black king on g8. Phase 2.5 8-check validated.
    PuzzleTemplate(
      archetype: RescueArchetype.counterCheck,
      puzzle: _cc2BishopCapturesShield,
      // d3: a chess-legal bishop diagonal from c4; doesn't reach bK-g8 (3,5 is
      // not a diagonal), doesn't attack bQ-h3, doesn't defend g2. Honest decoy.
      decoyPool: [Square(3, 2)],
      // a7 is off the c4–f7 rescue diagonal and off any threat lane (bQ-h3
      // has no slider line to g1 or c4); safe cosmetic.
      removableScenery: ['bP-a7'],
      sceneryPool: [
        Piece(
          id: 'bP-b7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 1,
          rank: 6,
        ),
      ],
    ),
    // ── Sprint V1 — CAM1 (captureAttackerMinor). Nxh2: the g4 knight captures
    // the bishop checking on h2. Phase 2.5 8-check validated. No decoyPool —
    // every knight-reachable square from g4 is already in legalMoves (the
    // single unoccupied alternative, f2, is blocked by wP-f2).
    PuzzleTemplate(
      archetype: RescueArchetype.captureAttackerMinor,
      puzzle: _cam1KnightTakesBishop,
      // a7 is off bB-h2's diagonal to g1 (one-square line, nothing between).
      removableScenery: ['bP-a7'],
      sceneryPool: [
        Piece(
          id: 'bP-b7',
          type: PieceType.pawn,
          color: PieceColor.dark,
          file: 1,
          rank: 6,
        ),
      ],
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
    dangerHint: 'One piece can answer this. Find it.',
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
  // Decoys: knight squares that flee but land no blow (e3, c7, b4, f4).
  // Note: e7 was removed — Ne7 also checks the king on g8, so it was a second
  // valid rescue masquerading as a decoy (the failure copy would have lied).
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
      Square(4, 2), // e3 (was e7 — e7 is a 2nd check on g8, a dishonest decoy)
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

  // ════════════════════════════════════════════════════════════════════
  // Sprint V1 — Tier-1 expansion additions (in `expansionTemplates`).
  // Each Phase 2.5–validated via the 8-check geometry gate documented at
  // docs/sprint-v1-phase2.5-validation.md.
  // ════════════════════════════════════════════════════════════════════

  // ── CC2 — Bishop captures the shield (PROTOTYPE).
  // Archetype: COUNTER-CHECK. The black queen on h3 threatens Qxg2# (the
  // h2/g2 shelter pawns can't catch it because the queen captures with check
  // and the wK has no flight). White answers with Bxf7+ — the c4 bishop
  // captures the f7 shield pawn and checks the bK on g8, so black must respond
  // to the check and the g2 mate never lands.
  // Why it saves: an unexpected check redirects the position before the
  // attack arrives.
  // Decoys: bishop moves that neither check the bK nor stop the threat —
  // d5/e6 (still on the same diagonal but stop short of f7), b5/a6 (wrong
  // direction). Other bishop squares (b3/d3) are decoyPool candidates; b3 is
  // excluded as a second check (b3→g8 is a real diagonal).
  static const Puzzle _cc2BishopCapturesShield = Puzzle(
    id: 'cc2-bishop-captures-shield',
    title: 'Bishop captures the shield',
    statusText: '▮ Mate is coming',
    pieces: [
      Piece(
        id: 'wK',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
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
        id: 'wB',
        type: PieceType.bishop,
        color: PieceColor.light,
        file: 2,
        rank: 3,
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
        file: 7,
        rank: 2,
      ),
      Piece(
        id: 'bP-a7',
        type: PieceType.pawn,
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
    tappableSquare: Square(2, 3), // c4 (the bishop)
    legalMoves: [
      Square(5, 6), // f7 * (captures the shield, checks the bK on g8)
      Square(3, 4), // d5
      Square(4, 5), // e6
      Square(1, 4), // b5
      Square(0, 5), // a6
    ],
    rescueTo: Square(5, 6), // f7
    rescueNotation: 'Bxf7+',
    dangerHint: 'The queen is one step from sealing the king in.',
    failureHint:
        "That move doesn't break the threat. Strike at the other king.",
    successExplanation: 'THE BISHOP CRASHES THROUGH',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );

  // ── CAM1 — Knight takes the bishop (PROTOTYPE).
  // Archetype: CAPTURE THE ATTACKER (minor). A black bishop has landed on h2
  // and gives check along the h2–g1 diagonal. The g4 knight leaps to h2:
  // Nxh2 — the checker is gone and the check is over in one move.
  // Why it saves: you remove the piece that's attacking you.
  // Decoys: the knight's other reachable squares (h6, f6, e5, e3) — they
  // move but leave the bishop on h2 still giving check.
  static const Puzzle _cam1KnightTakesBishop = Puzzle(
    id: 'cam1-knight-takes-bishop',
    title: 'Knight takes the bishop',
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
        id: 'wP-c2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 2,
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
        id: 'wP-g2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ),
      // No wP-h2 — the black bishop occupies h2 and checks the king.
      Piece(
        id: 'wN',
        type: PieceType.knight,
        color: PieceColor.light,
        file: 6,
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
        id: 'bB',
        type: PieceType.bishop,
        color: PieceColor.dark,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'bP-a7',
        type: PieceType.pawn,
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
    tappableSquare: Square(6, 3), // g4 (the knight)
    legalMoves: [
      Square(7, 1), // h2 * (captures the checking bishop)
      Square(7, 5), // h6
      Square(5, 5), // f6
      Square(4, 4), // e5
      Square(4, 2), // e3
    ],
    rescueTo: Square(7, 1), // h2
    rescueNotation: 'Nxh2',
    dangerHint: 'A bishop is biting. Hit it back.',
    failureHint: 'The bishop is still there. Take it.',
    successExplanation: 'THE KNIGHT TAKES THE BISHOP',
    threatenedKing: Square(6, 0), // g1
    isPrototype: true,
  );
}
