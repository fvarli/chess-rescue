# Archived — CC1 "The Rook above the king"

## Original memo summary

**Motif.** `counterCheck`

**Proposed rescue.** `Rf8+` — wR slides from f3 up the f-file to f8, checking bK on g8 along the 8th rank.

**Threat.** `Qxh2#` (mate-in-one), supported by bB-a6 covering f1 via the a6-f1 diagonal.

**Position.** wK g1, wPs a2/f2/g2/h2, wR f3, bB a6, bK g8, bP h7, bQ h3.

**Proposed `legalMoves` (omitting `Rxh3`).** f8 (rescue), f4, f5, e3, d3.

**R0 claim.** First non-knight counter-check; geometrically distinct from P1/A4/B4 in piece type, rescue square, and area.

## Rejection record

- **Decision.** REJECTED.
- **Phase.** Phase 2.5 (geometry validation).
- **Reviewer.** Author self-audit per the lead's discipline correction.
- **Check that failed.** #5 — *no second valid rescue*.
- **Rationale.** From the same tappable piece (wR-f3), `Rxh3` is a chess-legal move (slide along the 3rd rank to h3 captures the threatening queen). Capturing the threatening queen directly resolves the mate-in-one (no queen → no Qxh2#). This is a second valid rescue at the **position** level, even though the author proposed omitting it from the `legalMoves` list (per the P1 convention of hiding chess-legal moves). R5's spirit — *"one mover, one rescue"* — is structurally violated when the rescuer piece has two legal moves that both resolve the danger. The hiding convention exists for *decoys*, not for *alternative rescues*.
- **Future-sprint guidance.** A counter-check candidate where the rescuer can also reach the threatening piece's square via capture is structurally weak. Future remixes should:
  1. Position the rescuer so its line of attack to the threatening piece is blocked (by a friendly piece, a wall of pawns, or geometry), OR
  2. Choose a rescuer + threat geometry where capture is mechanically impossible (e.g., a rook rescuer with the threatening queen on a different rank/file/diagonal entirely).

  The "rook counter-check" SHAPE is still potentially valuable for a future sprint; the specific CC1 geometry isn't.
