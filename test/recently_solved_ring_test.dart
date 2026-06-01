import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';
import 'package:chess_rescue/core/models/recently_solved_ring.dart';

RecentlySolvedEntry _entry(String id, {int minutesAgo = 0}) =>
    RecentlySolvedEntry(
      canonicalPuzzleId: id,
      encounteredPuzzleId: id,
      episodeId: 'ep1-strike-back',
      solvedAt: DateTime.utc(
        2026,
        6,
        1,
      ).subtract(Duration(minutes: minutesAgo)),
    );

void main() {
  group('RecentlySolvedRing', () {
    test('empty ring has no entries', () {
      final ring = RecentlySolvedRing.empty();
      expect(ring.entries, isEmpty);
    });

    test('insert into an empty ring places the entry at index 0', () {
      final ring = RecentlySolvedRing.empty().insert(
        _entry('p1-knight-rescue'),
      );
      expect(ring.entries.length, 1);
      expect(ring.entries.first.canonicalPuzzleId, 'p1-knight-rescue');
    });

    test('insert preserves recency ordering — newest first', () {
      var ring = RecentlySolvedRing.empty();
      ring = ring.insert(_entry('a', minutesAgo: 30));
      ring = ring.insert(_entry('b', minutesAgo: 20));
      ring = ring.insert(_entry('c', minutesAgo: 10));
      expect(ring.entries.map((e) => e.canonicalPuzzleId).toList(), [
        'c',
        'b',
        'a',
      ]);
    });

    test('insert beyond capacity drops the oldest entry', () {
      var ring = RecentlySolvedRing.empty();
      for (var i = 0; i < RecentlySolvedRing.capacity; i++) {
        ring = ring.insert(_entry('id-$i', minutesAgo: 100 - i));
      }
      expect(ring.entries.length, RecentlySolvedRing.capacity);

      // Insert one more — oldest (id-0) should drop.
      ring = ring.insert(_entry('id-new'));
      expect(ring.entries.length, RecentlySolvedRing.capacity);
      expect(ring.entries.first.canonicalPuzzleId, 'id-new');
      expect(
        ring.entries.map((e) => e.canonicalPuzzleId).contains('id-0'),
        isFalse,
      );
    });

    test(
      're-inserting an existing canonical id is move-to-front, no duplicate',
      () {
        var ring = RecentlySolvedRing.empty();
        ring = ring.insert(_entry('a'));
        ring = ring.insert(_entry('b'));
        ring = ring.insert(_entry('c'));
        ring = ring.insert(_entry('a')); // re-insert
        expect(ring.entries.map((e) => e.canonicalPuzzleId).toList(), [
          'a',
          'c',
          'b',
        ]);
        expect(ring.entries.length, 3);
      },
    );

    test('visibleExcluding filters by canonical id, preserves order', () {
      var ring = RecentlySolvedRing.empty();
      ring = ring.insert(_entry('a'));
      ring = ring.insert(_entry('b'));
      ring = ring.insert(_entry('c'));

      final visible = ring.visibleExcluding({'b'});
      expect(visible.map((e) => e.canonicalPuzzleId).toList(), ['c', 'a']);
    });

    test('visibleExcluding with empty set returns all entries', () {
      var ring = RecentlySolvedRing.empty();
      ring = ring.insert(_entry('a'));
      ring = ring.insert(_entry('b'));
      expect(
        ring.visibleExcluding(const <String>{}).map((e) => e.canonicalPuzzleId),
        ['b', 'a'],
      );
    });

    test('JSON round-trip preserves order and entry data', () {
      var ring = RecentlySolvedRing.empty();
      ring = ring.insert(_entry('a'));
      ring = ring.insert(_entry('b'));
      ring = ring.insert(_entry('c'));

      final decoded = RecentlySolvedRing.fromJson(ring.toJson());
      expect(decoded.entries.map((e) => e.canonicalPuzzleId).toList(), [
        'c',
        'b',
        'a',
      ]);
    });

    test('fromJson on missing/malformed entries falls back to empty', () {
      final emptyish = RecentlySolvedRing.fromJson(const <String, dynamic>{});
      expect(emptyish.entries, isEmpty);
    });
  });
}
