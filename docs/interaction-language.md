# Interaction Language

Chess Rescue has four states and three transitions. That's it.

## States

| State      | What it means                                                              |
|------------|----------------------------------------------------------------------------|
| `danger`   | Puzzle is live. King is in peril. Status pill is red. Hint invites a tap.  |
| `selected` | Player has tapped their piece. Legal-move dots are visible. King still red.|
| `rescued`  | The rescue move landed. Board breathes mint. Status pill turns green.      |
| `failed`   | A non-rescue move was committed. King flashes red. Hint softens, offers retry. |

Initial state is always `danger`. There is no `idle`, no `paused`, no `menu`.

## Transitions

```
       (tap rescuing piece)
danger ─────────────────────►  selected
  ▲                              │
  │                              │ (tap any legal square)
  │                              ▼
  │                  wind-up (80ms) → slide (220ms)
  │                              │
  │                ┌─────────────┴─────────────┐
  │                │                           │
  │            (target is f6)              (target is anything else)
  │                │                           │
  │                ▼                           ▼
  │             rescued                     failed
  │           (bloom → settle              (140ms flash +
  │            → breath loop)               micro-shake →
  │                │                        380ms fade)
  │ (tap button)   │                           │
  └────────────────┴───────────────────────────┘
                (320ms settle)
```

There is **always** exactly one button on screen: `Reset` in `danger` / `selected`, `Try again ↺` in `failed`, `Reset` (filled mint) in `rescued`.

## Tap targets

- Only **the rescuing knight (e4)** is tappable in the slice. Tapping any other white piece is a no-op. Tapping black pieces is a no-op.
- When `selected`, tapping any of the 8 hardcoded legal squares commits a move. Tapping anywhere else clears the selection silently and returns to `danger`.

This is deliberate scope reduction. We are validating *the rescue*, not chess exploration.

## Copy per state

| State      | Headline                  | Hint                                                            |
|------------|---------------------------|-----------------------------------------------------------------|
| `danger`   | Save the king.            | Tap a white piece to see its moves.                             |
| `selected` | Where will it go?         | Tap a highlighted square to move.                               |
| `rescued`  | Rescued.                  | knight to f6 · check & fork *(mono, all caps, letter-spaced)*   |
| `failed`   | Not the move.             | That move doesn't break the attack. Look for a check.           |

Headlines cross-fade with a 6px upward slide; the hint follows ~80ms later, so reading lands as a sequence: verdict, then meaning. Copy is taken verbatim from `playable.jsx`.

## Status pill (top of screen)

A single capsule pill at the top, monospaced and quiet. It contains a colored dot and a label:

