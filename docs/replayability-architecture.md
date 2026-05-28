# Replayability Architecture

> Status: **design (Phase 19A)**. Nothing in `lib/` changes yet. This document
> defines the system; implementation is sequenced in the roadmap at the end.

## The problem

The 5 handcrafted puzzles are emotionally strong but deterministic. Replayed,
they decay into memory recall — the player stops *feeling* the rescue and starts
*remembering the answer*. We need replayability that scales **without** turning
Chess Rescue into a tactics trainer, a random-puzzle app, or a Stockfish wrapper.

## The stance

**We do not generate chess positions. We compose emotional rescue situations.**

Replayability comes from **curated combinatorics**, not generation:

> hand-authored templates  ×  deterministic, readability-gated variations  ×  emotionally-paced sessions

Every instance the player ever sees is hand-validated *by construction*. There is
no engine, no procedural search, no runtime randomness chaos, no difficulty ladder.

The product identity stays fixed: **pressure → insight → rescue → relief**, and the
felt result is *"I survived,"* never *"I solved a hard chess problem."*

## The unit hierarchy

```
Archetype          the emotional rescue category — the FEELING + the rescue-logic shape
   └─ Template     a hand-authored concrete situation of that archetype
        └─ Variation        a deterministic, seeded transform (mirror / offset / decoy / density)
             └─ Instance     == today's Puzzle model, produced by applyVariation()
                  └─ Session a short, ordered, emotionally-paced selection of instances
```

- **Archetype** — see `rescue-archetypes.md`. ~6–8 categories (counter-check,
  capture-attacker, block-file, seal-diagonal, remove-defender, …). Defines feeling
  + rescue logic, not geometry.
- **Template** — a `PuzzleTemplate`: today's `Puzzle` fields **plus** an `archetype`
  tag and variation metadata (legal transforms, cluster bounding box, decoy pool,
  lane definition). The 5 current puzzles become the first templates.
- **Variation** — a tiny deterministic spec `(templateId, mirror, offset, decoySet,
  density)`. `applyVariation(template, variation)` transforms *all* square
  coordinates consistently and re-derives `legalMoves`/`rescueTo`.
- **Instance** — exactly the existing `Puzzle` model. Nothing downstream knows it
  was generated.
- **Session** — a `List<Puzzle>` chosen for an emotional arc (album sequencing).

## The seam (why the runtime never changes)

`GameController({List<Puzzle>? puzzles})` already consumes a `List<Puzzle>` and
exposes `currentPuzzle`/`_index`. **The entire UI, motion, haptics, and persistence
layer only ever sees a `List<Puzzle>`.** A `SessionComposer` produces that list.

```
SessionComposer(seed) ──▶ List<Puzzle> ──▶ GameController ──▶ (unchanged) RescueScreen
```

So this whole system slots in behind a single boundary. `Puzzle`, `GameController`'s
public surface, every widget, `MotionTokens`, `Haptics`, and `ProgressStore` are
**untouched**. The player can't see the architecture — they just stop running out of
fresh rescues.

## Variation system (same emotion, different geometry)

`applyVariation(template, variation) → Puzzle`, deterministic and pure.

| Transform | Effect | Why it's safe |
|---|---|---|
| **Mirror (horizontal)** | `file → 7 − file` for every piece/square | left/right feel flips; rescue stays valid (e.g. Nf6+ → its mirror) |
| **Board offset** | translate the whole cluster by `(dx, dy)` | same rescue in a new board region; today everything hugs g1 |
| **Decoy swap** | choose a different believable decoy set from the pool | changes texture, not the rescue |
| **Pawn-density** | add/remove a couple of context pawns | changes clutter feel within limits |

**Forbidden:** unreadable clutter, hidden tactical-only moves, multi-line calc
trees, engine-only correctness, random chaos.

**Deferred (identity stability):** *rotation* and *color inversion*. The invariant
**"you = light pieces, at the bottom"** is preserved so the player never loses track
of who they are. Revisit only if a strong reason emerges.

