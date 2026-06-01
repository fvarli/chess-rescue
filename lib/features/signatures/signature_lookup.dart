import '../../core/models/puzzle.dart';
import '../../core/models/puzzle_library.dart';
import '../../core/models/puzzle_template.dart';
import '../../core/models/variation.dart';

/// Pure derivation layer for the SIGNATURES UI. Resolves a stored
/// `encounteredPuzzleId` (which may carry a `#mirror` suffix) into a
/// renderable [Puzzle] instance for thumbnail and detail rendering.
///
/// Returns null defensively if the canonical id is no longer in the
/// library — storage outlives code, and a future library removal must
/// not crash the SIGNATURES tab.
Puzzle? resolvePuzzleFor(String encounteredPuzzleId) {
  final canonical = canonicalPuzzleId(encounteredPuzzleId);
  final isMirror = encounteredPuzzleId.contains('#mirror');
  final template = _findTemplate(canonical);
  if (template == null) return null;
  return template.toPuzzle(isMirror ? Variation.mirror : Variation.identity);
}

/// Returns the (currently authored-EN) puzzle title for the canonical id.
///
/// PR 2 V1 surfaces the authored EN title via [Puzzle.title]. Existing
/// puzzle copy (status / hints / success explanation) is fully localized
/// in [puzzleCopyFor], but titles are not currently wired through that
/// pipeline — adding localized titles is an additive future improvement.
/// Returns the canonical id verbatim as a defensive fallback so the UI
/// never renders blank.
String localizedPuzzleTitle(String canonicalPuzzleIdValue) {
  final template = _findTemplate(canonicalPuzzleIdValue);
  return template?.puzzle.title ?? canonicalPuzzleIdValue;
}

PuzzleTemplate? _findTemplate(String canonicalId) {
  for (final t in PuzzleLibrary.templates) {
    if (t.puzzle.id == canonicalId) return t;
  }
  for (final t in PuzzleLibrary.expansionTemplates) {
    if (t.puzzle.id == canonicalId) return t;
  }
  return null;
}
