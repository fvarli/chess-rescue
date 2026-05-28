import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/rescue_archetype.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/session_composer.dart';

List<String> _ids(List<Puzzle> s) => [for (final p in s) p.id];

RescueArchetype _archetypeOf(Puzzle p) {
  final baseId = p.id.split('#').first;
  return PuzzleLibrary.templates
      .firstWhere((t) => t.puzzle.id == baseId)
      .archetype;
}

void main() {
  group('SessionComposer', () {
    List<Puzzle> compose(int seed) =>
        SessionComposer.compose(templates: PuzzleLibrary.templates, seed: seed);

    test('deterministic: same seed -> same session ids', () {
      expect(_ids(compose(7)), _ids(compose(7)));
      expect(_ids(compose(42)), _ids(compose(42)));
    });

    test('seed varies output: >=2 distinct sessions across seeds 1..8', () {
      final distinct = {
        for (var s = 1; s <= 8; s++) _ids(compose(s)).join(','),
      };
      expect(distinct.length, greaterThanOrEqualTo(2));
    });

    test('session length is 5', () {
      for (var s = 1; s <= 8; s++) {
        expect(compose(s).length, SessionComposer.sessionLength);
      }
    });

    test('no duplicate ids within a session', () {
      for (var s = 1; s <= 8; s++) {
        final ids = _ids(compose(s));
        expect(ids.toSet().length, ids.length, reason: 'seed $s: $ids');
      }
    });

    test('every instance passes validation + readability', () {
      for (var s = 1; s <= 8; s++) {
        for (final p in compose(s)) {
          expect(validatePuzzle(p).isValid, isTrue, reason: p.id);
          expect(readabilityScore(p).passed, isTrue, reason: p.id);
        }
      }
    });

    test('no same archetype back-to-back', () {
      for (var s = 1; s <= 8; s++) {
        final session = compose(s);
        for (var i = 1; i < session.length; i++) {
          expect(
            _archetypeOf(session[i]) == _archetypeOf(session[i - 1]),
            isFalse,
            reason: 'seed $s: ${_ids(session)}',
          );
        }
      }
    });

    test('base/mirror mix — not all-base and not all-mirror', () {
      for (var s = 1; s <= 8; s++) {
        final ids = _ids(compose(s));
        final mirrors = ids.where((id) => id.contains('#mirror')).length;
        expect(
          mirrors,
          greaterThanOrEqualTo(1),
          reason: 'seed $s all-base: $ids',
        );
        expect(
          mirrors,
          lessThan(ids.length),
          reason: 'seed $s all-mirror: $ids',
        );
      }
    });

    test(
      'runtime compatibility: PuzzleLibrary.all is the original 5 base ids',
      () {
        expect(_ids(PuzzleLibrary.all), [
          'p1-knight-rescue',
          'p2-take-the-checker',
          'p3-block-the-file',
          'p4-seal-the-diagonal',
          'p5-win-the-queen',
        ]);
      },
    );
  });
}
