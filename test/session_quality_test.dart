import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/rescue_archetype.dart';
import 'package:chess_rescue/core/models/variation.dart';

// Phase 24 — replayability QA: objective session-quality invariants locked over
// seeds 1–50. (Audit verdict: no behavior tuning needed; these tests guard the
// "fresh but authored" guarantees the composer already provides.)

final _templates = [
  ...PuzzleLibrary.templates,
  ...PuzzleLibrary.expansionTemplates,
];
final _canonicalIds = {for (final t in PuzzleLibrary.templates) t.puzzle.id};

Set<(int, int)> _sqs(Puzzle p) => {for (final x in p.pieces) (x.file, x.rank)};

bool _setEq<T>(Iterable<T> a, Iterable<T> b) {
  final sa = a.toSet(), sb = b.toSet();
  return sa.length == sb.length && sa.containsAll(sb);
}

RescueArchetype _archetype(Puzzle p) => _templates
    .firstWhere((t) => t.puzzle.id == canonicalPuzzleId(p.id))
    .archetype;

bool _isExpansion(Puzzle p) => !_canonicalIds.contains(canonicalPuzzleId(p.id));

bool _isTextured(Puzzle p) {
  final t = _templates.firstWhere(
    (t) => t.puzzle.id == canonicalPuzzleId(p.id),
  );
  final c = t.toPuzzle(
    p.id.contains('#mirror') ? Variation.mirror : Variation.identity,
  );
  return !_setEq(p.legalMoves, c.legalMoves) || !_setEq(_sqs(p), _sqs(c));
}

void main() {
  group('session quality invariants (seeds 1–50)', () {
    test('mirror balance: every session has 1–4 mirrors (never all/none)', () {
      for (var s = 1; s <= 50; s++) {
        final mirrors = PuzzleLibrary.session(
          s,
        ).where((p) => p.id.contains('#mirror')).length;
        expect(mirrors, inInclusiveRange(1, 4), reason: 'seed $s');
      }
    });

    test('canonical-anchored: finale canonical, ≤2 expansion middles, '
        'opener mostly canonical', () {
      // Sprint V1 §6.1 opener relief: opener is canonical-dominant
      // (~75% of seeds) with seed-gated expansion in the remainder.
      // Finale stays canonical-locked. Middle slots 1–3 still bounded
      // by the canonical-anchored cap at ≤2 expansion.
      var openerExpansionCount = 0;
      for (var s = 1; s <= 50; s++) {
        final session = PuzzleLibrary.session(s);
        final middleExpansion = session
            .sublist(1, 4)
            .where(_isExpansion)
            .length;
        expect(middleExpansion, lessThanOrEqualTo(2), reason: 'seed $s');
        expect(_isExpansion(session.last), isFalse, reason: 'seed $s finale');
        if (_isExpansion(session.first)) openerExpansionCount++;
      }
      // Opener canonical in ≥60% of seeds (soft bound — preserves
      // "opener is a soft landing" framing while admitting §6.1 relief).
      expect(
        50 - openerExpansionCount,
        greaterThanOrEqualTo(30),
        reason:
            'opener should remain canonical-dominant '
            '(saw ${50 - openerExpansionCount}/50 canonical openers)',
      );
    });

    test('texture: ≤2 textured boards, only in slots 1–3 (clean bookends)', () {
      for (var s = 1; s <= 50; s++) {
        final session = PuzzleLibrary.session(s);
        final textured = [
          for (var i = 0; i < session.length; i++)
            if (_isTextured(session[i])) i,
        ];
        expect(
          textured.length,
          lessThanOrEqualTo(2),
          reason: 'seed $s $textured',
        );
        for (final i in textured) {
          expect(i >= 1 && i <= 3, isTrue, reason: 'seed $s slot $i');
        }
      }
    });

    test('opener + finale are consistent, untextured bookends', () {
      for (var s = 1; s <= 50; s++) {
        final session = PuzzleLibrary.session(s);
        expect(
          _archetype(session.first),
          RescueArchetype.captureAttackerMinor,
          reason: 'seed $s opener',
        );
        expect(
          [RescueArchetype.blockFile, RescueArchetype.sealDiagonal],
          contains(_archetype(session.last)),
          reason: 'seed $s finale',
        );
        expect(_isTextured(session.first), isFalse, reason: 'seed $s opener');
        expect(_isTextured(session.last), isFalse, reason: 'seed $s finale');
      }
    });

    test('exactly 5 distinct archetypes per session', () {
      for (var s = 1; s <= 50; s++) {
        final session = PuzzleLibrary.session(s);
        expect(session.map(_archetype).toSet().length, 5, reason: 'seed $s');
      }
    });

    test('seed 0 stays the canonical onboarding session (lock)', () {
      expect(PuzzleLibrary.session(0).map((p) => p.id).toList(), const [
        'p1-knight-rescue',
        'p2-take-the-checker',
        'p3-block-the-file',
        'p4-seal-the-diagonal',
        'p5-win-the-queen',
      ]);
    });
  });
}
