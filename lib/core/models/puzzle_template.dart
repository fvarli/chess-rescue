import 'puzzle.dart';
import 'rescue_archetype.dart';
import 'square.dart';
import 'variation.dart';

/// A hand-authored rescue situation tagged with its archetype — the Template
/// layer of the Phase 19A replayability architecture
/// (Archetype → Template → Variation → Instance → Session).
///
/// In 19B, `toPuzzle()` is the identity conversion (runtime sees the same
/// `Puzzle`). 19C will turn this into the variation seam, e.g.
/// `applyVariation(puzzle, variation)`. No variation metadata lives here yet —
/// it arrives with the engine that consumes it.
class PuzzleTemplate {
  const PuzzleTemplate({
    required this.archetype,
    required this.puzzle,
    this.decoyPool = const [],
  });

  final RescueArchetype archetype;
  final Puzzle puzzle;

  /// Extra hand-vetted, honest decoy squares (base coordinates) beyond the
  /// authored `puzzle.legalMoves`. Empty = no decoy variation (Phase 23B).
  /// Every entry must be a believable, non-resolving move of the hero piece.
  final List<Square> decoyPool;

  /// Produce a runtime instance, optionally transformed by a [Variation].
  /// The default (identity) returns the base puzzle unchanged — the variation
  /// seam from Phase 19A.
  Puzzle toPuzzle([Variation variation = Variation.identity]) =>
      applyVariation(puzzle, variation);

  /// Preview-only (Phase 23B): a decoy-textured instance. `textureSeed 0`
  /// reproduces the canonical authored decoys (then [variation]); `> 0` swaps
  /// 1–2 decoys from [decoyPool]. Decoy texture is selected in base coordinates
  /// first, then the geometric variation is applied — the two are orthogonal.
  /// Not wired into the live runtime.
  Puzzle toTexturedPuzzle({
    Variation variation = Variation.identity,
    int textureSeed = 0,
  }) => applyVariation(
    applyDecoyTexture(puzzle, decoyPool, textureSeed),
    variation,
  );
}
