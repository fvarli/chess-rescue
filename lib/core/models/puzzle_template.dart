import 'puzzle.dart';
import 'rescue_archetype.dart';
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
  const PuzzleTemplate({required this.archetype, required this.puzzle});

  final RescueArchetype archetype;
  final Puzzle puzzle;

  /// Produce a runtime instance, optionally transformed by a [Variation].
  /// The default (identity) returns the base puzzle unchanged — the variation
  /// seam from Phase 19A.
  Puzzle toPuzzle([Variation variation = Variation.identity]) =>
      applyVariation(puzzle, variation);
}
