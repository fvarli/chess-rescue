# Composer Audit Report

> **Status.** Investigation-only deliverable. No code changed; no
> commits made. The audit subject (`SessionComposer` in
> `lib/core/models/session_composer.dart`) is untouched. Empirical
> numbers are reproduced verbatim from the existing deterministic
> test `test/endless_exposure_analysis_test.dart` (1000 seeds /
> 5000 puzzle slots; sample re-run for this audit matches Sprint
> V1 Phase 3d output bit-for-bit).
>
> Scope is Endless mode by lead direction. Episode-mode reach is
> noted as a one-column annotation in §3 but not analyzed
> separately — canonical-episode pools are hand-picked in
> `episode_library.dart` and so the suppression problem the lead
> asked about lives entirely in Endless composition.

---

## §1. Executive summary

The Chess Rescue puzzle library contains **11 puzzles** today: 5
canonical (`PuzzleLibrary.templates`) and 6 expansion
(`PuzzleLibrary.expansionTemplates`). `SessionComposer.compose()`
runs the Endless mode and emits 5-puzzle sessions; over a 1000-seed
sample (5000 puzzle slots), **10 of 11 puzzles surface** and **1 is
categorically unreachable**:

- **`cam1-knight-takes-bishop` (`captureAttackerMinor`, expansion):
  0.00%.** Suppressed by the **opener-slot canonical lock** at
  `session_composer.dart:189` (`openerCands.first`) combined with
  the **byArchetype population order** at
  `session_composer.dart:139` (`[...templates, ...expansion]`). The
  canonical P2 is always at index 0 of
  `byArchetype[captureAttackerMinor]`; the opener slot is the only
  slot in the pipeline that admits `captureAttackerMinor` at all.
  CAM1 has no other path into a session.

The remaining ten puzzles split into three reachability tiers
(§4): high (canonical anchors P2/P3/P4/P5 + canonical-cap-favored
P1, 5.94–20%), medium (single-expansion-per-archetype B1/B3, ~8–9%),
and low-but-healthy (rising-slot 4-way share P1/A4/B4/CC2 plus
expansion siblings, 4.5–5%).

**"+50 puzzles" answer (§7).** If 50 new expansion puzzles are
added uniformly across the 8 `RescueArchetype` values, roughly
**~38 would be reachable** at small per-puzzle session-wide share
(typically 0.5–1.5%), and **~12 would be unreachable** — the ~6
puzzles authored as `captureAttackerMinor` (opener lock) plus the
~6 authored as `escapeSquare` (no slot in any
`candidates(...)` call). The single most leveraged change to
unblock expansion content is fixing the **opener-slot canonical
lock**; see §6 for three tiers of options.

The recommendations in §6 are **proposals**, not commitments. No
fix is implemented in this sprint per the lead's directive.

---

## §2. Composition pipeline map

### §2.1 Entry points (production)

Three production call sites reach the composer; one debug surface
also exercises it.

```
                  ┌─ PuzzleLibrary.session(seed)                                        ─┐
                  │      lib/core/models/puzzle_library.dart:125–131                     │
                  │      seed == 0 → canonical `all`                                     │
                  │      seed ≥ 1 → SessionComposer.compose(...)                         │
                  │                                                                      │
   GameController ┼─ ctor: SessionComposer.composeEpisode(...)                           ─┤
                  │      lib/features/rescue_game/game_controller.dart:26                │
                  │                                                                      │
                  ├─ Endless rotation: SessionComposer.composeEpisode(..., seed += 1)    ─┤
                  │      lib/features/rescue_game/game_controller.dart:381               │
                  │                                                                      │
                  └─ resetProgress: SessionComposer.composeEpisode(..., seed: 0)         ─┘
                         lib/features/rescue_game/game_controller.dart:424

   (debug only) lib/debug/instance_gallery.dart:53–54 — PuzzleLibrary.session(1) / (2)
```

All four ultimately funnel through one of two composer methods:

- `SessionComposer.composeEpisode(episode: …, …)` — episode-aware
  dispatcher (canonical / master / endless).
- `SessionComposer.compose(templates: …, expansion: …, seed: …)` —
  the 5-slot Endless pipeline (also reached via
  `composeEpisode(EpisodeKind.endless)`).

### §2.2 `composeEpisode()` routing (lines 38–52)

