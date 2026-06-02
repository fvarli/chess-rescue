import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/variation.dart';

// Phase 22B — the Tier-1 expansion families live in `expansionTemplates`, NOT
// in the live runtime. They must clear the same gate the shipped 5 face:
// structural validity, readability, and geometry-safe copy — base AND mirror.

// A file-letter adjacent to a rank digit (Qg2, f3, F6, e1) — chess notation.
final _notation = RegExp(r'[a-hA-H][1-8]');

bool _hasNotation(String s) => _notation.hasMatch(s) || s.contains('#');

void _expectSafeDisplayedCopy(Puzzle p) {
  for (final field in [
    p.statusText,
    p.successExplanation,
    p.dangerHint,
    p.failureHint,
  ]) {
    expect(
      _hasNotation(field),
      isFalse,
      reason: '${p.id}: stale notation in displayed copy → "$field"',
    );
  }
}

void main() {
  final pool = PuzzleLibrary.expansionTemplates;

  group('expansion pool shape', () {
    test('contains the Tier-1 families and Sprint V1 additions', () {
      expect(pool.length, 6);
      expect(pool.map((t) => t.puzzle.id).toList(), [
        'a4-the-breakaway',
        'b1-the-martyr',
        'b3-remove-the-defender',
        'b4-the-cross-check',
        'cc2-bishop-captures-shield',
        'cam1-knight-takes-bishop',
      ]);
    });

    test('is not wired into the live runtime', () {
      // Onboarding/session invariants are untouched by the expansion pool.
      expect(PuzzleLibrary.all.length, 5);
      expect(PuzzleLibrary.session(0).length, 5);
      for (final t in pool) {
        expect(
          PuzzleLibrary.templates.contains(t),
          isFalse,
          reason: t.puzzle.id,
        );
      }
    });

    test('every rescue is among its whitelisted moves', () {
      for (final t in pool) {
        expect(
          t.puzzle.legalMoves.contains(t.puzzle.rescueTo),
          isTrue,
          reason: t.puzzle.id,
        );
      }
    });
  });

  group('expansion families pass the gate (base + mirror)', () {
    test('structurally valid', () {
      for (final t in pool) {
        final base = validatePuzzle(t.puzzle);
        expect(base.isValid, isTrue, reason: '${t.puzzle.id}: ${base.errors}');
        final mirror = t.toPuzzle(Variation.mirror);
        final m = validatePuzzle(mirror);
        expect(m.isValid, isTrue, reason: '${mirror.id}: ${m.errors}');
      }
    });

    test('emotionally readable', () {
      for (final t in pool) {
        final base = readabilityScore(t.puzzle);
        expect(base.passed, isTrue, reason: '${t.puzzle.id}: ${base.notes}');
        final mirror = t.toPuzzle(Variation.mirror);
        final m = readabilityScore(mirror);
        expect(m.passed, isTrue, reason: '${mirror.id}: ${m.notes}');
      }
    });

    test('displayed copy is geometry-safe', () {
      for (final t in pool) {
        _expectSafeDisplayedCopy(t.puzzle);
        _expectSafeDisplayedCopy(t.toPuzzle(Variation.mirror));
      }
    });
  });
}
