import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressStore.unlockedRecords', () {
    test('default for an empty store is an empty list', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.unlockedRecords, isEmpty);
      expect(s.unlockedRecordsSet, isEmpty);
    });

    test(
      'addUnlockedRecord persists across reloads, in insertion order',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s1 = await ProgressStore.create();
        await s1.addUnlockedRecord('first-rescue');
        await s1.addUnlockedRecord('ep1-strike-back');
        await s1.addUnlockedRecord('endless-spark');
        final s2 = await ProgressStore.create();
        expect(s2.unlockedRecords, [
          'first-rescue',
          'ep1-strike-back',
          'endless-spark',
        ]);
        expect(s2.unlockedRecordsSet, {
          'first-rescue',
          'ep1-strike-back',
          'endless-spark',
        });
      },
    );

    test('addUnlockedRecord is idempotent — no duplicates', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addUnlockedRecord('first-rescue');
      await s.addUnlockedRecord('first-rescue');
      await s.addUnlockedRecord('first-rescue');
      final fresh = await ProgressStore.create();
      expect(fresh.unlockedRecords, ['first-rescue']);
    });

    test('clear() removes the unlocked-records list', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addUnlockedRecord('first-rescue');
      await s.addUnlockedRecord('unbroken');
      await s.clear();
      final fresh = await ProgressStore.create();
      expect(fresh.unlockedRecords, isEmpty);
    });

    test('reading a malformed JSON falls back to empty', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_unlocked_records': '{not valid json',
      });
      final s = await ProgressStore.create();
      expect(s.unlockedRecords, isEmpty);
    });

    test('reading a JSON that is not a list falls back to empty', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_unlocked_records': '{"oops": true}',
      });
      final s = await ProgressStore.create();
      expect(s.unlockedRecords, isEmpty);
    });
  });

  group('ProgressStore.unlockedRecordDates (PR-12)', () {
    test('default for an empty store is an empty map', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.unlockedRecordDates, isEmpty);
    });

    test('addUnlockedRecord writes a date for the new id', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      final stamp = DateTime.utc(2026, 6, 9, 12, 0);
      await s.addUnlockedRecord('first-rescue', now: stamp);
      final fresh = await ProgressStore.create();
      expect(fresh.unlockedRecords, ['first-rescue']);
      expect(fresh.unlockedRecordDates['first-rescue'], stamp);
    });

    test('two unlocks build the date map alongside the id list', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      final t1 = DateTime.utc(2026, 6, 9, 12, 0);
      final t2 = DateTime.utc(2026, 6, 10, 13, 30);
      await s.addUnlockedRecord('first-rescue', now: t1);
      await s.addUnlockedRecord('ep1-strike-back', now: t2);
      final fresh = await ProgressStore.create();
      expect(fresh.unlockedRecords, ['first-rescue', 'ep1-strike-back']);
      expect(fresh.unlockedRecordDates, {
        'first-rescue': t1,
        'ep1-strike-back': t2,
      });
    });

    test(
      'addUnlockedRecord is idempotent on the date map — re-calls do not overwrite',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        final original = DateTime.utc(2026, 6, 9, 12, 0);
        final later = DateTime.utc(2026, 6, 12, 9, 0);
        await s.addUnlockedRecord('first-rescue', now: original);
        // Re-call with a different timestamp — date map must not change.
        await s.addUnlockedRecord('first-rescue', now: later);
        final fresh = await ProgressStore.create();
        expect(fresh.unlockedRecordDates['first-rescue'], original);
      },
    );

    test(
      'legacy unlocks (id list set, date map missing) keep "unlocked, undated" semantics',
      () async {
        // Simulate a player who unlocked records before PR-12 shipped.
        SharedPreferences.setMockInitialValues({
          'flutter.cr_unlocked_records': '["first-rescue","familiar-ground"]',
        });
        final s = await ProgressStore.create();
        expect(s.unlockedRecords, ['first-rescue', 'familiar-ground']);
        // Date map is silently empty — chronology starts when we start tracking.
        expect(s.unlockedRecordDates, isEmpty);
      },
    );

    test(
      'addUnlockedRecord for a legacy-listed id is a no-op (preserves undated semantics)',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_unlocked_records': '["first-rescue"]',
        });
        final s = await ProgressStore.create();
        await s.addUnlockedRecord(
          'first-rescue',
          now: DateTime.utc(2026, 6, 9),
        );
        final fresh = await ProgressStore.create();
        // List unchanged.
        expect(fresh.unlockedRecords, ['first-rescue']);
        // No date back-filled — legacy unlock stays undated.
        expect(fresh.unlockedRecordDates, isEmpty);
      },
    );

    test('clear() removes the date map alongside the id list', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addUnlockedRecord('first-rescue', now: DateTime.utc(2026, 6, 9));
      await s.clear();
      final fresh = await ProgressStore.create();
      expect(fresh.unlockedRecordDates, isEmpty);
    });

    test('malformed JSON for the date map falls back to empty', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_unlocked_record_dates': '{not valid json',
      });
      final s = await ProgressStore.create();
      expect(s.unlockedRecordDates, isEmpty);
    });

    test(
      'date map entries with unparseable timestamps are silently skipped',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_unlocked_record_dates':
              '{"first-rescue":"2026-06-09T12:00:00.000Z","bad":"not-a-date"}',
        });
        final s = await ProgressStore.create();
        expect(s.unlockedRecordDates, {
          'first-rescue': DateTime.utc(2026, 6, 9, 12, 0),
        });
      },
    );
  });
}
