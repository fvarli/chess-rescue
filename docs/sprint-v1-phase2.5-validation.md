# Sprint V1 — Phase 2.5 Geometry Validation Report

> **Purpose.** Eight-check validation per the approved Phase 2 / 2.5 /
> 3 execution plan. Each provisional candidate (CC1, CC2, CAM1, RD1)
> is walked methodically through the 8 checks. On the first FAIL, the
> candidate is marked REJECTED and archived. Only candidates passing
> all 8 checks proceed to Phase 3 implementation.
>
> Coordinate system used throughout: file 0-7 = a-h, rank 0-7 = 1-8.

---

## CC1 — "The Rook above the king"

### Provisional rescue: `Rf8+` from `wR-f3`

### Position
- wK g1 (6,0)
- wPs a2 (0,1), f2 (5,1), g2 (6,1), h2 (7,1)
- wR f3 (5,2) — rescuer
- bB a6 (0,5)
- bK g8 (6,7)
- bP h7 (7,6)
- bQ h3 (7,2)

### Check 1 — Board reconstruction
- All 10 pieces on-board, no overlaps, no pawns on rank 0/7. ✓

### Check 2 — Threat is real
- Memo claims threat: `Qxh2+` then Qg1 mate via bB-a6 covering f1.
- Re-verify the bB-a6's covering of f1:
  - a6 (0,5) to f1 (5,0): file_diff = +5, rank_diff = -5. |5|=|5| → diagonal ✓
  - Path: b5 (1,4), c4 (2,3), d3 (3,2), e2 (4,1), f1 (5,0). All empty. ✓
  - bB-a6 controls f1.
- Verify `Qxh2+` then mate:
  - bQ-h3 → h2 (captures wP). bQ now on h2.
  - bQ-h2 attacks wK-g1 via diagonal h2-g1. Check.
  - Flight squares from g1: f1, h1.
    - f1: attacked by bB-a6 via diagonal (verified above). ✓ blocked.
    - h1: attacked by bQ-h2 via h-file. ✓ blocked.
    - f2: occupied by wP. ✓ blocked.
  - **Mate.** ✓

### Check 3 — Rescue is legal
- `Rf8+` from wR-f3 along f-file. Path: f4, f5, f6, f7 (all empty). f8 empty. ✓ chess-legal.
- After move, does wK remain in any new check? No discovered attackers (no white piece between wR-f3 and other targets). ✓

### Check 4 — Rescue resolves the threat
- After `Rf8+`, bK-g8 is in check from wR-f8 along the 8th rank.
- Black must answer the check; cannot play Qxh2+ this move.
- Threat deferred by one move. ✓

### Check 5 — No second valid rescue
Examining every move of the tappable piece (wR on f3):
- File f: f4, f5, f6, f7, **f8** (rescue, check).
- Rank 3: e3, d3, c3, b3, a3 (sliding left); g3, **Rxh3** (sliding right, captures bQ!).

