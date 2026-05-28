import 'piece.dart';
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
    this.removableScenery = const [],
    this.sceneryPool = const [],
  });

  final RescueArchetype archetype;
  final Puzzle puzzle;

  /// Extra hand-vetted, honest decoy squares (base coordinates) beyond the
  /// authored `puzzle.legalMoves`. Empty = no decoy variation (Phase 23B).
  /// Every entry must be a believable, non-resolving move of the hero piece.
  final List<Square> decoyPool;

  /// Ids of pure-cosmetic pieces safe to drop for scenery variation (Phase 23C).
  final List<String> removableScenery;

  /// Hand-vetted addable context pawns (base coordinates) for scenery variation.
  /// Each must be off every functional square + tension lane and plausible.
  final List<Piece> sceneryPool;

  /// Produce a runtime instance, optionally transformed by a [Variation].
  /// The default (identity) returns the base puzzle unchanged — the variation
  /// seam from Phase 19A.
  Puzzle toPuzzle([Variation variation = Variation.identity]) =>
      applyVariation(puzzle, variation);

  /// Preview-only: a textured instance (Phase 23B decoys + 23C scenery).
  /// `textureSeed 0` + `scenerySeed 0` reproduce the canonical board (then
  /// [variation]); `> 0` swap 1–2 decoys / toggle 1–2 cosmetic pawns. Scenery
  /// (pieces) and decoys (legalMoves) are selected in base coordinates first —
  /// orthogonal to each other — then the geometric variation is applied. Not
  /// wired into the live runtime.
  Puzzle toTexturedPuzzle({
    Variation variation = Variation.identity,
    int textureSeed = 0,
    int scenerySeed = 0,
  }) {
    var base = applyScenery(puzzle, removableScenery, sceneryPool, scenerySeed);
    base = applyDecoyTexture(base, decoyPool, textureSeed);
    return applyVariation(base, variation);
  }
}
