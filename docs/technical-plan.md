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
       ├─ StatusBar(state, msg)
       ├─ HeadlineText(state)
       ├─ BoardWidget(
       │      pieces, selected, legal, state,
       │      onTapSquare: game.handleSquare,
       │   )
       └─ FooterButton(state, onReset: game.reset)
```

`GameController` owns all mutable state. Widgets are stateless apart from animation controllers that drive purely visual concerns (danger pulse, rescue glow).

## Move whitelist

There is no chess engine. `GameController.select` and `commitMove` consult a hardcoded `legalMovesFor(Piece)` function that mirrors `playable.jsx:14-25`. For this slice, only the knight on e4 returns a non-empty list — its 8 destination squares. Anything not in that list is a silent no-op.

A move to `(5,5)` = f6 wins. Any other landing transitions to `failed` and is *not* a win, even if the move would be chess-legal.

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

## What is intentionally out of scope

- Multiple puzzles, puzzle progression, puzzle library.
- A real legal-move generator (knight moves, slider pieces, check detection).
- Settings, sound, music, themes, accessibility toggles, locale.
- Tests. The success criterion is felt, not asserted. Tests come once the loop is locked.
- Splash screens, app icons beyond Flutter defaults.

## Where the slice expects to grow

- **More puzzles** → `puzzle.dart` becomes a list; `GameController` takes a `Puzzle` in its constructor.
- **Real engine** → replace the `legalMovesFor` whitelist with a `LegalMoveService` that wraps a pure-Dart engine. The board widget's API does not change.
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
