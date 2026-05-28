import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/variation.dart';

// Phase 23D — decoy + scenery texture wired into live composed sessions
// (seed >= 1). Seed 0 stays the canonical onboarding; texture is light, lands
// only on the middle slots, and never breaks rescue / readability / copy.

final _templates = [
  ...PuzzleLibrary.templates,
  ...PuzzleLibrary.expansionTemplates,
];

final _notation = RegExp(r'[a-hA-H][1-8]');

Set<(int, int)> _sqs(Puzzle p) => {for (final x in p.pieces) (x.file, x.rank)};

bool _setEq<T>(Iterable<T> a, Iterable<T> b) {
  final sa = a.toSet(), sb = b.toSet();
  return sa.length == sb.length && sa.containsAll(sb);
}

Puzzle _canonicalFor(Puzzle p) {
  final t = _templates.firstWhere(
    (t) => t.puzzle.id == canonicalPuzzleId(p.id),
  );
  final mirror = p.id.contains('#mirror');
  return t.toPuzzle(mirror ? Variation.mirror : Variation.identity);
}

// Textured = decoys (legalMoves) or scenery (piece squares) differ from the
// canonical instance of the same family + orientation.
bool _isTextured(Puzzle p) {
  final c = _canonicalFor(p);
  return !_setEq(p.legalMoves, c.legalMoves) || !_setEq(_sqs(p), _sqs(c));
}

Set<(int, int)> _occupiedMoves(Puzzle p) => {
  for (final m in p.legalMoves)
    if (p.pieces.any((pc) => pc.file == m.file && pc.rank == m.rank))
      (m.file, m.rank),
};

String _sig(List<Puzzle> s) => [
  for (final p in s)
    '${p.id}:'
        '${p.legalMoves.map((m) => '${m.file}${m.rank}').join('.')}:'
        '${p.pieces.map((x) => '${x.id}${x.file}${x.rank}').join('.')}',
].join('/');

void main() {
  group('runtime texture (Phase 23D)', () {
    test('seed 0 is the canonical 5, untextured', () {
      final s = PuzzleLibrary.session(0);
      expect(s.map((p) => p.id).toList(), const [
        'p1-knight-rescue',
        'p2-take-the-checker',
        'p3-block-the-file',
        'p4-seal-the-diagonal',
        'p5-win-the-queen',
      ]);
      for (final p in s) {
        expect(_isTextured(p), isFalse, reason: p.id);
      }
    });

    test('deterministic per seed (ids + legalMoves + piece squares)', () {
      for (var s = 1; s <= 6; s++) {
        final a = PuzzleLibrary.session(s);
        final b = PuzzleLibrary.session(s);
        expect(_sig(a), _sig(b), reason: 'seed $s');
      }
    });

    test('every runtime puzzle: length 5, valid, readable, copy-safe', () {
      for (var s = 1; s <= 24; s++) {
        final session = PuzzleLibrary.session(s);
        expect(session.length, 5, reason: 'seed $s');
        for (final p in session) {
          final tag = '${p.id} seed=$s';
          expect(validatePuzzle(p).isValid, isTrue, reason: tag);
          expect(
            readabilityScore(p).passed,
            isTrue,
            reason: '$tag: ${readabilityScore(p).notes}',
          );
          for (final f in [
            p.statusText,
            p.successExplanation,
            p.dangerHint,
            p.failureHint,
          ]) {
            expect(
              _notation.hasMatch(f) || f.contains('#'),
              isFalse,
              reason: '$tag stale copy → "$f"',
            );
          }
        }
      }
    });

    test('clean bookends; at most 2 textured, only in slots 1–3', () {
      for (var s = 1; s <= 24; s++) {
        final session = PuzzleLibrary.session(s);
        expect(_isTextured(session.first), isFalse, reason: 'opener seed=$s');
        expect(_isTextured(session.last), isFalse, reason: 'finale seed=$s');
        final textured = [
          for (var i = 0; i < session.length; i++)
            if (_isTextured(session[i])) i,
        ];
        expect(
          textured.length,
          lessThanOrEqualTo(2),
          reason: 'seed=$s $textured',
        );
        for (final i in textured) {
          expect(i >= 1 && i <= 3, isTrue, reason: 'seed=$s slot=$i');
        }
      }
    });

    test(
      'rescue + copy preserved; no scenery on legal-move squares; no dups',
      () {
        for (var s = 1; s <= 24; s++) {
          for (final p in PuzzleLibrary.session(s)) {
            final c = _canonicalFor(p);
            final tag = '${p.id} seed=$s';
            expect(p.rescueTo, c.rescueTo, reason: tag);
            expect(p.legalMoves.contains(p.rescueTo), isTrue, reason: tag);
            expect(p.statusText, c.statusText, reason: tag);
            expect(p.dangerHint, c.dangerHint, reason: tag);
            expect(p.failureHint, c.failureHint, reason: tag);
            expect(p.successExplanation, c.successExplanation, reason: tag);
            expect(
              _setEq(_occupiedMoves(p), _occupiedMoves(c)),
              isTrue,
              reason: tag,
            );
            expect(
              _sqs(p).length,
              p.pieces.length,
              reason: '$tag duplicate square',
            );
          }
        }
      },
    );

    test('canonical ids resolve to known families', () {
      for (var s = 1; s <= 12; s++) {
        for (final p in PuzzleLibrary.session(s)) {
          final fam = canonicalPuzzleId(p.id);
          expect(
            _templates.any((t) => t.puzzle.id == fam),
            isTrue,
            reason: fam,
          );
        }
      }
    });

    test('different seeds produce meaningfully different sessions', () {
      final sigs = {
        for (var s = 1; s <= 12; s++) _sig(PuzzleLibrary.session(s)),
      };
      expect(sigs.length, greaterThanOrEqualTo(6));
    });
  });
}
