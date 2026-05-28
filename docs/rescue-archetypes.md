# Rescue Archetypes, Puzzle Grammar & Readability

> Status: **design (Phase 19A)**. Companion to `replayability-architecture.md`.
> Defines *what makes a Chess Rescue puzzle*, independent of geometry.

A puzzle is an **emotional rescue situation**, not a chess problem. Every template
belongs to one archetype (its feeling + rescue logic) and must satisfy the puzzle
grammar (readability) below.

---

## Archetype taxonomy

Each archetype is a reusable emotional shape. The current 5 puzzles already
instantiate the first five; the rest are the authoring frontier.

### 1. Counter-check  *(real: "Knight rescue", Nf6+)*
- **Feeling:** "I hit back." You don't defend — you threaten *them*.
- **Visual shape:** the rescuer leaps to deliver check on the enemy king, off the
  threat axis. The board's tension flips direction.
- **Readability requirement:** the enemy king must be visible and the rescuer's
  check obvious (a clear knight-jump or line to it).
- **Rescue logic:** give check → opponent must answer → the threatened mate never
  arrives (tempo).
- **Failure pattern:** any move that doesn't check.

### 2. Capture the attacker — minor  *(prototype: "Take the checker", gxf3)*
- **Feeling:** "I grab the threat." Humble, direct.
- **Visual shape:** a small piece (pawn) takes the checking piece on an adjacent lane.
- **Readability:** the checker sits one obvious capture away.
- **Rescue logic:** remove the checking piece → check ends.
- **Failure pattern:** pushes/moves that leave the checker on the board.

### 3. Capture the attacker — heavy / queen  *(prototype: "Win the queen", Rxe1)*
- **Feeling:** "I snatch the danger." The prize is the most dangerous piece.
- **Visual shape:** a piece takes the **queen** along a shared rank/file/diagonal.
- **Readability:** the queen is the loud threat; the capturing line is clear.
- **Rescue logic:** remove the heavy attacker (often a checking queen).
- **Failure pattern:** any non-capture / capturing the wrong piece.

### 4. Block a file  *(prototype: "Block the file", Ng3)*
- **Feeling:** "I stand in the way."
- **Visual shape:** a body interposes on a **vertical** lane between attacker and king.
- **Readability:** the open file from attacker to king must read as a single bright lane.
- **Rescue logic:** occupy the square on the lane between them.
- **Failure pattern:** moves off the lane.

### 5. Seal a diagonal  *(prototype: "Seal the diagonal", Be3)*
- **Feeling:** "I close the line."
- **Visual shape:** a body interposes on a **diagonal** lane.
- **Readability:** the diagonal from attacker to king reads as one clear line.
- **Rescue logic:** occupy a square on that diagonal.
- **Failure pattern:** moves off the diagonal (incl. tempting near-misses like d2).

### 6. Remove the defender  *(frontier)*
- **Feeling:** "I break the support." The mate only works because one piece guards it.
- **Visual shape:** capture the piece that defends the mating square; the threat collapses.
- **Readability:** the defender→mating-square relationship must be visible (not a
  hidden engine truth). Keep it to a **one-link** support, never a chain.
- **Rescue logic:** capture the single defender.
- **Failure pattern:** capturing/attacking anything else.

### 7. Forced interposition (sacrifice)  *(frontier)*
- **Feeling:** "I give one to save all." Bittersweet, decisive.
- **Visual shape:** offer a piece into the lane to stop mate, even though it can be taken.
- **Readability:** the sacrifice square is on the obvious lane; the "it's a sac" is
  felt, not calculated. No deep follow-up required — the *moment* is the rescue.
- **Rescue logic:** interpose on the lane (the point is stopping mate *now*).
- **Failure pattern:** refusing the sac / saving the piece instead.

### 8. Escape square  *(deferred)*
- **Feeling:** "I slip free."
- **Why deferred:** the king *moves*, which interacts with the failed-flash anchoring
  (the flash sits on the threatened-king square). Revisit when the failure visuals
  support a moving king. Documented for completeness, not for near-term authoring.

---

## Puzzle grammar (rules every template must satisfy)

So each instance reads in a glance, under pressure:

