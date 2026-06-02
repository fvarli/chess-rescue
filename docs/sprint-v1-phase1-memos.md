# Sprint V1 — Phase 1 Candidate Memos

> **Purpose.** Phase 1 output for the quality-first content sprint.
> 12 candidate position memos generated across the lead-set priority
> motifs. The lead serves as the Phase 2 reviewer per the sprint
> plan §12 Q1; this document is the input to that gate.
>
> **Distribution this round.**
>
> | Motif | Candidates |
> |---|---|
> | `counterCheck` | 4 (CC1-CC4) |
> | `captureAttackerMinor` | 2 (CAM1-CAM2) |
> | `removeDefender` | 2 (RD1-RD2) |
> | `blockFile` | 1 (BF1) |
> | `sealDiagonal` | 1 (SD1) |
> | `forcedInterposition` | 1 (FI1) — only if reads instantly |
> | `captureAttackerHeavy` | 1 (CAH1) — only if not too obvious |
>
> **Format per memo.**
> - Piece layout (compact algebraic — files a-h, ranks 1-8)
> - Threat description (what mates next if white does nothing)
> - Rescue move (chess notation)
> - Authored `legalMoves` list (the rescue + decoys the player sees)
> - Copy sketch (`statusText`, `dangerHint`, `failureHint`, `successExplanation`)
> - **R0 analysis**: how this position is distinct from existing
>   exemplars of the same motif (the load-bearing rule)
> - Mirror check note

---

## Existing exemplars (reference, for R0 comparison)

| Motif | Exemplar id | Setup signature | Rescue |
|---|---|---|---|
| `counterCheck` | P1 (knight-rescue) | wK g1; bQ h3 threatens Qxg2#; wN e4 | Nf6+ (checks bK on g7) |
| `counterCheck` | A4 (the-breakaway) | wK g1; bQ e2 + bB a8 hunt the wN on d5 | Nf6+ (same square as P1 — knight escapes + checks bK on g8) |
| `counterCheck` | B4 (the-cross-check) | wK g1; bQ g7 checks down g-file; wN e5 | Ng6+ (blocks file + checks bK on h8) |
| `captureAttackerMinor` | P2 (take-the-checker) | wK g1 in check from bN f3 | gxf3 (g2 pawn captures the knight) |
| `blockFile` | P3 (block-the-file) | wK g1; bR/bQ on g-file threatens | (file block) |
| `sealDiagonal` | P4 (seal-the-diagonal) | (diagonal interpose) | (diagonal block) |
| `captureAttackerHeavy` | P5 (win-the-queen) | wK g1 in check; capture the queen | Rxe1 (sample) |
| `forcedInterposition` | B1 (the-martyr) | wK g1; bQ a7 on a7-g1 diagonal | Rd4 (interpose far from the king) |
| `removeDefender` | B3 (remove-the-defender) | wK g1; bQ h3 threatens Qg2#, bB c6 keeps mate intact | Nxc6 (eliminate the keystone) |

**Key R0 patterns the canon already overuses:**
- wK on g1 with kingside shelter (every existing puzzle)
- bK on g7 / g8 / h8 (most counter-check exemplars)
- Knight as rescuer (3 of 4 counter-checks)
- Rescue square f6 / g6 / e4 area
- Qxg2# as the mate threat (P1, B3 directly; others adjacent)

For R0 distinctness, **new candidates that break ANY of these patterns are stronger.**

---

# counterCheck candidates (priority 1)

## CC1 — "The Rook above the king"

A rook counter-check — rescuer is NOT a knight, breaking the canon's strongest pattern.

**Position** (white moves to rescue):
```
   a b c d e f g h
8  .  .  .  .  .  .  k  .
7  .  .  .  .  .  .  .  p
6  b  .  .  .  .  .  .  .
5  .  .  .  .  .  .  .  .
4  .  .  .  .  .  .  .  .
3  .  .  .  .  .  R  .  q
2  P  .  .  .  .  P  P  P
1  .  .  .  .  .  .  K  .
```

**Threat.** `bQ-h3` plans `Qxh2+` next move, supported by `bB-a6` controlling the f1 flight square via the a6-h1 diagonal: `1.… Qxh2+ Kf1 (forced) 2.… Qg1#` (or mate the same move if mate logic checks out — verify in implementation).

**Rescue.** `Rf8+` — `wR-f3` slides up the f-file (clear because f4-f7 empty in this setup) to f8, checking `bK-g8` along the 8th rank. Black must answer the check; the Qxh2 threat is abandoned for the tempo.

