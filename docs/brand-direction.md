# Brand & Store Asset Direction — Chess Rescue

The creative brief for store-facing identity (app icon, screenshots, feature graphic,
marketing). **This is a spec, not the rendered art** — a designer or image tool produces the
PNGs from it. Grounded in the in-game **D4** system (`visual-direction.md`); store steps live in
`closed-test-checklist.md`; listing copy in `play-store-metadata-draft.md`.

Chess Rescue is a **mobile-first emotional rescue game** (panic → insight → rescue → relief →
pride), not a chess platform/trainer/engine/database. The brand sells **"I survived,"** not
"I solved a chess exercise."

## Brand spine & palette (locked — from D4, use verbatim)

**Spine:** *danger → the one move → relief* = **coral → leap → mint**, on a deep field.

| Role | Hex |
|---|---|
| Field (deep) | `#0D0E12` |
| Surface / raised | `#161821` / `#1D2030` |
| **Danger (coral)** | `#FF5A4C` |
| **Rescue (mint)** | `#5EE2C0` |
| Accent (periwinkle) | `#8AA1FF` |
| Text / dim | `#EAEAF2` / 55% |

**Type:** Inter Tight (display, tracking −0.01em ≥22px); system mono only for micro-labels
(uppercase, 0.14em). Two styles, no more. **Voice:** calm, relieving, unjudgmental, premium —
never clever or competitive.

**Avoid always:** generic chess pieces, chess-club / federation / academy / tournament emblems,
medieval/casino/gamer-neon. Chess appears only as *DNA* (the knight's leap; the king as the
saved subject), never as a literal club piece.

## 1. Brand direction

**"The one move between lost and saved."** Identity is an *emotional arc*, not a chessboard.
Every asset retells one three-part story in the D4 palette — a **coral danger zone**, a **single
luminous leap**, a **mint zone of relief** — on the near-black field, with generous negative
space and zero ornament. Reads *premium · intelligent · emotional · minimal*, and is
unmistakable in a store full of wooden boards and white knights.

## 2. Top 5 icon concepts

Format: **symbolism · emotional signal · store visibility · small-size readability · uniqueness
· implementation.**

### ★ Concept 1 — "The Leap" (RECOMMENDED)
A single luminous **two-segment stroke** abstracting the knight's move (the 2-then-1 dog-leg of
Nf6+) — *not a horse, not an L-piece* — launching from a small **coral** danger node (lower-left)
and arcing up to land in a **mint** relief glow (upper-right). The stroke grades coral→mint along
its path; a soft mint bloom marks the landing. One gesture, two zones, dark field. Rescue reads
first; chess is subtext.
- **Symbolism:** the one move that escapes danger; the leap *is* the rescue.
- **Emotional signal:** motion, escape, "I got out" — hope, not strategy.
- **Store visibility:** luminous mint on near-black pops hard against white/wood chess icons.
- **Small-size readability:** one bold stroke + endpoint glow reads at 48px (tune weight; keep the dog-leg legible; no fine detail).
- **Uniqueness:** very high — no chess app uses an abstract leap path; fully ownable.
- **Implementation:** low–med (vector stroke + gradient + glow). Adaptive-icon clean: foreground = stroke+bloom, background = the dark field.

### Concept 2 — "The Released Breath"
A single soft-cornered square, lower half **coral**, upper half **mint**, with a thin luminous
seam where they meet (the instant of rescue).
- Panic → relief · pure feeling · bold duotone (very strong) · excellent at small size · high but
  genre-mute (no chess) · trivial to build. *(Pure-emotion alternate.)*

### Concept 3 — "The Saved King"
A minimal **custom geometric crown/king mark** (never a chess-set piece) lit from below by a mint
relief halo on the dark field.
- The survivor · protection/pride · good visibility · good small-size if simple · med uniqueness ·
  med build (must stay abstract to dodge the club look). *(Highest chess signal.)*

