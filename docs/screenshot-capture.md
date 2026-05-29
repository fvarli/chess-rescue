# Screenshot Capture — fast path (< 10 min)

Capture all 6 Play Store phone frames using the **screenshot harness**, which drives the real
`RescueScreen` into each state deterministically (no manual play-through). Marketing headline
bands (copy in `store-assets-spec.md §27C`) are composited afterward in a design tool — this doc
gets you the faithful **raw frames** fast. Companion: `screenshot-workflow.md` (general/compositing).

## Automated export (recommended — Linux desktop, one command)

One command renders all 6 frames **with their §27C headline bands baked in** and writes Play-ready
**1080×2400** PNGs to `assets/store/screenshots/final/` — no manual swiping, no separate compositing:

```sh
flutter run -t lib/debug/screenshot_harness.dart -d linux --dart-define=SHOT_EXPORT=true
```

It drives each state, captures via `RepaintBoundary.toImage(pixelRatio: 3.0)`, prints
`SHOT_EXPORT_DONE`, and exits. Output: `01-hook.png … 06-everyday-comeback.png`. Overrides:
`--dart-define=SHOT_OUT=<dir>` (output dir) and `--dart-define=INTER_TTF=<path>` (a real Inter
`.ttf` for type fidelity — falls back to the engine's system sans if absent; **never bundled into
the app**). Debug-only entrypoint; absent from any release build.

The manual on-device flow below stays available — e.g. to capture on a specific phone, or to hand
raw frames to a designer for custom band compositing.

## 1. Boot a 1080×2400 device

Use a real phone or an emulator at **1080×2400** (9:16), e.g. a Pixel-class AVD. Portrait.

## 2. Run the harness

```sh
flutter run -t lib/debug/screenshot_harness.dart -d <device>
```

It opens a 6-page **swipe** deck. Each page auto-drives to its state and shows a small
**verification chip** — `[SHOT n]` · beat · target headline — so you always know which frame
you're on. (Debug-only entrypoint; never ships in release.)

## 3. Capture each frame

Swipe pages **1 → 6**, in order. On each page wait for it to settle (the chip + a stable board),
then grab the frame:

```sh
flutter screenshot --out=assets/store/screenshots/shot_1.png
# …or Android:
adb exec-out screencap -p > assets/store/screenshots/shot_1.png
```

| Shot | Beat | State captured | Seed / puzzle | Marketing headline to composite (§27C) |
|---|---|---|---|---|
| 1 | Hook | danger, SAVED 4 | seed 0 · `p5-win-the-queen` | "It looks lost. It isn't." |
| 2 | Danger | danger (cold open) | seed 0 · `p1-knight-rescue` | "Your king is in danger." |
| 3 | One Move | selected (move-dots) | seed 0 · `p1-knight-rescue` | "One move can save it." |
| 4 | Rescue | rescued (mint bloom) | seed 0 · `p1-knight-rescue` | "Rescued." |
| 5 | Completion | rescued + all done | seed 0 · finale + SAVED badge | "The board is quiet now." |
| 6 | Everyday comeback | danger (fresh) | seed 1 · opener | "Always one move from saved." |

## 4. Turn the overlay OFF for the real capture

The chip is for orientation only. In `lib/debug/screenshot_harness.dart` set:

```dart
const bool _showShotOverlay = false;
```

Hot-restart, then re-capture clean frames (no chip). (The chip is also `kDebugMode`-gated, so it
can never appear in a release build regardless.)

## 5. Composite the headline bands

Over each raw frame add the §27C **headline + subheadline** band (Inter Tight, dark field, one
accent per beat) in a design tool, export at 1080×2400. (Kept out of the harness so type quality
stays in design control — see the Phase-28 typography note.)

---

**Total:** boot (≈2 min) + run (≈1 min) + swipe/capture ×6 (≈3 min) → raw frames in **< 10 min**.
The band compositing is a separate, quick design pass.