**Authored `legalMoves` for wR on f3** (tappableSquare = `Square(5, 2)`):
- `Square(5, 7)` — f8 (rescue)
- `Square(5, 3)` — f4 (push, no check)
- `Square(5, 4)` — f5 (push, no check)
- `Square(4, 2)` — e3 (sideways, no check)
- `Square(3, 2)` — d3 (sideways, no check)

(`Rxh3` capturing the queen is intentionally OMITTED from the
authored list — chess-legal but hides a second rescue. Same
authoring convention as P1 which omits Nc3.)

**Copy sketch.**
- `statusText`: "▮ Mate's coming"
- `dangerHint`: "The queen is one step from sealing the king in."
- `failureHint`: "That move doesn't break the threat. Strike at the other king."
- `successExplanation`: "THE ROOK STRIKES BACK"

**R0 analysis.** Existing canon has 3 counter-checks, ALL knight rescuers, all ending on f6 or g6. CC1 uses a **rook** on f8 — different piece, different square, different geometric area (8th rank check vs. f6/g6 check). A trained player who has internalised P1/A4/B4 cannot reach CC1 from position memory; they must catch the counter-check shape fresh. ✓

**Mirror.** Mirror flips files. `wR f3 → wR c3`, `bK g8 → bK b8`, `bQ h3 → bQ a3`, `wK g1 → wK b1`, `bB a6 → bB h6`. Rescue mirror: `Rc8+` (rook slides up c-file to c8, checks bK on b8 along 8th rank). Clean mirror. ✓

---

## CC2 — "Take the shield, take the king"

A bishop counter-check that captures the kingside shield pawn — rescue is `Bxf7+`.

**Position.**
```
   a b c d e f g h
8  .  .  .  .  .  .  k  .
7  p  .  .  .  .  p  .  p
6  .  .  .  .  .  .  .  .
5  .  .  .  .  .  .  .  .
4  .  .  B  .  .  .  .  .
3  .  .  .  .  .  .  .  q
2  P  .  .  .  .  P  P  P
1  R  .  .  .  .  .  K  .
```

**Threat.** `bQ-h3` plays `Qxg2#` next move: `Qxg2` attacks `wK-g1` along the g-file; `f1` attacked by `Qg2` diagonally; `h1` attacked along h-file. No flight. Mate.

**Rescue.** `Bxf7+` — wB on c4 captures bP on f7 along the c4-f7 diagonal (path through d5, e6 must be empty — confirmed). On f7, the bishop attacks bK on g8 via the f7-g8 diagonal. Counter-check.

**Authored `legalMoves` for wB on c4** (tappableSquare = `Square(2, 3)`):
- `Square(5, 6)` — f7 (rescue, captures bP-f7)
- `Square(3, 4)` — d5 (push, blocked-future, no check)
- `Square(4, 5)` — e6 (further push, blocked at f7 — no check)
- `Square(1, 4)` — b5 (other direction, no check)
- `Square(0, 5)` — a6 (further, no check)

**Copy sketch.**
- `statusText`: "▮ The king sits exposed"
- `dangerHint`: "The queen is one step from winning the file."
- `failureHint`: "That move doesn't disturb the queen. Hit back."
- `successExplanation`: "THE BISHOP CRASHES THROUGH"

**R0 analysis.** A bishop rescuer that CAPTURES the f7 pawn while delivering check — this is a textbook chess motif (the f7 weakness) but ALIEN to Chess Rescue's existing counter-check exemplars, which are all knight-based and don't involve capturing the kingside shield. A trained player would solve from the "there's a check available; capture is the bonus" instinct, not from memory. ✓

**Mirror.** wB c4 → wB f4; bK g8 → bK b8; bQ h3 → bQ a3; etc. Rescue mirror: `Bxc7+` (capturing the mirrored bP-c7 along f4-c7 diagonal). Clean. ✓

---

## CC3 — "The far-side knight"

A knight counter-check from an unusual starting square, with the rescue on f6 like P1/A4 — BUT the geometric setup forces the player to find the knight from a fresh angle. **WEAKER candidate**; risks feeling like a P1 re-skin per R0. Submitting for lead's evaluation.

**Position.**
```
   a b c d e f g h
8  .  .  .  .  .  .  k  .
7  .  .  .  .  .  p  .  p
6  .  .  .  .  .  .  .  .
5  .  .  .  N  .  .  .  .   <- wN d5 (vs. P1's e4 / B4's e5)
4  .  .  .  .  .  .  .  .
3  .  .  .  .  .  .  .  q
2  P  P  .  .  .  P  P  P
1  R  N  B  .  Q  B  K  .   <- atmospheric back rank
```

**Threat.** `bQ-h3` → `Qxg2#` (standard mate, no extra support needed).

