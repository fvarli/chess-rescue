import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/session_composer.dart';
import 'package:chess_rescue/core/models/variation.dart';

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
  group('geometry-safe displayed copy', () {
    test('base puzzles carry no notation in displayed fields', () {
      for (final t in PuzzleLibrary.templates) {
        _expectSafeDisplayedCopy(t.puzzle);
      }
    });

    test('mirror variants carry no notation in displayed fields', () {
      for (final t in PuzzleLibrary.templates) {
        _expectSafeDisplayedCopy(t.toPuzzle(Variation.mirror));
      }
    });

    test(
      'composed sessions (seeds 1..8) carry no stale displayed notation',
      () {
        for (var s = 1; s <= 8; s++) {
          final session = SessionComposer.compose(
            templates: PuzzleLibrary.templates,
            seed: s,
          );
          for (final p in session) {
            _expectSafeDisplayedCopy(p);
          }
        }
      },
    );
  });

  group('rescueNotation is internal metadata only', () {
    test('base keeps exact notation', () {
      final p1 = PuzzleLibrary.templates.first.puzzle;
      expect(p1.rescueNotation, 'Nf6+');
    });

    test('mirror variants clear notation (no stale value)', () {
      for (final t in PuzzleLibrary.templates) {
        expect(t.toPuzzle(Variation.mirror).rescueNotation, '');
      }
    });
  });
}
