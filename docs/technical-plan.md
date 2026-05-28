# Technical Plan — Flutter Vertical Slice

## Stack

- **Flutter 3.41+ / Dart 3.11+** stable channel.
- **Platforms:** Android (primary), Linux (developer preview). iOS, web, macOS, Windows intentionally not scaffolded.
- **State management:** `ChangeNotifier` from the SDK. No Riverpod, Bloc, GetX, or Provider. The slice is too small to earn a state library.
- **Rendering:** `CustomPaint` for pieces (no SVG package, no asset images). `Stack` + `Positioned` for board layout. `AnimationController` for the danger pulse and rescue pop.
- **Haptics:** `HapticFeedback` from `flutter/services`. No `vibration` package.
- **Fonts:** system stack only. No `google_fonts`.

The dependency footprint is whatever `flutter create` ships with, plus nothing.

## Directory map

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   └── models/
│       ├── piece.dart
│       ├── square.dart
│       └── puzzle.dart
└── features/
    └── rescue_game/
        ├── game_state.dart
        ├── game_controller.dart
        ├── rescue_screen.dart
        └── widgets/
            ├── board_widget.dart
            ├── piece_widget.dart
            ├── status_bar.dart
            ├── headline_text.dart
            └── footer_button.dart
```

## Data flow

```
RescueScreen
  └─ ListenableBuilder(game)            ← rebuilds on GameController.notifyListeners()
       ├─ StatusBar(state, msg, counter: "PUZZLE n/5")
       ├─ HeadlineText(state)
       ├─ AnimatedSwitcher(key: currentPuzzle.id)   ← crossfade on puzzle change
       │    └─ BoardWidget(
       │         pieces, selected, legal, state,
       │         threatenedKing, rescueTo,
       │         onTapSquare: game.handleSquare,
       │       )
       ├─ HintText(state, dangerHint, failureHint, successExplanation)
       └─ FooterButton(state, label, onTap: game.onPrimaryAction)
