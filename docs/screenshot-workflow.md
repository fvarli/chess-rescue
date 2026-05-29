# Screenshot Capture Workflow — Chess Rescue

How to capture the Play Store phone screenshots. The **narrative, headlines, and composition**
are specced in `store-assets-spec.md §27C`; this doc is the *capture + compositing* recipe.
(Raw captures can't be produced here — there's no GUI/emulator to drive — so this is a manual
step. Output goes to `assets/store/screenshots/`.)

Target: **1080×2400** (9:16), 6 frames, dark field. Play needs ≥2; we ship the 6-beat set.

## A. Capture the raw game states

Run a release build on a 1080×2400 phone or emulator and reach each state, then grab the frame:

```sh
flutter run --release -d <device>
# reach the state, then either:
flutter screenshot --out=assets/store/screenshots/raw_<n>.png
# or (Android):
adb exec-out screencap -p > assets/store/screenshots/raw_<n>.png
```

States to capture (→ map to the §27C beats):
1. **Danger** — king glowing coral, threat pill (raw for screens 1 & 2).
2. **Selected** — hero piece lifted, accent move-dots fanned out (screen 3).
3. **Rescued** — mint bloom on the destination, "◐ Attack broken" (screen 4).
4. **Completion** — "The board is quiet now." + mint SAVED badge (screen 5).
5. **A fresh danger board** (a different session) — for the everyday-comeback close (screen 6).

Tip: for clean, repeatable states, set a known seed / use the debug entrypoints, and disable
the focus pulse mid-capture if it blurs the frame.

## B. Composite the store frames

Over each raw capture, add the **Inter Tight headline band** (top) + textDim subheadline from
the §27C table, on the dark field, in a design tool (Figma/Sketch/Affinity). Keep one accent
color per beat; consistent band placement; export at 1080×2400.

| Screen | Raw state | Headline (see §27C for subheadline) |
|---|---|---|
| 1 Hook | Danger (most dramatic) | "It looks lost. It isn't." |
| 2 Danger | Danger | "Your king is in danger." |
| 3 The move | Selected | "One move can save it." |
| 4 Rescue | Rescued | "Rescued." |
| 5 Completion | Completion | "The board is quiet now." |
| 6 Everyday comeback | Fresh danger board | "Always one move from saved." |

## C. Optional future automation

A widget test can drive `RescueScreen` into each state and capture raw frames headlessly via a
`RepaintBoundary` → `toImage(format: png)` (no device needed). The headline/subheadline
compositing still belongs in a design tool (real Inter Tight). Not built yet — capture manually
for the first closed test.
