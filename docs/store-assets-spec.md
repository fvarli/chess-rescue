# Store Asset Production Spec — Chess Rescue (Phase 27)

Production-ready specs for the three Play Store assets, built on the locked brand direction
**"The Leap"** (`brand-direction.md`). This is a **build spec, not the rendered art** — a designer
or image tool produces the PNGs; on-device screenshots are captured manually.

Palette/voice locked from D4: field `#0D0E12`, danger coral `#FF5A4C`, relief mint `#5EE2C0`,
accent `#8AA1FF`, text `#EAEAF2`/dim; **Inter Tight** only. Spine: *danger → the one move →
relief* (coral → leap → mint). Copy must **motivate, not describe** — lead with feeling.

---

## 27A — App icon (4 directions + winner)

All are "The Leap": abstract knight-leap, coral→mint, dark field — no literal piece, board, or
club/tournament look.

### ★ A — The Trajectory  — **LOCKED WINNER**
- **Concept:** one luminous, tapered **leap arc** from a small coral node (lower-left), bending
  upward with a subtle knight's-elbow, to a **mint landing bloom** (upper-right); stroke grades
  coral→mint; the bloom is the relief breath. Vast negative space on the deep field.
- **Symbolism:** the single move from danger to safety; motion = escape; coral→mint = panic→relief.
- **Strengths:** rescue reads first; premium/minimal; the mint bloom is the reusable focal motif
  across all assets; high contrast → store pop.
- **Weaknesses:** chess cue is faint (accepted — rescue first); anchor with the knight's-elbow bend
  + coral→mint duotone so it never reads as a generic "swoosh."
- **48px readability:** excellent — one bold tapered stroke + endpoint glow; weight the coral start
  heavier; keep the bloom legible.
- **Uniqueness:** very high — no chess app owns a coral→mint leap arc.
- **Build note:** keep the subtle knight's-elbow bend (chess DNA as subtext).

### B — The Two-Beat L  *(runner-up)*
Knight's exact move (up-2, over-1) as a clean angular coral→mint stroke + glowing mint node.
Strongest "knight" recognition; bold/crisp at any size; reads more "chess move" than "rescue";
48px excellent; uniqueness high but right angles are commoner than arcs. *(Swap in only if testing
shows the genre cue is too faint.)*

### C — The Gap Jump
Coral danger band + mint safe band split by a dark gap, a marker mid-leap with a coral→mint trail.
Most literal "danger becoming safety"; clearest narrative; but more elements → clutter, marker can
vanish tiny, banding reads like a loading bar; 48px medium; iconicity weaker.

### D — The Pivot
The leap's final upstroke doubles as a relief **✓** (coral down-beat → mint up-tick). Very
emotional dual-read; but checkmarks are over-used (could read as a to-do/verified app); weakest
chess subtext; 48px excellent; uniqueness medium.

---

## 27B — Feature graphic (1024×500, built on The Trajectory)

Goal: **maximize Play CTR**; carry panic→insight→rescue→relief; pure branding, no screenshots.
The leap arc + mint bloom is the hero. Inter Tight only (≤2 weights); keep text in ~924×400 safe.

### ★ FG-1 — "The Leap, large"  — **recommended**
Hero trajectory arc across the left ~60% (coral node lower-left → mint bloom at the left-third
optical center); wordmark **CHESS RESCUE** stacked on the right third, tagline *"One move saves
the king."* (textDim) beneath. Deep field, heavy negative space. **Focal:** the mint bloom.
**Emotion:** relief (mint-dominant), just enough coral tension. **CTR:** bright mint bloom on
near-black = thumb-stopper; the arc leads the eye into the wordmark. Shares the icon's exact mark.

### FG-2 — "Danger → Safe sweep"  *(runner-up)*
Full-width gradient coral (left) → field → mint (right) (echoes the in-game backdrop transition);
the arc rides the seam; wordmark centered-right in the mint zone. Tells the whole journey in one
read; very brand-coherent.

### FG-3 — "The single breath"
Extreme minimalism: mostly black, small arc + outsized mint bloom, wordmark small bottom-left.
Calmest, most premium tile; risk: too quiet for some audiences.

### FG-4 — "Two states, one move"
Abstract coral-tinted tension texture (no board) on the left resolving to open mint calm on the
right; the arc crosses the divide. Strong before/after contrast; keep the coral side abstract so
it never reads "chessboard."

---

## 27C — Screenshot system (6 screens)

Real in-game captures on the dark field + a consistent **Inter Tight headline band** (top) and one
**textDim subheadline**; one accent per beat. Arc: panic→insight→rescue→relief→pride→**everyday
comeback**. Store preview shows the first 2–3 → screens 1–3 carry the hook.

| # | Beat | Headline | Subheadline | Visual focus | Composition |
|---|---|---|---|---|---|
| 1 | **Hook** | "It looks lost. It isn't." | "One move turns it around — can you find it?" | The most dramatic danger frame (king glowing coral, threat looming) — instant stakes | Bold hero thumbnail; perilous board centered, coral-dominant, big dark margins, small brand mark. The tile that earns the tap. |
| 2 | **Danger** | "Your king is in danger." | "The threat is named. The pressure is real." | Danger state — king glowing coral, status pill, coral backdrop breath | Board dominant; status pill top; coral glow; headline band. Panic. |
| 3 | **The move** | "One move can save it." | "Not deep calculation — just insight." | Selected state — piece lifted, `#8AA1FF` legal-move dots fanned out | Board with the dot constellation; accent color; headline band. Insight. |
| 4 | **Rescue** | "Rescued." | "A quiet breath of relief — not a fireworks show." | Rescued state — mint bloom on the destination, mint backdrop, "◐ Attack broken" | The money shot: mint-dominant, minimal text, let it breathe. Relief (emotional peak). |
| 5 | **Completion** | "The board is quiet now." | "A 90-second ritual, whenever the day gets loud." | Completion finale — the quiet line + mint SAVED badge | Calm, centered, restrained mint, heavy negative space. Quiet pride. |
| 6 | **Everyday comeback** | "Always one move from saved." | "Open it anytime — a fresh rescue, in about a minute." | An inviting, fresh danger board, calm and ready — "here's your next one" | Single clean board, warm/mint calm, generous margins, headline band; an open invitation to return. Short session · replay · comeback · everyday. |

**Screen-1 hook — A/B candidates** (table headline is the default; all keep imminent danger + the
one-move rescue + curiosity — copy that *motivates*, not *describes*):
- "One move from saved." / "Spot the rescue before the board falls."
- "Can you find the one move?" / "Every position looks lost — until it's rescued."
- "You're about to lose…" / "…unless you find the move that saves it." *(cliffhanger)*

Ship the default; run 2–3 as Play store-listing experiments once live.

---

## Asset targets & handoff

- **Master icon:** 1024×1024 PNG (flatten — no alpha — for the 512×512 Play listing export).
- **Adaptive icon:** foreground = the leap arc + bloom; background = `#0D0E12`; keep the mark inside
  the central **~66% safe zone** (circle/squircle masking); **verify the 48px render**.
- **Feature graphic:** 1024×500 (FG-1).
- **Screenshots:** 1080×2400 (9:16) × 6, per the table; dark field + Inter Tight headline band.
- **Wire-up:** render → `flutter_launcher_icons` (recipe in `closed-test-checklist.md`) → export the
  512² Play icon.

**Design-review gate (lead, on rendered art):** icon reads *rescue* at 48px and pops in a store
grid; FG-1 stops the thumb; screenshots 1–4 carry panic→relief.
