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

## What is intentionally out of scope

- Persistence (completion is in-memory, session-only).
- A real legal-move generator (knight moves, slider pieces, check detection).
- Settings, sound, music, themes, accessibility toggles, locale.
- Tests. The success criterion is felt, not asserted. Tests come once the loop is locked.
- Splash screens, app icons beyond Flutter defaults.
- Accounts, backend, multiplayer, monetization, analytics, menus.

## Where the prototype expects to grow

- **Persistence** → swap the in-memory `_completed` set for a local store (e.g. `shared_preferences`); the controller API stays the same.
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
