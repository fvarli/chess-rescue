import 'piece.dart';
import 'puzzle.dart';
import 'square.dart';

/// Result of the Phase 19A readability gate — is an instance *emotionally
/// legible*? (Distinct from `validatePuzzle`, which checks structural
/// soundness.) `passed` requires every dimension to pass.
class ReadabilityScore {
  const ReadabilityScore({
    required this.threatVisibility,
    required this.rescueClarity,
    required this.clutter,
    required this.visualBalance,
    required this.moveDiscoverability,
    required this.emotionalImmediacy,
    required this.panicReadability,
    this.notes = const [],
  });

  final bool threatVisibility;
  final bool rescueClarity;
  final bool clutter;
  final bool visualBalance;
  final bool moveDiscoverability;
  final bool emotionalImmediacy;
  final bool panicReadability;

  /// Human-readable reasons for any failing dimension.
  final List<String> notes;

  bool get passed =>
      threatVisibility &&
      rescueClarity &&
      clutter &&
      visualBalance &&
      moveDiscoverability &&
      emotionalImmediacy &&
      panicReadability;
}

// ── Pure geometry helpers (no blockers, no legality, no engine) ──

int _chebyshev(int f1, int r1, int f2, int r2) {
  final df = (f1 - f2).abs();
  final dr = (r1 - r2).abs();
  return df > dr ? df : dr;
}

bool _knightRelation(int f1, int r1, int f2, int r2) {
  final df = (f1 - f2).abs();
  final dr = (r1 - r2).abs();
  return (df == 1 && dr == 2) || (df == 2 && dr == 1);
}

bool _sameRankOrFile(int f1, int r1, int f2, int r2) => f1 == f2 || r1 == r2;

bool _sameDiagonal(int f1, int r1, int f2, int r2) =>
    (f1 - f2).abs() == (r1 - r2).abs();

/// Does a dark piece geometrically relate to [target] given its movement type?
/// (Alignment only — ignores blockers; a lenient v1 proxy.)
bool _aligned(Piece p, int tf, int tr) {
  switch (p.type) {
    case PieceType.queen:
      return _sameRankOrFile(p.file, p.rank, tf, tr) ||
          _sameDiagonal(p.file, p.rank, tf, tr);
    case PieceType.rook:
      return _sameRankOrFile(p.file, p.rank, tf, tr);
    case PieceType.bishop:
      return _sameDiagonal(p.file, p.rank, tf, tr);
    case PieceType.knight:
      return _knightRelation(p.file, p.rank, tf, tr);
    case PieceType.king:
    case PieceType.pawn:
      return false; // not treated as the looming attacker
  }
}

bool _between(Square a, Square mid, Square b) {
  // mid strictly between a and b along a straight rank/file/diagonal.
  final dfAB = b.file - a.file, drAB = b.rank - a.rank;
  final dfAM = mid.file - a.file, drAM = mid.rank - a.rank;
  // collinear (straight line) check
  if (dfAB * drAM != drAB * dfAM) return false;
  final stepF = dfAB.sign, stepR = drAB.sign;
  // must be a rank/file/diagonal direction
  if (!((stepF == 0) ||
      (stepR == 0) ||
      (stepF.abs() == 1 && stepR.abs() == 1))) {
    // diagonal requires |df|==|dr|; rank/file requires one zero — already
    // implied by collinearity + integer steps, but guard anyway.
  }
  final maxSteps = (dfAB.abs() > drAB.abs() ? dfAB.abs() : drAB.abs());
  for (var i = 1; i < maxSteps; i++) {
    if (a.file + stepF * i == mid.file && a.rank + stepR * i == mid.rank) {
      return true;
    }
  }
  return false;
}