- `danger`:   `▮ Active threat · Qg2#`
- `selected`: `▮ Active threat · Qg2#` *(stays the same — the threat hasn't moved)*
- `rescued`:  `◐ Attack broken · Nf6+`
- `failed`:   `▮ Still trapped`

## Haptics

The slice uses Flutter's built-in `HapticFeedback`, accessed through `lib/core/haptics.dart` so the tactile vocabulary stays consistent:

| Moment                       | Feedback                              |
|------------------------------|---------------------------------------|
| Piece select                 | `selectionClick()`                    |
| Commit tap (immediate)       | `selectionClick()`                    |
| Rescue arrival               | `mediumImpact()`                      |
| Failed arrival               | `heavyImpact()`                       |
| Footer button (on tap-down)  | `selectionClick()`                    |

The commit produces **two haptics**: one on tap (acknowledges the touch) and one on arrival (carries the outcome). No haptic on idle or on tap-miss. We never punish a curious tap.

## Timing summary (Phase 11)

All values live in `lib/core/theme/motion.dart` as `MotionTokens`.

| Step                            | Duration       | Curve                  |
|---------------------------------|----------------|------------------------|
| Selection ring scale-in         | 140ms          | easeOutCubic           |
| Piece lift (1.0 → 1.05)         | 180ms          | easeOutCubic           |
| Legal dot bloom (per dot)       | 180ms          | easeOutCubic           |
| Legal dot stagger (per group)   | +24ms each     | (distance-ordered)     |
| Commit wind-up (ring contract)  | 80ms           | easeOutCubic           |
| Piece slide                     | 220ms          | easeInOutCubic         |
| Danger pulse                    | 2400ms (40/60) | easeOutSine→easeInSine |
| Rescue bloom                    | 280ms          | easeOutCubic           |
| Rescue settle                   | 420ms          | easeOutCubic           |
| Rescue breath (loop)            | 3000ms         | easeInOutSine          |
| Failed hold                     | 140ms          | (flat)                 |
| Failed fade                     | 380ms          | easeOutCubic           |
| Failed micro-shake              | 80ms / 2 cycles| sine                   |
| Background gradient transition  | 600ms          | easeOutCubic           |
| Headline cross-fade + slide     | 240ms (320 res)| easeOutCubic           |
| Hint cross-fade (delayed)       | 320ms (80 wait)| easeOutCubic           |
| Button press in                 | 80ms           | easeOut                |
| Button press out                | 160ms          | easeOutCubic           |
| Failed invite breath            | 2400ms loop    | easeInOutSine          |
| Board ambient breath            | 4800–6400ms    | easeInOutSine          |
| Reset overlay fade              | 200ms          | easeOutCubic           |
| Reset settle                    | 320ms          | easeOutCubic           |

Total budget from rescue-tap to "Rescued." being legible: **~580ms** (80 wind-up + 220 slide + 280 bloom). Slow enough to feel deliberate, fast enough to feel responsive.

## Motion Rationale (Phase 11 — why each token is what it is)

The values above were tuned in Phase 11 to refine the *felt quality* of the rescue loop without touching gameplay, copy, or palette. Each refinement carries a one-line reason and an "avoided" note so future-you knows what was deliberate.

### Piece selection — grasp, don't tag
- **What:** Ring scales in 0.94 → 1.0 over 140ms; selected piece lifts to scale 1.05 over 180ms.
- **Why it improves feel:** the piece acknowledges the touch with a physical change of its own, not just a ring drawn around it.
- **Avoided:** large scale (≥1.10) which reads arcade; `easeOutBack` overshoot; pulsing the ring (would compete with the danger pulse).

### Legal-move dots — fan, don't pop
- **What:** Dots stagger by Manhattan distance from origin, 24ms per group, each blooming 180ms with scale 0.6 → 1.0.
- **Why it improves feel:** fan-out gives the move set a *direction* — moves grow outward from the piece, reinforcing causality.
- **Avoided:** stagger >40ms/step (feels like loading); aggressive start scale (<0.4) reads as zooming in.

### Move commitment — the knight should travel
- **What:** 80ms wind-up (ring contracts, dots fade) → 220ms easeInOutCubic slide → outcome.
- **Why it improves feel:** teleporting pieces is the single biggest "prototype" tell. The 220ms slide turns the commit moment into a journey, and the dual-haptic structure (tap + arrive) doubles tactile information.
- **Avoided:** arced/parabolic slide (overdesigned); multi-segment knight-L path (steals attention from outcome).

### Danger pulse — breathe, don't alarm
- **What:** 2400ms period, asymmetric (40% easeOutSine inhale / 60% easeInSine exhale), alpha 0.40–0.65, with a 2% scale breath on the king square.
- **Why it improves feel:** symmetric easing reads like a smoke alarm; asymmetric breath reads like a thing under stress.
- **Avoided:** color shift (would read as state change); haptic on each pulse (nightmare); particle emission.

### Rescue glow — bloom → settle → breath
- **What:** 280ms bloom (scale 1.0 → 1.08, glow 0 → 0.85) → 420ms settle (1.08 → 1.02, 0.85 → 0.55) → 3000ms breath loop (alpha 0.45 ↔ 0.60).
- **Why it improves feel:** the prior glow stopped animating after 320ms and just sat at full alpha — emotionally flat. Bloom → settle → breath is the shape of relief: a brief lift, then a long slow exhale.
- **Avoided:** fireworks, expanding rings, color sweeps, screen shake.

### Failed flash — sting, don't shout
- **What:** 140ms solid + 380ms easeOutCubic fade, with an 80ms / 2-cycle / 1px horizontal micro-shake on the leading edge.
- **Why it improves feel:** the prior 180+300 hold-then-fade read as "considered" rather than "stung." Shorter hold + longer decay + 1px wince makes failure feel like a moment that *passes*.
- **Avoided:** whole-board shake; red full-screen flash; X-mark icon; sad-trombone copy.

### Background gradient — slow + ease
- **What:** 600ms easeOutCubic transition, with center.y shifting -0.2 → -0.1 in rescued (warmth comes *up* toward the player).
- **Why it improves feel:** linear easing on chrome reads as "machine." 600ms easeOutCubic reads as "intentional."

### Headline + hint — staggered settle
- **What:** Headline 240ms easeOutCubic + 6px upward slide; hint 320ms with first 80ms held (delayed entry).
- **Why it improves feel:** parallel fade made the two texts feel like one block of UI. Stagger creates a reading sequence — verdict, then meaning.
- **Avoided:** typewriter; character-by-character; scale-in.

### Footer button — immediate press, breath on fail
- **What:** GestureDetector (no InkWell). Press 1.0 → 0.97 over 80ms easeOut on tap-down with haptic; return 0.97 → 1.0 over 160ms easeOutCubic on tap-up. In `failed` state only, ambient breath scale 1.0 ↔ 1.012 over 2400ms.
- **Why it improves feel:** Material InkWell carries ripple-completion latency that disagrees with the "tactile" intent. Custom press lands haptic + visual on the same frame as the touch.
- **Avoided:** large bounce; glow burst; color flash; "Try again!" exclamation.

### Board ambient breath — alive at rest
- **What:** Whole-board scale 1.000 ↔ 1.006 over 4800ms (danger/selected), 6400ms (rescued), held at 1.0 for 600ms after a fail then resumed.
- **Why it improves feel:** a fully static board is the third "prototype" tell. A 0.6% scale change is invisible until you stop and ask why the screen feels alive — exactly the level of motion wanted at idle.
- **Avoided:** rotation; drift; parallax; color cycling; >1% amplitude.

### Reset — settle, don't snap
- **What:** 200ms overlay fade (rescue/fail glow → 0) → state snaps back, AnimatedPositioned slides the knight home over 220ms → 320ms settle window during which danger pulse and gradient re-engage.
- **Why it improves feel:** a snap-reset reads as "the simulation was reloaded." 520ms total reads as "the position has been restored."
- **Avoided:** full board fade-to-black; spin/flip transitions; modal "Replay?" sheet.

### Motion curve audit
- **What:** All curves resolved to `easeOutCubic` (UI standard), `easeInOutCubic` (slide), `easeInOutSine` (breath), `easeOutSine` / `easeInSine` (asymmetric breath), `easeOut` (press). Defaults `easeInOut` and `easeOut` are gone where avoidable.
- **Why it improves feel:** consistent curves create a felt language; defaults create a felt absence of intent.
