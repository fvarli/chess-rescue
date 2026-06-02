# Archived — CAH1 (captureAttackerHeavy)

## Original memo summary

**Motif.** `captureAttackerHeavy`.

**Proposed concept.** Sketched "a bishop captures the threatening black queen." The capture move resolves a mate threat by removing the heavy attacker.

## Rejection record

- **Decision.** NOT PURSUED.
- **Phase.** Phase 1 candidate generation.
- **Reviewer.** Author self-rejection during memo writing.
- **Reason.** The author could not find a `captureAttackerHeavy` shape that satisfies the lead's *"only if it does not feel too obvious"* qualifier.

  Capture-the-queen positions tend to be **too obvious by their nature**:
  - The queen is the heaviest attacker; "take the queen" is the most aggressive chess move
  - The player's chess instinct (separate from the rescue instinct Chess Rescue trains) fires immediately on seeing an undefended/lightly-defended queen
  - The puzzle reads as "execute the chess move" rather than "find the rescue under pressure"

  Without a position where the queen is awkwardly defended (so capturing requires a less-obvious calculation) OR where the capturing piece is humble/surprising, the candidate doesn't exercise the rescue instinct meaningfully.
- **Future-sprint guidance.** A future `captureAttackerHeavy` candidate must engineer "the queen capture isn't obvious." Possible mechanisms:
  - The capturing piece is far away and the player has to *find* it (e.g., a queenside knight that can reach the kingside queen via a knight tour)
  - The capture is part of a discovered-attack mechanism (the capturing piece's move also reveals another attack)
  - The capture is a sacrifice where the player has to see the follow-up clearly enough to commit
  - The position has multiple plausible defensive moves; the capture must read as the correct one only after thought

  P5 (`win-the-queen`) achieves obviousness-avoidance by having the queen capture be a *rook* move (Rxe1) where the rook's path involves crossing through the threat area. Future heavy-attacker candidates need similar engineering.

  Expect future sprints to produce 0-1 new `captureAttackerHeavy` positions max. The motif's natural ceiling under R0 + the obviousness constraint is low.