**Determinism & QA:** a variation is a finite tuple, so the valid-instance set is
**bounded and enumerable** → every instance is snapshot-testable. No infinite
generation, no unbounded QA surface.

**Validity guarantee:** after every transform, re-assert (cheap, on the transformed
squares) that (a) the rescue is still the unique whitelisted win and (b) the
attacker→king lane is unobstructed. Variations that fail are **dropped, not
shipped.**

## Copy is decoupled from geometry

Success/danger/failure copy lives at the **archetype/template** level, not per
square (e.g. success reads "KNIGHT CHECKS BACK", not "Nf6+"). This means geometric
variation can never produce wrong notation. `Puzzle.rescueNotation` becomes
optional/derived, not load-bearing.

## Readability scoring (the anti-drift guardrail)

A **pure validation function**, run at authoring/variation time (not runtime, not
ML). It is a **gate, not a generator** — its only job is to reject instances that
aren't instantly readable, keeping the combinatorial space inside the
"emotionally readable" subset. Dimensions: threat visibility, rescue clarity,
clutter, visual balance, move discoverability, emotional immediacy, panic
readability (full rubric in `rescue-archetypes.md`). An instance must pass **all**
gates to enter the playable set. This is the single most important mechanism
keeping the product from drifting into a generic tactics app.

## Session composition (album sequencing, not level progression)

A session is a short (~5) ordered list following an emotional arc, deterministic
per seed:

1. **Opener** — simple, visible rescue (low load, re-enter the loop)
2. **Rising** — aggressive counter-check (tension spike)
3. **Mid** — a line-seal / interposition (spatial beat)
4. **Peak** — queen-panic / capture-the-heavy-attacker (max pressure)
5. **Finale** — calm, clean rescue (resolution → "the board is quiet now")

`SessionComposer(seed)` rules: hit the arc; never two same-archetype back-to-back;
vary the rescuer piece-type; only pick readability-passing instances; keep it short
(mobile rhythm). Seeded → reproducible, which enables a future daily session with no
new architecture. Think album sequencing, not a difficulty ladder.

**v1 (19E):** the arc maps to the current taxonomy as opener = capture-minor,
rising = counter-check, middle = interpose (block-file / seal-diagonal), peak =
capture-heavy (queen), finale = the other interpose. Each archetype appears once
(no back-to-back); the two interposes sit at middle + finale (separated by the peak),
seed choosing their order; each slot is base-or-mirror forced to a mix. It is
**preview-only** — not wired into the runtime (mirrored copy is not geometry-safe;
see the roadmap entry below).

## Worked example (proving the model on paper)

Take the current **knight rescue** (counter-check archetype): white K g1, black
threatens mate, white N e4 plays Nf6+.

- **Mirror:** files flip (`f→7−f`). King g1→b1, knight e4→d4, rescue square
  f6→c6. The knight still checks the mirrored enemy king; unique rescue preserved;
  lane unobstructed → **passes**. Feels like a left-side rescue.
- **Offset (+0, none) / decoy swap:** keep geometry, swap two decoy destinations
  from the pool → same rescue, different "almost" temptations.
- **Offset that pushes the cluster off-board or a pawn into the knight's path** →
  validity/readability check **fails** → dropped.

Two readable, emotionally-identical-but-spatially-fresh instances from one template,
plus an automatically-rejected bad one. That is the whole system in miniature.

## Risks & pitfalls

- **Unsound transforms** → re-validate every instance; drop failures.
- **Copy/notation drift** → archetype-level copy; `rescueNotation` non-load-bearing.
- **Identity confusion** → "you = light, bottom" invariant; defer color/rotation.
- **Drift into tactics-trainer** → archetype taxonomy + readability gates optimize
  for *immediacy*; ban multi-line trees and engine-only correctness.
- **Sameness** → geometry transforms change spatial feel; emotional repetition per
  archetype is *intended* (replay a feeling, like a song).
- **Over-engineering readability** → simple heuristics + authoring review, not a
  scoring rabbit hole.
- **Combinatorial QA** → finite + deterministic → enumerate + snapshot-test.