**Rescue.** `Nf6+` — wN d5 → f6 (knight move). Checks bK on g7… wait, bK on g8 here, and Nf6 attacks g8 (knight move f6→g8 — yes). Counter-check.

**Authored `legalMoves` for wN on d5** (tappableSquare = `Square(3, 4)`):
- `Square(5, 5)` — f6 (rescue)
- `Square(5, 3)` — f4
- `Square(4, 6)` — e7
- `Square(2, 6)` — c7
- `Square(1, 3)` — b4

**Copy sketch.**
- `statusText`: "▮ Active threat"
- `dangerHint`: "Tap a white piece to see its moves."
- `failureHint`: "That move doesn't break the attack. Look for a check."
- `successExplanation`: "THE KNIGHT STRIKES BACK"

**R0 analysis.** Concern: same rescue square as P1/A4 (f6), same rescue piece (knight), same threat shape (Qxg2#). Only difference: the knight starts on d5 instead of e4. A trained player who has internalised P1 would IMMEDIATELY see Nf6+ here — solving from POSITION memory of P1, not from MOTIF instinct fresh. **CC3 likely fails R0. Submitting honestly for lead's call on whether to reject.**

**Mirror.** Clean.

---

## CC4 — "Discovered check via knight jump"

A knight jumps off the line of a hidden wQ, simultaneously checking bK with the knight's own attack AND opening wQ's check via discovery — a DOUBLE CHECK counter-check (the strongest chess motif).

**Position.**
```
   a b c d e f g h
8  .  .  .  .  .  .  k  .
7  .  .  .  .  .  .  .  p
6  .  .  .  .  .  .  .  .
5  .  .  .  .  N  .  .  .   <- wN e5 (in the way of wQ a1)
4  .  .  .  .  .  .  .  .
3  .  .  .  .  .  .  .  q
2  P  .  .  .  .  P  P  P
1  Q  .  .  .  .  .  K  .   <- wQ a1 (long diagonal a1-h8 blocked at e5)
```

**Threat.** `bQ-h3` → `Qxg2#` as in standard pattern.

**Rescue.** `Nxf7+` — wN e5 → f7. This (a) captures bP on f7 if there is one (otherwise just moves to f7) AND (b) checks bK on g8 from f7 (knight square attacks g8) AND (c) opens the a1-h8 diagonal so wQ on a1 ALSO checks bK on g8 (assuming the diagonal is now clear). **Double check** — black must move the king (can't block, can't capture both attackers). 

Wait — if bK has to move (can't capture wN on f7 because wQ also attacks the king's destination via the diagonal), the threat is averted by the FORCED king move using black's tempo.

Hmm actually let me verify: After `Nxf7+`, wN is on f7 and wQ on a1 is on the a1-h8 diagonal (now clear because e5 emptied). wQ attacks g8 via the diagonal a1-h8 — but wait, does this diagonal pass through g8? a1 (0,0), h8 (7,7). Diagonal: b2, c3, d4, e5, f6, g7, h8. So the diagonal goes to g7 then h8 — NOT through g8. So wQ on a1 does NOT attack g8 directly.

Hmm. Double check requires both attackers to attack the king square. wQ on a1 attacks g7 (not g8) on the diagonal. So Nxf7+ delivers SINGLE check from the knight only; wQ's discovered attack hits g7, which is just an additional threat but not a king-attack.

So CC4 is actually just a Nxf7+ counter-check with a "bonus" wQ attack on g7 — not a true double check. Reduces the elegance.

Let me reconsider. For true double check, the discovered attacker needs to attack bK's square (g8). To attack g8 via a long range piece, the piece must be on g-file or on a diagonal through g8 (a2-g8 or h7-g8).

A queen on a2 (the same as the bishop discussion in CC2): a2-g8 diagonal. If wN on (say) e6 is blocking it, then wN moving off opens the queen's check. But e6 must be on the a2-g8 diagonal: a2 (0,1), g8 (6,7). Diagonal a2→g8: b3, c4, d5, e6, f7. So yes, e6 IS on a2-g8 diagonal.

Revised CC4 position:
- wK g1, wP a2 (replaced by wQ), wP f2, g2, h2
- wQ a2 (light square ✓)
- wN e6 (blocking the a2-g8 diagonal)
- bK g8, bQ h3 (threat), bPs atmospheric

Wait wPa2 is the kingside-shelter convention pawn — replacing with wQ-a2 changes the atmosphere. Let me adjust to keep shelter intact and add wQ elsewhere.

Hmm, but the a2-g8 diagonal specifically needs the queen at a2 (or somewhere on that line). What if wQ is on b3 (also on the a2-g8 diagonal via b3-g8 part)? b3 (1,2), g8 (6,7). Diagonal: c4, d5, e6, f7. Yes b3-g8 is a diagonal segment.

Let me restart CC4 cleanly:

**CC4 revised** — wQ on b3, wN on d5 blocking, wN moves to discover queen check.

Actually this gets complicated. Let me drop the "double check" ambition and propose a simpler discovered check:

**CC4 — Discovered check from a knight move**

Position:
- wK g1; wP f2, g2, h2
- wQ on b3 (the hidden attacker, dark/light irrelevant; b3 = 1+2=3 odd → light, same as g8 light)
- wN on d5 (blocks the b3-g8 diagonal)
- bK g8, bQ h3 (threat)
- bP f7, h7 (atmospheric; need to verify f7's role)

Wait — f7 is on the b3-g8 diagonal. So bP-f7 ALSO blocks the diagonal. So wN moving off d5 doesn't fully open the diagonal because f7 still blocks.

If bP-f7 is removed: b3-d5-e6-f7-g8. With f7 empty, the path goes b3-c4-d5-e6-f7-g8. wN on d5 blocks. wN moves off → wQ attacks g8 directly. Discovered check.

But removing bP-f7 leaves bK exposed and CC2-type setups happen. Trade-offs.

Let me simplify even more: skip the double-check concept for CC4 and instead propose a simpler shape. **CC4 — Knight check from an unfamiliar square.**

**CC4 (simpler) — "Knight from the wing"**

Position:
- wK g1, wP f2, g2, h2
- wN a4 (knight on the queenside!)
- bK g8, bQ h3 (threat)
- bPs atmospheric

Rescue: Knight from a4 to... what squares attack g8? Knight squares attacking g8: f6, h6. From a4, knight moves: b6, c5, c3, b2 (blocked by wP-b2 if present)... a4 is far from f6/h6.

Knight from a4 to f6 — needs to be a single knight move. a4 (0,3), f6 (5,5). Diff 5, 2 — yes! Knight moves max 2/1 or 1/2. Diff 5/2 is NOT a knight move (knight moves are 1/2 or 2/1).

So Na4-f6 is not a single move. CC4 fails.

OK I'll drop the elaborate setup for CC4. Submitting it as a weaker candidate:

**CC4 — "The bishop pin-break"** (final attempt)

A bishop counter-check from an unusual square — let me try just g6 (a hard-to-find bishop check):

For a bishop to give check at g6 (wait g6 is the destination), bishop has to be ON g6 and the king has to be on a square attacked. Actually wait, I confused myself.

For a bishop to give CHECK to bK on g8, the bishop has to END on a square that attacks g8. As established, those squares are a2/b3/c4/d5/e6/f7 (NE diagonal) and h7.

CC1 used Rf8 (rook on 8th rank). CC2 used Bxf7+ (bishop on f7 via capture).

For variety, CC4 could be Bxh7+ — bishop captures h7 pawn and attacks g8 from h7.

Setup:
- wK g1, wP f2, g2, h2
- wB on a square that can reach h7. Light-squared bishop diagonals to h7: a8 (via a8-h1 diagonal — wait, that doesn't go through h7. Let me recompute), b1-h7 (b1 (1,0), h7 (7,6). Diff 6, 6. Diagonal b1-h7: c2, d3, e4, f5, g6, h7. Yes.) — so a bishop on b1, c2, d3, e4, f5, g6 could reach h7.
- Let me put wB on e4 (light: 4+3=7 odd ✓).
- Path: e4-f5-g6-h7 (capturing bP-h7).
- For path to be clear, f5 and g6 must be empty.
- After Bxh7+, wB on h7 attacks g8 (one-step diagonal).

Setup:
- wK g1, wP a2, f2, g2, h2
- wB e4 (the rescuer)
- wR a1 atmospheric
- bK g8, bQ h3 (threat), bP a7, f7, h7 (atmospheric; h7 will be captured)
- bN b8 atmospheric

Rescue: `Bxh7+` (wB from e4 to h7, capturing bP, checking bK on g8 from h7).

Verify uniqueness: from e4, other moves that check bK:
- Bg6 (attacks g8 via g6-h7-g8? Wait, g6 to g8 is along g-file, not diagonal. Bishop on g6 attacks via diagonals from g6: f5-e4 (back), h5, h7, f7. Doesn't attack g8 directly.) — so Bg6 doesn't check.
- Bf5 — attacks via f5-g6-h7 (one direction) and f5-e6-d7 (other). Doesn't attack g8 directly.
- Bxh7+ — yes, only this gives check.

Good, single rescue.

Authored legalMoves:
- `Square(7, 6)` — h7 (rescue, captures bP)
- `Square(5, 4)` — f5 (decoy, sliding NE)
- `Square(6, 5)` — g6 (decoy, sliding NE further)
- `Square(3, 4)` — d5 (decoy, sliding NW)
- `Square(2, 5)` — c6 (decoy, further NW)

Copy:
- `statusText`: "▮ The rook is loaded"
- `dangerHint`: "The queen is closing in."
- `failureHint`: "That moves but doesn't disturb. Find the check."
- `successExplanation`: "THE BISHOP SWEEPS IN"

R0 analysis: This is similar to CC2 (also a bishop capture that checks bK), but with a DIFFERENT capture (h7 instead of f7) and DIFFERENT geometric direction. Whether this is distinct ENOUGH from CC2 to ship both is a Phase 2 call — the lead may judge them too similar. Submitting honestly.

Mirror: clean (mirrors a8-side).

---

# captureAttackerMinor candidates (priority 2)

## CAM1 — "The bishop takes the knight"

Existing P2 has a pawn capturing a knight (`gxf3`). CAM1 has a **bishop** capturing a **bishop** — different pieces, different geometry.

**Position concept.**
- wK g1 in check from `bB-h2` (the threatening minor piece — bishop on h2 attacks g1 diagonally).
- Wait — bishops can't move to h2 if there's a pawn there. So no wP-h2.
- Setup: wK g1 with wP-f2, g2 (h2 empty); `bB-h2` is checking via diagonal h2-g1.
- Rescue piece: `wB-c1` (dark-squared, same color as h2 — h2 = 7+1 = 8 even → dark). c1 is dark (2+0=2 even). Same diagonal? c1 to h2 — c1 (2,0), h2 (7,1). Diff 5, 1 — not a diagonal. Hmm.
- Alternative: wN on g4 captures bB on h2 — Nxh2 — knight from g4 to h2 (file diff 1, rank diff 2 — knight move yes). Knight captures bishop, ending the check.

**Rescue.** `Nxh2` — wN g4 → h2, capturing the checking bishop. Wait, that's a knight capturing a minor — same piece category but a different piece type (knight vs pawn) and a different threat type (bishop vs knight).

**Authored `legalMoves` for wN on g4** (tappableSquare = `Square(6, 3)`):
- `Square(7, 1)` — h2 (rescue, captures bB)
- `Square(7, 5)` — h6 (decoy, away from check)
- `Square(5, 5)` — f6 (decoy)
- `Square(4, 4)` — e5 (decoy)
- `Square(5, 1)` — f2 — wait, f2 has wP. Self-capture illegal, exclude.
- `Square(4, 2)` — e3 (decoy)

**Copy.**
- `statusText`: "▮ In check"
- `dangerHint`: "A bishop is biting. Hit it back."
- `failureHint`: "The bishop is still there. Take it."
- `successExplanation`: "THE KNIGHT TAKES THE BISHOP"

**R0 analysis.** P2 is a PAWN capturing a KNIGHT. CAM1 is a KNIGHT capturing a BISHOP. Different rescue piece, different threat piece, different geometric area (g4-h2 vs. g2-f3). A trained player who knows P2's "humble pawn" pattern won't recognise CAM1 from memory — they catch the "capture the checker" motif fresh on a new pair of pieces. ✓

**Mirror.** Clean (knight mirrors to b4, bishop mirrors to a2).

---

## CAM2 — "The rook eats the rook"

A rook captures a checking rook. Different from P2's gxf3 (pawn capture) and from CAM1 (knight capture).

**Position concept.**
- wK on g1, kingside shelter
- bR on g3 — checking wK on g1 down the open g-file (wP-g2 is removed or never there)
- wR on c3 — can capture: Rxg3 (sliding along the 3rd rank)
- Atmospheric: standard pieces.

Wait — is bR on g3 checking wK on g1? Yes if no piece between (no wP-g2 in this setup). So check.

**Rescue.** `Rxg3` — wR c3 captures bR on g3.

**Authored `legalMoves` for wR c3** (tappableSquare = `Square(2, 2)`):
- `Square(6, 2)` — g3 (rescue, captures bR)
- `Square(4, 2)` — e3 (decoy)
- `Square(3, 2)` — d3 (decoy)
- `Square(2, 4)` — c5 (decoy, up the c-file)
- `Square(2, 1)` — c2 (decoy, down the c-file)

**Copy.**
- `statusText`: "▮ In check"
- `dangerHint`: "The rook is at the door."
- `failureHint`: "That doesn't end the check. Take the rook."
- `successExplanation`: "ROOK FOR ROOK"

**R0 analysis.** P2 captures a knight with a pawn (delicate). CAM2 captures a rook with a rook (even trade). Different geometric area (3rd rank vs. f3-g2). A trained player solves from "capture the checker" instinct on a new piece pair. **Concern:** CAM2 might be TOO simple — rook captures rook is the most obvious chess move. Whether this is "too obvious" for a Chess Rescue puzzle is a Phase 2 call.

**Mirror.** Clean.

---

# removeDefender candidates (priority 3)

## RD1 — "The pinned defender"

A piece holds together the mate threat; capture it to dissolve the threat.

**Position concept.**
- wK g1, kingside shelter
- `bQ h3` poised for `Qxg2#`
- `bB f7` defends g6 (knight outpost would be on g6)? No — the defender concept: a black piece supports the queen's path or covers a flight square.
- Cleaner: `bQ h3` plans `Qxg2#`; `bR a8` defends along the 8th rank or some pivotal piece.

Actually let me make this simpler. B3 (existing) has `Nxc6` — capturing a bishop that defends a square in the mate net. RD1 could mirror this concept with different pieces.

- `bQ h3` plans `Qxg2#`. The mate works because `bN g3` covers f1 (knight square attacks f1).
- If wN captures bN g3 → `Nxg3` — removes the f1-controller, makes Qxg2 NOT mate (wK escapes to f1).

**Position.**
```
   a b c d e f g h
8  .  .  .  .  .  .  k  .
7  .  .  .  .  .  p  .  p
6  .  .  .  .  .  .  .  .
5  .  .  .  .  N  .  .  .   <- wN e5
4  .  .  .  .  .  .  .  .
3  .  .  .  .  .  .  n  q   <- bN g3, bQ h3
2  P  .  .  .  .  P  .  P   <- wPs (no g2!)
1  .  .  .  .  .  .  K  .
```

**Threat.** `Qxg2+` — wait, wP-g2 isn't here in this setup. Let me reconsider.

Re-setup: with `bN g3` covering f1, the threat must be a mate that REQUIRES f1 to be covered.
- Try `bQ h3` → `Qh1#`? bQ on h1 attacks wK on g1 (g1 adjacent), wK escape squares: f1 (attacked by bN g3 via knight pattern? bN g3 → f1 yes), f2 (occupied by wP). So h1 mate.
- Verify Q reach h1: bQ on h3 → h1 down h-file. Path through h2 — if wP on h2, blocked. So need to remove wP-h2.

Updated position: wP only on f2, g2 (no h2). bQ-h3 plays Qh1#.
But then bQ-h3 → Qh1+: path h3→h2→h1 — if h2 empty (no wP), goes directly. Qh1+ checks wK (h1 attacks g1). Flights: f1 covered by bN-g3 (knight attack); f2 occupied. Mate.

OK threat = Qh1# next move.

Rescue: `Nxg3` removes bN. Then Qh1+ check, flights: f1 NOT covered (bN gone), f2 occupied. Flight to f1 saves the king. So removing the defender DEFANGS the mate.

**Authored `legalMoves` for wN e5** (tappableSquare = `Square(4, 4)`):
- `Square(6, 2)` — g3 (rescue, captures bN)
- `Square(5, 2)` — f3 (decoy)
- `Square(4, 6)` — e7 (decoy)
- `Square(2, 5)` — c6 (decoy)
- `Square(2, 3)` — c4 (decoy)

**Copy.**
- `statusText`: "▮ Held up by one piece"
- `dangerHint`: "A defender is holding the mate together."
- `failureHint`: "That doesn't free the king. Take the keystone."
- `successExplanation`: "REMOVE THE KEYSTONE"

**R0 analysis.** B3 has bN-d4 capturing a bishop on c6 (the keystone). RD1 has wN-e5 capturing a knight on g3 (the keystone). Different rescue piece location, different captured piece, different mate logic (covering f1 vs. covering g2). Distinct enough that a player solves from "remove the defender" instinct fresh. ✓

**Mirror.** Clean.

---

## RD2 — "Take the pinner"

A pin is holding a white piece. Capture the pinning piece; the pinned piece can then move to address the threat.

This is a more complex "remove the defender" variant — the "defender" being a black pinning piece.

**Concern.** Pin mechanics may be too cognitively heavy for the existing puzzle UX. Submitting as the second `removeDefender` candidate for completeness; lead may reject as TOO COMPLEX for the loop.

**Position concept.**
- wK g1, threat against wK.
- A black piece pins a white piece that would otherwise rescue.
- White captures the pinning piece, freeing the pinned defender to address the threat in a follow-up.

But — Chess Rescue is single-move rescue. The rescue must IMMEDIATELY end the threat. A capture that "frees a piece to address the threat next move" doesn't work in a single-move framework.

**RD2 — REJECTED at memo level.** The pin mechanic doesn't fit single-move rescue. Submitting for the lead's awareness; the candidate is dropped.

(I'll keep this as a memo so the lead sees the consideration. Reduces my CC/CAM/RD count by 1 — I'll add an extra candidate in another motif to compensate, OR accept a 11-memo Phase 1 output.)

---

# blockFile / sealDiagonal candidates (priority 4)

## BF1 — "Throw the knight on the line"

A piece interposes on an open file held by a black slider.

**Position concept.**
- wK g1, kingside shelter
- `bR a1` would be threatening Rxa-something — no, `bR` on the back rank attacks back rank.
- Actually: `bR g8` on g-file, with g-file open (no wP-g2 or wP-g2 removed). bR plans Rxg1# (or similar). White interposes on g4 or g3 or g5 — block the file.
- Existing P3 has block-the-file with a similar setup. For R0 distinctness, vary the blocking piece and the blocking square.

**Position.**
```
   a b c d e f g h
8  .  .  .  .  .  .  r  .   <- bR g8
7  .  .  .  .  .  p  .  p
6  .  .  .  .  .  .  .  .
5  .  .  .  N  .  .  .  .   <- wN d5 (rescuer)
4  .  .  .  .  .  .  .  .
3  .  .  .  .  .  .  .  q
2  P  .  .  .  .  P  .  P   <- wP (no g2, file open)
1  .  .  .  .  .  .  K  .
```

**Threat.** `bR-g8` plays `Rxg1#` — slides down g-file to g1, taking wK. Path g8-g7-g6-g5-g4-g3-g2-g1: all empty in this setup. Mate threat.

Hmm but actually for Rxg1 to be mate, wK has no flight. With wP on f2 (white), Rxg1 attacks g1 and flights f1, h1.  bQ-h3 attacks h1 via the h-file (path h3 → h2 → h1, with h2 having wP-h2). So h1 attacked. f1: any attacker? No. So wK can flee to f1, NOT mate. Need stronger threat.

Let me make threat = Rxg2+ then Rxg1# (two-move sequence) — but we need MATE IN ONE for the single-rescue logic.

Alternative: just make `bR-g8` checking by itself if g-file is fully open. Wait, bR-g8 attacks g1 down g-file — if g-file empty, then `Rxg1#` is direct. Flights f1, h1 — need both attacked.

Add `bB a8` controlling h1 via long diagonal (a8 to h1 — a8 (0,7), h1 (7,0). Diff 7, 7. Diagonal! Squares: b7, c6, d5 (occupied by wN), e4, f3, g2, h1. So bB on a8 attacks h1 IF the diagonal is clear. But wN on d5 BLOCKS the diagonal.

So with wN on d5 blocking, bB on a8 doesn't control h1. wK escape to h1 still works.

Hmm. Let me use a different blocker setup. Remove wN from d5 (put it elsewhere) and add a piece controlling h1.

Or: change the threat. What if the threat isn't immediate mate but instead just immediate check? In existing P3 the player blocks the file; not necessarily mate-in-one.

Actually let me just make this: bR on g8 threatens `Rxg1+` (check; wK is forced to move). It's not mate, but it's a forcing tactic the player must block.

Hmm, but in P3 it's already mate-in-one. Let me try to make BF1 mate-in-one too.

Add `bN h3` (in addition to bQ h3? conflict.) — let me put `bN f3` covering h2, no wait — this gets contrived.

Let me just author with bP on g2 (so g-file is blocked by wP-g2). bR on g8 threatens... nothing directly because wP blocks. So this doesn't work as block-the-file.

Block-the-file requires the file to be open between attacker and king.

OK let me simplify: BF1 follows P3's structure but with a different blocking square and a different rescue piece.

**BF1 revised — "Knight on g5"**
- bQ on g8 (instead of P3's setup) — wait, bQ on g8 attacks g1 down g-file, but the queen is more flexible.
- Threat: bQ g8 → Qxg2# (if g-file open through g2 first... no, bQ on g8 to g2 is along g-file, requires path open).
- Atmosphere: wK g1, wP f2, h2 (no g2); bQ g8; threat Qxg2+ then Qxg1#? Need single-move.

Hmm. Let me just propose BF1 with the existing P3 pattern but altered piece:

**BF1 (proposal, may be too similar to P3)** — `wR a4` slides to `g4` (different from P3's d4 perhaps?).

Submitting as memo with the explicit caveat that this may be too close to P3:

**Position.**
- wK g1, wP f2, h2 (g-file open)
- wR a4 (rescuer)
- bQ g8 (threat)
- Atmospheric pieces

Rescue: `Rg4` — wR slides from a4 along 4th rank to g4, blocking the g-file.

**R0 concern.** P3 is exactly this shape with different specifics. The lead may judge BF1 too close to P3. Submitting for evaluation.

---

## SD1 — "The bishop on the line"

Seal a diagonal that a black slider commands.

**Position concept.**
- wK g1; `bB a7` threatens via the a7-g1 diagonal (a7-b6-c5-d4-e3-f2-g1).
- Need to interpose. White rook or bishop on a square in the diagonal.

P4 has seal-the-diagonal with similar setup. For SD1 R0 distinctness, vary the diagonal direction or the interposing piece.

**Position.**
- wK g1, wP g2, h2 (no f2 — f2 vacant means diagonal a7-g1 needs another blocker check; actually if f2 is empty AND the diagonal is otherwise open, then bB-a7 attacks g1).
- `bB a7` (the threat)
- `wR d1` (rescuer)
- Atmospheric pieces

Rescue: `Rd4` — wR d1 to d4, interposes on a7-g1 diagonal (d4 IS on the diagonal).

**R0 concern.** B1 (the-martyr) has Rd4 as a rescue (also a rook to d4 on a diagonal). SD1 with `Rd4` would be visually identical to B1 in terms of rescue piece+square. **Almost certainly fails R0.** Submitting for honesty; lead likely rejects.

---

# forcedInterposition (martyr) candidate (priority 5)

## FI1 — "The knight stops the queen"

A piece (typically the most expendable) interposes on a line, sacrificing itself.

**Concern.** B1's existing martyr (Rd4) is geometrically distinctive. FI1 risks feeling either too close to B1 OR too contrived. The lead's bar: "only if reads instantly."

**Concept.**
- bQ on a long diagonal threatening wK directly.
- A white knight (not a rook) interposes — knight on the diagonal.
- The knight is captured next move (it's a sacrifice / martyr).

Setup brainstorm:
- `bQ d8` on the d-file? d8 to d1 isn't a diagonal. Not useful for forcedInterposition (which is diagonal-flavored).
- `bQ a7` threatens via a7-g1 diagonal (same as B1).
- `wN somewhere` interposes.

**Submitting concern:** I cannot find a forcedInterposition position that meaningfully distinguishes from B1 AND reads instantly. FI1 is likely dropped at Phase 2; submitting blank with this explanation.

---

# captureAttackerHeavy candidate (priority 6)

## CAH1 — "The bishop wins the queen"

A bishop captures the threatening black queen.

**Concern.** Capturing the queen with a smaller piece feels "obviously the right move" — risks failing the "not too obvious" test.

**Concept.**
- bQ checks wK or threatens mate.
- wB on a square that can reach the queen along a diagonal.
- Rescue: Bxq.

Without a pin or supporting piece that COMPLICATES the queen-capture, this reads as "the queen is en prise; take it."

**Submitting concern:** Standard "capture the queen" puzzles are typically too obvious. CAH1 is likely dropped at Phase 2; submitting blank with this explanation.

---

# Summary table

| Memo | Motif | Strength | Lead's likely verdict |
|---|---|---|---|
| CC1 | counterCheck | Strong | Promising for accept |
| CC2 | counterCheck | Strong | Promising for accept |
| CC3 | counterCheck | **Weak (R0 risk)** | Likely reject |
| CC4 | counterCheck | Medium | Possible accept or reject as too-close-to-CC2 |
| CAM1 | captureAttackerMinor | Strong | Promising for accept |
| CAM2 | captureAttackerMinor | Medium | Possible "too obvious" reject |
| RD1 | removeDefender | Strong | Promising for accept |
| RD2 | removeDefender | **REJECTED at memo level** (pin mechanic doesn't fit single-move) | Not pursued |
| BF1 | blockFile | **Weak (R0 risk — too close to P3)** | Likely reject |
| SD1 | sealDiagonal | **Weak (R0 risk — Rd4 same as B1)** | Likely reject |
| FI1 | forcedInterposition | **Author couldn't find a non-derivative shape** | Drop |
| CAH1 | captureAttackerHeavy | **Author couldn't find a non-obvious shape** | Drop |

**Realistic Phase 2 output projection:** 3-5 accepted candidates from {CC1, CC2, CC4, CAM1, RD1} — focused on the priority-1/2/3 motifs. The lower-priority motifs (blockFile, sealDiagonal, forcedInterposition, captureAttackerHeavy) didn't yield strong-enough new positions this round and are honestly deferred to a future sprint.

This matches the [[feedback-quality-over-symmetry]] principle: better to ship 3-5 excellent positions across 3 motifs than to force weak entries across all categories.

---

**End of Phase 1 memos.** Awaiting Phase 2 reviewer (proposal: lead) walk-through.

