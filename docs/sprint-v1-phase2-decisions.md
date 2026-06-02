# Sprint V1 — Phase 2 + 2.5 Decisions Document

> **Status.** Phase 2 (memo-level review) and Phase 2.5 (geometry
> validation) are complete. This document records the final accept
> set entering Phase 3 implementation. Per the lead's discipline
> correction: no candidate was marked accepted until Phase 2.5
> validation passed.
>
> **Phase 1 inputs.** 12 candidate position memos at
> `docs/sprint-v1-phase1-memos.md` (left unchanged as the Phase 1
> historical record).
>
> **Phase 2.5 detailed validation findings.** Available at
> `docs/sprint-v1-phase2.5-validation.md` — full 8-check walkthrough
> per provisional candidate.

---

## Final accept set: 2 positions

| Memo | Motif | Provisional rescue | Phase 2.5 result |
|---|---|---|---|
| **CC2** | `counterCheck` | `Bxf7+` from wB-c4 | **ACCEPTED** — all 8 checks pass |
| **CAM1** | `captureAttackerMinor` | `Nxh2` from wN-g4 | **ACCEPTED** — all 8 checks pass |

**Phase 3 implementation ships 2 new positions.** Per
[[feedback-quality-over-symmetry]], this is the correct outcome.
The lower-than-floor count (2 vs. the original sprint plan's
5-floor) is the lead-revised expectation: *"if fewer than 4 pass,
ship fewer. Do not patch; do not invent replacements."*

---

## Phase 2 — memo-level decisions

| Memo | Motif | Decision | Phase | Archive file |
|---|---|---|---|---|
| CC1 | `counterCheck` | Provisionally selected → REJECTED at 2.5 | 2.5 | [cc1-rook-above-king.md](archive/rejected/sprint-v1/cc1-rook-above-king.md) |
| CC2 | `counterCheck` | Provisionally selected → **ACCEPTED at 2.5** | — | (Phase 3) |
| CC3 | `counterCheck` | REJECTED — R0 fail vs. P1 | 2 | [cc3-far-side-knight.md](archive/rejected/sprint-v1/cc3-far-side-knight.md) |
| CC4 | `counterCheck` | REJECTED — R0 fail vs. CC2 | 2 | [cc4-bishop-sweeps-in.md](archive/rejected/sprint-v1/cc4-bishop-sweeps-in.md) |
| CAM1 | `captureAttackerMinor` | Provisionally selected → **ACCEPTED at 2.5** | — | (Phase 3) |
| CAM2 | `captureAttackerMinor` | REJECTED — quality concern | 2 | [cam2-rook-eats-rook.md](archive/rejected/sprint-v1/cam2-rook-eats-rook.md) |
| RD1 | `removeDefender` | Provisionally selected → REJECTED at 2.5 | 2.5 | [rd1-pinned-defender.md](archive/rejected/sprint-v1/rd1-pinned-defender.md) |
| RD2 | `removeDefender` | NOT PURSUED (multi-move mechanic) | 1 | [rd2-take-the-pinner.md](archive/rejected/sprint-v1/rd2-take-the-pinner.md) |
| BF1 | `blockFile` | REJECTED — R0 fail vs. P3 | 2 | [bf1-knight-on-g5.md](archive/rejected/sprint-v1/bf1-knight-on-g5.md) |
| SD1 | `sealDiagonal` | REJECTED — R0 fail vs. B1 | 2 | [sd1-bishop-on-the-line.md](archive/rejected/sprint-v1/sd1-bishop-on-the-line.md) |
| FI1 | `forcedInterposition` | NOT PURSUED (no non-derivative shape found) | 1 | [fi1-no-shape-found.md](archive/rejected/sprint-v1/fi1-no-shape-found.md) |
| CAH1 | `captureAttackerHeavy` | NOT PURSUED (no non-obvious shape found) | 1 | [cah1-no-shape-found.md](archive/rejected/sprint-v1/cah1-no-shape-found.md) |

**Totals:** 2 accepted, 10 archived (5 Phase 2 rejects + 3 Phase 1 not-pursued + 2 Phase 2.5 rejects).

---

## Phase 2.5 — 8-check validation summary

Full per-check walkthroughs are in
`docs/sprint-v1-phase2.5-validation.md`. Summary:

| Check | CC1 | CC2 | CAM1 | RD1 |
|---|---|---|---|---|
| #1 Board reconstruction | ✓ | ✓ | ✓ | ✓ |
| #2 Threat is real | ✓ | ✓ | ✓ | ✓ (with memo correction: threat is Qxh2#, not Qh1# as memo said) |
| #3 Rescue is legal | ✓ | ✓ | ✓ | **✗ FAIL** — Nxg3 is not a chess-legal knight move from e5 |
| #4 Rescue resolves threat | ✓ | ✓ | ✓ | (not reached) |
| #5 No second valid rescue | **✗ FAIL** — Rxh3 captures the threatening queen | ✓ | ✓ | (not reached) |
| #6 Mirror validity | (not reached) | ✓ | ✓ | (not reached) |
| #7 Decoy honesty | (not reached) | ✓ | ✓ | (not reached) |
| #8 R0 distinctness from validated board | (not reached) | ✓ | ✓ | (not reached) |

**CC1 failed Check 5.** The proposed `legalMoves` omission of
`Rxh3` followed P1's convention of hiding chess-legal moves, but
the omitted move directly resolves the threat by capturing the
queen. R5's spirit — "one rescue from the rescuer" — fails when
the rescuer can also capture the threat directly. Authoring
convention can hide *decoys*, not *alternative rescues*.

