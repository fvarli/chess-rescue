import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/variation.dart';

/// Regression guard for `canonicalPuzzleId` (lib/core/models/variation.dart),
/// which becomes load-bearing for the Signature Rescues PR 1 storage layer:
/// every `SignatureEntry` / `RecentlySolvedEntry` derives its canonical id
/// from this function, and the canonical-dedupe rule depends on its
/// behaviour for mirror and edge-case ids.
void main() {
  group('canonicalPuzzleId', () {
    const canonicals = <String>[
      'p1-knight-rescue',
      'p2-take-the-checker',
      'p3-block-the-file',
      'p4-seal-the-diagonal',
      'p5-win-the-queen',
      'a4-the-breakaway',
      'b1-the-martyr',
      'b3-remove-the-defender',
      'b4-the-cross-check',
      'cc2-bishop-captures-shield',
      'cam1-knight-takes-bishop',
    ];

    test('each canonical id maps to itself', () {
      for (final id in canonicals) {
        expect(canonicalPuzzleId(id), id, reason: 'canonical $id');
      }
    });

    test('each "#mirror" variant maps to its canonical base', () {
      for (final id in canonicals) {
        expect(canonicalPuzzleId('$id#mirror'), id, reason: 'mirror of $id');
      }
    });

    test('an id with no `#` suffix returns itself unchanged', () {
      expect(canonicalPuzzleId('unknown-id'), 'unknown-id');
      expect(canonicalPuzzleId('foo-bar-baz'), 'foo-bar-baz');
    });

    test('a double-suffix id captures up to the FIRST `#` (defensive)', () {
      // split('#').first → 'foo' (split with no limit splits all, but
      // .first is the first element).
      expect(canonicalPuzzleId('foo#mirror#bar'), 'foo');
      expect(canonicalPuzzleId('p1-knight-rescue#a#b#c'), 'p1-knight-rescue');
    });

    test('empty input returns empty string', () {
      expect(canonicalPuzzleId(''), '');
    });
  });
}