```dart
// session_composer.dart:38–52
static List<Puzzle> composeEpisode({
  required Episode episode,
  required List<PuzzleTemplate> templates,
  List<PuzzleTemplate> expansion = const [],
  required int seed,
}) {
  switch (episode.kind) {
    case EpisodeKind.canonical:
      return _composeCanonicalEpisode(episode, templates, expansion, seed);
    case EpisodeKind.master:
      return _composeMasterEpisode(episode, templates, expansion, seed);
    case EpisodeKind.endless:
      return compose(templates: templates, expansion: expansion, seed: seed);
  }
}
```

For canonical and master kinds, the pool is the episode's
hand-picked `canonicalPuzzleIds` from `episode_library.dart`. Those
lists do not include CC2 or CAM1 today and are not modified by this
audit. The audit's analytical surface is `compose()` (the Endless
path).

### §2.3 `compose()` — the 5-slot Endless pipeline (lines 129–235)

#### §2.3.1 `byArchetype` population order (lines 138–141)

```dart
// session_composer.dart:138–141
final byArchetype = <RescueArchetype, List<PuzzleTemplate>>{};
for (final t in [...templates, ...expansion]) {
  byArchetype.putIfAbsent(t.archetype, () => []).add(t);
}
```

Canonical templates iterate first because `templates` precedes
`expansion` in the spread. **For every archetype that has both a
canonical entry and one or more expansion entries, the canonical is
deterministically at index 0** and is the entry that
`.first`-locked slots resolve to.

A `candidates()` helper (lines 142–144) concatenates per-archetype
lists in the order requested:

```dart
// session_composer.dart:142–144
List<PuzzleTemplate> candidates(List<RescueArchetype> archs) => [
  for (final a in archs) ...?byArchetype[a],
];
```

The order of `archs` matters: when a slot accepts two archetypes
(middle, peak), the first archetype's pool is prepended.

#### §2.3.2 The five slots (lines 156–194)

```dart
// session_composer.dart:156–166
final openerCands = candidates([RescueArchetype.captureAttackerMinor]);
final risingCands = candidates([RescueArchetype.counterCheck]);
final middleCands = candidates([
  middleInterpose,
  RescueArchetype.forcedInterposition,
]);
final peakCands = candidates([
  RescueArchetype.captureAttackerHeavy,
  RescueArchetype.removeDefender,
]);
final finaleCands = candidates([finaleInterpose]);
```

`middleInterpose` and `finaleInterpose` are split by a coin flip
above (lines 148–154):

```dart
// session_composer.dart:148–154
final interposeSwap = rng.nextBool();
final middleInterpose = interposeSwap
    ? RescueArchetype.blockFile
    : RescueArchetype.sealDiagonal;
final finaleInterpose = interposeSwap
    ? RescueArchetype.sealDiagonal
    : RescueArchetype.blockFile;
```

So the middle slot accepts `{blockFile|sealDiagonal}` ∪
`forcedInterposition`; the finale slot accepts the OTHER member of
`{blockFile, sealDiagonal}`. Per-session the two interpose
archetypes are exclusive — one is middle, the other is finale.

Slot allocation (lines 188–194):

```dart
// session_composer.dart:188–194
final chosen = <PuzzleTemplate>[
  openerCands.first,            // opener — canonical-locked, simple/readable
  risingCands[risingIdx],       // rising — counter-check / breakaway / cross-check
  middleCands[middleIdx],       // middle — interpose (block / seal / martyr)
  peakCands[peakIdx],           // peak  — high-stakes resolution
  finaleCands.first,            // finale — canonical-locked, the other interpose
];
```

`risingIdx`, `middleIdx`, `peakIdx` are uniform draws over their
candidate lists (lines 169–171):

```dart
// session_composer.dart:169–171
var risingIdx = rng.nextInt(risingCands.length);
var middleIdx = rng.nextInt(middleCands.length);
var peakIdx = rng.nextInt(peakCands.length);
```

#### §2.3.3 Canonical-anchored cap (lines 173–186)

```dart
// session_composer.dart:173–186
// Canonical-anchored cap: at most two of the three middle slots may be an
// expansion family (index != 0). If all three are expansion, revert one
// (seed-chosen) to its canonical anchor so >= 1 middle stays canonical and
// the session is always >= 3/5 canonical (with the locked opener + finale).
if (risingIdx != 0 && middleIdx != 0 && peakIdx != 0) {
  switch (rng.nextInt(3)) {
    case 0:
      risingIdx = 0;
    case 1:
      middleIdx = 0;
    default:
      peakIdx = 0;
  }
}
```

