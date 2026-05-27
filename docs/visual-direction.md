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

| State      | Treatment                                                                                  |
|------------|--------------------------------------------------------------------------------------------|
| `danger`   | Threatened king square: inset 2px `danger` border, outer glow `danger@66%`, 1.8s pulse.    |
| `selected` | Origin square: inset 2px `accent` border, `accent@25%` fill.                               |
| `legal`    | Empty target: filled `accent` dot at 28% square radius. Occupied: 2px `accent@80%` ring.   |
| `rescued`  | Destination square: inset 2px `rescue` border, outer glow `rescue@66%`, 320ms scale pop.   |
| `failed`   | Threatened king square: 180ms `danger` flash, then 300ms ease-out fade.                    |

## Motion

| Element                      | Duration | Curve            |
|------------------------------|----------|------------------|
| Selection ring appear         | 120ms    | ease-out         |
| Legal-move dots fade in       | 140ms    | ease-out         |
| Move-commit pause             | 180ms    | linear hold      |
| Rescue glow ramp + scale pop  | 320ms    | ease-out         |
| Danger pulse                  | 1800ms   | ease-in-out loop |
| Headline / hint cross-fade    | 220ms    | ease-out         |
| Failed flash + fade           | 480ms    | ease-out         |

Motion is restrained on purpose. The board breathes; it does not perform.
