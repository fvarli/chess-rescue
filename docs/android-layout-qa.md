# Android Layout QA

Manual checklist for verifying the single-screen layout on real Android phones.
Chess Rescue is a board-dominant, portrait, no-scroll game; the goal of this QA
is "nothing overflows, the board stays the hero, everything is one-thumb
reachable" — not pixel perfection across every device.

## Tested layout assumptions

- **Portrait only** (`setPreferredOrientations([portraitUp])` in `main.dart`).
- **Text scale clamped to 1.35×** (`MediaQuery.withClampedTextScaling` in `main.dart`) so the fixed composition stays stable; larger system fonts are honored only up to 1.35×.
- **Board size** = `min(maxWidth − 32, maxHeight − 260)` clamped to `[200, 360]` (logical px), computed inside `SafeArea`. On normal/tall phones it is width-bound (≈360) — identical to before; it only shrinks on short screens.
- **No scroll by design.** The reserve (260) covers the status row, headline, two-line completion hint, footer, and gaps at 1.35× text. Pathological tiny heights (<~440 logical, e.g. small split-screen) are out of scope.

## Build / run

```bash
flutter build apk --debug                 # → build/app/outputs/flutter-apk/app-debug.apk
flutter run -d <android-device-id>        # flutter devices to list
flutter build linux --debug && ./build/linux/x64/debug/bundle/chess_rescue   # desktop smoke
# Re-test first run (clear local progress):
rm ~/.local/share/com.chessrescue.chess_rescue/shared_preferences.json   # Linux
# Android: clear app storage in Settings, or `adb shell pm clear com.chessrescue.chess_rescue`
```

## Device profiles

- [ ] **1080×2400** (Pixel-class) emulator — primary target.
- [ ] **Small phone** ~720×1280 / 360dp wide — tightest common case.
- [ ] **Large phone** (e.g. 1440×3120).
- [ ] **Linux desktop** — resize the window very narrow and very short to stress the formula (board should shrink, no overflow banner).

## Text scale

- [ ] System font size at maximum → layout stays stable (clamped 1.35×), no overflow, board still dominant, hint + footer still fit.

## Flows

- [ ] First-run cold open: soft focus pulse on the rescuing piece; hint "One move saves the game." (full interface visible).
- [ ] Select → legal dots fan out → commit f6 → "Rescued." (first rescue settles a beat longer).
- [ ] Wrong move → "Not the move." + danger flash/micro-shake → "Try again ↺" → retry returns to danger.
- [ ] "Next puzzle ↦" → board crossfades to the next puzzle in danger; counter increments.
- [ ] Complete all five → footnote "The board is quiet now." beneath the move line; SAVED badge turns mint; footer "Start over ↻".
- [ ] Start over → puzzle 1 in danger; badge stays mint; footnote gone.
- [ ] Relaunch → resumes the saved puzzle in danger; SAVED count persists; onboarding does NOT reappear.
- [ ] Long-press the SAVED badge (debug reset) → back to puzzle 1, badge clears, onboarding re-arms on next launch.

## Layout checks

- [ ] No render-overflow banner in any state (especially the 2-line completion finale).
- [ ] Board centered and clearly dominant.
- [ ] Footer button reachable one-thumb; tap target comfortable (~48px).
- [ ] Status pill and SAVED badge do not collide on the top row.
- [ ] Hint never clips or wraps awkwardly.
- [ ] Safe-area correct on notch / camera cutout / gesture-nav bar (content inset, gradient bleeds behind).

## Haptics (on device, system haptics enabled)

- [ ] Selection tick on piece tap.
- [ ] Medium impact on rescue.
- [ ] Heavy impact on failed move.
- [ ] Selection tick on footer button / reset.
- Note: impacts use `HapticFeedback` constants (no VIBRATE permission needed); strength varies by device and OS haptic settings.

## Performance

- [ ] 60fps with the danger pulse + ambient board breath + rescue glow running.
- [ ] No jank on the puzzle-to-puzzle crossfade or the commit slide.
