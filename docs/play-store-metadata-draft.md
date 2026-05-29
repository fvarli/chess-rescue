# Play Store Metadata — Draft

Draft listing copy for the Google Play Console. **Not for submission as-is** — fill the
`<placeholders>` and capture the graphics first (see `closed-test-checklist.md`). Tone is
seeded from `product-vision.md`: relief, calm, "not a chess trainer."

## Identity

- **App name / title** (≤30 chars): `Chess Rescue` (12)
- **Developer / publisher:** `<Lunexa Games>`
- **Package:** `com.lunexa.games.chessrescue`
- **Category:** Games → **Puzzle** (alt: Casual)
- **Tags:** puzzle, casual, brain, relax, chess
- **Contains ads:** No · **In-app purchases:** No

## Short description (≤80 chars)

```
One move saves the king. A calm, offline 90-second rescue ritual.
```
(65 chars)

## Full description (≤4000 chars)

```
Chess Rescue is a calm, offline puzzle game about one feeling: the relief of saving a
position that looked lost.

It is not a chess trainer. No openings, no ratings, no opponents, no clocks. Every puzzle
drops you into visible danger — your king is under threat — and asks for a single move: the
rescue. Find it, commit, and the board answers with a quiet breath of relief. Miss it, and
there's no loss screen and no shame — just a soft reset and another try.

A 90-second ritual for when a small fight in your day didn't go your way. A reminder that a
position that looks lost is sometimes one move from rescued.

• One move, one rescue, one feeling — repeated.
• Gentle by design: failure just resets, calmly.
• Fully offline. No accounts, no ads, no tracking, no network.
• No chess knowledge required — if you can see the danger, you can find the move.
• Short sessions that stay fresh without ever feeling random.

Chess is the medium. Relief is the product.
```

## Content & audience

- **Content rating:** expect **Everyone** (no violence, no ads, no user-generated content,
  no shared data). Complete the IARC questionnaire in the Console.
- **Target audience:** general; optionally mark family-friendly.

## Data Safety form (answers)

- **Data collected:** None.
- **Data shared:** None.
- **Encryption in transit / data deletion:** N/A (no data leaves the device).
- **On-device storage only:** game progress via local app storage; user can clear via system
  Settings or uninstall.
- **Permissions:** none (release manifest declares no runtime permissions).
- **Privacy policy URL:** `<host docs/privacy-policy.md and paste the URL>`

## Graphics required (capture before listing — see closed-test-checklist.md)

> Art direction + the icon/feature-graphic/screenshot concepts live in `brand-direction.md`
> (recommended icon: the abstract coral→mint "knight-leap").

- **App icon:** 512×512 PNG (32-bit) → `assets/store/play-icon-512.png` ✅ (launcher icon "The
  Trajectory" also wired into the app; default Flutter logo replaced).
- **Feature graphic:** 1024×500 → `assets/store/feature-graphic-1024x500.png` ✅ **(text-free v1)**;
  add the wordmark overlay in a design tool (see `store-assets-spec.md` → text-overlay spec).
- **Phone screenshots:** 2–8, 9:16 (1080×2400) — capture pending (see `screenshot-workflow.md`).
  Capture the signature states:
  1. danger (king glowing, threat named), 2. a piece selected (move dots fanned out),
  3. rescued (mint breath), 4. completion ("The board is quiet now." + SAVED badge).

## Contact

- **Support email:** `<support email>`
- **Website (optional):** `<url>`