This is the only mechanism that re-shapes a randomized slot after
draw. **It systematically biases canonical anchors upward** at the
expense of all expansion siblings in the same archetype list.

Effective firing rate today: `risingCands.length = 4` (so 3/4
chance `risingIdx != 0`), `middleCands.length = 2` either way (so
1/2 chance `middleIdx != 0`), `peakCands.length = 2` (so 1/2 chance
`peakIdx != 0`). Product = **3/16 ≈ 18.75% of sessions**, with the
re-targeted slot a uniform 1/3 among rising/middle/peak.

#### §2.3.4 Base/mirror forced mix (lines 196–199)

```dart
// session_composer.dart:196–199
final useMirror = [for (var i = 0; i < chosen.length; i++) rng.nextBool()];
if (useMirror.every((m) => m)) useMirror[0] = false;
if (useMirror.every((m) => !m)) useMirror[0] = true;
```

Affects geometry only. Template choice is already locked above. No
visibility impact.

#### §2.3.5 Texture seed assignment (lines 201–229)

```dart
// session_composer.dart:201–209 (excerpt)
final texturedCount = rng.nextInt(3);          // 0, 1, or 2 middle slots
final picked = ([1, 2, 3]..shuffle(rng)).take(texturedCount).toSet();
```

Per the in-code comment at lines 204–205: *"Drawn after the 22C
draws so template + mirror selection is unchanged."* Texture
operates entirely on the chosen template; it cannot rescue a
suppressed expansion entry or further suppress a chosen one.

#### §2.3.6 `_instance()` graceful degradation (lines 240–262)

```dart
// session_composer.dart:240–262 (excerpt)
final attempts = <Puzzle Function()>[
  () => t.toTexturedPuzzle(variation: v, textureSeed: textureSeed, scenerySeed: scenerySeed),
  () => t.toTexturedPuzzle(variation: v, textureSeed: textureSeed),
  () => t.toTexturedPuzzle(variation: v),
  () => t.toPuzzle(),
];
for (final make in attempts) {
  final p = make();
  if (_ok(p)) return p;
}
return t.toPuzzle();
```

All four attempts operate on the **same template `t`** — degradation
relaxes texture/mirror, not template choice. If every attempt
fails, the canonical base of the chosen template is returned. No
fallback to a different template. **Visibility-neutral.**

### §2.4 Episode composers (lines 54–117)

- `_composeCanonicalEpisode` (lines 54–91) reads
  `episode.canonicalPuzzleIds`; seed 0 returns the authored pool
  verbatim, seed ≥ 1 applies forced-mix mirror and optional
  middle-slot texture.
- `_composeMasterEpisode` (lines 93–117) mirrors every slot and
  optionally textures only the middle.

Both pull from `episode.canonicalPuzzleIds`, which today never
references CC2 or CAM1. Visibility for Endless-only expansion is
unaffected by these methods.

### §2.5 Non-findings

- **No deduplication logic.** Sessions never check or guard against
  recently-played puzzles. Seed selection is stateless.
- **No recency penalty.** No persisted "seen-recently" set is
  consulted.
- **No archetype weighting.** Uniform `rng.nextInt(...)` per
  candidate list.
- **No expansion blocklist.** Expansion entries are first-class
  inside `byArchetype` once the lead-cap rules above resolve.
- **No locale / progression / streak gating** at the composer
  layer. The composer is pure given (templates, expansion, seed).

---

## §3. Per-puzzle visibility table

Endless slot eligibility column legend:
- `O` opener (line 189) — `.first`-locked to index 0 of `captureAttackerMinor`.
- `R` rising (line 190) — uniform on `counterCheck`.
- `M` middle (line 191) — uniform on `{blockFile|sealDiagonal}` ∪ `forcedInterposition`.
- `P` peak (line 192) — uniform on `captureAttackerHeavy` ∪ `removeDefender`.
- `F` finale (line 193) — `.first`-locked to index 0 of `{blockFile|sealDiagonal}`.

`Index` is the position of the puzzle inside `byArchetype[its-archetype]` — index 0 wins all `.first`-locked slots.

