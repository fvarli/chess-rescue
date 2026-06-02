# Archived — RD1 "The pinned defender" (remove the defender)

## Original memo summary

**Motif.** `removeDefender`

**Proposed rescue.** `Nxg3` — wN-e5 captures bN-g3 (the "defender" that supports the f1 flight square coverage in the mate net).

**Position.** wK g1; wPs a2/f2/h2 (no g2); wN e5; bN g3; bQ h3; bK g8; bPs f7/h7.

**Threat (per memo).** Originally `Qh1#`; corrected at Phase 2.5 to `Qxh2#` (h-file is blocked by wP-h2, so Qh1 isn't directly reachable; Qxh2 captures the pawn and mates).

**Author's self-rating.** Strong (per Phase 1 memo). Concern: differed geometric setup from B3.

## Rejection record

- **Decision.** REJECTED.
- **Phase.** Phase 2.5 (geometry validation).
- **Reviewer.** Author self-audit per the lead's discipline correction.
- **Check that failed.** #3 — *rescue is not chess-legal from the stated starting square*.
- **Rationale.** The proposed rescue `Nxg3` requires wN-e5 to reach g3 in one move.
  - e5 (4,4) to g3 (6,2): file_diff = +2, rank_diff = -2. Magnitudes |2| and |2|.
  - **This is a bishop move pattern, not a knight move pattern.** Knight moves are 1/2 or 2/1 offsets — equal magnitudes (2/2 or 1/1) are NOT knight-legal.
  - Knight from e5 reaches: g6 (6,5), g4 (6,3), c6 (2,5), c4 (2,3), f7 (5,6), f3 (5,2), d7 (3,6), d3 (3,2). **g3 (6,2) is not in this set.**

  The author misidentified a bishop move as a knight move when writing the memo. The candidate is geometrically broken.
- **What could work (NOT pursued this sprint).** The intended motif — capture bN-g3 to defang the mate net — is actually achievable in this position by `fxg3` (wP-f2 captures bN-g3 via pawn diagonal forward). After fxg3, bN is removed; Qxh2+ becomes only check (not mate) because f1 is no longer covered (bN gone) and bQ on h2 doesn't itself cover f1.

  However:
  1. `fxg3` makes the puzzle a `captureAttackerMinor` archetype (pawn capturing minor piece), NOT `removeDefender`. The categorization would slide.
  2. Per the lead's "do not patch weak candidates" directive, the right action is to reject RD1 entirely and defer the "remove defender via knight move" motif to a future sprint.
- **Future-sprint guidance.** When proposing a `removeDefender` candidate:
  1. Verify the rescue's chess-legality on the actual board BEFORE writing the memo (not after).
  2. Place the rescuer piece so it CAN geometrically reach the defender's square in one move.
  3. Avoid pawn-recapture rescues; those slide into `captureAttackerMinor` categorization and dilute the motif's identity.
  4. Pre-flight verification: for each proposed rescuer-piece + rescue-square pair, confirm the move pattern matches the piece's movement rules.

  This is a process improvement — the geometric pre-flight should happen during candidate generation, not be discovered at Phase 2.5 validation.