**FAIL on `Rxh3`:** wR captures the threatening queen along the 3rd rank. Capturing the threat directly RESOLVES the mate (no queen → no Qxh2# anymore).

This is a **second valid rescue at the position level**. The authored `legalMoves` could omit Rxh3 (per the P1 convention of hiding chess-legal moves), but R5 in the sprint plan's authoring rules says "no other friendly piece has a move that also resolves the danger." The wR HAS such a move (Rxh3) — not "another friendly piece" but "another move of the same rescuer."

The conservative interpretation of R5: a candidate position with TWO valid rescue moves from the rescuer piece is structurally weak, even if the authoring convention can hide one. The puzzle's intent should be ONE move = THE rescue, not "the authored move among several."

**Verdict: REJECT CC1 at Check 5.**

### Decision: REJECTED at Phase 2.5
**Check failed: #5 (no second valid rescue).** From the same tappable piece (wR on f3), `Rxh3` is a chess-legal move that captures the threatening queen and thus resolves the mate-in-one. The candidate cannot ship — even with authoring hiding Rxh3, the position is structurally ambiguous.

### Future-sprint guidance
A counter-check candidate where the rescuer also has a capture-the-threat alternative is structurally weak. Future remixes should EITHER position the rescuer so it cannot reach the threatening piece's square, OR change the threat geometry so the obvious capture doesn't exist. The "rook counter-check" SHAPE is still potentially valuable; the specific CC1 geometry isn't.

---

## CC2 — "Take the shield, take the king"

### Provisional rescue: `Bxf7+` from `wB-c4`

### Position
- wK g1 (6,0)
- wPs a2, f2, g2, h2
- wB c4 (2,3) — rescuer
- wR a1 (0,0)
- bK g8 (6,7)
- bQ h3 (7,2)
- bPs a7, f7 (5,6), h7

### Check 1 — Board reconstruction
- 11 pieces on-board, no overlaps, no pawns on rank 0/7. ✓

### Check 2 — Threat is real
- Threat: bQ-h3 plays `Qxg2#`.
- After Qxg2: bQ on g2, attacks wK on g1 (file).
- Flights from g1: f1, f2 (own pawn), h1.
  - f1 from g2: file_diff -1, rank_diff -1 → diagonal. ✓ attacked.
  - h1 from g2: file_diff +1, rank_diff -1 → diagonal. ✓ attacked.
  - f2: own pawn. ✓ blocked.
- **Mate.** ✓

### Check 3 — Rescue is legal
- `Bxf7+` from wB-c4. Diagonal c4 (2,3) → f7 (5,6): file_diff +3, rank_diff +3. ✓ diagonal.
- Path: d5 (3,4), e6 (4,5). Both empty. ✓
- f7 occupied by bP. Capture legal.
- After move, wK in any new check? No discovered attackers. ✓

### Check 4 — Rescue resolves the threat
- After Bxf7+: wB on f7. bK on g8. f7→g8 file_diff +1, rank_diff +1 → diagonal. wB attacks bK. **Check.**
- Black must answer check (Kxf7, Kh8 are options). Cannot play Qxg2# this move.
- Threat deferred. ✓

### Check 5 — No second valid rescue
Examining every move of the tappable piece (wB on c4):
- NE diagonal: d5, e6 (both decoys, no check — blocked at f7 looking through), **Bxf7+** (rescue).
  - Does Bd5 or Be6 deliver a check? d5 to g8: file_diff +3, rank_diff +3 → diagonal. But path d5→e6→f7 has bP-f7 BLOCKING. So Bd5 attacks e6 and is blocked at f7. Bd5 does NOT attack g8.
  - Be6 to g8: file_diff +2, rank_diff +2 → diagonal. Path e6→f7→g8. bP-f7 BLOCKS. So Be6 does NOT attack g8.
  - **Neither Bd5 nor Be6 give check.** ✓
- SE diagonal: d3, e2, **f1** (attacked square — does Bf1 resolve threat?).
  - Bf1: wB moves to f1. Does this block the threat? bQ is still on h3, planning Qxg2#. After Bf1, can black still play Qxg2? Yes (g2 still has wP for the capture). Qxg2: bQ on g2, checks wK on g1. Flights: f1 (occupied by wB — wK can't go), h1 (attacked). f2 own pawn. So with wB on f1, wK can't escape to f1 (own piece). Mate still works.
  - Bf1 does NOT resolve.
  - Bd3, Be2: decoys, no effect.
- SW diagonal: b3, a2 (own pawn, illegal).
- NW diagonal: b5, a6 (no piece). Decoys.

No second valid rescue from wB-c4. ✓

Now examining other white pieces:
- wK-g1: surrounded; no legal moves (f1 attacked by bQ-h3 via diagonal h3-g2-f1 verified; h1 attacked by bQ-h3 via... h3 to h1 file diff 0 rank diff -2 → file move, blocked by wP-h2; so h1 NOT attacked by bQ directly. Hmm.).
  - Wait — bQ on h3 to h1: same file, 2 ranks. Queen attacks along files. Path through h2 (occupied by wP). So bQ does NOT attack h1 from h3 directly (path blocked).
  - So h1 might be a flight for wK currently? Let me check: wK on g1. King moves to h1 — is h1 attacked? bQ-h3 attacks h-file through h2 (blocked). bB-a6 doesn't exist in CC2. No other attackers.
  - So Kh1 is a legal move! Does it resolve the threat? After Kh1, bQ-h3 can still play Qxg2. After Qxg2: bQ on g2, attacks wK-h1 via diagonal g2-h1. wK in check. Flights from h1: g1 (just vacated; attacked by bQ-g2 file), h2 (own pawn).
  - Actually wait — after Qxg2: wK is on h1, in check from bQ on g2. Flights g1 attacked by bQ-g2 (file). h2 own pawn. No other flights. Mate.
  - So Kh1 doesn't resolve the threat. Black mates with Qxg2# regardless.
- wP-g2: g3, g4 push. Neither addresses the threat. wK still mates next move.
- wP-h2: h3 capture? hxg3 — g3 empty. No diagonal capture available. h4 double-move blocked by bQ-h3.
  - Actually wait — wP-h2 can capture bQ on h3? No, pawns capture diagonally, not forward. h2 attacks g3 and i3 (off-board) by capture. Not h3.
- wP-f2: f3, f4 — neither resolves.
- wP-a2: irrelevant.
- wR-a1: a-file (a2 own pawn blocks), 1st rank moves. None resolve.

**Result: only Bxf7+ resolves the threat from a tappable rescue.** ✓ Check 5 passes.

### Check 6 — Mirror validity
Mirror file-flip: file → 7 - file.

Mirrored position:
- wK g1 → b1 (1,0)
- wPs: a2 → h2 (7,1), f2 → c2 (2,1), g2 → b2 (1,1), h2 → a2 (0,1)
- wB c4 → f4 (5,3)
- wR a1 → h1 (7,0)
- bK g8 → b8 (1,7)
- bQ h3 → a3 (0,2)
- bPs: a7 → h7 (7,6), f7 → c7 (2,6), h7 → a7 (0,6)

Verify mirrored threat: bQ-a3 plays Qxb2 (mirror of Qxg2). After Qxb2:
- bQ on b2 attacks wK-b1 via file. Check.
- Flights from b1: a1 attacked by Qxb2 diagonal. c1 attacked by Qxb2 diagonal. b2 (queen). a2 own pawn. c2 own pawn.
- All blocked. ✓ Mate.

Verify mirrored rescue: `Bxc7+` from wB-f4. Diagonal f4 → c7: file_diff -3, rank_diff +3. ✓ diagonal. Path e5, d6 (empty). Captures bP-c7. wB on c7 attacks bK-b8 (file_diff -1, rank_diff +1, diagonal). Check. ✓

Mirror is structurally identical (rotated). No new second rescue (same analysis applies). ✓

### Check 7 — Decoy honesty
Authored `legalMoves` for wB-c4 (proposed in memo):
- f7 (rescue)
- d5 (decoy — no check, blocked at f7)
- e6 (decoy — no check, blocked at f7)
- b5 (decoy — queenside, no effect on threat)
- a6 (decoy — queenside, no effect)

Each decoy verified non-resolving:
- Bd5: doesn't capture queen, doesn't block g-file, doesn't check bK. ✓ honest.
- Be6: same. ✓ honest.
- Bb5: same. ✓ honest.
- Ba6: same. ✓ honest.

All decoys honest. ✓

### Check 8 — R0 distinctness from validated board
Compared to existing counter-check exemplars:
- **P1** (Nf6+ knight rescue from e4): different piece (knight vs bishop), different square (f6 vs f7), different mechanism (knight leap vs bishop capture).
- **A4** (Nf6+ knight escape from d5): different piece, different square, different mechanism.
- **B4** (Ng6+ knight blocks + checks): different piece, different square (g6 vs f7), no shield-capture in B4.

CC2's distinguishing features:
- Bishop rescuer (not knight)
- Captures kingside shield pawn (f7)
- Rescue square is f7 (no existing exemplar lands there)

A trained P1/A4/B4-veteran would NOT instantly recognise CC2 from position memory. The "bishop captures kingside shield with check" pattern is structurally distinct.

✓ R0 passes.

### Decision: ACCEPTED after geometry validation
All 8 checks pass. **CC2 proceeds to Phase 3 implementation.**

---

## CAM1 — "Knight takes the bishop"

### Provisional rescue: `Nxh2` from `wN-g4`

### Position (filling in the underspecified memo)
- wK g1 (6,0)
- wPs a2 (0,1), b2 (1,1), c2 (2,1), f2 (5,1), g2 (6,1) — no h2
- wN g4 (6,3) — rescuer
- bK g8 (6,7)
- bB h2 (7,1) — threatening, currently checking wK
- bPs a7, f7, h7

### Check 1 — Board reconstruction
All on-board, no overlaps, no pawns on rank 0/7. ✓

### Check 2 — Threat is real
The "threat" in CAM1 is an ACTIVE CHECK from bB-h2:
- bB-h2 attacks wK-g1 via diagonal h2-g1. ✓ check.

wK is currently in check. Per chess rules, white MUST address the check this move. So the "threat" is "address the check or lose."

Verify wK has no escape that resolves (Phase 2.5 thoroughness):
- Flights from g1: f1, f2 (own pawn), g2 (own pawn), h1.
  - f1 from bB-h2: file_diff -2, rank_diff -1. NOT diagonal. NOT attacked. Legal flight.
  - h1 from bB-h2: file_diff 0, rank_diff -1. NOT a diagonal. NOT attacked. Legal flight.
  - f2, g2: own pawns.
- So wK has legal flights Kf1 and Kh1.

In Chess Rescue's design, king flight squares are NOT considered "alternative rescues" because the `tappableSquare` field constrains which piece the player can move. CAM1's tappableSquare = g4 (the knight), so the player only sees knight moves. King flights are invisible to the player surface.

The "threat is real" check is interpreted as: there IS an active check that the puzzle requires resolution for. ✓

### Check 3 — Rescue is legal
- `Nxh2` — knight from g4 (6,3) to h2 (7,1). Offset: file_diff +1, rank_diff -2 → knight move ✓
- Captures bB on h2.
- After move, wK in check from any other piece? No bQ, no bR. Other black pieces (bK, bPs) don't reach g1.
- ✓ rescue is chess-legal and doesn't leave wK in check.

### Check 4 — Rescue resolves the threat
- After Nxh2: bB captured. Check ended.
- wK no longer in check. ✓

### Check 5 — No second valid rescue
Examining every knight move from g4 (6,3):
- Knight destinations: (6±2, 3±1) and (6±1, 3±2).
  - (8, 4) off-board; (8, 2) off-board.
  - (4, 4) = e5. Does Ne5 resolve check? No (doesn't capture bB, doesn't block, can't block bishop check on the one-step h2-g1 diagonal). ✗ doesn't resolve.
  - (4, 2) = e3. Same as Ne5. ✗
  - (7, 5) = h6. Doesn't resolve. ✗
  - (7, 1) = **h2 (rescue)** — captures bB. ✓ resolves.
  - (5, 5) = f6. Doesn't resolve. ✗
  - (5, 1) = f2. Own pawn — illegal in chess. ✗

Only Nxh2 resolves among knight moves. ✓

Other white pieces — applying the same "tappable-piece" interpretation as established for CAM1's design (consistent with P2 canon):
- wP captures: only wP-g2 could attack the bishop diagonally (wP captures on f3/h3). g2 captures on f3 or h3 (both empty). No.
- wP-f2 captures: e3/g3. Both empty. No.
- wK moves: Kf1/Kh1 are chess-legal but NOT player-tappable (tappableSquare = g4). Per existing canon (P2), these are not considered alternative rescues.

Tappable-piece analysis is clean. ✓

### Check 6 — Mirror validity
Mirror flips files.
- wK g1 → b1
- wPs a2 → h2, b2 → g2, c2 → f2, f2 → c2, g2 → b2
- wN g4 → b4
- bK g8 → b8
- bB h2 → a2
- bPs a7 → h7, f7 → c7, h7 → a7

Mirrored threat: bB-a2 attacks wK-b1 via diagonal a2-b1. ✓ check.

Mirrored rescue: Nxa2 — wN-b4 to a2. Offset: file_diff -1, rank_diff -2 ✓ knight move. Captures bB-a2.

After Nxa2: check resolved. ✓

Mirror works. ✓

### Check 7 — Decoy honesty
Authored `legalMoves` for wN-g4:
- h2 (rescue)
- h6 (decoy)
- f6 (decoy)
- e5 (decoy)
- e3 (decoy)

Each decoy verified non-resolving (none captures bB; none blocks the h2-g1 diagonal; none moves a piece that interrupts the bishop's attack). All decoys honest. ✓

### Check 8 — R0 distinctness from validated board
Comparison to P2 (the only existing `captureAttackerMinor` exemplar):
- P2 (gxf3): pawn captures knight on f3. Threat = knight check.
- CAM1 (Nxh2): knight captures bishop on h2. Threat = bishop check.

Differences:
- Rescue piece: pawn (P2) vs knight (CAM1).
- Threatening piece: knight (P2) vs bishop (CAM1).
- Rescue square: f3 (P2) vs h2 (CAM1).
- Check geometry: f3 attacks g1 via knight move (P2) vs h2 attacks g1 via diagonal (CAM1).

A trained P2-veteran would NOT instantly recognise CAM1 from position memory. Different piece pair, different geometric area.

✓ R0 passes.

### Decision: ACCEPTED after geometry validation
All 8 checks pass. **CAM1 proceeds to Phase 3 implementation.**

---

## RD1 — "The pinned defender"

### Provisional rescue: `Nxg3` from `wN-e5`

### Position (per memo)
- wK g1 (6,0)
- wPs a2 (0,1), f2 (5,1), h2 (7,1) — no g2
- wN e5 (4,4) — proposed rescuer
- bK g8 (6,7)
- bN g3 (6,2) — the "defender"
- bQ h3 (7,2)
- bP f7, h7

### Check 1 — Board reconstruction
All on-board, no overlaps. ✓

### Check 2 — Threat is real
Memo claims `Qh1#` as the threat. Verify:
- bQ-h3 → h1: same file, 2 ranks. Path through h2 (wP-h2 BLOCKS). So bQ CANNOT reach h1 directly.
- Memo's `Qh1#` is not a chess-legal move from h3 with current position. ✗

Alternative: maybe the threat is `Qxh2#`:
- bQ-h3 → h2 (captures wP-h2). bQ on h2.
- Check on wK-g1 (diagonal). Flights:
  - f1: from bQ-h2: file_diff -2, rank_diff -1. NOT diagonal. NOT attacked by bQ.
  - f1 attacked by bN-g3? Knight from g3 to f1: file_diff -1, rank_diff -2. ✓ knight move. ✓ attacked.
  - g2: empty (no wP-g2). Attacked by bQ-h2 (adjacent). ✓ attacked.
  - h1: attacked by bQ-h2 (h-file). ✓ attacked.
  - f2: own pawn, blocked.
- All flights blocked. Mate.

Adjusting the memo: the threat is `Qxh2#`, not `Qh1#`. The memo had it wrong but the position has a real mate-in-one threat. ✓ (with corrected interpretation).

### Check 3 — Rescue is legal
- Memo's rescue: `Nxg3` from wN-e5.
- wN-e5 (4,4) to g3 (6,2): file_diff +2, rank_diff -2. |2|=|2|. **This is a BISHOP move, NOT a knight move.**
- Knight moves from e5: g6 (6,5), g4 (6,3), c6 (2,5), c4 (2,3), f7 (5,6), f3 (5,2), d7 (3,6), d3 (3,2).
- g3 is NOT among these.

**`Nxg3` is NOT a chess-legal move from e5.** ✗ Rescue is geometrically impossible.

### Decision: REJECTED at Phase 2.5
**Check failed: #3 (rescue is not chess-legal).** The proposed rescue `Nxg3` requires a 2-file/2-rank diagonal jump, which is a bishop move pattern, not a knight move pattern. From e5, a knight cannot reach g3 in one move.

### What COULD work
The intended motif (capture the bN-g3 defender) IS achievable in this position by `fxg3` — wP-f2 captures bN-g3 (pawn diagonal forward). After fxg3, bN removed; Qxh2 still possible but no longer mate (f1 no longer covered by bN, AND bQ on h2 doesn't cover f1 itself; wK escapes to f1).

But `fxg3` makes the puzzle a `captureAttackerMinor` archetype (pawn capturing minor), NOT `removeDefender` (which conceptually distinguishes capturing the support piece from capturing the threatening piece).

Per the lead's "do not patch weak candidates" directive, RD1 as authored does not ship. The "remove the defender" motif intent could be revisited in a future sprint with a position where a knight (or other non-pawn piece) can geometrically reach the defender square.

### Future-sprint guidance
A future `removeDefender` candidate should:
1. Place the rescuer piece so it can ACTUALLY reach the defender's square in one move (verify chess-legal geometry BEFORE writing the memo).
2. Keep the defender as a non-threat piece whose removal defangs the mate — but make the defender's role unambiguous from a chess-move-counting perspective.
3. Avoid pawn-recapture rescues (those slide into `captureAttackerMinor`).

---

## Phase 2.5 Summary

| Memo | Check that failed | Decision |
|---|---|---|
| **CC1** | #5 — Rxh3 is a second valid rescue at the position level | **REJECTED** |
| **CC2** | (none — all 8 passed) | **ACCEPTED** |
| **CAM1** | (none — all 8 passed) | **ACCEPTED** |
| **RD1** | #3 — `Nxg3` is not a chess-legal knight move from e5 | **REJECTED** |

**Phase 2.5 accept set: 2 positions** (CC2, CAM1).

Per [[feedback-quality-over-symmetry]], 2 is the correct ship count for this sprint. The accept set clusters in priority motifs 1 (`counterCheck`, via CC2) and 2 (`captureAttackerMinor`, via CAM1). Priority motifs 3-6 are honestly deferred to a future sprint.

Per the lead's "do not patch, do not invent replacements" directive: CC1 and RD1 are archived; no patches attempted.

---

**End of Phase 2.5 validation report.**