**RD1 failed Check 3.** The proposed rescue `Nxg3` requires a
file_diff=2 / rank_diff=2 jump from e5. Knight moves are 1/2 or
2/1 — equal magnitudes are bishop moves, not knight moves. The
author conflated piece movement rules at memo-writing time. Per
the lead's "do not patch" directive, the candidate is archived
rather than re-authored.

---

## Process learnings for future sprints

The Phase 2.5 failures reveal two process improvements worth
adopting permanently:

### Learning 1 — Pre-flight geometric verification during candidate writing

The RD1 failure (`Nxg3` not a knight move) is the kind of error
that should never reach Phase 2.5. Future candidate generation
should include:
- For each proposed rescue piece + rescue square pair, compute
  the offset and verify it matches the piece's movement rules
  (knight: |1| + |2| or |2| + |1|; bishop: |x| = |y|; rook: x=0 or
  y=0; queen: any of the three).
- For each proposed move path involving sliders (bishop, rook,
  queen), verify all intermediate squares are accounted for as
  empty / blocked.

This is mechanical; it could even be a small validation script
or test. Worth automating.

### Learning 2 — Apply R5 at the position level, not just the surface level

The CC1 failure (`Rxh3` as a second rescue) reveals that the
existing canon's authoring convention (hiding chess-legal moves
from `legalMoves`) is a tool for managing *decoys*, not for
managing *alternative rescues*. A position that has TWO ways to
resolve the threat from the rescuer piece is structurally
ambiguous regardless of which one the authoring exposes.

Future candidate generation should explicitly check: "from the
rescuer piece's complete set of chess-legal moves, how many
resolve the threat?" If more than one, the position is rejected
at the memo level, before Phase 2.5.

These two learnings are not yet memorial standing rules but are
worth surfacing during Phase 3a authoring as the team encounters
similar decisions.

---

## Phase 3 scope (the implementation work that follows)

Per the original sprint plan §4 and the revised execution plan
§4.4, Phase 3 sub-phases:

### Phase 3a — Authoring (the 2 accepted positions)

For each of CC2 and CAM1:
- Code the `PuzzleTemplate` entry in
  `lib/core/models/puzzle_library.dart` `expansionTemplates`
- Add the embedded `Puzzle` const (position, pieces,
  threatenedKing, tappableSquare, legalMoves, rescueTo,
  rescueNotation, dangerHint, failureHint, successExplanation,
  title, statusText)
- `decoyPool` (1-2 hand-vetted decoy squares per R12)
- `removableScenery` + `sceneryPool` (optional per R13)
- `archetype` tag (`counterCheck` for CC2, `captureAttackerMinor`
  for CAM1)
- Add 4 strings to `app_en.arb` with `@key` blocks
- Translate to TR / ES

L10n delta: 4 strings × 3 locales × 2 positions = **24 new
strings.**

### Phase 3b — Automated tests

- `test/new_positions_v1_test.dart` (NEW): structural per-position
  tests
- `test/readability_test.dart` (extend): readability gate
  coverage for both new puzzles
- `test/variation_test.dart` (extend): mirror coverage for both
- Run `dart format lib/ test/`, `flutter analyze`,
  `flutter test --concurrency=1`

### Phase 3c — Real-device playtest (per sprint plan §5d)

Manual play of CC2 and CAM1 on a real device. R0 evaluated AGAIN
at this gate — geometry validation is necessary but not sufficient.
Either position can still be killed by the device-playtest's
qualitative feel test.

### Phase 3d — Composer integration

Verify `SessionComposer` picks up the new templates without
regressing existing tests:
- `test/session_composer_test.dart`
- `test/session_quality_test.dart`
- `test/runtime_session_test.dart`

### Phase 3e — Stop and report (per sprint plan §11)

```bash
dart format lib/ test/
flutter analyze
flutter test --concurrency=1
flutter build apk --release
```

Report and stop. No commits without lead authorisation per
[[project-overview]].

---

## Files affected

### Created during Phase 2 / 2.5
- `docs/sprint-v1-phase2.5-validation.md` (the 8-check walkthrough)
- `docs/sprint-v1-phase2-decisions.md` (this document)
- `docs/archive/rejected/sprint-v1/` directory (10 archived memo files)

### Phase 3 modifications (planned)
- `lib/core/models/puzzle_library.dart` (2 new `PuzzleTemplate` entries)
- `lib/l10n/app_en.arb` (8 new strings + `@key` blocks)
- `lib/l10n/app_tr.arb` (8 new strings)
- `lib/l10n/app_es.arb` (8 new strings)
- `test/new_positions_v1_test.dart` (NEW)
- `test/readability_test.dart` (extend)
- `test/variation_test.dart` (extend)

### Unchanged throughout
- `docs/sprint-v1-phase1-memos.md` (Phase 1 historical record)
- `lib/core/models/rescue_archetype.dart` (enum unchanged)
- `lib/core/models/episode_library.dart` (canonical lists unchanged)
- `lib/core/models/session_composer.dart` (composer logic unchanged)
- All Memory Trio files (Records / Signatures / Familiarity)
- All UI files

---

## Next step

Stop and report Phase 2.5 results to the lead per the sprint
plan §7.1 (stop-and-await gate). The lead confirms the 2-position
accept set before any Phase 3a authoring begins. This gates
against the team starting implementation on positions the lead
hasn't signed off on after the Phase 2.5 surprises.

---

**End of Phase 2 + 2.5 decisions document.**
