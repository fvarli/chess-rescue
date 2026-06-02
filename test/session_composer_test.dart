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
  return [
    ...PuzzleLibrary.templates,
    ...PuzzleLibrary.expansionTemplates,
  ].firstWhere((t) => t.puzzle.id == baseId).archetype;
}

final _canonicalIds = {for (final t in PuzzleLibrary.templates) t.puzzle.id};

bool _isExpansion(Puzzle p) => !_canonicalIds.contains(p.id.split('#').first);

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

  group('SessionComposer with expansion pool (Phase 22C)', () {
    List<Puzzle> compose(int seed) => SessionComposer.compose(
      templates: PuzzleLibrary.templates,
      expansion: PuzzleLibrary.expansionTemplates,
      seed: seed,
    );

    test('deterministic: same seed -> same session ids', () {
      expect(_ids(compose(11)), _ids(compose(11)));
      expect(_ids(compose(99)), _ids(compose(99)));
    });

    test('every session is length 5, valid, readable', () {
      for (var s = 1; s <= 16; s++) {
        final session = compose(s);
        expect(session.length, 5, reason: 'seed $s');
        for (final p in session) {
          expect(validatePuzzle(p).isValid, isTrue, reason: p.id);
          expect(readabilityScore(p).passed, isTrue, reason: p.id);
        }
      }
    });

    test('no same archetype back-to-back', () {
      for (var s = 1; s <= 16; s++) {
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

    test('no duplicate ids within a session', () {
      for (var s = 1; s <= 16; s++) {
        final ids = _ids(compose(s));
        expect(ids.toSet().length, ids.length, reason: 'seed $s: $ids');
      }
    });

    test('base/mirror mix — not all-base and not all-mirror', () {
      for (var s = 1; s <= 16; s++) {
        final ids = _ids(compose(s));
        final mirrors = ids.where((id) => id.contains('#mirror')).length;
        expect(mirrors, greaterThanOrEqualTo(1), reason: 'seed $s: $ids');
        expect(mirrors, lessThan(ids.length), reason: 'seed $s: $ids');
      }
    });

    test('canonical-anchored: finale canonical, ≤2 expansion middles', () {
      // Sprint V1 §6.1 opener relief: the opener slot may be expansion in
      // seed-gated relief sessions (~25%). Finale stays canonical; the
      // canonical-anchored cap still bounds expansion in middle slots 1–3
      // at ≤2.
      for (var s = 1; s <= 16; s++) {
        final session = compose(s);
        expect(_isExpansion(session.last), isFalse, reason: 'seed $s finale');
        final middleExpansion = session
            .sublist(1, 4)
            .where(_isExpansion)
            .length;
        expect(
          middleExpansion,
          lessThanOrEqualTo(2),
          reason: 'seed $s middle: ${_ids(session)}',
        );
      }
    });

    test('all four expansion families surface across seeds', () {
      final seen = <String>{};
      for (var s = 1; s <= 64; s++) {
        for (final p in compose(s)) {
          seen.add(p.id.split('#').first);
        }
      }
      for (final id in const [
        'a4-the-breakaway',
        'b1-the-martyr',
        'b3-remove-the-defender',
        'b4-the-cross-check',
      ]) {
        expect(
          seen.contains(id),
          isTrue,
          reason: '$id never surfaced (seeds 1..64)',
        );
      }
    });

    test('seed 0 stays the canonical onboarding session (lock)', () {
      expect(_ids(PuzzleLibrary.session(0)), const [
        'p1-knight-rescue',
        'p2-take-the-checker',
        'p3-block-the-file',
        'p4-seal-the-diagonal',
        'p5-win-the-queen',
      ]);
    });
  });
}
