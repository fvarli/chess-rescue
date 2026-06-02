# Sprint V1 — Phase 3 Final Report

> **Status.** Phase 3 implementation complete. Verification clean.
> Endless Exposure Analysis captured below. **Stopping here per the
> lead's directive: no commit, no push, awaiting further approval.**

---

## 1. Scope shipped

Per the lead's locked accept set:

| Memo | Motif | Rescue | Phase 2.5 |
|---|---|---|---|
| **CC2** | `counterCheck` | `Bxf7+` (wB-c4 captures bP-f7, checks bK-g8) | 8/8 ✓ |
| **CAM1** | `captureAttackerMinor` | `Nxh2` (wN-g4 captures bB-h2, ends check) | 8/8 ✓ |

Total: **2 positions.** No replacements generated. No rejected
candidates patched. No symmetry-driven additions.

---

## 2. Files changed

### Modified (5)

| File | Change |
|---|---|
| `lib/core/models/puzzle_library.dart` | +2 `PuzzleTemplate` entries in `expansionTemplates`; +2 `Puzzle` consts at end of class. |
| `lib/core/models/puzzle_l10n.dart` | +2 switch cases (`cc2-bishop-captures-shield`, `cam1-knight-takes-bishop`) and header comment updated. |
| `lib/l10n/app_en.arb` | +8 strings + `@`-blocks. |
| `lib/l10n/app_tr.arb` | +8 strings. |
| `lib/l10n/app_es.arb` | +8 strings. |

L10n delta: **24 new translatable strings** (4 per puzzle × 3 locales × 2 puzzles).

### Generated (4) — incidental, via `flutter gen-l10n`

`lib/l10n/gen/app_localizations.dart`,
`lib/l10n/gen/app_localizations_en.dart`,
`lib/l10n/gen/app_localizations_tr.dart`,
`lib/l10n/gen/app_localizations_es.dart`.

### Tests added (2 NEW)

| File | Purpose |
|---|---|
| `test/new_positions_v1_test.dart` | Per-position structural assertions for CC2 and CAM1 (mover, rescue, threatened king, threat piece, validity, readability, prototype flag, l10n switch wire-up in en/tr/es). |
| `test/endless_exposure_analysis_test.dart` | The lead-mandated analysis — runs `PuzzleLibrary.session(seed)` for seeds 1..1000, tallies canonical-id frequencies, prints structured report, asserts only that the new templates are present in `expansionTemplates`. |

### Tests extended (3)

| File | Change |
|---|---|
| `test/variation_test.dart` | +3 mirror tests for CC2/CAM1 (geometry pinning, validity + readability base AND mirror). |
| `test/readability_test.dart` | +2 readability tests for CC2/CAM1 (base + mirror). |
| `test/expansion_families_test.dart` | Updated pool count `4 → 6` and id list now includes the two Sprint V1 additions. |
| `test/puzzle_canonical_id_test.dart` | Canonical id list extended with the two new ids. |

### Unchanged (verified)

- `lib/core/models/rescue_archetype.dart` — enum unchanged.
- `lib/core/models/episode_library.dart` — Ep1–Ep5 canonical lists unchanged. CC2/CAM1 are NOT in any episode.
- `lib/core/models/session_composer.dart` — **untouched, by directive** (see §5).
- All Memory Trio code (Records / Signatures / Familiarity).
- All UI widgets.
- PR 1 storage layer (SharedPreferences keys, ProgressStore).

---

## 3. Test count delta

| Phase | Test count | Result |
|---|---|---|
| Baseline (before Sprint V1) | 357 | All pass |
| After Phase 3 | **382** | All pass (+25 tests added across the new + extended files) |

`flutter test --concurrency=1` exits clean. No regressions in any
pre-existing test.

---

## 4. Verification results

| Command | Result |
|---|---|
| `dart format lib/ test/` | 5 files reformatted (the new files + the modified test files), 109 unchanged. |
| `flutter analyze` | `No issues found! (ran in 1.4s)` |
| `flutter test --concurrency=1` | `01:06 +382: All tests passed!` |
| `flutter build apk --release` | `✓ Built build/app/outputs/flutter-apk/app-release.apk (47.8MB)` |

---

## 5. Endless Exposure Analysis

> **Lead's mandate (verbatim).** *"When Phase 3 is complete, I want a
> dedicated section in the final report called: 'Endless Exposure
> Analysis'. … If the analysis shows that new positions are
> technically present but rarely encountered, do NOT modify
> SessionComposer in this sprint. Instead: document the observation,
> quantify it, propose follow-up investigation work."*

