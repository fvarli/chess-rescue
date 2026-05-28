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
