# Rescue Archetypes, Puzzle Grammar & Readability

> Status: **design (Phase 19A; family catalog extended Phase 22A)**. Companion to `replayability-architecture.md`.
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

### 8. Escape square  *(special category — Phase 22A)*
- **Feeling:** "I slip free." The king *itself* moves to the one safe square.
- **Visual shape:** the king is ringed by empty-but-enemy-covered squares; exactly one
  neighbor is safe. Visually open (passes "king not boxed"), emotionally sealed.
- **Readability:** requires the **Escape Support Layer (Tier 2)** — the danger anchor must
  follow the relocating king, attacked king-steps must be shaded, and a lightweight
  "is-this-square-attacked" check must verify a *unique* safe square.
- **Rescue logic:** move the king to the only uncovered safe square.
- **Failure pattern:** stepping onto a covered square, or trying to block/capture instead
  of fleeing.
- **Status:** reserved as a **rare cinematic spike**, not the default language — the
  stationary king stays dominant. See families A1–A3 in the catalog below.

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
  archetype-flavored, so geometric variation never produces wrong move notation.
  `rescueNotation` is non-load-bearing (internal metadata only).

  **Geometry-safe copy (Phase 20, shipped):** displayed fields carry no squares/notation.

  | Archetype | statusText (danger) | successExplanation |
  |---|---|---|
  | counterCheck | `▮ Active threat` | `THE KNIGHT STRIKES BACK` |
  | captureAttackerMinor | `▮ In check` | `THE CHECKER IS GONE` |
  | blockFile | `▮ Checked on the file` | `THE FILE IS SEALED` |
  | sealDiagonal | `▮ Checked on the diagonal` | `THE DIAGONAL IS CLOSED` |
  | captureAttackerHeavy | `▮ Checked on the rank` | `THE QUEEN FALLS` |

  Rescued status is the constant `◐ Attack broken`. "file/diagonal/rank" are
  mirror-invariant, so base and mirror display identical, correct copy.
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
   **Decoy pool (Phase 23B):** eligible templates carry `PuzzleTemplate.decoyPool` — extra
   *hand-vetted, honest* hero moves used by `applyDecoyTexture` to vary the wrong-move
   texture (preview-only). Every pool entry must be a real, believable move that does **not**
   resolve the danger (the gate can't verify this — it's piece-type/blocker-blind), e.g. B3
   excludes `f3`, B4 excludes `g4`, A4 excludes `e7`.
   **Scenery (Phase 23C):** eligible templates also carry `removableScenery` (cosmetic pieces
   safe to drop) + `sceneryPool` (addable context **pawns**) used by `applyScenery` for
   at-a-glance freshness (preview-only). Pawns only (the gate ignores pawns as attackers);
   every pool square must be empty and off every functional square + tension lane (slider →
   king/hero), and plausible (ranks 2–7).
4. Run it (and a few of its variations) through the readability gate; fix or drop.
5. Tag it for session pacing (opener / rising / mid / peak / finale energy).

See `replayability-architecture.md` for how templates become sessions.

---

## Rescue family catalog — Phase 22A (design)

The shipped 5 families cluster on **capture / block / seal / counter-check** with a
stationary king. Phase 22A widens the *emotional language* with ~12 handcrafted families
across three feelings. This is a **design catalog, not positions** — no concrete boards.

