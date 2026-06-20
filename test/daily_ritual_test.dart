import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/home/daily_ritual.dart';

// PR-13 — pins the [solvedToday] proxy. The signal derives entirely
// from the existing RecentlySolved ring + isToday(); no new storage.

RecentlySolvedEntry _entry({
  required DateTime solvedAt,
  String canonicalId = 'p1-knight-rescue',
}) => RecentlySolvedEntry(
  canonicalPuzzleId: canonicalId,
  encounteredPuzzleId: canonicalId,
  episodeId: 'ep1-strike-back',
  solvedAt: solvedAt,
);

Future<ProgressStore> _freshStore() async {
  SharedPreferences.setMockInitialValues({});
  return ProgressStore.create();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('solvedToday — PR-13 derived daily-ritual signal', () {
    test('null store → false (degraded sessions stay quiet)', () {
      expect(solvedToday(null), isFalse);
    });

    test('empty ring → false', () async {
      final store = await _freshStore();
      expect(solvedToday(store), isFalse);
    });

    test('single entry whose solvedAt is today → true', () async {
      final store = await _freshStore();
      await store.recordRecentlySolved(
        _entry(solvedAt: DateTime.now().toUtc()),
      );
      expect(solvedToday(store), isTrue);
    });

    test('single entry whose solvedAt is last year → false', () async {
      final store = await _freshStore();
      await store.recordRecentlySolved(
        _entry(solvedAt: DateTime.utc(2025, 1, 1, 12, 0)),
      );
      expect(solvedToday(store), isFalse);
    });

    test('mixed ring (3 yesterday + 1 today) → true', () async {
      final store = await _freshStore();
      final now = DateTime.now().toUtc();
      final yesterday = now.subtract(const Duration(days: 1));
      // Each entry needs a distinct canonical id, otherwise the ring's
      // move-to-front dedupe collapses them.
      await store.recordRecentlySolved(
        _entry(solvedAt: yesterday, canonicalId: 'a'),
      );
      await store.recordRecentlySolved(
        _entry(solvedAt: yesterday, canonicalId: 'b'),
      );
      await store.recordRecentlySolved(
        _entry(solvedAt: yesterday, canonicalId: 'c'),
      );
      await store.recordRecentlySolved(_entry(solvedAt: now, canonicalId: 'd'));
      expect(solvedToday(store), isTrue);
    });

    test(
      'now: injection — a yesterday entry reads as today when the clock is also yesterday',
      () async {
        final store = await _freshStore();
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        await store.recordRecentlySolved(_entry(solvedAt: yesterday.toUtc()));
        // Production view (real clock): yesterday's rescue is NOT today.
        expect(solvedToday(store), isFalse);
        // Frozen-clock view (now = same yesterday): IS today.
        expect(solvedToday(store, now: yesterday), isTrue);
      },
    );
  });
}
