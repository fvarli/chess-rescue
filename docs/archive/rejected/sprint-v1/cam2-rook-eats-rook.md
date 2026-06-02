# Archived — CAM2 "Rook eats the rook"

## Original memo summary

**Motif.** `captureAttackerMinor`

**Proposed rescue.** `Rxg3` — wR-c3 captures bR-g3 along the 3rd rank.

**Position.** wK g1 in check from bR-g3 (g-file open, wP-g2 absent); wR c3 captures along 3rd rank.

**Author's self-rating.** Medium. Concern: "rook for rook" might be too obvious.

## Rejection record

- **Decision.** REJECTED.
- **Phase.** Phase 2 (independent quality check during reviewer audit).
- **Reviewer.** Author self-audit, lead-aligned per [[feedback-quality-over-symmetry]].
- **Check that failed.** Quality concern (passes R0 vs. P2/CAM1, fails the "feels like Chess Rescue" test).
- **Rationale.** CAM2 passes R0 cleanly against P2 (pawn captures knight) and CAM1 (knight captures bishop) — the piece pair (rook captures rook) is different from both. But the *experience* of solving CAM2 is "execute the most aggressive obvious chess move" — not the panic-then-rescue-instinct loop Chess Rescue is built around.

  In P2, the player has to notice that the humble g-pawn can capture a knight (an unusual tactic — a pawn taking a minor piece is the satisfying "humble move"). In CAM1, the player has to recognize that a knight can capture a bishop on the diagonal where the bishop is checking. Both involve a small "ah, that move" instinct.

  In CAM2, the player just sees "the checking rook is two squares to my right" and plays the obvious capture. There's no instinct exercised; it's chess execution.

  Per [[feedback-quality-over-symmetry]], better to ship without CAM2 than force a candidate that doesn't actually exercise the rescue instinct.
- **Future-sprint guidance.** A future `captureAttackerMinor` candidate must require the player to *notice* something non-obvious about the capture — typically:
  - The capturing piece is unexpected (humble or far-away)
  - The capture exposes a different tactical idea (e.g., discovered attack)
  - The capture involves a piece the player wouldn't normally choose to expose

  "Rook captures rook on adjacent rank" is too quotidian for the panic-loop experience.
