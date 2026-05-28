import 'puzzle.dart';
import 'rescue_archetype.dart';

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

  /// Produce the runtime instance. Identity for now — the variation seam.
  Puzzle toPuzzle() => puzzle;
}
