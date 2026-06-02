# Archived — RD2 "Take the pinner" (remove the defender variant)

## Original memo summary

**Motif.** `removeDefender`

**Proposed concept.** A black piece pins a white piece that would otherwise rescue. White captures the pinning piece, freeing the pinned defender to address the threat *on a subsequent move*.

## Rejection record

- **Decision.** NOT PURSUED (memo-level drop during Phase 1).
- **Phase.** Phase 1 candidate generation.
- **Reviewer.** Author self-rejection during memo writing.
- **Reason.** The pin mechanic requires a multi-move follow-up: capture the pinner THIS move, then play the pinned piece's rescue move NEXT turn. Chess Rescue's single-move-rescue framework (the rescue must IMMEDIATELY end the threat) doesn't accommodate this.

  The candidate was documented for completeness so the lead saw the consideration, then dropped without further pursuit.
- **Future-sprint guidance.** Multi-move tactics (pin-then-rescue, double attacks resolved over multiple turns, deflection followed by mate-in-two) are categorically incompatible with the single-move-rescue framework. Future `removeDefender` candidates must:
  1. Achieve the threat-defusing effect in the rescue move ITSELF (not as a setup for a future move).
  2. The captured "defender" must be a *current* support of the mate net, not a future obstacle.

  This is a permanent constraint on the motif. Pin-and-attack tactics belong to a different game.
