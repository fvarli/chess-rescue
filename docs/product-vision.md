# Chess Rescue — Product Vision

## What it is

Chess Rescue is a mobile-first **emotional comeback puzzle game** built on chess rules. It is not a chess training app, not an opening trainer, not a rating ladder, not a place to play opponents.

The product exists to produce one feeling, repeatedly: **the relief of saving a position that looked lost.**

## The core loop

```
   danger  →  select piece  →  commit move  →  rescue / fail  →  emotional response  →  retry
```

Every puzzle starts in visible peril. The board is dark, the king is glowing red, the threat is named. The player looks for one move — the rescue. They commit. The board reveals the outcome with restraint: a mint-green breath if they were right, a soft red flash and an unjudgmental retry if they were not.

Failure is not a loss screen. It's a returned breath. The puzzle resets without commentary or shame.

## Why D4 Convergence

Five design directions were explored (D1–D5). D4 was chosen as the primary direction because it converges the two qualities the product needs most:

- **D1 tactical clarity** — the player must instantly read the board: where the danger is, what they can do about it.
- **D2 cinematic restraint** — when the rescue lands, it must *land*. A spotlight, not a confetti cannon.

D3 (calm) and D5 (daily) feed the retry softness and the eventual once-per-day cadence, but D4 is the design spine.

## What the first vertical slice answers

> **Does making the rescue move feel satisfying?**

Nothing else. Not retention, not difficulty curves, not piece education, not progression. One puzzle, one rescue, one feeling — repeated until the feeling is undeniable.

The first slice is the canonical Nf6+ rescue from `primitives.jsx`. White's king on g1 is mate-threatened by the black queen on h3; the white knight on e4 jumps to f6 with check, breaking the attack.

## Product guardrails

These are not "version 1 cuts." They are durable choices that define what Chess Rescue is *not*:

- **No accounts.** No friction between the player and the puzzle.
- **No backend.** Puzzles ship with the app.
- **No multiplayer.** This is a solitary, restorative game.
- **No Stockfish / no chess engine.** Each puzzle ships with hand-curated legal moves and a single rescue answer.
- **No monetization.** Not in the slice, not in the foreseeable future.
- **No analytics yet.** We don't know what to measure until the feel is right.
- **No feature-heavy menus.** No settings page, no "puzzles I've solved", no streak gallery.
- **No traditional chess UI.** No coordinate notation by default, no move list, no FEN, no PGN, no clocks.
- **No wooden boards.** No fantasy pieces. No skeuomorphism.

## Who it's for

Not chess players. People who occasionally lose a small fight in their day — a missed bus, a tense conversation, a forgotten thing — and want a 90-second ritual that reminds them: a position that looks lost is sometimes one move from rescued.

Chess is the medium. Relief is the product.