- **One visible threatened king** — the danger-glow anchor.
- **One (rarely two) visible attacker(s)** on a **clear lane** to the king — the
  "tension lane." No hidden / inferred threats.
- **Exactly one rescue line** (`rescueTo`) + **2–5 believable decoys** — moves that
  *look* plausible but don't save (tempting near-misses, not random noise).
- **One tappable rescuer** (`tappableSquare`) — the only interactive piece.
- **Clutter limit** — ≤ ~12 pieces; no dense knot adjacent to the action.
- **Lane clarity** — attacker→king line and the rescue's effect are visually
  unobstructed.
- **Board-side weighting** — the action cluster sits coherently (a corner or side),
  not smeared across the whole board.
- **Copy at archetype/template level, not per-square** — success copy is
  archetype-flavored ("KNIGHT CHECKS BACK", "SEAL THE LINE"), so geometric variation
  never produces wrong move notation. `rescueNotation` is non-load-bearing.
- **No multi-line calculation** — the rescue is one believable move; the *feeling*
  carries it, not depth. Banned: engine-only correctness, hidden tactics, calc trees.

A `PuzzleTemplate` = today's `Puzzle` fields **+** `archetype` **+** variation
metadata: legal transforms, cluster bounding box (for offset), decoy pool, and the
lane definition (attacker square → king square) used by readability scoring.

---

## Readability scoring (authoring/variation gate)

A **pure validation function** evaluated at authoring/variation time — **not at
runtime, not ML**. It is a **gate, not a generator**: it rejects instances that
aren't instantly legible, keeping the variation space inside the readable subset.
An instance must pass **all** dimensions to ship.

| Dimension | Pass condition (conservative heuristic) |
|---|---|
| **Threat visibility** | attacker is on a clear, unobstructed lane to the king |
| **Rescue clarity** | the rescue's effect is visible: lands on the lane / captures the attacker / checks back |
| **Clutter** | piece count ≤ limit; no decoys stacked so as to obscure the lane |
| **Visual balance** | cluster fits a sane bounding box; not jammed into a 2×2 corner knot |
| **Move discoverability** | the rescuer's legal-move dots are distinct, non-overlapping; the rescue dot is reachable |
| **Emotional immediacy** | the danger is readable in < ~2 seconds (few elements, one clear lane) |
| **Panic readability** | under glance-pressure, the threatened king + attacker visually pop |

Output: a per-dimension pass/fail + an overall score. Thresholds start
**conservative** and are paired with human authoring review — deliberately simple,
not a scoring rabbit hole. Failing instances are dropped before they reach a session.

**v1 implementation (Phase 19D, `lib/core/models/readability.dart`):** the dimensions
are computed as **pure geometric heuristics** — alignment-by-piece-type, Chebyshev
proximity, strict betweenness, knight-relation — with **no blocker/legality/engine
logic**. `threatVisibility` = a dark Q/R/B/N aligned-by-type with, or within 2 squares
of, the king. `rescueClarity` = the rescue captures the attacker, interposes on the
king's line, or counter-checks the enemy king. `clutter` ≤ 20 pieces; `visualBalance`
= bounding box ≥ 3×3; `moveDiscoverability` = 2–8 distinct moves incl. the rescue;
`emotionalImmediacy`/`panicReadability` are composites. All 5 base + 5 mirror pass;
broken puzzles fail. **Limitation:** with no explicit per-template *lane* metadata yet,
the gate infers the attacker/lane geometrically — a lenient v1; a later phase can add
explicit lane metadata for sharper scoring. A debug-only instance gallery
(`lib/debug/instance_gallery.dart`, separate entrypoint) renders base + mirror
instances with their verdict for visual review; it is absent from release builds.

---

## Authoring checklist (per new template)

1. Pick an archetype; write its archetype-level copy (danger / failure / success).
2. Lay out: threatened king, attacker(s) on one clear lane, the single rescuer, the
   one rescue square, 2–5 believable decoys, minimal context pawns (≤ ~12 total).
3. Define variation metadata: legal transforms, cluster bounding box, decoy pool.
4. Run it (and a few of its variations) through the readability gate; fix or drop.
5. Tag it for session pacing (opener / rising / mid / peak / finale energy).

See `replayability-architecture.md` for how templates become sessions.