### Concept 4 — "The Open Net"
A tight **coral** lattice / closing ring on the dark field, broken open on one side into a **mint**
arc — the way out.
- Escape, danger→safety · survival/breakthrough · strong visibility · med small-size (keep to 2–3
  lines) · high uniqueness · med build. *(Pure rescue metaphor, no piece.)*

### Concept 5 — "The Single Move Dot"
An ultra-minimal cousin of #1: one luminous dot **leaping a gap** from a coral edge to a mint
landing, as an arcing trajectory.
- One move, one survivor · precise escape · good visibility · excellent at small size · high
  uniqueness · trivial build. *(Minimalist fallback if #1 muddies at 48px.)*

## 3. Screenshot strategy

A 6-beat narrative mirroring **panic → insight → rescue → relief → pride → invitation**. Each:
a real in-game capture on the dark field + one **Inter Tight** headline band (top), one accent
color per beat, consistent layout. (Store preview shows the first 2–3 — front-load the hook + the
leap.)

| # | Game state | Headline | Emotion |
|---|---|---|---|
| 1 | **Danger** — king glowing coral, threat named | "A position that looks lost." | panic |
| 2 | **Selected** — accent move-dots fanned out | "One move can save it." | insight |
| 3 | **Rescued** — the mint breath landing *(money shot)* | "Rescued." | relief |
| 4 | **Failed → retry** softness | "Miss it? No loss screen — just breathe and try again." | calm/safety |
| 5 | **Completion** — "The board is quiet now." + mint SAVED badge | "A 90-second ritual." | quiet pride |
| 6 | Clean type card / cold-open | "No chess skill required. Just the relief of getting out." | invitation |

## 4. Feature graphic (1024×500)

**Concept A (recommended) — "The Leap, large":** the hero leap motif (coral→mint stroke + mint
landing bloom) as focal point on the left third of the dark field; wordmark **CHESS RESCUE**
(Inter Tight, `#EAEAF2`, tight tracking) + tagline *"One move saves the king."* (textDim) on the
right. **Focal point:** the mint landing glow. Rule-of-thirds, heavy negative space, premium calm.

**Concept B — "Danger→Safe field":** a subtle radial gradient sweeping coral (left) → mint (right)
across the dark field (echoes the in-game backdrop transition); wordmark centered on the seam; the
leap mark as a small accent. Focal: the wordmark at the coral/mint boundary.

Typography: Inter Tight, ≤2 weights; tagline dimmed; no third font. Emotional focus: relief
(mint-dominant resolved half). **Recommend A** — icon and feature graphic then share one motif.

## 5. Final recommended direction

- **Icon:** Concept 1 **"The Leap"** (abstract knight-leap, coral→mint, dark field); Concept 5 as
  the 48px fallback if the dog-leg muddies.
- **Screenshots:** the 6-beat narrative; beats 1–3 are the store-preview hook.
- **Feature graphic:** Concept A, sharing the leap motif with the icon.
- **System:** D4 palette verbatim · Inter Tight · the *danger→leap→relief* spine · calm voice.

One ownable mark scaling from 48px icon → feature graphic → future splash/press, all telling the
same rescue story.

## Asset production spec (exact targets)

A designer or image tool renders these from the brief; then wire the icon via
`flutter_launcher_icons` (recipe in `closed-test-checklist.md`).

- **Master icon:** 1024×1024 PNG (flatten — no alpha — for the Play 512×512 listing export).
- **Adaptive icon:** foreground = the leap mark; background = `#0D0E12`. Keep the mark inside the
  central **~66% safe zone** (Android masks to circle/squircle); verify the **48px** render.
- **Feature graphic:** 1024×500 PNG/JPG.
- **Screenshots:** 1080×2400 (9:16), 2–8 frames, dark field + Inter Tight headline band, capturing
  the four signature states (danger / selected / rescued / completion).

**Design-review gate (the lead, on rendered art — I can't view it):** does the icon read *rescue*
(not chess club) at 48px? Does it pop in a store grid of wooden boards? Do screenshots 1–3 land
the panic→relief hook?
