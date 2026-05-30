# Chess Rescue — Master Release Roadmap

Post-closed-test strategy for the **v1 / "Master" release** that unlocks production access and
flips Chess Rescue from "MVP feels thin" to "premium indie puzzle game." Tester feedback is the
sole prioritization signal; nothing here is added on instinct.

The core identity is invariant: **"One move saves the king."** Every roadmap item either
sharpens that identity, makes the surrounding game *worthy* of it, or removes friction. If a
proposal blurs it, it's rejected.

## 0) Master Release non-negotiables (read first)

These are not preferences. Treat them as hard constraints on every PR, every sprint plan, and any
counter-proposal during the v1.1.0 cycle.

1. **The Master Release ships without difficulty modes.** No Easy / Normal / Hard. No mode picker.
   No "harder puzzle pack" labeled as such. Tester feedback did not name difficulty as a
   problem — adding it is *imagined* work, and the cost is real (UI surface, brand drift,
   engineering hours).
2. **Difficulty modes are deferred indefinitely.** Their next legitimate consideration is *only*
   on post-launch telemetry showing a bimodal completion curve (a large cohort solving
   everything trivially AND a large cohort dropping off at the same episode boundary). Absent
   that signal, they stay out.
3. **Difficulty modes must never delay the Master Release.** If during 1.1.0 any voice (tester,
   reviewer, future agent) proposes adding Easy/Normal/Hard, the answer is *defer*, not
   *re-scope*. The shippable scope is fixed: Localization → Visual → Episodes → Puzzles →
   Progression → Agency. Difficulty is Phase 2 at the earliest, only on evidence.
4. **The locked v1.1.0 priority order is:**
   1. Localization (TR / EN / ES, device-detected)
   2. Visual quality
   3. Episode system
   4. More puzzles (3 episodes × ~10 each)
   5. Progression visibility (levels, stars, library, streaks)
   6. Player agency (Medium model, §2)
   7. ~~Difficulty modes~~ — **deferred; only on post-launch telemetry**.
5. **Core mechanic is invariant.** Still exactly *one* rescuing move per puzzle. Agency widens
   the *path*, never the *answer*.

## 1) UX audit — what the tester feedback actually says

Mapping each piece of real feedback to the current code/UX (Phases 31-35 already shipped):

| Tester signal | Real cause (verified in repo) | Root issue |
|---|---|---|
| "Looks cheap" | Pieces are pure CustomPainter Bézier (`piece_widget.dart`), minimal by design but read as flat at thumbnail size; board is plain checker with no surface texture | **Visual polish bar set too low** — refine, don't rebuild |
| "Only 5 levels" | `PuzzleLibrary` ships 5 canonical + 6 expansion-family puzzles + replayability engine (mirrors/decoys/scenery); felt count vs. real count diverge because the player never sees a level number | **Content count + count-visibility** |
| "Progress unclear" | No persisted "lifetime" counter shown; only in-session "n SAVED" | **No persistent progression surface** |
| "No level indicator" | Status pill says "PUZZLE n/m" but that's *session-local*, not lifetime/episode | **No level numbering across sessions** |
| "No language support" | All UI strings hardcoded English; no `intl`/`flutter_localizations` | **Localization missing** |
| "Pieces feel generic" | Same as "looks cheap" — Bézier abstraction reads as undercooked | **Piece visual character** |
| "No long-term motivation" | Session loop cycles seeds; no narrative of progression, no map, no "X to go" | **No progression narrative** |
| ✅ "Core mechanic understood" | Phase 35 intro overlay + already-wired onboarding hint + Phase 34 focus cue strengthening | **Don't touch; preserve** |

What the feedback does **NOT** say: difficulty selection, harder puzzles, tutorial system,
accounts, social features, ads, multiplayer. Nothing about deeper chess. The feedback is about
**production polish, content volume, motivation visibility, and language reach** — not gameplay
depth. Plan accordingly.

## 2) Design investigation A — Incorrect-move exploration & player agency

**Question:** Should players be allowed to attempt wrong moves before finding the rescue?