**Direction:** the **stationary king stays the dominant language**; king-movement rescues
(Set A's true escapes) are **rare cinematic spikes**, a special category. Design the full
emotional range now and flag the system work each family needs (tiers below).

Tag per family: `[archetype · king-state · tier]`. Tiers: **T1** authorable today (no
system change), **T2** needs the Escape Support Layer, **T3** needs the Calm/Deflection
readability branch (both detailed under "Implementation tiers").

### SET A — Panic Escapes
*The walls close; you don't fight, you flee. Find the one breath of air.*

**A1 · The Air Pocket** — `[escapeSquare · KING MOVES · T2]`
- **Feeling:** claustrophobia breaking into a single gasp of air.
- **Shape:** king ringed by empty squares; 2–3 distant attackers cover all neighbors but one.
- **Rescue:** king steps to the only neighbor no enemy covers.
- **Failure:** stepping onto an empty-but-covered square; or blocking/capturing instead of moving.
- **Readability risk:** "covered but empty" danger is invisible — needs attacked-step shading so the one un-shaded exit reads.
- **Why different:** pure flight; the only act is the king's own survival.
- **Variation:** mirror-safe; offset-risky near edges (keep ≥1 off every edge); re-verify the single-safe-square invariant after each transform.
- **Mobile:** sparse and thumb-clear, but leans entirely on legible shading.

**A2 · The Corridor** — `[escapeSquare · KING MOVES · T2]`
- **Feeling:** running down a narrow hallway with something behind you; the exit is straight ahead.
- **Shape:** a slider bears down; an empty lane opens *away* from it.
- **Rescue:** king flees one step down the corridor, out of the slider's mating reach.
- **Failure:** a lateral step still in the net, or a step toward the slider.
- **Readability risk:** the corridor must read as a clean empty lane; side-square coverage must be shaded.
- **Why different:** kinetic relief — motion *away* — vs A1's static gasp.
- **Variation:** mirror-safe; corridor length gives offset room if not edge-anchored.
- **Mobile:** a long thin empty lane parses instantly; the king's slide sells the escape.

**A3 · The Cold Doorway** — `[escapeSquare · KING MOVES · T2]`
- **Feeling:** courage against instinct — the only shelter is the scariest-looking square.
- **Shape:** obvious flight squares are covered; the safe square sits inside the enemy formation (a knight's blind spot, behind a pawn).
- **Rescue:** king steps *into* the scary square the attacker can't actually reach.
- **Failure:** fleeing to the open-looking far square (covered); refusing the counterintuitive one.
- **Readability risk:** highest of the escapes — the safe square *looks* unsafe; needs shading + extreme restraint.
- **Why different:** relief through counter-instinct courage — surprising, memorable.
- **Variation:** mirror-safe; most fragile under offset (leans on a specific enemy's geometry).
- **Mobile:** absolute minimum pieces, or the surprise doesn't land.

**A4 · The Breakaway** — `[counterCheck (escape flavor) · KING STATIONARY · T1]`
- **Feeling:** a hunted piece bolts free *and* turns to strike — escape + defiance in one leap.
- **Shape:** a key white piece is forked while the king is also threatened, on two clear separate lines.
- **Rescue:** the hunted piece leaps to a square that escapes capture *and* checks; the forced reply breaks the king's threat.
- **Failure:** fleeing to a quiet safe square (king's threat still lands); a checking square that's covered.
- **Readability risk:** two ideas at once (escape + check) — keep the king-line and hunter-line distinct.
- **Why different:** escape *feeling* with a stationary king — bridges Set A and Set B.
- **Variation:** gate-compatible today; mirror-safe.
- **Mobile:** ≤10 pieces so both lines stay legible.

### SET B — Heroic Counters
*You don't run. You strike back — often by giving something up.*

**B1 · The Martyr** — `[forcedInterposition (sacrificial) · KING STATIONARY · T1]`
- **Feeling:** "take me, not the king." A noble piece throws itself into the line to die.
- **Shape:** a slider checks down a lane; a *valuable* white piece interposes, visibly undefended.
- **Rescue:** interpose on the lane — the check breaks now; the coming capture is beside the point.
- **Failure:** a move that doesn't fully block; or "saving" the valuable piece and losing the king.
- **Readability risk:** geometrically identical to P3/P4 — the sacrifice must be carried by copy + the visible value of the offered piece.
- **Why different:** blocks feel safe/clever; the Martyr feels costly. Same move type, opposite emotion.
- **Variation:** gate-compatible today; mirror/offset-safe like P3/P4.
- **Mobile:** proven interposition geometry; only the emotional read is new.

**B2 · The Lure** — `[deflection (NEW) · KING STATIONARY · T3]`
- **Feeling:** misdirection — "look over here." Dangle bait the attacker can't refuse.
- **Shape:** the mating attacker can be deflected; a white move makes a forcing threat elsewhere.
- **Rescue:** the deflecting move forces the attacker off the mating line → the threat dissolves.
- **Failure:** a threat the attacker can *ignore* (not forcing); or grabbing the bait yourself.
- **Readability risk:** "why it works" depends on the enemy's forced reply — risks feeling like 2 moves; must be clearly forcing.
- **Why different:** you win by making the *enemy* move wrong — indirection.
- **Variation:** needs new deflection logic; a check-flavored Lure fits counterCheck today.
- **Mobile:** two foci (lure target + king) — keep in one glance.

**B3 · Remove the Defender** — `[removeDefender (enum exists) · KING STATIONARY · T1*]`
- **Feeling:** dismantling — the attack stands on one prop; kick it out and it collapses.
- **Shape:** a dark attacker threatens mate, sustained by exactly ONE defender.
- **Rescue:** capture that lone defender; the attacker is now unsupported / its mate refuted.
- **Failure:** capturing the attacker directly (still defended → recapture); or taking the wrong piece.
- **Readability risk:** the gate sees a capture and passes *structurally* but can't verify the defender is the keystone — needs authoring discipline (and later a "threat actually defused" check). Avoid boards where several captures look equal.
- **Why different:** two-step logic compressed into one strike — reading the enemy's structure.
- **Variation:** *authorable now with care*; mirror/offset-safe.
- **Mobile:** keep the defender→attacker→king chain visible; ≤11 pieces.

**B4 · The Cross-Check** — `[counterCheck (cross-check flavor) · KING STATIONARY · T1]`
- **Feeling:** defiant reversal — answer a check with a check that's also a shield.
- **Shape:** enemy checks; a white move blocks *and* gives check (interpose-with-check or discovery).
- **Rescue:** the block-that-checks escapes check and seizes the initiative in one move.
- **Failure:** blocking without checking (passive); checking without blocking (still in check — illegal).
- **Readability risk:** two king-lines in one move — keep clean and separate.
- **Why different:** defend AND attack in the *same* move — distinct from P1's pure counter-check.
- **Variation:** gate-compatible today; mirror-safe.
- **Mobile:** low piece count for one-glance parsing.

### SET C — Calm Intelligence
*No panic, no violence — a quiet, almost invisible move defuses everything.*

**C1 · The Vent** — `[quietDefense / luft (NEW) · KING STATIONARY · T3]`
- **Feeling:** a held breath released — a tiny move opens air for the king; the threat silently dies.
- **Shape:** back-rank box: the king is hemmed by its OWN pieces/the edge; a quiet pawn nudge opens a flight square.
- **Rescue:** push the pawn (no capture, no check) — the would-be mate now has an answer, so it never works.
- **Failure:** trying to capture/block the attacker; or moving the wrong pawn.
- **Readability risk:** the win is the *absence* of a future event — nothing visibly happens; needs copy + a flight-square highlight.
- **Why different:** the quietest possible win — anti-climax as relief.
- **Variation:** needs T3 quiet-move logic; back-rank versions are edge-anchored → offset-risky.
- **Mobile:** risk of "did I do anything?" — lean on the highlight + copy.

**C2 · The Invisible Wall** — `[guardSquare / invisibleDefense (NEW) · KING STATIONARY · T3]`
- **Feeling:** a shield appears from nowhere — no clash, the attack just can't land.
- **Shape:** the attacker wants one mating square; a white piece quietly moves to *guard* it (not block the lane, not capture).
- **Rescue:** cover the target square so any arrival is recaptured → mate refuted before it happens.
- **Failure:** blocking the lane (wrong square); guarding the wrong square; an irrelevant capture.
- **Readability risk:** the defended square is *off* the obvious lane — needs a threat-square concept + highlight.
- **Why different:** defense without confrontation — you change nothing visible yet win.
- **Variation:** needs T3 "guards the threat square" logic + `threatSquare` metadata; mirror-safe.
- **Mobile:** must highlight the contested target square, or the move is opaque.

**C3 · The Unpin** — `[unpin (NEW) · KING STATIONARY · T3]`
- **Feeling:** a paralyzed ally wakes up — free a frozen defender and it springs back to guard.
- **Shape:** a white defender is pinned (can't move without exposing the king), so it isn't truly guarding; a quiet move removes the pin.
- **Rescue:** unpin (block the pinning line / guard behind the pinned piece); the freed piece now defends the threatened square.
- **Failure:** moving the pinned piece itself (loses king); addressing the wrong line.
- **Readability risk:** a pin is an invisible relationship — needs pin-visualization. The most chess-literate family.
- **Why different:** you fix the *board*, not the threat directly — cerebral restoration.
- **Variation:** needs T3 unpin logic + pin metadata; mirror-safe.
- **Mobile:** highest chess-knowledge demand — keep rare and heavily telegraphed, or it tilts toward trainer.

**C4 · The Long View** — `[prophylaxis (NEW) · KING STATIONARY · T3]`
- **Feeling:** foresight, total calm — see where the storm will land and take that ground first.
- **Shape:** the attacker needs ONE key square to begin; a white piece quietly occupies/controls it first.
- **Rescue:** take/cover the key square → the assault can never start.
- **Failure:** reacting to the present instead of the future square; covering the wrong one.
- **Readability risk:** the threat isn't live yet — clashes with "you are in danger NOW"; hardest to make feel urgent.
- **Why different:** winning *before* the fight — pure intelligence, the far pole from Set A's panic.
- **Variation:** needs T3 prophylaxis logic + "attacker's key square" metadata; mirror/offset-safe.
- **Mobile:** must manufacture visible tension for a threat that hasn't happened — use sparingly.

### Archetype taxonomy changes (proposed)

Consumes the frontiers and adds new shapes (enum **not** edited in this phase):
- **Activate:** `escapeSquare` (A1–A3), `forcedInterposition` (B1), `removeDefender` (B3).
- **Add:** `deflection` (B2), `quietDefense` (C1), `guardSquare`/`invisibleDefense` (C2),
  `unpin` (C3), `prophylaxis` (C4).
- **Reuse:** `counterCheck` for A4 and B4 — split out `crossCheck` later if the gate logic diverges.

### Implementation tiers

All extensions stay **geometric/heuristic — no engine**, per the product guardrails.
- **T1 — authorable today, zero system change:** A4, B1, B4, B3 (*with care*). Stationary-king
  capture / interpose / counter-check rescues that pass the current gate.
  **DONE (Phase 22B)** — authored as `PuzzleLibrary.expansionTemplates`
  (`a4-the-breakaway`, `b1-the-martyr`, `b3-remove-the-defender`, `b4-the-cross-check`),
  gated by `test/expansion_families_test.dart` (validation + readability + copy-safety +
  mirror) and shown in the debug gallery.
  **WIRED (Phase 22C)** — surfaced in live composed sessions (seed >= 1) via the
  multi-template `SessionComposer`: A4/B4 in the rising slot, B1 in the interpose slot, B3 in
  the reframed "high-stakes resolution" peak. Canonical-anchored (opener + finale locked,
  <= 2 expansion middles → >= 3/5 canonical); seed-0 onboarding unchanged.
- **T2 — Escape Support Layer** (A1–A3): danger anchor follows the relocating king; a
  `rescueClarity` "escape" branch (rescue = empty, king-legal, not attacked, *uniquely* safe);
  an attacked-square shading overlay; a lightweight "is-square-attacked" check.
- **T3 — Calm/Deflection branch** (B2, C1, C2, C3, C4): `threatSquare` (+ pin / key-square /
  forced-reply) metadata on `Puzzle`; `rescueClarity` branches for quiet / guard / deflection /
  unpin / prophylaxis; highlights for the contested/target/key square.

**Identity risks to watch:** Unpin (C3) and Long View (C4) flirt with "chess literacy" — keep
rare, telegraph hard. The Lure (B2) and the quiet families (C1/C2/C4) win via something that
*doesn't* happen or the enemy's reply — telegraph so the rescue still reads as one clean
insight, not a calculated sequence.