```

`GameController` owns all mutable state. Widgets are stateless apart from animation controllers that drive purely visual concerns (danger pulse, rescue glow).

## Move whitelist

There is no chess engine. `GameController._legalMovesFor(Piece)` returns the **current puzzle's** `legalMoves` list when the tapped piece sits on that puzzle's `tappableSquare`, else an empty list (a silent no-op). Each puzzle whitelists one rescue square plus a few decoys.

A move to the puzzle's `rescueTo` wins. Any other whitelisted landing transitions to `failed` and is *not* a win, even if the move would be chess-legal.

See **Phase 12 — Puzzle sequencing** below for the multi-puzzle model.

## Coordinate convention

- `file`: 0–7 (a–h)
- `rank`: 0–7 (1–8)
- Origin is bottom-left from the player's perspective (white at the bottom).
- Screen rendering uses `(file * sq, (7 - rank) * sq)` so rank 7 is at the top of the screen.

This matches `primitives.jsx` exactly to keep cross-referencing trivial.

## Animation strategy

| Concern                  | Implementation                                                          |
|--------------------------|-------------------------------------------------------------------------|
| Danger pulse on king sq  | `AnimationController` (1.8s, repeat reverse) inside `BoardWidget`        |
| Rescue glow + scale pop  | One-shot `AnimationController` (320ms ease-out) triggered on state→rescue|
| Failed flash on king sq  | One-shot `AnimationController` (480ms ease-out) triggered on state→failed |
| Legal-dots fade-in       | `AnimatedOpacity` per dot, 140ms                                         |
| Headline / hint swap     | `AnimatedSwitcher` 220ms                                                 |
| Commit pause             | `Future.delayed(180ms)` inside `GameController.commitMove` before reveal |

Animation controllers are owned by the widgets that play them. The controller does not orchestrate animation timing beyond the commit pause.

## Phase 12 — Puzzle sequencing

The single puzzle became a curated 5-puzzle sequence. Motion (Phase 11) and the D4 palette are untouched.

- **`Puzzle` model** (`lib/core/models/puzzle.dart`) carries per-puzzle data: `id`, `title`, `statusText`, `pieces`, `tappableSquare`, `legalMoves`, `rescueTo`, `rescueNotation`, `dangerHint`, `failureHint`, `successExplanation`, `threatenedKing`, `isPrototype`.
- **`PuzzleLibrary.all`** (`lib/core/models/puzzle_library.dart`) holds the five puzzles hardcoded in Dart. Puzzle 1 is the real canonical rescue; 2–5 are `isPrototype: true` placeholders (block-the-file, capture-the-checker, seal-the-diagonal, win-the-queen). All keep the king stationary so the failed-flash (on `threatenedKing`) stays correct.
- **`GameController`** holds `_index`, the puzzle list, and a session-only `Set<String> _completed`. `onPrimaryAction()` routes the footer button: `rescued` → `nextPuzzle()` (or `startOver()` on the last), otherwise `reset()` (retry/restart the current puzzle, reusing the Phase 11 settle animation).
- **Puzzle transition** is a board-level `AnimatedSwitcher` in `RescueScreen` keyed by `currentPuzzle.id` (240ms crossfade). Same key = in-place update so in-puzzle `AnimatedPositioned` moves still animate; key change = crossfade to the next board in `danger`. No new motion tokens.
- **Counter** `PUZZLE n/5` lives in the status pill (`StatusBar.counter`).
- **Puzzle authoring & quality** conventions (rescue archetypes, the design rubric, and why P2–P5 are prototype placeholders) live in `docs/puzzle-design.md`.

## Phase 14 — Local progress

Progress now persists locally (offline only — no accounts/backend).

- **`ProgressStore`** (`lib/core/storage/progress_store.dart`) is a tiny wrapper over `shared_preferences`. It persists exactly two things: the current puzzle index (`cr_puzzle_index`) and the set of completed puzzle ids (`cr_completed_ids`). Async `create()` loads once; `puzzleIndex` / `completedIds` are then read synchronously; `save()` / `clear()` write.
- **Injection is top-down:** `main()` is async — it builds the store and passes it `ChessRescueApp → RescueScreen → GameController(store:)`. Widgets only forward the reference; no persistence logic lives in UI.
- **Restore:** the controller's constructor reads the store, adds the completed ids (filtered to known puzzles), and `_loadPuzzle(clampedIndex)` — which always sets `state = danger`. Transient `selected`/`rescued`/`failed`/in-flight state is never persisted, so a relaunch always resumes the saved puzzle in `danger`.
- **Save triggers (only three):** on rescue (after adding the id), on next/start-over, and on reset-progress. `_persist()` is fire-and-forget via `unawaited`.
- **Progress display:** a small dim mono `N SAVED` badge top-right of the status row (`SavedBadge`), shown when `completedCount > 0`. The `PUZZLE n/5` counter stays in the pill.
- **Reset (debug):** long-press the `SavedBadge` → `GameController.resetProgress()` clears `_completed`, returns to puzzle 1 in `danger`, fires a haptic, and clears the store. No settings screen, no confirmation.

## Phase 15 — First-run experience

A brand-new player gets a *light-touch* cold open — the normal game, gently biased toward understanding. No onboarding screens, no chrome stripping, no delayed reveals.

- **Flag:** `ProgressStore.onboardingSeen` (`cr_onboarding_seen`). The controller's `_onboarding` is `true` only when a store exists and the flag is unset. `isOnboarding` gates all first-run treatments.
- **Lifecycle:** `onboardingSeen` is persisted at the **first rescue** (so it never re-triggers), but `_onboarding` stays `true` in memory through that rescued screen and flips `false` only when the player advances off puzzle 1 (`onPrimaryAction`). `resetProgress()` re-arms it (debug long-press = "cleared storage").
- **Three onboarding-only nudges** (everything else stays normal — counter, footer, badge all visible):
  1. **Focus cue** — a soft breathing accent glow on `currentPuzzle.tappableSquare` during the opening danger state (`BoardWidget.focusSquare`), reusing the danger-pulse rhythm; fades out (`focusCueFade`) on selection.
  2. **Copy** — `HintText.onboarding` swaps the instructional hints for evocative ones (danger "One move saves the game.", selected "Find the rescue.", failed "The king is still trapped."); rescued keeps its normal explanation.
  3. **Held first rescue** — `BoardWidget.extendedSettle` lengthens the rescue glow's settle by `MotionTokens.firstRescueSettleExtra` (the bloom stays fixed; `bloomEnd` is computed from the live `_rescueBloom.duration`). No CTA delay.
- **Additive motion tokens only:** `firstRescueSettleExtra`, `focusCueFade`, `focusCueAlphaMin/Max`, `focusCueFillAlpha`. Existing tokens unchanged.

## What is intentionally out of scope

- A real legal-move generator (knight moves, slider pieces, check detection).
- Settings, sound, music, themes, accessibility toggles, locale.
- Tests. The success criterion is felt, not asserted. Tests come once the loop is locked.
- Splash screens, app icons beyond Flutter defaults.
- Accounts, backend, multiplayer, monetization, analytics, menus.

## Where the prototype expects to grow

- **Persistence** → done in Phase 14 via `ProgressStore` (`shared_preferences`). To persist more (e.g. best times, per-puzzle stats), extend that store; the injection path stays the same.
- **More puzzles** → append to `PuzzleLibrary.all`; nothing else changes.
- **Real engine** → replace the per-puzzle `legalMoves` whitelist with a `LegalMoveService` wrapping a pure-Dart engine. The board widget's API does not change.
- **Daily cadence (D5)** → a new feature folder `features/daily/` consumes the controller through a daily-puzzle provider.

## Run recipe

```bash
cd /home/fvarli/Desktop/MobileProjects/chess-rescue
flutter pub get
flutter run -d linux         # fastest local preview
# or
flutter run -d <android-id>  # real target
```

Format & lint:

```bash
dart format .
flutter analyze
```
