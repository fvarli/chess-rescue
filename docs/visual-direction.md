# Visual Direction — D4 Convergence

The primary visual direction for Chess Rescue is **D4 Convergence**: a deep matte canvas, slate-on-charcoal board, and two state colors (coral danger, mint rescue) that carry every emotional beat.

Source of truth: `docs/components/d4-converge.jsx` and `docs/components/primitives.jsx`.

## Palette

| Token         | Hex / RGBA                       | Use                                          |
|---------------|----------------------------------|----------------------------------------------|
| `bg`          | `#0D0E12`                        | App background, deep navy-black              |
| `surface`     | `#161821`                        | Cards, raised surfaces                       |
| `surface2`    | `#1D2030`                        | Secondary raised surfaces                    |
| `text`        | `#EAEAF2`                        | Primary text, light pieces                   |
| `textDim`     | `rgba(234,234,242,0.55)`         | Hint copy, dimmed labels                     |
| `textMuted`   | `rgba(234,234,242,0.32)`         | Coordinates, micro-labels                    |
| `hairline`    | `rgba(255,255,255,0.07)`         | 1px dividers, button borders                 |
| `boardLight`  | `#3A3E4C`                        | Light squares (slate)                        |
| `boardDark`   | `#1A1C26`                        | Dark squares (charcoal)                      |
| `gridLines`   | `rgba(255,255,255,0.04)`         | Faint inner grid                             |
| `danger`      | `#FF5A4C`                        | Threat, failure, king-in-check               |
| `rescue`      | `#5EE2C0`                        | Rescue, win, success glow                    |
| `accent`      | `#8AA1FF`                        | Selection ring, legal-move dots              |
| `pieceLight`  | `#EAEAF2`                        | Light piece fill                             |
| `pieceDark`   | `#0C0D14`                        | Dark piece fill                              |

**Piece strokes:** light pieces stroke with `rgba(12,13,20,0.55)`; dark pieces stroke with `rgba(234,234,242,0.22)`. Stroke weight `1.15px` (scaled to viewBox 100×100).

## Typography

- **Display:** system sans (Inter Tight if available) — used for headlines and body. Letter-spacing tightened to `-0.01em` at 22px and above.
- **Mono:** system monospace — used only for the top status pill and any micro-labels, uppercase, letter-spacing `0.14em`.

Two text styles, no more. The product earns drama from color and silence, not typographic variety.

## Pieces

Pieces are custom-painted vector silhouettes transcribed from `primitives.jsx:14-148`. Each piece is built from primitive shapes (paths, circles, ellipses) on a 100×100 viewBox so silhouettes stay crisp at touch sizes.

- **King** — Greek cross finial, tapered body, two-band collar.
- **Queen** — five-bead crown, slender body (narrower than king).
- **Rook** — four battlements, cylindrical body, broad base.
- **Bishop** — pointed mitre with a single diagonal slit.
- **Knight** — horse-head profile, facing left. Iconic.
- **Pawn** — spherical head, soft body, broad base.

No fantasy pieces. No imported chess fonts. No PNG sprites.

## Board

- 8×8, square cells of `boardSize / 8`.
- 4px corner radius on the board frame.
- Outer shadow: `0 30px 60px rgba(0,0,0,0.55)` + 1px white hairline at 4% opacity.
- Optional inner grid at 4% white for tactile texture.

## State decoration

| State      | Treatment                                                                                                  |
|------------|------------------------------------------------------------------------------------------------------------|
| `danger`   | Threatened king square: 2px `danger` border + outer glow alpha 0.40↔0.65, 2.4s asymmetric breath (40% in / 60% out), 2% scale breath. |
| `selected` | Origin square: 2.5px `accent` border + `accent@15%` fill, scaled in 0.94→1.0 over 140ms. Selected piece itself lifts to scale 1.05. |
| `legal`    | Empty target: filled `accent` dot at 28% square radius. Occupied: 2px `accent@80%` ring. Dots fan by Manhattan distance, 24ms/step. |
| `rescued`  | Destination square: 2px `rescue` border + glow with bloom (1.0→1.08, 280ms) → settle (1.08→1.02, 420ms) → breath loop (alpha 0.45↔0.60, 3s). Rescued knight ambient-lifted to 1.04. |
| `failed`   | Threatened king square: 140ms `danger` flash + 1px / 2-cycle / 80ms micro-shake → 380ms easeOutCubic fade. |

## Motion

All values live in `lib/core/theme/motion.dart` as `MotionTokens` — single source of truth.

| Element                            | Duration       | Curve                         |
|------------------------------------|----------------|-------------------------------|
| Selection ring scale-in            | 140ms          | easeOutCubic                  |
| Piece lift (1.0 → 1.05)            | 180ms          | easeOutCubic                  |
| Legal dot bloom (per dot)          | 180ms          | easeOutCubic                  |
| Legal dot stagger (per group)      | +24ms each     | distance-ordered              |
| Commit wind-up (ring contract)     | 80ms           | easeOutCubic                  |
| Piece slide (commit)               | 220ms          | easeInOutCubic                |
| Danger pulse                       | 2400ms (40/60) | easeOutSine → easeInSine      |
| Rescue bloom                       | 280ms          | easeOutCubic                  |
| Rescue settle                      | 420ms          | easeOutCubic                  |
| Rescue breath (loop)               | 3000ms         | easeInOutSine                 |
| Failed hold                        | 140ms          | (flat)                        |
| Failed fade                        | 380ms          | easeOutCubic                  |
| Failed micro-shake                 | 80ms / 2 cycles| sine                          |
| Background gradient transition     | 600ms          | easeOutCubic                  |
| Headline cross-fade + 6px slide    | 240ms (320 rescued) | easeOutCubic             |
| Hint cross-fade (delayed)          | 320ms (80 wait)| easeOutCubic                  |
| Button press in / out              | 80 / 160ms     | easeOut / easeOutCubic        |
| Failed-state invite breath         | 2400ms loop    | easeInOutSine                 |
| Board ambient breath               | 4800–6400ms    | easeInOutSine                 |
| Reset overlay fade                 | 200ms          | easeOutCubic                  |
| Reset settle                       | 320ms          | easeOutCubic                  |

Motion is restrained on purpose. The board breathes; it does not perform. Symmetric `easeInOut` is deliberately avoided — it reads as machine timing.