/// Conservative, heuristic readability gate. See docs/rescue-archetypes.md.
ReadabilityScore readabilityScore(Puzzle p) {
  final notes = <String>[];

  // clutter
  final clutter = p.pieces.length <= 20;
  if (!clutter) notes.add('clutter: ${p.pieces.length} pieces (> 20)');

  // visualBalance — bounding box not jammed into a knot
  var minF = 7, maxF = 0, minR = 7, maxR = 0;
  for (final pc in p.pieces) {
    if (pc.file < minF) minF = pc.file;
    if (pc.file > maxF) maxF = pc.file;
    if (pc.rank < minR) minR = pc.rank;
    if (pc.rank > maxR) maxR = pc.rank;
  }
  final width = maxF - minF, height = maxR - minR;
  final visualBalance = width >= 3 && height >= 3;
  if (!visualBalance) {
    notes.add('visualBalance: bounding box ${width}x$height (need >= 3x3)');
  }

  // moveDiscoverability
  final distinct = p.legalMoves.toSet().length == p.legalMoves.length;
  final moveDiscoverability =
      p.legalMoves.length >= 2 &&
      p.legalMoves.length <= 8 &&
      distinct &&
      p.legalMoves.contains(p.rescueTo);
  if (!moveDiscoverability) {
    notes.add(
      'moveDiscoverability: ${p.legalMoves.length} moves, '
      'distinct=$distinct, rescueInMoves=${p.legalMoves.contains(p.rescueTo)}',
    );
  }

  // threatVisibility — a dark attacker aligned-by-type with, or near, the king
  final king = p.threatenedKing;
  final darkAttackers = p.pieces.where(
    (pc) =>
        pc.color == PieceColor.dark &&
        (pc.type == PieceType.queen ||
            pc.type == PieceType.rook ||
            pc.type == PieceType.bishop ||
            pc.type == PieceType.knight),
  );
  final threatVisibility = darkAttackers.any(
    (pc) =>
        _aligned(pc, king.file, king.rank) ||
        _chebyshev(pc.file, pc.rank, king.file, king.rank) <= 2,
  );
  if (!threatVisibility) {
    notes.add('threatVisibility: no dark attacker aligned/near the king');
  }

  // rescueClarity — capture | interpose | counter-check
  final capturesAttacker = p.pieces.any(
    (pc) =>
        pc.color == PieceColor.dark &&
        pc.file == p.rescueTo.file &&
        pc.rank == p.rescueTo.rank,
  );
  final interposes = p.pieces.any(
    (pc) =>
        pc.color == PieceColor.dark &&
        (pc.type == PieceType.queen ||
            pc.type == PieceType.rook ||
            pc.type == PieceType.bishop) &&
        _between(Square(pc.file, pc.rank), p.rescueTo, king),
  );
  final darkKing = p.pieces.where(
    (pc) => pc.color == PieceColor.dark && pc.type == PieceType.king,
  );
  final counterChecks =
      darkKing.isNotEmpty &&
      (_knightRelation(
            p.rescueTo.file,
            p.rescueTo.rank,
            darkKing.first.file,
            darkKing.first.rank,
          ) ||
          _sameRankOrFile(
            p.rescueTo.file,
            p.rescueTo.rank,
            darkKing.first.file,
            darkKing.first.rank,
          ) ||
          _sameDiagonal(
            p.rescueTo.file,
            p.rescueTo.rank,
            darkKing.first.file,
            darkKing.first.rank,
          ));
  final rescueClarity = capturesAttacker || interposes || counterChecks;
  if (!rescueClarity) {
    notes.add('rescueClarity: rescue neither captures, interposes, nor checks');
  }

  // panicReadability — threat visible and the king not boxed in
  var occupiedNeighbors = 0;
  for (var df = -1; df <= 1; df++) {
    for (var dr = -1; dr <= 1; dr++) {
      if (df == 0 && dr == 0) continue;
      final nf = king.file + df, nr = king.rank + dr;
      if (p.pieces.any((pc) => pc.file == nf && pc.rank == nr)) {
        occupiedNeighbors++;
      }
    }
  }
  final panicReadability = threatVisibility && occupiedNeighbors <= 6;
  if (!panicReadability) {
    notes.add(
      'panicReadability: threat hidden or king boxed in '
      '($occupiedNeighbors neighbors)',
    );
  }

  // emotionalImmediacy — composite: low load + clear danger + clear rescue
  final emotionalImmediacy = clutter && threatVisibility && rescueClarity;
  if (!emotionalImmediacy && !notes.any((n) => n.startsWith('emotional'))) {
    notes.add('emotionalImmediacy: danger or rescue not immediately legible');
  }

  return ReadabilityScore(
    threatVisibility: threatVisibility,
    rescueClarity: rescueClarity,
    clutter: clutter,
    visualBalance: visualBalance,
    moveDiscoverability: moveDiscoverability,
    emotionalImmediacy: emotionalImmediacy,
    panicReadability: panicReadability,
    notes: notes,
  );
}
