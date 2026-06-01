import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';

void main() {
  group('RecentlySolvedEntry', () {
    test('JSON round-trips for a canonical-only entry', () {
      final solvedAt = DateTime.utc(2026, 6, 1, 9, 0, 0);
      final original = RecentlySolvedEntry(
        canonicalPuzzleId: 'p2-take-the-checker',
        encounteredPuzzleId: 'p2-take-the-checker',
        episodeId: 'ep1-strike-back',
        solvedAt: solvedAt,
      );
      final decoded = RecentlySolvedEntry.fromJson(original.toJson());

      expect(decoded.canonicalPuzzleId, original.canonicalPuzzleId);
      expect(decoded.encounteredPuzzleId, original.encounteredPuzzleId);
      expect(decoded.episodeId, original.episodeId);
      expect(decoded.solvedAt.toUtc(), original.solvedAt.toUtc());
      expect(decoded.endlessSeed, isNull);
      expect(decoded.endlessMirrored, isNull);
    });

    test('JSON round-trips for an Endless-encountered entry', () {
      final original = RecentlySolvedEntry(
        canonicalPuzzleId: 'b3-remove-the-defender',
        encounteredPuzzleId: 'b3-remove-the-defender#mirror',
        episodeId: 'ep5-endless-rescue',
        solvedAt: DateTime.utc(2026, 6, 1, 10, 0, 0),
        endlessSeed: 99,
        endlessMirrored: true,
      );
      final decoded = RecentlySolvedEntry.fromJson(original.toJson());

      expect(decoded.canonicalPuzzleId, 'b3-remove-the-defender');
      expect(decoded.encounteredPuzzleId, 'b3-remove-the-defender#mirror');
      expect(decoded.endlessSeed, 99);
      expect(decoded.endlessMirrored, true);
    });

    test('equality is canonical-id-based — same id, different other fields, '
        'still equal', () {
      final a = RecentlySolvedEntry(
        canonicalPuzzleId: 'p4-seal-the-diagonal',
        encounteredPuzzleId: 'p4-seal-the-diagonal',
        episodeId: 'ep2-end-the-threat',
        solvedAt: DateTime.utc(2026, 6, 1),
      );
      final b = RecentlySolvedEntry(
        canonicalPuzzleId: 'p4-seal-the-diagonal',
        encounteredPuzzleId: 'p4-seal-the-diagonal#mirror',
        episodeId: 'ep5-endless-rescue',
        solvedAt: DateTime.utc(2026, 5, 1),
        endlessSeed: 42,
        endlessMirrored: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different canonical ids are not equal', () {
      final a = RecentlySolvedEntry(
        canonicalPuzzleId: 'p4-seal-the-diagonal',
        encounteredPuzzleId: 'p4-seal-the-diagonal',
        episodeId: 'ep2-end-the-threat',
        solvedAt: DateTime.utc(2026, 6, 1),
      );
      final b = RecentlySolvedEntry(
        canonicalPuzzleId: 'p5-win-the-queen',
        encounteredPuzzleId: 'p5-win-the-queen',
        episodeId: 'ep2-end-the-threat',
        solvedAt: DateTime.utc(2026, 6, 1),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
