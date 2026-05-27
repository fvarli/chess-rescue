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
  │                            commit pause (180ms)
  │                              │
  │                ┌─────────────┴─────────────┐
  │                │                           │
  │            (target is f6)              (target is anything else)
  │                │                           │
  │                ▼                           ▼
  │             rescued                     failed
  │                │                           │
  │ (tap button)   │                           │
  └────────────────┴───────────────────────────┘
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

The headline cross-fades over 220ms when state changes. Copy is taken verbatim from `playable.jsx` to preserve the chosen voice — terse, unjudgmental, with a single full stop.

## Status pill (top of screen)

A single capsule pill at the top, monospaced and quiet. It contains a colored dot and a label:

- `danger`:   `▮ Active threat · Qg2#`
- `selected`: `▮ Active threat · Qg2#` *(stays the same — the threat hasn't moved)*
- `rescued`:  `◐ Attack broken · Nf6+`
- `failed`:   `▮ Still trapped`

## Haptics

The slice uses Flutter's built-in `HapticFeedback`:

| Moment                       | Feedback                              |
|------------------------------|---------------------------------------|
| Piece select                 | `HapticFeedback.selectionClick()`     |
| Rescue (correct move)        | `HapticFeedback.mediumImpact()`       |
| Failed (wrong move)          | `HapticFeedback.heavyImpact()`        |
| Reset                        | `HapticFeedback.selectionClick()`     |

No haptic on idle or on tap-miss. We never punish a curious tap.

## Timing summary

| Step                       | Duration |
|----------------------------|----------|
| Selection ring + dots in   | 120–140ms |
| Player tap → commit pause  | 180ms    |
| Rescue reveal              | 320ms    |
| Fail flash + settle        | 480ms    |
| State cross-fade           | 220ms    |

Total budget from rescue-tap to "Rescued." being legible: **~500ms**. Slow enough to feel deliberate, fast enough to feel responsive.
