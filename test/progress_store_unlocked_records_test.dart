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
}
