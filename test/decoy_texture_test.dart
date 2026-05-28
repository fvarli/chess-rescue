import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_template.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/core/models/variation.dart';

// Phase 23B — decoy texture (preview-only): vary the believable wrong moves
// around a fixed rescue, keeping the board geometry identical.

final _all = [...PuzzleLibrary.templates, ...PuzzleLibrary.expansionTemplates];

List<PuzzleTemplate> get _eligible =>
    _all.where((t) => t.decoyPool.isNotEmpty).toList();

PuzzleTemplate _t(String id) => _all.firstWhere((t) => t.puzzle.id == id);

void main() {
  const variations = [Variation.identity, Variation.mirror];

  group('decoy texture — gate, rescue, count (base + mirror)', () {
    test(
      'every textured instance is valid + readable; rescue + count held',
      () {
        for (final t in _eligible) {
          final authoredLen = t.puzzle.legalMoves.length;
          for (final v in variations) {
            final canonicalRescue = t.toPuzzle(v).rescueTo;
            for (var s = 0; s <= 8; s++) {
              final p = t.toTexturedPuzzle(variation: v, textureSeed: s);
              final tag = '${p.id} s=$s v=${v.id}';
              expect(validatePuzzle(p).isValid, isTrue, reason: tag);
              expect(
                readabilityScore(p).passed,
                isTrue,
                reason: '$tag: ${readabilityScore(p).notes}',
              );
              // rescue preserved (per variation)
              expect(p.rescueTo, canonicalRescue, reason: tag);
              expect(p.legalMoves.contains(p.rescueTo), isTrue, reason: tag);
              // count + distinctness held
              expect(p.legalMoves.length, authoredLen, reason: tag);
              expect(
                p.legalMoves.toSet().length,
                p.legalMoves.length,
                reason: tag,
              );
              expect(p.legalMoves.length, inInclusiveRange(2, 8), reason: tag);
            }
          }
        }
      },
    );
  });

  group('decoy texture — anchor + determinism', () {
    test('textureSeed 0 reproduces the canonical decoys (per variation)', () {
      for (final t in _eligible) {
        for (final v in variations) {
          expect(
            t.toTexturedPuzzle(variation: v, textureSeed: 0).legalMoves,
            t.toPuzzle(v).legalMoves,
            reason: '${t.puzzle.id} v=${v.id}',
          );
        }
      }
    });

    test('same (template, seed, variation) is deterministic', () {
      for (final t in _eligible) {
        for (final v in variations) {
          for (var s = 1; s <= 6; s++) {
            expect(
              t.toTexturedPuzzle(variation: v, textureSeed: s).legalMoves,
              t.toTexturedPuzzle(variation: v, textureSeed: s).legalMoves,
            );
          }
        }
      }
    });

    test('mirror ∘ decoy == decoy then mirror (orthogonal composition)', () {
      for (final t in _eligible) {
        for (var s = 1; s <= 6; s++) {
          final base = t.toTexturedPuzzle(textureSeed: s);
          final mirrored = t.toTexturedPuzzle(
            variation: Variation.mirror,
            textureSeed: s,
          );
          final expected = base.legalMoves
              .map((sq) => transformSquare(sq, Variation.mirror))
              .toSet();
          expect(
            mirrored.legalMoves.toSet(),
            expected,
            reason: '${t.puzzle.id} s=$s',
          );
        }
      }
    });
  });

  group('decoy honesty — dishonest squares never surface', () {
    test('A4 never offers e7, B3 never f3, B4 never g4', () {
      final cases = {
        'a4-the-breakaway': const Square(4, 6), // e7 (a real 2nd check)
        'b3-remove-the-defender': const Square(5, 2), // f3 (blocks the guard)
        'b4-the-cross-check': const Square(6, 3), // g4 (blocks the file)
      };
      cases.forEach((id, banned) {
        final t = _t(id);
        for (var s = 0; s <= 30; s++) {
          expect(
            t.toTexturedPuzzle(textureSeed: s).legalMoves.contains(banned),
            isFalse,
            reason: '$id offered ${banned.toString()} at s=$s',
          );
        }
      });
    });
  });

  group('decoy texture — scope guards', () {
    test('ineligible templates (no pool) are no-ops', () {
      for (final id in const ['p2-take-the-checker', 'p3-block-the-file']) {
        final t = _t(id);
        expect(t.decoyPool, isEmpty, reason: id);
        expect(
          t.toTexturedPuzzle(textureSeed: 7).legalMoves,
          t.puzzle.legalMoves,
          reason: id,
        );
      }
    });

    test('texture never alters displayed copy', () {
      for (final t in _eligible) {
        final base = t.puzzle;
        final p = t.toTexturedPuzzle(textureSeed: 3);
        expect(p.statusText, base.statusText);
        expect(p.dangerHint, base.dangerHint);
        expect(p.failureHint, base.failureHint);
        expect(p.successExplanation, base.successExplanation);
      }
    });
  });

  group('A4 decoy correctness fix', () {
    test('A4 offers e3 (not e7) and still rescues on f6', () {
      final a4 = _t('a4-the-breakaway').puzzle;
      expect(a4.legalMoves.contains(const Square(4, 2)), isTrue); // e3
      expect(a4.legalMoves.contains(const Square(4, 6)), isFalse); // e7
      expect(a4.rescueTo, const Square(5, 5)); // f6
    });
  });
}