| id | archetype | pool | episode reach | Index | Slot eligibility | Empirical % | Reachable? |
|---|---|---|---|---|---|---|---|
| `p1-knight-rescue` | counterCheck | canonical | Ep1, Ep4 | 0 | R | **5.94%** | Reachable (rising; canonical-cap boost) |
| `p2-take-the-checker` | captureAttackerMinor | canonical | Ep2 | 0 | O | **20.00%** | Reachable (opener anchor — appears in every session) |
| `p3-block-the-file` | blockFile | canonical | Ep3 | 0 | M, F | **15.72%** | Reachable (M when interposeSwap=true, F when interposeSwap=false) |
| `p4-seal-the-diagonal` | sealDiagonal | canonical | Ep3 | 0 | M, F | **15.88%** | Reachable (M when interposeSwap=false, F when interposeSwap=true) |
| `p5-win-the-queen` | captureAttackerHeavy | canonical | Ep2, Ep4 | 0 | P | **10.90%** | Reachable (peak; canonical-cap boost) |
| `a4-the-breakaway` | counterCheck | expansion | Ep1 | 1 | R | **4.54%** | Reachable (rising 4-way share) |
| `b1-the-martyr` | forcedInterposition | expansion | Ep3, Ep4 | 0 | M | **8.40%** | Reachable (sole forcedInterposition; M slot in every session) |
| `b3-remove-the-defender` | removeDefender | expansion | Ep2 | 0 | P | **9.10%** | Reachable (peak; sole removeDefender) |
| `b4-the-cross-check` | counterCheck | expansion | Ep1 | 2 | R | **4.58%** | Reachable (rising 4-way share) |
| `cc2-bishop-captures-shield` | counterCheck | expansion | Endless-only | 3 | R | **4.94%** | Reachable (rising 4-way share) |
| `cam1-knight-takes-bishop` | captureAttackerMinor | expansion | Endless-only | 1 | O | **0.00%** | **NOT reachable** — opener `.first` locks to P2; no other slot accepts this archetype |

Column sanity check: percentages sum to 100.00% (sample
normalization: 5000 puzzle slots over 1000 seeds × 5 slots).
**Eligibility ≠ reachability** — CAM1's eligibility column lists
`O` because the opener is the only archetype-matching slot, but
the `.first` lock means CAM1's *effective* reachability there is
0.

---

## §4. Reachability classification

### §4.1 Never appears (the suppression case)

- **`cam1-knight-takes-bishop`** — 0/5000 slots in the empirical
  sample. Root cause is the **archetype × `.first` lock**
  interaction:
  - The opener slot is the only slot accepting
    `captureAttackerMinor`.
  - That slot is hard-locked to `openerCands.first`.
  - Canonical templates iterate first into `byArchetype`, so P2 is
    index 0 of `byArchetype[captureAttackerMinor]`. CAM1 is index 1.
  - There is no second admission point for this archetype.
- **Future hypothetical: any expansion `escapeSquare`** — the
  archetype is defined in `RescueArchetype` (line 12 of
  `rescue_archetype.dart`) but appears in **zero** `candidates(...)`
  calls in the composer. An `escapeSquare` template would be
  unreachable in Endless regardless of `.first` lock; it is
  unreachable by absence of any slot.

### §4.2 Significantly below peers (dilution, not suppression)

- **`a4-the-breakaway`** (4.54%), **`b4-the-cross-check`** (4.58%),
  **`cc2-bishop-captures-shield`** (4.94%) — each takes ~1/4 of the
  rising slot (4 candidates, uniform draw). Expected ~5%; observed
  in line. P1 (5.94%) sits slightly above by virtue of the
  canonical-anchored cap (§2.3.3) — when the cap fires (~3/16 of
  sessions) and the seed picks "rising" (1/3 of those), `risingIdx`
  is forced to 0 → P1.
- These are not suppressed — they are operating at the
  mathematical share the slot allocates them.

### §4.3 Appears at canonical-anchor frequency

- **`p2-take-the-checker`** (20.00%) — opener `.first` anchor, every
  session.
- **`p3-block-the-file`** (15.72%) and **`p4-seal-the-diagonal`**
  (15.88%) — finale `.first` in 50% of sessions plus middle-slot
  share in the other 50% (1-of-2 middle candidates when their
  archetype is the active `middleInterpose`). Plus a small
  canonical-cap boost.
- **`p5-win-the-queen`** (10.90%) — peak slot 1-of-2 candidates (50%
  baseline) plus canonical-cap boost.
- **`b1-the-martyr`** (8.40%) — middle slot, 1-of-2 candidates in
  every session (forcedInterposition is always in `middleCands`
  regardless of `interposeSwap`). Suppressed slightly by
  canonical-cap dragging share toward P3/P4.
