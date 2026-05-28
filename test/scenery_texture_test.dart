import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_template.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/core/models/variation.dart';

// Phase 23C — scenery texture (preview-only): cosmetic context-pawn changes that
// must never touch the rescue, the tension lane, or any functional square.

final _all = [...PuzzleLibrary.templates, ...PuzzleLibrary.expansionTemplates];

List<PuzzleTemplate> get _eligible =>
    _all.where((t) => t.removableScenery.isNotEmpty).toList();

PuzzleTemplate _t(String id) => _all.firstWhere((t) => t.puzzle.id == id);

// — Local geometry mirrors readability.dart's (private) helpers, so the test can
// independently verify scenery never lands on a slider→king/hero lane.
bool _aligned(Piece p, int tf, int tr) {
  final df = (p.file - tf).abs(), dr = (p.rank - tr).abs();
  switch (p.type) {
    case PieceType.queen:
      return p.file == tf || p.rank == tr || df == dr;
    case PieceType.rook:
      return p.file == tf || p.rank == tr;
    case PieceType.bishop:
      return df == dr;
    default:
      return false;
  }
}

bool _between(Square a, Square mid, Square b) {
  final dfAB = b.file - a.file, drAB = b.rank - a.rank;
  final dfAM = mid.file - a.file, drAM = mid.rank - a.rank;
  if (dfAB * drAM != drAB * dfAM) return false; // collinear
  final stepF = dfAB.sign, stepR = drAB.sign;
  final maxSteps = dfAB.abs() > drAB.abs() ? dfAB.abs() : drAB.abs();
  for (var i = 1; i < maxSteps; i++) {
    if (a.file + stepF * i == mid.file && a.rank + stepR * i == mid.rank) {
      return true;
    }
  }
  return false;
}

bool _onLane(Puzzle p, Square sq) {
  for (final s in p.pieces) {
    if (s.color != PieceColor.dark) continue;
    if (s.type != PieceType.queen &&
        s.type != PieceType.rook &&
        s.type != PieceType.bishop) {
      continue;
    }
    for (final tgt in [p.threatenedKing, p.tappableSquare]) {
      if (_aligned(s, tgt.file, tgt.rank) &&
          _between(Square(s.file, s.rank), sq, tgt)) {
        return true;
      }
    }
  }
  return false;
}

Set<(int, int)> _squares(Puzzle p) => {
  for (final pc in p.pieces) (pc.file, pc.rank),
};

Set<(int, int)> _occupiedMoves(Puzzle p) => {
  for (final m in p.legalMoves)
    if (p.pieces.any((pc) => pc.file == m.file && pc.rank == m.rank))
      (m.file, m.rank),
};

void main() {
  const variations = [Variation.identity, Variation.mirror];

  group('scenery — anchor, determinism, gate (base + mirror)', () {
    test('scenerySeed 0 reproduces the canonical board', () {
      for (final t in _eligible) {
        for (final v in variations) {
          expect(
            t.toTexturedPuzzle(variation: v, scenerySeed: 0).pieces,
            t.toPuzzle(v).pieces,
            reason: '${t.puzzle.id} v=${v.id}',
          );
        }
      }
    });

    test('deterministic + valid + readable; ≤ 20 pieces', () {
      for (final t in _eligible) {
        for (final v in variations) {
          for (var s = 1; s <= 8; s++) {
            final p = t.toTexturedPuzzle(variation: v, scenerySeed: s);
            final tag = '${t.puzzle.id} s=$s v=${v.id}';
            expect(
              p.pieces,
              t.toTexturedPuzzle(variation: v, scenerySeed: s).pieces,
              reason: tag,
            );
            expect(validatePuzzle(p).isValid, isTrue, reason: tag);
            expect(
              readabilityScore(p).passed,
              isTrue,
              reason: '$tag: ${readabilityScore(p).notes}',
            );
            expect(p.pieces.length, lessThanOrEqualTo(20), reason: tag);
          }
        }
      }
    });
  });

  group('scenery — rescue / moves / copy untouched', () {
    test('rescue, legalMoves, and displayed copy are unchanged', () {
      for (final t in _eligible) {
        for (final v in variations) {
          final canonical = t.toPuzzle(v);
          for (var s = 1; s <= 8; s++) {
            final p = t.toTexturedPuzzle(variation: v, scenerySeed: s);
            final tag = '${t.puzzle.id} s=$s v=${v.id}';
            expect(p.rescueTo, canonical.rescueTo, reason: tag);
            expect(p.legalMoves, canonical.legalMoves, reason: tag);
            expect(p.statusText, canonical.statusText, reason: tag);
            expect(p.dangerHint, canonical.dangerHint, reason: tag);
            expect(p.failureHint, canonical.failureHint, reason: tag);
            expect(
              p.successExplanation,
              canonical.successExplanation,
              reason: tag,
            );
            // No scenery occupies a legal-move square (capture targets aside).
            expect(_occupiedMoves(p), _occupiedMoves(canonical), reason: tag);
          }
        }
      }
    });
  });

  group('scenery — added pawns are safe', () {
    test(
      'added squares: pawn, plausible rank, off functional squares + lanes',
      () {
        for (final t in _eligible) {
          final base = t.puzzle;
          final baseSq = _squares(base);
          for (var s = 1; s <= 12; s++) {
            final scenic = t.toTexturedPuzzle(scenerySeed: s); // base coords
            for (final (f, r) in _squares(scenic).difference(baseSq)) {
              final sq = Square(f, r);
              final tag = '${t.puzzle.id} s=$s added ${sq.toString()}';
              final piece = scenic.pieces.firstWhere(
                (pc) => pc.file == f && pc.rank == r,
              );
              expect(piece.type, PieceType.pawn, reason: tag);
              expect(
                r >= 1 && r <= 6,
                isTrue,
                reason: '$tag rank',
              ); // ranks 2–7
              expect(
                base.legalMoves.contains(sq),
                isFalse,
                reason: '$tag move',
              );
              expect(t.decoyPool.contains(sq), isFalse, reason: '$tag decoy');
              expect(
                sq == base.tappableSquare,
                isFalse,
                reason: '$tag tappable',
              );
              expect(sq == base.rescueTo, isFalse, reason: '$tag rescue');
              expect(sq == base.threatenedKing, isFalse, reason: '$tag king');
              expect(_onLane(base, sq), isFalse, reason: '$tag lane');
            }
          }
        }
      },
    );
  });

  group('scenery — composition + scope', () {
    test('scenery + decoy + mirror compose cleanly', () {
      for (final t in _eligible) {
        final combo = t.toTexturedPuzzle(
          variation: Variation.mirror,
          textureSeed: 1,
          scenerySeed: 1,
        );
        expect(validatePuzzle(combo).isValid, isTrue, reason: t.puzzle.id);
        expect(readabilityScore(combo).passed, isTrue, reason: t.puzzle.id);
        expect(combo.rescueTo, t.toPuzzle(Variation.mirror).rescueTo);
      }
    });

    test('P1 (dense cold-open) has no scenery and is a no-op', () {
      final p1 = _t('p1-knight-rescue');
      expect(p1.removableScenery, isEmpty);
      expect(p1.sceneryPool, isEmpty);
      expect(p1.toTexturedPuzzle(scenerySeed: 9).pieces, p1.puzzle.pieces);
    });
  });
}