### 5.1 Methodology

The test `test/endless_exposure_analysis_test.dart` calls
`PuzzleLibrary.session(seed)` for `seed` in 1..1000 (seed 0 is the
canonical onboarding session — excluded). Each composed session is
length 5, so the sample is **5000 puzzle slots**. Every puzzle's
canonical id (mirror variants collapsed via `canonicalPuzzleId`) is
tallied and the report is `print`ed.

### 5.2 Raw output (captured verbatim from the test run)

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

### 5.3 Answers to the lead's five reporting requirements

#### (1) Can SessionComposer naturally select each position?

- **CC2: YES.** It appears in 247 of 5000 puzzle slots across 1000 seeds.
- **CAM1: NO.** It appears in **0** of 5000 slots. The template is
  registered in `expansionTemplates` (the wiring assertion in the test
  passes), but the composer's slot-allocation logic never selects it.
  See §5.3.5 for the mechanism.

#### (2) Approximate selection frequency

- **CC2:** 247 / 5000 = **4.94%** of all puzzle slots → on average,
  ~1 CC2 puzzle per ~4 Endless sessions (~1 in every 20 puzzles
  played). At a typical session length of 5, a player solving 4
  Endless sessions in a sitting will encounter CC2 roughly once.
- **CAM1:** 0 / 5000 = **0.00%**. Not surfaced at all in the sample.

#### (3) Relative frequency vs. existing expansion baselines

| Expansion baseline | Count | CC2 ratio | CAM1 ratio |
|---|---|---|---|
| A4 (counterCheck) | 227 | 1.09 | 0.00 |
| B1 (forcedInterposition) | 420 | 0.59 | 0.00 |
| B3 (removeDefender) | 455 | 0.54 | 0.00 |
| B4 (counterCheck) | 229 | 1.08 | 0.00 |
| **Mean** | 332.8 | 0.74 | 0.00 |

CC2 sits at parity with the two other expansion `counterCheck`
families (A4, B4): ~227–247 each. The mean is pulled up by B1 and B3
because each is the *only* expansion candidate in its archetype slot.
This is structural — see §5.3.5.

#### (4) Realistically discoverable by regular players?

- **CC2: discoverable.** ~5% session-wide presence means a typical
  player solving 50 Endless puzzles will encounter CC2 roughly **2–3
  times** — enough for the pattern to become familiar without
  saturating. Comparable to A4 / B4 visibility.
- **CAM1: NOT discoverable.** A player solving 50,000 puzzles would
  still encounter it 0 times under the current composer logic.

#### (5) Evidence of composer weighting suppressing visibility

**Yes — CAM1's 0% is fully explained by the composer's
canonical-locked opener slot.** The relevant code in
`lib/core/models/session_composer.dart`:

```dart
// line 156
final openerCands = candidates([RescueArchetype.captureAttackerMinor]);
...
// line 188-194
final chosen = <PuzzleTemplate>[
  openerCands.first, // opener — canonical-locked, simple/readable
  risingCands[risingIdx], // rising — counter-check / breakaway / cross-check
  middleCands[middleIdx], // middle — interpose (block / seal / martyr)
  peakCands[peakIdx], // peak — high-stakes resolution
  finaleCands.first, // finale — canonical-locked, the other interpose
];
```

`candidates([archetype])` walks `byArchetype[archetype]`, which is
populated by `for (final t in [...templates, ...expansion]) ...`. So
the canonical P2 (the only `captureAttackerMinor` in `templates`) is
**always at index 0** of `openerCands`. The opener slot is hard-coded
to `openerCands.first`, so **P2 always wins the opener slot**. CAM1
sits at index 1 and is never reached.

This is consistent with the file's own design comment:

```dart
// line 16-17
/// slot. The opener and finale stay **canonical-locked**, and at most
/// two of the three middle slots may be an expansion family
```

CC2 surfaces because it's `counterCheck`, which is the
`risingCands` slot. That slot is seeded:

```dart
// line 169
var risingIdx = rng.nextInt(risingCands.length);
```

`risingCands.length == 4` (P1, A4, B4, CC2 — the four counterCheck
families). Each gets a fair seed-driven slot. The observed CC2 share
(~24.7% of the rising-slot 1000 sessions, manifested as ~4.94% of
the 5000-slot sample) matches the expected uniform 25%.

### 5.4 Constraint honored (verbatim from the lead's directive)