**Current behavior (verified in `game_controller.dart` + `puzzle_library.dart`):**
- The rescuer is the **only tappable piece** (puzzle's `tappableSquare` whitelist).
- On the rescuer, the puzzle declares a fan of `legalMoves` — **multiple destinations, only one
  is `rescueTo`**. Wrong destination already triggers `GameState.failed`, status "▮ Still trapped",
  fail haptic, and a soft reset via "Try again" footer. So **destination-level exploration already
  exists**.
- Other white pieces are **inert** — tapping them does nothing. This is what reads as "rails."

**Recommendation: open piece-choice exploration, keep the soft-reset model. Implement as the
"Medium model" below.**

### Three models considered

| Model | What changes | Lift | Identity risk |
|---|---|---|---|
| Minimal | Tapping a non-rescuer white piece shakes briefly + status pill flashes "Only one piece can reach the threat" | 1–2 days | None — feedback only |
| **Medium (recommended)** | Any white piece is selectable; non-rescuers fan **0 legal moves** (curated per puzzle) → status flashes "That piece can't break the attack — try another"; rescuer behaves as today (multi-destination fan, soft reset on wrong target) | ~1 sprint | Low — wrong-piece selection is a brief no-commit attempt, not a "real" move |
| Full | Generate real chess legal moves for every piece; any move that isn't `rescueTo` triggers "Still trapped" + soft reset | 2–4 sprints (needs an engine-lite); doubles authoring burden | Medium — starts to feel like a chess sandbox |

### Why Medium beats Minimal and Full

- It **gives agency** (tester signal: feels too narrow) without becoming a chess sandbox.
- The "one rescue move" core is *preserved* — `rescueTo` is still the only winning state.
- It removes the worst rails feeling (other pieces inert) cheaply (~1 sprint), without a chess
  engine.
- Status pill copy is bespoke per beat (we already do this in `puzzle_library.dart`); adds richness
  without new mechanics.

### What we explicitly reject

- **Score penalties** — conflicts with the calm/no-shame brand (`product-vision.md`). Wrong
  attempts soft-reset; no score deduction.
- **Difficulty-dependent restriction tiers** — see investigation B.
- **Hint systems / "reveal the rescuer"** — would dissolve the only puzzle moment. The focus cue
  in onboarding is the cap.

### Identity check
> "Find the ONE move that saves the game."
Medium model: the *answer* is still one piece × one square. The *path* to that answer now allows
the player to feel out the board, learn the wrong-piece patterns, and choose the rescuer
themselves. Identity intact; agency restored.

## 3) Design investigation B — Difficulty modes

**Question:** Should the v1 ship Easy / Normal / Hard?

**Decision (non-negotiable, restated from §0): NO. Deferred indefinitely; only revisited on
post-launch telemetry showing a clear bimodal completion curve. Difficulty modes must never
delay the Master Release — if pressure to add them arises mid-sprint, the answer is *defer*,
not *re-scope*.**

### Why no difficulty modes in v1
1. **No tester named this.** Adding it = engineering against imagined feedback.
2. **It splits the audience and the brand.** A "Hard mode" badge introduces a competitive register
   that fights the calm/relief identity (memory: `feedback_store_copy_voice.md`).
3. **It adds UI surface** (mode picker, badge variants, per-mode progress) for a hypothetical gain.
4. **It conflicts with the agency model.** If we ship the Medium agency model above, players already
   self-pace difficulty — focused on rescuer = "easy mode", open exploration = "hard mode" — without
   a switch.
5. **Natural difficulty curve solves it.** Episodes are *authored* warmup → peak. Episode 1's
   puzzles are gentle (clear rescuer, short fan), late episodes are tight (multiple plausible pieces,
   long fans). The difficulty exists; it just isn't labeled.

### When to revisit
If post-launch telemetry shows a **bimodal completion rate** (a chunk solve everything trivially +
a chunk drop off at episode 3), then a "Take it slow" toggle can be added in Phase 2 — but
labeled as comfort, not as Easy/Normal/Hard. Brand-safe phrasing only.

## 4) Feature priority table

Locked to the brief's stated priority order, with rationale and the *blocker bit* each item lifts.

| Rank | Feature | Lifts | Risk if skipped | Sprint cost |
|---|---|---|---|---|
| 1 | **Localization (TR/EN/ES, device-detected)** | "No language support" | **Production gated**: closed listings are already TR/ES; the app must speak them | 2 sprints |
| 2 | **Visual quality refinement** (pieces, board, motion, victory/failure) | "Looks cheap", "pieces feel generic" | First-impression cheapness undermines word-of-mouth | 3 sprints |
| 3 | **Puzzle quantity expansion** (3 episodes × 10 puzzles ≈ 30 new) | "Only 5 levels" | Tester drop-off after first session | 4 sprints (authoring-heavy) |
| 4 | **Onboarding refinement** (intro copy + first-session breadcrumbs + "1 of N" badge) | "Don't immediately understand", reinforce post-intro | Phase 35 intro shipped; this finishes the job | 1 sprint |
| 5 | **Progression systems** (episode model, level numbers, stars, progress map, streaks) | "Progress unclear", "no level indicator", "no long-term motivation" | The biggest single tester complaint cluster | 3 sprints |
| 6 | **Player agency** (Medium model from §2) | Implicit "feels rails-y" subtext, even if not named | Without it, content expansion still feels thin | 1 sprint |
| 7 | **Difficulty modes** | None named — **DEFER** | Adds surface for a non-issue | 0 in v1; Phase 2 only on evidence |

Total v1 sprint cost: **~14 sprints (~12–16 weeks)**, parallelizable where noted.

## 5) Release roadmap

Two-week sprints. Items 1–6 ship as the **Master Release (1.1.0)**. Item 7 is held in reserve.

```
SPRINT 1–2   Phase A — Localization (TR/EN/ES, device-detected) ────────► v1.0.1
SPRINT 3–4   Phase B — Visual quality (pieces + board + motion v2) ─────► v1.0.2 (closed-track)
SPRINT 5–8   Phase C — Content expansion (3 episodes × ~10 puzzles)     │
             (authoring runs in parallel with B from sprint 4)          │
SPRINT 6     Phase D — Onboarding refinement                            │
                                                                        │
SPRINT 9–11  Phase E — Progression (episodes/levels/stars/map/streaks) ─► v1.1.0-rc1 (closed-track)
SPRINT 12    Phase F — Player agency (Medium model)                    ─► v1.1.0-rc2
SPRINT 13    Bake / regression hardening / Vitals watch                ─► **v1.1.0 production**
SPRINT 14+   Phase 2 hold: telemetry-driven decisions
             (difficulty toggle, second-language batch, monetization)
```

**Gate to ship 1.1.0**: every tester problem from §1 has a concrete countermeasure in the
release; on-device test on OPPO A91 + a small + a large screen; closed-test re-run only if a
P0 surfaces (otherwise promote internal → production via the closed track already running).

## 6) Exact implementation plan (per phase)

### Phase A — Localization (TR/EN/ES)
- Add deps `flutter_localizations` (SDK), `intl: ^0.20.x`; enable `generate: true` in `pubspec.yaml`.
- Create `lib/l10n/` with `app_en.arb`, `app_tr.arb`, `app_es.arb`.
- Add `l10n.yaml` (template: `app_en.arb`, output-class `AppL10n`, output-dir `lib/l10n/gen`).
- Extract every user-facing string: intro overlay (4 strings), headlines (4), hints (~12), status
  messages, footer labels, completion footnote, debug overlay (debug-mode only — exclude from
  release locales).
- Per-puzzle locale-keyed copy: `puzzle_library.dart` keeps logical ids; ARB holds the language.
  Introduce `puzzle.l10nKey` → `AppL10n.of(context).puzzle_p1_dangerHint` etc. via generated keys.
- `MaterialApp`: `localizationsDelegates: AppL10n.localizationsDelegates`,
  `supportedLocales: AppL10n.supportedLocales`, `localeResolutionCallback` → device locale if in
  {en, tr, es} else en.
- Update Play Console store listing (already EN/TR/ES finalized in `play-store-metadata-draft.md`).

### Phase B — Visual quality
- **Pieces** (`piece_widget.dart`): keep the Bézier silhouettes (premium-indie identity), but add
  (a) a 2-stop linear gradient fill (top highlight → body color), (b) an inner 1px soft inner-shadow
  along the lower-right edge, (c) a 0.6px outer outline at 1× scale that vanishes at very small sizes.
  Tune `pieceLightStroke` / `pieceDarkStroke` opacities (already in palette).
- **Board** (`board_widget.dart`): add a subtle 4% white grain texture overlay (single sprite tile)
  to break the flat checker; deepen `boardLight`/`boardDark` contrast by ~3% delta; soft 1px inner
  vignette on the board container.
- **Danger glow** (already tuned in Phase 34): leave.
- **Rescue bloom** (`MotionTokens.rescueBloom/Settle/Breath…`): add a single concentric ring
  expand-and-fade on commit (one sprite, no particles) — quiet pride, not fireworks (memory:
  `feedback_store_copy_voice.md`).
- **Failure**: keep gentle. Add a 1-pixel boardwide red rim flash (160ms) + the existing micro-shake.
- **Type pass**: bundle Inter (license-clean) under `assets/fonts/Inter-*.ttf`, declare in
  pubspec — closes the "Inter falls back to system sans" fidelity gap discovered in Phase 33.

### Phase C — Content expansion
- **Episode model** in data: `lib/core/models/episode.dart` — `Episode {id, titleKey, puzzleIds,
  rank, descriptionKey}`. `EpisodeLibrary.all` curates the list.
- **Author 30 puzzles** across 3 episodes (10 each), seeded from `rescue-archetypes.md` &
  `expansion-families`. Suggested episodes:
  1. *First Rescues* — A1 Block, A2 Capture, A3 Pin-break (10 warmups; clear rescuer)
  2. *Heroic Counters* — B1 Martyr, B3 Remove-the-Defender, B4 Cross-Check (10 mid; tighter)
  3. *Calm Insight* — C1 Quiet-move, C2 Deflection, C3 Decoy (10 late; multi-plausible-piece;
     the agency model from §2 shines here)
- Reuse the replayability engine (mirrors/decoys/scenery) — each authored base instance multiplies.
- Run `expansion_families_test.dart` & gate checks on every new puzzle.
- v1 ships **3 episodes (30 puzzles)**. Roadmap parking: 3 more episodes for v1.2.

### Phase D — Onboarding refinement
- Intro overlay (Phase 35) copy unchanged. Add the one missing line — under the body, a small
  uppercase micro-label: **"Every board has exactly one rescue."** This closes the "why only one
  move is allowed" gap from the brief.
- After first rescue: a one-shot post-rescue toast (1.5s, auto-dismiss) reading "1 of 30 saved."
  Sets up the new lifetime counter (Phase E).
- Onboarding gates: keep focus cue + tappable-rescuer-only **for episode 1, levels 1–3** (instead
  of just puzzle 1). After that, the agency model (§2) engages.

### Phase E — Progression
- **Persistence**: extend `ProgressStore` with `lifetimeSaved: int`, `starsByPuzzle: Map<id,int>`,
  `episodeProgress: Map<episodeId,int>`, `streakLastDay: String`, `streakCount: int`. New keys, no
  migration drama (additive; defaults 0/empty).
- **Stars**: 3 = solved on first attempt; 2 = within 3 attempts; 1 = solved (any attempts). Awarded
  on rescue; never decreased after. No "re-grind for stars" UI.
- **Level numbering**: status pill shows `E1 · L4` (episode + level within episode); session 5/5
  becomes a session-level loop visible only in episode play. Use compact micro-label, fits the
  Phase 34 ellipsis-safe layout.
- **Progress map**: new screen `lib/features/progress_map/`. A vertical scrollable list of episodes;
  each episode is a row with name, completion (e.g. "7 / 10"), aggregate stars, an "open" tap.
  Tapping an episode opens its level list (same row pattern) → tapping a level jumps directly into
  it. No literal world map; just a calm typographic list. Entry point: a tiny **"Library ↗"** button
  on the rescued completion screen, *not* the danger screen (preserves drop-into-danger).
- **Streaks**: `streakLastDay` is YYYY-MM-DD of the last rescue; `streakCount` increments by 1 if
  the new rescue is the next day, resets to 1 otherwise (or unchanged if same day). Shown as a tiny
  badge ("🔥 3" — but mint, no emoji conflicts) in the rescued screen only. No FOMO push; never on
  danger.
- **No accounts.** All state on-device (memory: `play-console-data-safety.md`).

### Phase F — Player agency (Medium model)
- Allow `handleSquare` to *select* any white piece (`game_controller.dart` ~ line 132).
- Non-rescuer pieces have `legalMoves = const []` (already true for the chess-rule generator) →
  fan out 0 dots → flash status pill **"That piece can't break the attack — try another"** for
  500ms, then deselect.
- Rescuer behaves as today.
- Per-puzzle copy override: `puzzle.wrongPieceHint?: String` to bespoke the flash text per beat
  (optional; falls back to default).
- Failed-rescue soft reset already works; reuse.

### Phase G — Difficulty modes (DEFERRED)
Held. See §3 — only revisit on Phase 2 telemetry.

## 7) Claude Code tasks (concrete PR list to drive future phases)

Each row = one Claude Code session, one PR, one commit.

| # | Title | Phase | Deps |
|---|---|---|---|
| C1 | `feat(l10n): wire flutter_localizations + en/tr/es scaffolding` | A | — |
| C2 | `feat(l10n): extract intro overlay + headline + hint strings to ARB` | A | C1 |
| C3 | `feat(l10n): localize per-puzzle copy (statusText/dangerHint/failureHint/successExplanation)` | A | C2 |
| C4 | `feat(l10n): device-locale resolution + en fallback` | A | C2 |
| V1 | `feat(visual): premium visual foundation (Inter + piece gradient + board grain/vignette)` | B | — |
| V2 | `feat(visual): rescue bloom ring + failure rim-flash` | B | V1 |
| Co1 | `feat(content): introduce Episode model + EpisodeLibrary` | C | — |
| Co2 | `feat(content): author Episode 1 (First Rescues, 10 puzzles)` | C | Co1 |
| Co3 | `feat(content): author Episode 2 (Heroic Counters, 10 puzzles)` | C | Co1 |
| Co4 | `feat(content): author Episode 3 (Calm Insight, 10 puzzles)` | C | Co1 |
| O1 | `feat(onboarding): add "exactly one rescue" line + "1 of N saved" toast` | D | E1 |
| O2 | `feat(onboarding): extend focus-cue scaffold to E1 L1–L3 only` | D | Co2 |
| E1 | `feat(progress): extend ProgressStore (lifetimeSaved/stars/episodes/streak)` | E | Co1 |
| E2 | `feat(progress): episode + level numbering in status pill` | E | E1 |
| E3 | `feat(progress): stars (3-2-1 by attempts) + persistence` | E | E1 |
| E4 | `feat(progress): library screen (episodes → levels), Library ↗ entry` | E | E1 |
| E5 | `feat(progress): daily streak counter on rescued screen` | E | E1 |
| A1 | `feat(agency): allow selecting any white piece + non-rescuer flash` | F | — |
| R1 | `chore(release): regression sweep + Vitals watch + v1.1.0 production rollout` | bake | all above |

Each PR ships with: matching tests, on-device check on OPPO A91, no rollback of brand guardrails.

## 8) Flutter architecture changes

Additive only — nothing existing changes shape unless called out.

- **New deps** (`pubspec.yaml`): `flutter_localizations`, `intl`, `flutter` `generate: true`.
  No third-party state lib, no analytics, no ads, no auth, no chess engine.
- **New top-level dirs**:
  - `lib/l10n/` (ARB + generated AppL10n)
  - `lib/features/progress_map/` (Library screen)
  - `lib/core/models/episode.dart` (Episode model + EpisodeLibrary)
- **Extended**:
  - `ProgressStore` (new keys, additive)
  - `GameController` (one new branch in `handleSquare` for non-rescuer selection; no progression
    code changes)
  - `MaterialApp` in `main.dart` (localization delegates + locale resolution)
- **Untouched**:
  - Replayability engine (mirrors/decoys/scenery) — content multiplies for free
  - SessionComposer
  - Readability gate
  - Phase 34/35 polish (focus cue, intro overlay, overflow fix)
- **Tests**:
  - L10n: every supported locale resolves; ARB key presence parity test (no missing keys
    EN→TR/ES).
  - Progression: ProgressStore round-trip for new keys; star award math; streak rollover at
    midnight local; episode → puzzle lookup; library screen widget test.
  - Agency: selecting non-rescuer triggers flash + auto-deselect; rescuer behavior unchanged.

## 9) Localization architecture

```
lib/
  l10n/
    app_en.arb         # default + template
    app_tr.arb
    app_es.arb
    gen/               # generated AppL10n class (gitignored or committed; choose once)
  …
l10n.yaml              # arb-dir: lib/l10n, template-arb-file: app_en.arb,
                       # output-localization-file: app_l10n.dart,
                       # output-class: AppL10n
pubspec.yaml:
  dependencies:
    flutter_localizations: { sdk: flutter }
    intl: ^0.20.x
  flutter:
    generate: true
```

**Device locale resolution** (`main.dart`):

```dart
MaterialApp(
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: const [Locale('en'), Locale('tr'), Locale('es')],
  localeResolutionCallback: (device, supported) {
    final code = device?.languageCode;
    if (code == 'tr' || code == 'es') return Locale(code!);
    return const Locale('en'); // explicit fallback per brief
  },
  …
)
```

**String key conventions**:
- `intro_title`, `intro_body`, `intro_secondary`, `intro_cta`
- `headline_save_the_king`, `headline_where_will_it_go`, `headline_rescued`, `headline_not_the_move`
- `hint_one_move_saves`, `hint_find_the_rescue`, `hint_tap_highlighted`, `hint_default_<puzzleId>`
- `status_active_threat`, `status_attack_broken`, `status_in_check`, … (use family ids)
- `library_title`, `library_episode_progress`, `library_open`
- `streak_today`, `streak_n_days`
- `agency_wrong_piece` (the "try another piece" flash)

**Per-puzzle copy**: each puzzle's `statusText` / `dangerHint` / `failureHint` /
`successExplanation` becomes an ARB key `puzzle_<id>_dangerHint` etc. Authors translate puzzle
copy alongside puzzle authoring.

## 10) Monetization-safe roadmap

Brand commitment from the privacy/data-safety stance is **no ads, no IAP, no tracking**
(`docs/play-console-data-safety.md`, `docs/privacy-policy.md`). The roadmap must not paint us
into a corner where future monetization (if ever needed) would require breaking that promise.

**What's safe in v1 (compatible with later optional monetization):**
- Episode model already supports a future "Pack 4" as a one-time-purchase pack — episodes are
  data-driven, not hardcoded.
- Star/streak state already lives in `ProgressStore` — survives any future IAP add without
  schema migration.
- Localization doesn't preclude later store-page paid versions.
- The agency model is purely UX — no rev-share or platform hook.

**What v1 explicitly forbids** (would break the brand or compliance):
- Ad SDKs (AdMob etc.) — would require Data Safety re-filing, ID-for-advertising, privacy redo.
- Analytics SDKs (Firebase Analytics, Sentry) — same compliance impact.
- Account systems / login (Google Play Games is even riskier — pulls in identifiers).
- Push notifications.
- Any third-party SDK that initializes network at boot.

**If monetization is ever needed (Phase 2+, evidence-driven)**:
1. **Optional tip jar** — single-tier IAP "Support Lunexa Games" (consumable, can be re-tipped).
   No content gating. Re-files Data Safety for the IAP only.
2. **Episode packs** — a single non-consumable IAP per future episode bundle (≥ episode 4). Old
   players keep what they have. No FOMO copy.
3. **Never**: ads, subscriptions, season-passes, daily-rewards-with-counter, streak-recovery sales.

This stance is the brand. Document it once; never relitigate per phase.

## 11) Risk register + guardrails

| Risk | Likelihood | Mitigation |
|---|---|---|
| Content authoring slips (Phase C) | High (authoring is hard) | Ship Episode 1 alone if Ep 2/3 slip; release notes adjust |
| Localization parity gaps | Medium | ARB parity test in CI; native review on TR + ES before promote |
| Visual refinement makes pieces worse | Medium | Each visual PR ships with before/after screenshot exports; reject if "thumbnail tells less" |
| Agency model confuses early players | Low | Keep onboarding rails for E1 L1–L3 (Phase D, O2) |
| Progress map feels like menu-creep | Low | Entry point only on rescued screen, never danger |
| Tester demand for difficulty modes appears post-launch | Possible | Phase 2 hold; "Take it slow" comfort toggle ready to scope |
| AAB size growth from Inter fonts + texture | Low | Inter subset (Latin + Latin-Ext), 1-tile texture; total < 2 MB add |

**Hard guardrails (re-stating)**:
- Never break "One move saves the king."
- **Master Release ships without difficulty modes; difficulty modes never delay v1.1.0.** They
  are Phase 2 at the earliest, gated on post-launch telemetry only (see §0).
- No ads, no IAP, no tracking, no accounts in v1.
- No chess-trainer registers (openings, ratings, opponents, clocks). Ever.
- Calm/relief voice; failure is gentle (no shame copy).
- D4 palette only; Inter as the type system; existing motion language extended, not replaced.
