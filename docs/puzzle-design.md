# Puzzle Design

Chess Rescue is **not** a chess tactics trainer. Each puzzle exists to make the
player feel they *saved the game*: clear danger, one believable rescue, a gentle
failure. Emotional readability beats chess difficulty. This doc records the
design rules and the rationale behind the five puzzles in
`lib/core/models/puzzle_library.dart`.

## The rubric (every puzzle must satisfy)

- **Clear danger** — the king's peril reads at a glance (danger glow + status pill).
- **One believable rescue** — a single board-legal move that visibly answers the threat.
- **2–5 plausible decoys** — tempting-but-wrong moves of the same piece.
- **Concise danger hint** — one line, shown in the danger state.
- **Soft failure hint** — unjudgmental, gently points back toward the idea.
- **Satisfying success explanation** — mono caps, names the move and why it works.

## Rescue archetypes

The prototype covers three rescue families across five puzzles:

| # | Title | Archetype | Rescue | Why it saves |
|---|-------|-----------|--------|--------------|
| 1 | Knight rescue | **Counter-check** (zwischenzug) | `Nf6+` | Check the black king back; the threatened `Qg2#` never gets played. |
| 2 | Take the checker | **Capture the attacker** (minor) | `gxf3` | The g2 pawn removes the knight that was checking g1. |
| 3 | Block the file | **Interpose** (file) | `Ng3` | The knight steps between the queen on g5 and the king down the g-file. |
| 4 | Seal the diagonal | **Interpose** (diagonal) | `Be3` | The bishop sits on the a7–g1 diagonal, sealing the queen's line. |
| 5 | Win the queen | **Capture the attacker** (the queen) | `Rxe1` | The rook takes the queen that crashed the back rank with check. |

Puzzles 2 and 5 are both captures, and 3 and 4 are both interposes, but each
feels distinct in piece, line, and prize (a humble pawn grabbing a knight vs. a
rook snatching the queen; a knight plugging a file vs. a bishop sealing a
diagonal).

## Deliberate design liberties

These are intentional, not bugs:

1. **Only Puzzle 1 is engine-real.** It is transcribed from the canonical source
   (`docs/components/primitives.jsx`). Puzzles 2–5 are handcrafted prototype
   placeholders, flagged `isPrototype: true`. They are board-legal and
   emotionally readable but **not** validated by a chess engine.
2. **Decoys are about temptation, not legality.** In the "in check" puzzles,
   several whitelisted decoys are moves that don't resolve the check — which a
   real engine would forbid while in check. We surface them anyway because the
   point is *emotional*: "you moved, but you didn't save it." The failure hint
   covers the gap. There is no engine; moves are whitelisted (see the technical
   plan's "Move whitelist" section).
3. **Self-captures are not shown.** Earlier Puzzle 1 included a decoy that landed
   on its own pawn (an illegal self-capture inherited from the source). It was
   removed; decoys now only land on empty or enemy squares.
4. **The king stays put.** All five puzzles keep the white king stationary so the
   danger glow and the failure flash stay anchored to a meaningful square
   (`threatenedKing`). King-movement archetypes — notably "create an escape
   square" — are deferred to a later phase, after the interaction language and
   puzzle structure mature.

## Status / copy conventions

- **All displayed copy is geometry-safe (Phase 20)** — no squares, no notation — so
  base and mirror variants read identically and correctly. Status pill: `▮ Active
  threat` / `▮ In check` / `▮ Checked on the file|diagonal|rank` (mirror-invariant
  concepts). Success pill is the constant `◐ Attack broken`. `successExplanation` is an
  archetype line (e.g. "THE FILE IS SEALED"). See `docs/rescue-archetypes.md` for the
  table.
- `rescueNotation` is **internal metadata only** — not displayed; kept on base puzzles,
  cleared on variants.
- Headlines ("Save the king." / "Where will it go?" / "Rescued." / "Not the
  move.") and the selected-state instruction are generic across all puzzles.
- `dangerHint`, `failureHint`, and `successExplanation` are per-puzzle (geometry-safe).

## Authoring a new puzzle

Append a `Puzzle` to `PuzzleLibrary.all`. Give it: unique `id`, `title`,
`statusText`, a piece list with locally-unique ids, the `tappableSquare`, a
`legalMoves` whitelist (one `rescueTo` + 2–5 decoys), `rescueNotation`, the three
hint strings, the `threatenedKing` square, and `isPrototype: true` until
engine-validated. Keep the king stationary and run the rubric above against it.
