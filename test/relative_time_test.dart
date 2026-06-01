import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/util/relative_time.dart';

void main() {
  group('isToday', () {
    test('returns true for the same calendar day', () {
      final now = DateTime(2026, 6, 1, 14, 0, 0);
      expect(isToday(DateTime(2026, 6, 1, 0, 30, 0), now: now), isTrue);
      expect(isToday(DateTime(2026, 6, 1, 23, 59, 59), now: now), isTrue);
      expect(isToday(now, now: now), isTrue);
    });

    test('returns false for the calendar day before', () {
      final now = DateTime(2026, 6, 1, 0, 30, 0);
      expect(isToday(DateTime(2026, 5, 31, 23, 59, 59), now: now), isFalse);
    });

    test('returns false for the calendar day after', () {
      final now = DateTime(2026, 6, 1, 23, 30, 0);
      expect(isToday(DateTime(2026, 6, 2, 0, 0, 0), now: now), isFalse);
    });

    test('returns false for a different month / year', () {
      final now = DateTime(2026, 6, 1);
      expect(isToday(DateTime(2026, 5, 1), now: now), isFalse);
      expect(isToday(DateTime(2025, 6, 1), now: now), isFalse);
    });

    test('is calendar-day based, not 24h-window based '
        '(a save 23 hours ago across midnight is not today)', () {
      final now = DateTime(2026, 6, 1, 0, 30, 0);
      // 23 hours ago = 2026-05-31 01:30:00 — different calendar day.
      final twentyThreeHoursAgo = now.subtract(const Duration(hours: 23));
      expect(isToday(twentyThreeHoursAgo, now: now), isFalse);
    });
  });
}
