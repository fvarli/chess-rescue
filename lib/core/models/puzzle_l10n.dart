import '../../l10n/gen/app_localizations.dart';
import 'puzzle.dart';
import 'variation.dart' show canonicalPuzzleId;

// Localized per-puzzle copy resolved at the widget layer. The Puzzle model
// keeps its authored EN strings as the golden source (and as the safe fallback
// for any puzzle id not yet wired below). C3 covers the nine canonical ids:
// p1–p5 plus expansion families a4, b1, b3, b4.
class PuzzleCopy {
  const PuzzleCopy({
    required this.statusText,
    required this.dangerHint,
    required this.failureHint,
    required this.successExplanation,
  });

  final String statusText;
  final String dangerHint;
  final String failureHint;
  final String successExplanation;
}

/// Returns the localized copy for [puzzle] in the current locale. Mirrored /
/// textured puzzle ids (e.g. `p1-knight-rescue#mirror`) collapse to their base
/// id via [canonicalPuzzleId], so all variants of a puzzle share its copy.
/// Unknown ids fall back to the puzzle's authored EN strings.
PuzzleCopy puzzleCopyFor(Puzzle puzzle, AppL10n t) {
  switch (canonicalPuzzleId(puzzle.id)) {
    case 'p1-knight-rescue':
      return PuzzleCopy(
        statusText: t.puzzleP1StatusText,
        dangerHint: t.puzzleP1DangerHint,
        failureHint: t.puzzleP1FailureHint,
        successExplanation: t.puzzleP1SuccessExplanation,
      );
    case 'p2-take-the-checker':
      return PuzzleCopy(
        statusText: t.puzzleP2StatusText,
        dangerHint: t.puzzleP2DangerHint,
        failureHint: t.puzzleP2FailureHint,
        successExplanation: t.puzzleP2SuccessExplanation,
      );
    case 'p3-block-the-file':
      return PuzzleCopy(
        statusText: t.puzzleP3StatusText,
        dangerHint: t.puzzleP3DangerHint,
        failureHint: t.puzzleP3FailureHint,
        successExplanation: t.puzzleP3SuccessExplanation,
      );
    case 'p4-seal-the-diagonal':
      return PuzzleCopy(
        statusText: t.puzzleP4StatusText,
        dangerHint: t.puzzleP4DangerHint,
        failureHint: t.puzzleP4FailureHint,
        successExplanation: t.puzzleP4SuccessExplanation,
      );
    case 'p5-win-the-queen':
      return PuzzleCopy(
        statusText: t.puzzleP5StatusText,
        dangerHint: t.puzzleP5DangerHint,
        failureHint: t.puzzleP5FailureHint,
        successExplanation: t.puzzleP5SuccessExplanation,
      );
    case 'a4-the-breakaway':
      return PuzzleCopy(
        statusText: t.puzzleA4StatusText,
        dangerHint: t.puzzleA4DangerHint,
        failureHint: t.puzzleA4FailureHint,
        successExplanation: t.puzzleA4SuccessExplanation,
      );
    case 'b1-the-martyr':
      return PuzzleCopy(
        statusText: t.puzzleB1StatusText,
        dangerHint: t.puzzleB1DangerHint,
        failureHint: t.puzzleB1FailureHint,
        successExplanation: t.puzzleB1SuccessExplanation,
      );
    case 'b3-remove-the-defender':
      return PuzzleCopy(
        statusText: t.puzzleB3StatusText,
        dangerHint: t.puzzleB3DangerHint,
        failureHint: t.puzzleB3FailureHint,
        successExplanation: t.puzzleB3SuccessExplanation,
      );
    case 'b4-the-cross-check':
      return PuzzleCopy(
        statusText: t.puzzleB4StatusText,
        dangerHint: t.puzzleB4DangerHint,
        failureHint: t.puzzleB4FailureHint,
        successExplanation: t.puzzleB4SuccessExplanation,
      );
    default:
      // Future puzzles without an l10n entry render their authored EN strings.
      return PuzzleCopy(
        statusText: puzzle.statusText,
        dangerHint: puzzle.dangerHint,
        failureHint: puzzle.failureHint,
        successExplanation: puzzle.successExplanation,
      );
  }
}
