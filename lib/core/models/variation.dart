import 'dart:math';

import 'puzzle.dart';
import 'square.dart';

/// A pure, deterministic geometric transform of a puzzle template
/// (Phase 19A architecture). 19C ships only `identity` and `mirror`.
class Variation {
  const Variation({
    required this.id,
    this.mirrorHorizontal = false,
    this.dx = 0,
    this.dy = 0,
  });

  final String id;
  final bool mirrorHorizontal;

  /// Board offset — reserved for a later phase. No 19C variation sets these.
  final int dx;
  final int dy;

  bool get isNoOp => !mirrorHorizontal && dx == 0 && dy == 0;

  static const Variation identity = Variation(id: 'identity');
  static const Variation mirror = Variation(
    id: 'mirror',
    mirrorHorizontal: true,
  );
}

/// The base (family) id for any instance — strips the `#variation` suffix.
/// A mirror counts as the same rescue family as its base (Phase 21 persistence).
String canonicalPuzzleId(String id) => id.split('#').first;

/// Mirror flips files (`file → 7 - file`) and preserves rank. Offset (dx/dy) is
/// reserved and must stay zero until the offset phase.
Square transformSquare(Square s, Variation v) {
  final file = (v.mirrorHorizontal ? 7 - s.file : s.file) + v.dx;
  final rank = s.rank + v.dy;
  return Square(file, rank);
}

/// Apply a variation to a base puzzle, producing a new instance.
///
/// A no-op variation returns the **same** instance, so the default
/// `PuzzleTemplate.toPuzzle()` stays byte-identical to the shipped puzzle.
/// Piece ids are preserved (deterministic, unique-within-puzzle, stable →
/// stable AnimatedPositioned keys). Copy is preserved as-is for now (variants
/// are preview-only; copy/notation is decoupled before variants ship).
Puzzle applyVariation(Puzzle base, Variation v) {
  assert(
    v.dx == 0 && v.dy == 0,
    'Board offset is reserved and not active yet (dx/dy must be 0).',
  );
  if (v.isNoOp) return base;

  Square t(Square s) => transformSquare(s, v);

  return Puzzle(
    id: '${base.id}#${v.id}',
    title: base.title,
    statusText: base.statusText,
    pieces: [
      for (final p in base.pieces)
        p.copyWith(
          file: (v.mirrorHorizontal ? 7 - p.file : p.file) + v.dx,
          rank: p.rank + v.dy,
        ),
    ],
    tappableSquare: t(base.tappableSquare),
    legalMoves: [for (final s in base.legalMoves) t(s)],
    rescueTo: t(base.rescueTo),
    // Exact notation is geometry-specific and not displayed; clear it on
    // variants rather than carry a stale value (Phase 20).
    rescueNotation: '',
    dangerHint: base.dangerHint,
    failureHint: base.failureHint,
    successExplanation: base.successExplanation,
    threatenedKing: t(base.threatenedKing),
    isPrototype: base.isPrototype,
  );
}

/// Preview-only **decoy texture** (Phase 23B): keep the rescue and all board
/// geometry identical, but vary the *believable wrong moves* around it.
///
/// `textureSeed == 0` (or an empty pool) returns the base unchanged — the
/// canonical authored decoy set is the dominant anchor. For `textureSeed > 0`,
/// deterministically swap **1–2** authored decoys for hand-vetted [decoyPool]
/// decoys, preserving the rescue, the decoy *count*, and distinctness. Apply
/// this in base coordinates *before* a geometric [applyVariation] (mirror), so
/// the two compose orthogonally.
///
/// Honesty (a decoy must not secretly resolve the danger) is an authoring
/// guarantee — the pool is hand-vetted; the gates are geometry-only.
Puzzle applyDecoyTexture(Puzzle base, List<Square> decoyPool, int textureSeed) {
  if (textureSeed == 0 || decoyPool.isEmpty) return base;

  final rescue = base.rescueTo;
  final authored = [
    for (final s in base.legalMoves)
      if (s != rescue) s,
  ];
  final extras = [
    for (final s in decoyPool)
      if (s != rescue && !authored.contains(s)) s,
  ];
  if (authored.isEmpty || extras.isEmpty) return base;

  final rng = Random(textureSeed);
  final maxSwap = [
    2,
    authored.length,
    extras.length,
  ].reduce((a, b) => a < b ? a : b);
  final swapCount = 1 + rng.nextInt(maxSwap);

  final positions = _pickDistinct(rng, authored.length, swapCount);
  final inserts = _pickDistinct(rng, extras.length, swapCount);

  final newAuthored = [...authored];
  for (var i = 0; i < swapCount; i++) {
    newAuthored[positions[i]] = extras[inserts[i]];
  }

  // Rebuild legalMoves preserving the rescue's original slot + decoy order.
  var d = 0;
  final newLegalMoves = [
    for (final s in base.legalMoves) s == rescue ? s : newAuthored[d++],
  ];

  return Puzzle(
    id: base.id,
    title: base.title,
    statusText: base.statusText,
    pieces: base.pieces,
    tappableSquare: base.tappableSquare,
    legalMoves: newLegalMoves,
    rescueTo: base.rescueTo,
    rescueNotation: base.rescueNotation,
    dangerHint: base.dangerHint,
    failureHint: base.failureHint,
    successExplanation: base.successExplanation,
    threatenedKing: base.threatenedKing,
    isPrototype: base.isPrototype,
  );
}

/// Deterministically pick `k` distinct indices in `[0, n)` using a partial
/// Fisher–Yates shuffle driven by [rng]. Requires `0 <= k <= n`.
List<int> _pickDistinct(Random rng, int n, int k) {
  final pool = [for (var i = 0; i < n; i++) i];
  for (var i = 0; i < k; i++) {
    final j = i + rng.nextInt(n - i);
    final tmp = pool[i];
    pool[i] = pool[j];
    pool[j] = tmp;
  }
  return pool.sublist(0, k);
}
