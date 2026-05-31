import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/episode_library.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Migration — derivation from existing completedIds', () {
    test('fresh install → ep1, only ep1 unlocked', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      final focus = EpisodeLibrary.firstNonCompleteFor(store.completedIds);
      expect(focus, EpisodeLibrary.ep1);
      for (final ep in EpisodeLibrary.all) {
        final p = EpisodeLibrary.progressFor(ep, store.completedIds);
        expect(
          p.isUnlocked,
          ep == EpisodeLibrary.ep1,
          reason: '${ep.id} unlock state',
        );
      }
    });

    test(
      'completedIds = {p1} → ep1 in progress, chain still locked downstream',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': ['p1-knight-rescue'],
        });
        final store = await ProgressStore.create();
        final focus = EpisodeLibrary.firstNonCompleteFor(store.completedIds);
        expect(focus, EpisodeLibrary.ep1);
        expect(
          EpisodeLibrary.progressFor(
            EpisodeLibrary.ep1,
            store.completedIds,
          ).completedCount,
          1,
        );
        expect(
          EpisodeLibrary.progressFor(
            EpisodeLibrary.ep2,
            store.completedIds,
          ).isUnlocked,
          isFalse,
        );
      },
    );

    test(
      'completedIds covers ep1 → focus moves to ep2, ep3-5 locked',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
          ],
        });
        final store = await ProgressStore.create();
        final focus = EpisodeLibrary.firstNonCompleteFor(store.completedIds);
        expect(focus, EpisodeLibrary.ep2);
        expect(
          EpisodeLibrary.progressFor(
            EpisodeLibrary.ep1,
            store.completedIds,
          ).isComplete,
          isTrue,
        );
        expect(
          EpisodeLibrary.progressFor(
            EpisodeLibrary.ep3,
            store.completedIds,
          ).isUnlocked,
          isFalse,
        );
      },
    );

    test(
      'completedIds covers ep1–ep3 → focus moves to ep4; ep4 AND ep5 unlocked',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_completed_ids': [
            'p1-knight-rescue',
            'a4-the-breakaway',
            'b4-the-cross-check',
            'p2-take-the-checker',
            'p5-win-the-queen',
            'b3-remove-the-defender',
            'p3-block-the-file',
            'p4-seal-the-diagonal',
            'b1-the-martyr',
          ],
        });
        final store = await ProgressStore.create();
        final focus = EpisodeLibrary.firstNonCompleteFor(store.completedIds);
        expect(focus, EpisodeLibrary.ep4);
        expect(
          EpisodeLibrary.progressFor(
            EpisodeLibrary.ep4,
            store.completedIds,
          ).isUnlocked,
          isTrue,
        );
        expect(
          EpisodeLibrary.progressFor(
            EpisodeLibrary.ep5,
            store.completedIds,
          ).isUnlocked,
          isTrue,
        );
      },
    );

    test(
      'migration does not modify existing keys (lifetimeSaved preserved)',
      () async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_lifetime_saved': 42,
          'flutter.cr_completed_ids': ['p1-knight-rescue'],
        });
        final store = await ProgressStore.create();
        expect(store.lifetimeSaved, 42);
        expect(store.completedIds, contains('p1-knight-rescue'));
      },
    );
  });

  group('ProgressStore episode keys', () {
    test('currentEpisodeId default null; round-trips on set', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.currentEpisodeId, isNull);
      await s.setCurrentEpisodeId('ep2-end-the-threat');
      final fresh = await ProgressStore.create();
      expect(fresh.currentEpisodeId, 'ep2-end-the-threat');
    });

    test('episodeSeeds default empty; setEpisodeSeed accumulates', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.episodeSeeds, isEmpty);
      await s.setEpisodeSeed('ep5-endless-rescue', 7);
      await s.setEpisodeSeed('ep1-strike-back', 2);
      final fresh = await ProgressStore.create();
      expect(fresh.seedFor('ep5-endless-rescue'), 7);
      expect(fresh.seedFor('ep1-strike-back'), 2);
      expect(fresh.seedFor('nonexistent'), 0); // default
    });

    test('clear() removes the new episode keys', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_current_episode_id': 'ep2-end-the-threat',
        'flutter.cr_best_endless_streak': 12,
      });
      final s = await ProgressStore.create();
      expect(s.currentEpisodeId, 'ep2-end-the-threat');
      expect(s.bestEndlessStreak, 12);
      await s.clear();
      final fresh = await ProgressStore.create();
      expect(fresh.currentEpisodeId, isNull);
      expect(fresh.bestEndlessStreak, 0);
    });
  });
}
