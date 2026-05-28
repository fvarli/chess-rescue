import 'piece.dart';
import 'puzzle.dart';
import 'square.dart';

/// Result of structural validation — empty errors means the puzzle is sound.
class PuzzleValidation {
  const PuzzleValidation(this.errors);
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

bool _inBounds(Square s) =>
    s.file >= 0 && s.file <= 7 && s.rank >= 0 && s.rank <= 7;

/// Pure structural check (no chess engine). Used to gate generated variations
/// before they can enter a session. See docs/replayability-architecture.md.
PuzzleValidation validatePuzzle(Puzzle p) {
  final errors = <String>[];

  // 1. All squares in bounds.
  for (final pc in p.pieces) {
    if (!_inBounds(Square(pc.file, pc.rank))) {
      errors.add('piece ${pc.id} out of bounds (${pc.file},${pc.rank})');
    }
  }
  if (!_inBounds(p.tappableSquare)) errors.add('tappableSquare out of bounds');
  if (!_inBounds(p.rescueTo)) errors.add('rescueTo out of bounds');
  if (!_inBounds(p.threatenedKing)) errors.add('threatenedKing out of bounds');
  for (final s in p.legalMoves) {
    if (!_inBounds(s)) errors.add('legalMove $s out of bounds');
  }

  // 2. Unique piece squares.
  final seen = <String>{};
  for (final pc in p.pieces) {
    if (!seen.add('${pc.file},${pc.rank}')) {
      errors.add('duplicate piece square (${pc.file},${pc.rank})');
    }
  }

  // 3. A light piece sits on tappableSquare.
  final onTap = p.pieces.where(
    (pc) =>
        pc.file == p.tappableSquare.file && pc.rank == p.tappableSquare.rank,
  );
  if (onTap.isEmpty || onTap.first.color != PieceColor.light) {
    errors.add('tappableSquare has no light piece');
  }

  // 4. rescueTo is one of the whitelisted legal moves.
  if (!p.legalMoves.contains(p.rescueTo)) {
    errors.add('rescueTo is not in legalMoves');
  }

  // 5. A light king sits on threatenedKing.
  final onKing = p.pieces.where(
    (pc) =>
        pc.file == p.threatenedKing.file && pc.rank == p.threatenedKing.rank,
  );
  if (onKing.isEmpty ||
      onKing.first.type != PieceType.king ||
      onKing.first.color != PieceColor.light) {
    errors.add('threatenedKing has no light king');
  }

  return PuzzleValidation(errors);
}