> *"If the analysis shows that new positions are technically present
> but rarely encountered, do NOT modify SessionComposer in this
> sprint."*

**SessionComposer was NOT modified.** This finding is reported as an
observation. A line-for-line `git diff` of `session_composer.dart`
between sprint start and now is empty.

### 5.5 Proposed follow-up (separate sprint)

The CAM1-at-0% finding suggests a future-sprint composer-design
question worth tracking:

> **"Should the canonical-locked opener slot permit expansion
> `captureAttackerMinor` candidates in some fraction of sessions, so
> that future CAM-family additions can ever be surfaced?"**

Possible paths (NOT decided this sprint; for the lead to consider):

1. **Seed-gated opener swap.** With probability `p` (e.g. 1/4), the
   opener picks `openerCands[rng.nextInt(openerCands.length)]`
   instead of `.first`. Preserves the canonical-anchor feel in the
   majority of sessions but lets expansion CAM families surface.
2. **Add a second `captureAttackerMinor` slot.** A new rising/middle
   variant slot that draws from this archetype. Bigger surgery —
   touches slot count and emotional pacing.
3. **Accept the design.** The opener is intentionally a "soft
   landing" — P2 is the simplest readable rescue in the canon.
   Future CAM positions might be reframed under a different
   archetype, or shipped as canonical replacements rather than
   expansion additions.

Recommendation: defer the decision until a second motivating CAM
candidate exists (so the design conversation is grounded in actual
content pressure, not hypothetical).

---

## 6. Constraints honored

| Constraint | Honored | Evidence |
|---|---|---|
| 2-position ship (no replacements) | ✓ | `expansionTemplates.length == 6` (was 4, +2 new). No third entry. |
| Rejected candidates archived, not patched | ✓ | CC1 + RD1 archive files unchanged at `docs/archive/rejected/sprint-v1/`. No CC1/RD1 references in lib/test. |
| PR 1 storage layer untouched | ✓ | No edits to `progress_store*.dart`, no new SharedPreferences keys. |
| `RescueArchetype` enum unchanged | ✓ | No edits to `lib/core/models/rescue_archetype.dart`. |
| `SessionComposer` logic unchanged | ✓ | No edits to `lib/core/models/session_composer.dart`. |
| Canonical episodes Ep1–Ep4 unchanged | ✓ | `episode_library.dart` untouched; episode-progress / migration / completion tests pass. |
| No new layers / progression / UI changes | ✓ | No widget files touched. No Records / Signatures / Familiarity changes. |
| Mirror compatibility preserved | ✓ | `variation_test.dart` extended; both new puzzles pass mirror geometry + validity + readability. |
| Per-locale parity (ARB keys) | ✓ | `arb_parity_test.dart` passes (8 new keys present in all three locales). |
| Geometry-safe displayed copy | ✓ | `expansion_families_test.dart`'s `_expectSafeDisplayedCopy` passes for CC2 + CAM1 base + mirror. |
| Readability gate not relaxed | ✓ | `readability.dart` unchanged. Both new positions pass the existing gate without modification. |

---

## 7. Unexpected findings / side effects

**None for the implementation itself.** The Endless Exposure
Analysis surfaced a non-implementation observation (CAM1 0%
visibility under the current composer) that the lead's directive
anticipated and instructed to be **documented, not fixed, this
sprint**. That observation is captured in §5.

The R0 instinct-not-memory check was performed at memo-level (Phase
2) and geometry-level (Phase 2.5). A device-playtest R0 pass is not
in this headless verification — flagged as a manual follow-up task
the lead can run when convenient. The headless suite confirms
*structural* readability + safety, not subjective feel.

---

## 8. Outstanding work (not done this sprint, per directive)

- Manual device playtest of CC2 + CAM1 (R0 feel check). Suggested
  but optional — the Phase 2.5 geometry validation is the
  load-bearing gate per the sprint plan.
- Composer follow-up investigation (§5.5). Awaits content-pressure
  trigger.
- Commit + push. **Holding per the lead's explicit instruction.**

---

## 9. Next step

**STOP.** Per the lead's directive:

> *"Do not commit. Do not push. Wait for further approval after
> reporting."*

Awaiting lead approval before any commit / push / merge / further
work. The working tree currently contains the Phase 3 implementation
on top of the previously-uncommitted Phase 2 + 2.5 artifacts; the
lead can review the diff in one place (`git status`, `git diff`).

---

**End of Phase 3 final report.**