## Implementation roadmap (each sub-phase independently shippable; runtime never changes)

- **19B — DONE.** `RescueArchetype` enum (`lib/core/models/rescue_archetype.dart`) +
  `PuzzleTemplate` (`lib/core/models/puzzle_template.dart`). The 5 puzzles are now
  `PuzzleLibrary.templates` (archetype-tagged); `PuzzleLibrary.all` is derived via the
  identity `toPuzzle()` seam → same 5 `Puzzle` instances, same order, zero behavior
  change. `GameController` is untouched. `toPuzzle()` is the seam 19C replaces with
  variation application.
- **19C — DONE (mirror).** `Variation` + pure `applyVariation()`
  (`lib/core/models/variation.dart`) with horizontal **mirror** (`file → 7 − file`,
  rank preserved; player stays light-at-bottom). No-op variation returns the same
  instance, so `PuzzleLibrary.all` is byte-identical. `validatePuzzle()`
  (`puzzle_validation.dart`) gates instances (bounds, unique squares, light piece on
  `tappableSquare`, `rescueTo ∈ legalMoves`, light king on `threatenedKing`).
  `PuzzleLibrary.mirrorVariants` exposes the 5 mirror instances (preview-only — `all`
  unchanged; no random selection / composer yet). Tests in `test/variation_test.dart`
  (11 cases): all 5 mirror variants validate; identity preserves instance; mirror is
  an involution. **Offset (`dx/dy`) is reserved, asserted-zero, not active.** Copy is
  preserved as-is (notation is geometrically stale on mirror — acceptable while
  variants are preview-only; decoupled before they ship).
- **19D — DONE.** `readabilityScore()` (`lib/core/models/readability.dart`) — the
  emotional-legibility gate (7 dimensions: threatVisibility, rescueClarity, clutter,
  visualBalance, moveDiscoverability, emotionalImmediacy, panicReadability), pure
  geometric heuristics (alignment / proximity / betweenness / knight-relation; no
  blockers, no engine). All 5 base + 5 mirror pass; obviously-broken puzzles fail
  (`test/readability_test.dart`). Debug instance gallery is a **separate entrypoint**
  `lib/debug/instance_gallery.dart` (run `flutter run -t lib/debug/instance_gallery.dart`)
  reusing `BoardWidget` — never imported by `lib/main.dart`, so it is tree-shaken out
  of the normal release artifact (release builds the default target). No in-app menu,
  no gameplay change.
- **19E — DONE (preview-only).** `SessionComposer.compose({templates, seed})`
  (`lib/core/models/session_composer.dart`) — deterministic, builds a paced
  5-puzzle session from the gated base+mirror pool (opener=capture-minor → rising=
  counter-check → middle=interpose → peak=win-queen → finale=interpose; each
  archetype once → no back-to-back; base/mirror forced to a mix). Same seed →
  identical session; different seeds vary the interpose order + base/mirror pattern.
  **Runtime is UNCHANGED:** `PuzzleLibrary.all`/`GameController` still ship the 5 base
  puzzles, because mirrored copy is **not geometry-safe** (15 square-specific strings
  in `statusText`/`rescueNotation`/`successExplanation` go stale on mirror). The
  composer is exposed preview-only (debug gallery shows seed-1/seed-2 sessions) and
  covered by `test/session_composer_test.dart`. **Prerequisite for runtime opt-in:** a
  geometry-safe-copy phase (decouple copy from squares — see 19A) so mirror variants
  can ship without stale notation. Persistence is untouched (no `#mirror` id reaches
  `ProgressStore`); how a `#mirror` completion maps to its base is deferred to that
  opt-in phase.
- **19F** — author more templates per archetype; tune readability thresholds.
- **Later** — optional daily-seed session (D5 cadence); reuses the seeded composer.

## Constraints honored

Preserves D4 restraint, board dominance, tactile pacing, no-scroll feel, emotional
minimalism, and the short-session mobile rhythm. Adds no UI, menus, progression,
currencies, or meta-game. No engine, no procedural generation, no difficulty/Elo.
