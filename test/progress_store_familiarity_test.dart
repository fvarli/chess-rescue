import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressStore — Familiarity flag (PR 3)', () {
    test('fresh install: hasSeenFirstFamiliarityHint is false', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.hasSeenFirstFamiliarityHint, isFalse);
    });

    test('markFirstFamiliarityHintSeen persists across reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.hasSeenFirstFamiliarityHint, isFalse);
      await s.markFirstFamiliarityHintSeen();
      final fresh = await ProgressStore.create();
      expect(fresh.hasSeenFirstFamiliarityHint, isTrue);
    });

    test(
      're-marking after seen is idempotent (no error, value stays true)',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        await s.markFirstFamiliarityHintSeen();
        await s.markFirstFamiliarityHintSeen();
        await s.markFirstFamiliarityHintSeen();
        final fresh = await ProgressStore.create();
        expect(fresh.hasSeenFirstFamiliarityHint, isTrue);
      },
    );

    test('clear() resets the flag to false', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.markFirstFamiliarityHintSeen();
      await s.clear();
      final fresh = await ProgressStore.create();
      expect(fresh.hasSeenFirstFamiliarityHint, isFalse);
    });

    test('missing key reads as false via the ?? fallback', () async {
      // Explicit no-key seed — equivalent to fresh, but the test name
      // documents the defensive fallback path through getBool().
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.hasSeenFirstFamiliarityHint, isFalse);
    });
  });
}
