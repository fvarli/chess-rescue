import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/signature_entry.dart';

void main() {
  group('SignatureEntry', () {
    test('JSON round-trips for a canonical-only entry', () {
      final adoptedAt = DateTime.utc(2026, 6, 1, 14, 23, 11);
      final original = SignatureEntry(
        canonicalPuzzleId: 'p1-knight-rescue',
        encounteredPuzzleId: 'p1-knight-rescue',
        episodeId: 'ep1-strike-back',
        adoptedAt: adoptedAt,
      );

      final json = original.toJson();
      final decoded = SignatureEntry.fromJson(json);

      expect(decoded.canonicalPuzzleId, original.canonicalPuzzleId);
      expect(decoded.encounteredPuzzleId, original.encounteredPuzzleId);
      expect(decoded.episodeId, original.episodeId);
      expect(decoded.adoptedAt.toUtc(), original.adoptedAt.toUtc());
      expect(decoded.endlessSeed, isNull);
      expect(decoded.endlessMirrored, isNull);
    });

    test('JSON round-trips for an Endless-encountered entry', () {
      final original = SignatureEntry(
        canonicalPuzzleId: 'b1-the-martyr',
        encounteredPuzzleId: 'b1-the-martyr#mirror',
        episodeId: 'ep5-endless-rescue',
        adoptedAt: DateTime.utc(2026, 6, 1, 10, 0, 0),
        endlessSeed: 4842,
        endlessMirrored: true,
      );

      final decoded = SignatureEntry.fromJson(original.toJson());

      expect(decoded.canonicalPuzzleId, 'b1-the-martyr');
      expect(decoded.encounteredPuzzleId, 'b1-the-martyr#mirror');
      expect(decoded.episodeId, 'ep5-endless-rescue');
      expect(decoded.endlessSeed, 4842);
      expect(decoded.endlessMirrored, true);
    });

    test('equality is canonical-id-based — two entries with the same '
        'canonical id are equal regardless of other fields', () {
      final a = SignatureEntry(
        canonicalPuzzleId: 'p1-knight-rescue',
        encounteredPuzzleId: 'p1-knight-rescue',
        episodeId: 'ep1-strike-back',
        adoptedAt: DateTime.utc(2026, 6, 1),
      );
      final b = SignatureEntry(
        canonicalPuzzleId: 'p1-knight-rescue',
        encounteredPuzzleId: 'p1-knight-rescue#mirror',
        episodeId: 'ep4-the-other-side',
        adoptedAt: DateTime.utc(2026, 5, 1),
        endlessSeed: 100,
        endlessMirrored: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('entries with different canonical ids are not equal', () {
      final a = SignatureEntry(
        canonicalPuzzleId: 'p1-knight-rescue',
        encounteredPuzzleId: 'p1-knight-rescue',
        episodeId: 'ep1-strike-back',
        adoptedAt: DateTime.utc(2026, 6, 1),
      );
      final b = SignatureEntry(
        canonicalPuzzleId: 'p2-take-the-checker',
        encounteredPuzzleId: 'p2-take-the-checker',
        episodeId: 'ep1-strike-back',
        adoptedAt: DateTime.utc(2026, 6, 1),
      );
      expect(a, isNot(equals(b)));
    });

    test('DateTime serializes as ISO 8601 UTC and round-trips losslessly', () {
      final adoptedAt = DateTime.utc(2026, 6, 1, 14, 23, 11, 0, 0);
      final entry = SignatureEntry(
        canonicalPuzzleId: 'p3-block-the-file',
        encounteredPuzzleId: 'p3-block-the-file',
        episodeId: 'ep3-hold-the-line',
        adoptedAt: adoptedAt,
      );
      final json = entry.toJson();
      expect(json['adoptedAt'], '2026-06-01T14:23:11.000Z');
      final decoded = SignatureEntry.fromJson(json);
      expect(decoded.adoptedAt.toUtc(), adoptedAt);
    });
  });
}