- **`b3-remove-the-defender`** (9.10%) — peak slot 1-of-2; symmetric
  with P5 but loses ~1.8% to the cap.
- **`p1-knight-rescue`** (5.94%) — rising 1-of-4 baseline (~5%) plus
  cap boost (~1%).

---

## §5. Suppression mechanism per case

### §5.1 CAM1 — opener `.first` lock × `byArchetype` canonical-first order

**Code path.**

The composer admits `captureAttackerMinor` candidates at one place
only (line 156):

```dart
// session_composer.dart:156
final openerCands = candidates([RescueArchetype.captureAttackerMinor]);
```

Then the opener slot is hard-locked to index 0 of that list (line
189):

```dart
// session_composer.dart:189
openerCands.first, // opener — canonical-locked, simple/readable
```

Index 0 is determined by population order at lines 138–141:

```dart
// session_composer.dart:138–141
final byArchetype = <RescueArchetype, List<PuzzleTemplate>>{};
for (final t in [...templates, ...expansion]) {
  byArchetype.putIfAbsent(t.archetype, () => []).add(t);
}
```

The spread `[...templates, ...expansion]` puts the five canonical
templates first. P2 (`p2-take-the-checker`,
`RescueArchetype.captureAttackerMinor`) is the only
`captureAttackerMinor` in `templates`, so it is the FIRST entry to
land in `byArchetype[captureAttackerMinor]` — index 0 forever.

CAM1, registered in `expansionTemplates`, lands at index 1.
`.first` never reaches it.

**No other admission.** A grep of `compose()` confirms no other
slot calls `candidates([..., captureAttackerMinor])`. The middle,
peak, rising, and finale slots all admit other archetypes only.
CAM1 has zero reachable slots.

### §5.2 Generalized form — any `.first`-locked-slot expansion

Two slots use `.first` (lines 189 and 193):

```dart
// session_composer.dart:189,193
openerCands.first,           // → byArchetype[captureAttackerMinor][0]
finaleCands.first,           // → byArchetype[finaleInterpose][0]
                             //   finaleInterpose ∈ {blockFile, sealDiagonal}
```

This generalizes to:

> **Any expansion `PuzzleTemplate` whose archetype is one of
> `{captureAttackerMinor, blockFile, sealDiagonal}` cannot enter
> the opener or finale slot.** It can only reach the middle slot,
> and only when its archetype matches the active `middleInterpose`
> (blockFile/sealDiagonal) or is `forcedInterposition` (Martyr is
> always in `middleCands`).

So:
- An expansion `captureAttackerMinor` has **zero reachable slots**
  (no middle admission for this archetype).
- An expansion `blockFile` or `sealDiagonal` reaches **middle only,
  in 50% of sessions** (the half where its archetype is the active
  `middleInterpose`).

### §5.3 Generalized form — archetype not in any `candidates(...)` call

```dart
// rescue_archetype.dart:4–13 (the enum, abbreviated)
enum RescueArchetype {
  counterCheck,
  captureAttackerMinor,
  blockFile,
  sealDiagonal,
  captureAttackerHeavy,
  removeDefender,
  forcedInterposition,
  escapeSquare, // deferred (king moves) — no template yet
}
```

`escapeSquare` is not referenced in any composer `candidates(...)`
call. A future `escapeSquare` expansion entry would be unreachable
in Endless **by archetype-slot omission**, distinct from the
`.first` lock pattern but structurally similar. The composer
treats archetype as a slot key; archetypes outside the key set are
silently dropped.

Documentation drift note: `rescue_archetype.dart` enum comments
mark `removeDefender` and `forcedInterposition` as "frontier — no
template yet" (lines 10–11), but both have shipped expansion
templates (B3 and B1). The comments are stale and not consulted by
any code path; flagged for cleanup in a future sprint (not in
scope here).

---

## §6. Recommendations — three tiers, NOT implementation

Each tier is sized by blast radius. None is implemented in this
sprint per directive. All tier names below are working titles for
the recommended approach, not formal labels.

### §6.1 Minimal fix — seed-gated opener relief

**Idea.** Replace `openerCands.first` with a low-probability seeded
swap so the canonical anchor still dominates but expansion siblings
get airtime:

```text
// pseudocode for §6 illustration only — NOT to be committed
opener = (rng.nextInt(4) == 0 && openerCands.length > 1)
    ? openerCands[1 + rng.nextInt(openerCands.length - 1)]
    : openerCands.first;
```

**Tradeoff matrix.**

- **Pros.** ~2-line diff. Preserves the "opener is the easy soft
  landing" pacing intent (canonical wins 75% of sessions).
  Unblocks CAM1 immediately (~5% session-wide reach with one
  expansion entry; falls to ~25/N% with N expansion entries).
- **Cons.** Asymmetric: only addresses opener. Finale `.first` lock
  stays. Any future expansion `blockFile`/`sealDiagonal` still
  shut out of finale. Doesn't address `escapeSquare` invisibility
  at all.
- **Tests that need to be re-baselined.** `test/session_composer_test.dart`
  "opener is canonical" invariant (the test asserts opener is always
  P2; that becomes "opener is captureAttackerMinor canonical in
  ≥75% of seeds"). `test/session_quality_test.dart` bookend-
  consistency check (lines ~79–94 per the prior exploration — needs
  the same softening). The "all 4 expansion families surface" test
  in session_composer_test (lines 173–191) doesn't need changing
  but would observe a 5th surface.

### §6.2 Moderate fix — uniform "canonical-anchor with relief"

**Idea.** Apply the §6.1 seed-gated relief to **both** `.first`-
locked slots (opener AND finale), and audit the relief rate so it
composes correctly with the canonical-anchored cap (§2.3.3 — would
need recomputation so total canonical ratio per session still ≥ 3/5
in expectation, OR the cap rule needs relaxation).

**Tradeoff matrix.**

- **Pros.** Generalizes to any archetype that has only `.first`-locked
  admission. Frees both bookends symmetrically. Future expansion in
  `blockFile`/`sealDiagonal` can reach finale.
- **Cons.** Reshuffles the entire canonical-ratio expectation. The
  cap's invariant ("≥3/5 canonical per session") needs either an
  exception clause for the seed-gated bookend reliefs or a
  rebalanced rate. Two test files re-baselined; the
  `session_quality_test.dart` bookend-consistency assertion likely
  rewrites from "opener+finale are canonical" to a probabilistic
  bound.
- **Tests that need to be re-baselined.** `test/session_composer_test.dart`
  opener AND finale invariants. `test/session_quality_test.dart`
  bookend section. `test/runtime_session_test.dart` no-back-to-back
  rule needs re-verification (the bookend reliefs might
  accidentally place two same-archetype puzzles adjacent if
  middle-slot and finale-slot both land on `blockFile` — currently
  the canonical-locked finale prevents this).
- **Still does NOT address `escapeSquare`.** That requires §6.3.

### §6.3 Architectural fix — archetype-slot decoupling

**Idea.** Replace archetype-as-slot-key with pacing-arc-as-slot-key.
The composer would express its intent ("opener = soft landing",
"rising = building tension", "middle = interposition flavor",
"peak = high stakes", "finale = resolution") as **pacing tags**
on `PuzzleTemplate`. Archetype becomes a content classifier (for
Records, Records Sheet, content authoring guidance) but not a
selection key.

In pseudocode:

```text
// pseudocode for §6 illustration only — NOT to be committed
PuzzleTemplate {
  archetype: RescueArchetype.captureAttackerMinor,    // unchanged — for Records
  pacingTags: {PacingTag.softLanding, PacingTag.resolution},  // NEW
}
final openerCands = candidates(PacingTag.softLanding);
final risingCands = candidates(PacingTag.buildingTension);
...
```

**Tradeoff matrix.**

- **Pros.** Future-proof. Adding `escapeSquare` content no longer
  requires composer changes. Per-puzzle authoring decides which
  slots a template can occupy without piggy-backing on archetype.
  Content authoring gains explicit pacing intent. Decouples the
  Records (archetype-tagged) layer from the composer (pacing-
  tagged) layer.
- **Cons.** **Large.** Every `PuzzleTemplate` declaration touched.
  Every composer-pinned test rebaselined. The canonical-anchored
  cap rule probably re-expressed in pacing-tag language. Content
  authoring rules updated. Risk of accidentally re-pinning the
  same suppression by mis-tagging the new field.
- **Tests affected.** All composer-quality tests
  (`session_composer_test.dart`, `session_quality_test.dart`,
  `session_composer_episode_test.dart`,
  `runtime_session_test.dart`), the per-puzzle structural tests
  (`new_positions_v1_test.dart`, `expansion_families_test.dart`),
  any test reading `t.archetype` against expectations.
- **Recommended only if the lead anticipates 30+ more expansion
  puzzles across multiple new archetypes.** Otherwise §6.1 buys
  most of the practical benefit at 1% of the cost.

### §6.4 Composite recommendation

If the lead intends to ship more expansion content in 2026:

- **Now:** §6.1 (minimal opener relief). 1 PR.
- **Next:** §6.3 architecture decision, but only after a second
  motivating CAM-family candidate or an `escapeSquare` candidate
  creates real content pressure.

If the lead is content with the existing 11 puzzles plus occasional
counterCheck/peak additions:

- **Now:** **No change.** Constrain future content authoring to
  non-suppressed archetypes (`counterCheck`, `forcedInterposition`,
  `captureAttackerHeavy`, `removeDefender`, and `blockFile`/
  `sealDiagonal` for middle-slot-only acceptance).
- **Document the constraint** in `docs/rescue-archetypes.md` so
  future content authoring sees the limitation up-front (this is
  documentation work, not composer work).

The "do nothing now and constrain authoring" path is honored by
the existing test discipline — it does not require a sprint.

---

## §7. The "+50 puzzles" question

> **"If we add 50 more expansion puzzles today, would players
> realistically encounter them?"**

Below is an **arithmetic projection** from the current composer
logic (no stub templates, no test re-runs — closed-form per the
lead's locked clarification). Assume the 50 new puzzles are
distributed uniformly across the 8-archetype enum (~6 per
archetype). Per-puzzle session-wide share = (slot occupancy share) ×
(slot-slot-of-5 = 0.2 if slot fires every session, scaled if not).

### §7.1 Per-archetype projection

| Archetype | New count | Slot reached | New share per slot per session | Per-puzzle session-wide | Reachable? |
|---|---|---|---|---|---|
| `counterCheck` | 6 | rising (every session) | 1 / (4 existing + 6 new) = 10% × 1 slot | ~10% × 1/5 = **2.00%** | yes |
| `captureAttackerMinor` | 6 | opener (every session) | **0%** (`.first` lock; only P2 wins) | **0%** | **NO** |
| `blockFile` | 6 | middle in ~50% of sessions (finale `.first`-locked) | 1 / (1 + 6 + 1 + 6) ≈ 1/14 of middle when active | ~1/14 × 0.5 × 1/5 ≈ **0.71%** | yes |
| `sealDiagonal` | 6 | middle in ~50% of sessions | same as blockFile | ~**0.71%** | yes |
| `captureAttackerHeavy` | 6 | peak (every session) | 1 / (1 + 6 + 1 + 6) = 1/14 of peak | ~1/14 × 1/5 ≈ **1.43%** | yes |
| `removeDefender` | 6 | peak (every session) | same as captureAttackerHeavy | ~**1.43%** | yes |
| `forcedInterposition` | 6 | middle (every session) | 1 / 14 of middle | ~1/14 × 1/5 ≈ **1.43%** | yes |
| `escapeSquare` | 6 | **(none — archetype not in any `candidates(...)` call)** | **0%** | **0%** | **NO** |

Notes on the math:

- Middle-slot dilution assumes the active `middleInterpose` (blockFile
  or sealDiagonal) pools its candidates with `forcedInterposition`
  into a single `middleCands` list. With current authoring + 6 new
  per archetype, the list runs (1 canonical + 6 new) + (1 existing
  expansion B1 + 6 new) = 14 entries.
- Peak-slot dilution similarly: (1 canonical P5 + 6 new
  captureAttackerHeavy) + (1 existing B3 + 6 new removeDefender) =
  14 entries.
- The canonical-anchored cap (§2.3.3) fires ~3/16 of sessions and
  re-targets one of rising/middle/peak to index 0. With heavier
  expansion pools, the per-slot non-zero-index probability rises,
  so the cap fires MORE often (e.g. with 10-way rising, 9/10
  non-zero × ½ × ½ = 9/40 ≈ 22.5% — up from 18.75%). The cap's
  rescues redistribute frequency from new-expansion candidates back
  to canonical anchors. Projected per-puzzle numbers above are
  modest under-estimates by ~10-15%.
- These projections assume the per-puzzle template clears the
  validation + readability gate every time. The `_instance()`
  degradation logic (§2.3.6) doesn't change *which* template
  occupies a slot; it only changes the texture/mirror parameters.
  An authored template that fails both `validatePuzzle` and
  `readabilityScore` even at canonical-base attempt would never
  reach players — but that is a template defect, not a composer
  effect.

### §7.2 Headline answer

> Roughly **38 of the 50 new puzzles would be reachable** at a
> small per-puzzle session-wide share (typically 0.7–2.0%). The
> remaining **~12 would never surface** under the current composer
> logic: ~6 by `captureAttackerMinor` archetype (opener-lock
> suppression — the same mechanism that caps CAM1 today) and ~6 by
> `escapeSquare` archetype (no slot accepts this archetype). The
> exact split depends on how the author distributes the 50 across
> the enum; constraining authoring to the six reachable archetypes
> would lift the reachable count to 50 of 50 without composer
> changes.

---

## §8. Open questions / out of scope

Surfaced during the audit; explicitly NOT decided here.

1. **Should `escapeSquare` enter the composer at all?** The enum
   comment marks it "deferred (king moves)." If a future sprint
   ships king-flight content, the slot mapping needs a decision:
   does it pair with the opener (soft landing — `escapeSquare` IS
   the king moving), the rising slot (`escapeSquare` as
   counter-tactic), or a new slot? §6.3 architectural shift may be
   the right vehicle.
2. **Should episode mode admit Endless-only expansion?** Today
   `episode_library.dart` hand-picks ids per episode; CC2 and CAM1
   are absent. If §6.x unlocks CAM1 in Endless, the question of
   whether it should also feature in (say) Ep2 (capture/remove
   focus) becomes worth asking. Pure authoring decision, not a
   composer change.
3. **`rescue_archetype.dart` enum-comment staleness.** Lines 10–11
   describe `removeDefender` and `forcedInterposition` as "frontier
   — no template yet," but B3 and B1 ship as expansion templates
   for both. Doc-comment cleanup, 1-line change each. Not in scope
   here.
4. **Texture system interaction with expansion exposure.**
   Confirmed in §2.3.5 / §2.3.6: texture and `_instance()`
   degradation are template-preserving — they do NOT affect which
   templates surface. Recorded here so future audits don't re-ask.
5. **Telemetry signal for live exposure.** No production telemetry
   captures per-puzzle play frequency today (composer is offline
   only). If §6 changes ship, a 1-week production exposure
   measurement (counted via existing `completedIds` accumulation
   on the device) would let the team verify the model
   empirically. Not in scope here.

---

## §9. Appendix — empirical capture (verbatim test output)

Reproduced from
`flutter test test/endless_exposure_analysis_test.dart --reporter expanded`,
run during this audit on top of the unmodified Sprint V1 source:

```
===== Endless Exposure Analysis (Sprint V1 / Phase 3d) =====
Sample size: 1000 seeds (seed 1..1000; seed 0 excluded)
Total puzzles across all sessions: 5000

Per-puzzle frequency (descending):
  p2-take-the-checker                       1000 (20.00%)
  p4-seal-the-diagonal                       794 (15.88%)
  p3-block-the-file                          786 (15.72%)
  p5-win-the-queen                           545 (10.90%)
  b3-remove-the-defender                     455 (9.10%)
  b1-the-martyr                              420 (8.40%)
  p1-knight-rescue                           297 (5.94%)
  cc2-bishop-captures-shield                 247 (4.94%)
  b4-the-cross-check                         229 (4.58%)
  a4-the-breakaway                           227 (4.54%)

CC2 — count 247 (4.94% of all puzzles)
  CC2 / a4-the-breakaway          = 1.09 (baseline 227)
  CC2 / b1-the-martyr             = 0.59 (baseline 420)
  CC2 / b3-remove-the-defender    = 0.54 (baseline 455)
  CC2 / b4-the-cross-check        = 1.08 (baseline 229)

CAM1 — count 0 (0.00% of all puzzles)
  CAM1 / a4-the-breakaway          = 0.00 (baseline 227)
  CAM1 / b1-the-martyr             = 0.00 (baseline 420)
  CAM1 / b3-remove-the-defender    = 0.00 (baseline 455)
  CAM1 / b4-the-cross-check        = 0.00 (baseline 229)

Expansion baseline mean (A4/B1/B3/B4): 332.8
CC2 / baseline-mean  = 0.74
CAM1 / baseline-mean = 0.00
===== End report =====
```

Test result: PASS (1/1). No code changes. CAM1's empirical 0% is
the documented finding — the test's only hard assertion is wiring
(both templates present in `expansionTemplates`).

---

**End of Composer Audit Report.** No implementation. Awaiting
lead direction on which §6 tier (if any) to pursue in a
subsequent sprint.
