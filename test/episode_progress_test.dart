import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/episode_library.dart';

void main() {
  group('progressFor — derivation by kind', () {
    test('empty completedIds → ep1 unlocked, ep2-5 locked', () {
      const empty = <String>{};
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep1, empty).isUnlocked,
        isTrue,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep1, empty).completedCount,
        0,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep1, empty).isComplete,
        isFalse,
      );
      for (final ep in [
        EpisodeLibrary.ep2,
        EpisodeLibrary.ep3,
        EpisodeLibrary.ep4,
        EpisodeLibrary.ep5,
      ]) {
        expect(
          EpisodeLibrary.progressFor(ep, empty).isUnlocked,
          isFalse,
          reason: '${ep.id} should be locked when nothing is completed',
        );
      }
    });

    test('completing ep1 unlocks ep2 only', () {
      const ids = {
        'p1-knight-rescue',
        'a4-the-breakaway',
        'b4-the-cross-check',
      };
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep1, ids).isComplete,
        isTrue,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep2, ids).isUnlocked,
        isTrue,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep3, ids).isUnlocked,
        isFalse,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep4, ids).isUnlocked,
        isFalse,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep5, ids).isUnlocked,
        isFalse,
      );
    });

    test(
      'completing ep3 unlocks BOTH ep4 AND ep5 in the same boot (simultaneous)',
      () {
        const ids = {
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
          'p2-take-the-checker',
          'p5-win-the-queen',
          'b3-remove-the-defender',
          'p3-block-the-file',
          'p4-seal-the-diagonal',
          'b1-the-martyr',
        };
        expect(
          EpisodeLibrary.progressFor(EpisodeLibrary.ep3, ids).isComplete,
          isTrue,
        );
        expect(
          EpisodeLibrary.progressFor(EpisodeLibrary.ep4, ids).isUnlocked,
          isTrue,
        );
        expect(
          EpisodeLibrary.progressFor(EpisodeLibrary.ep5, ids).isUnlocked,
          isTrue,
        );
      },
    );

    test('partial ep1 progress does not unlock ep2', () {
      const ids = {'p1-knight-rescue'};
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep1, ids).completedCount,
        1,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep1, ids).isComplete,
        isFalse,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep2, ids).isUnlocked,
        isFalse,
      );
    });

    test('master + endless never report isComplete: true', () {
      const ids = {
        'p1-knight-rescue',
        'a4-the-breakaway',
        'b4-the-cross-check',
        'p2-take-the-checker',
        'p5-win-the-queen',
        'b3-remove-the-defender',
        'p3-block-the-file',
        'p4-seal-the-diagonal',
        'b1-the-martyr',
      };
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep4, ids).isComplete,
        isFalse,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep5, ids).isComplete,
        isFalse,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep4, ids).completedCount,
        0,
      );
      expect(
        EpisodeLibrary.progressFor(EpisodeLibrary.ep5, ids).completedCount,
        0,
      );
    });
  });

  group('firstNonCompleteFor', () {
    test('empty set → ep1', () {
      expect(EpisodeLibrary.firstNonCompleteFor({}), EpisodeLibrary.ep1);
    });

    test('mid-ep1 → ep1 (still in progress)', () {
      expect(
        EpisodeLibrary.firstNonCompleteFor({'p1-knight-rescue'}),
        EpisodeLibrary.ep1,
      );
    });

    test('ep1 done → ep2', () {
      expect(
        EpisodeLibrary.firstNonCompleteFor({
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
        }),
        EpisodeLibrary.ep2,
      );
    });

    test(
      'all 9 canonical+expansion done → ep4 (first non-complete in order)',
      () {
        const ids = {
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
          'p2-take-the-checker',
          'p5-win-the-queen',
          'b3-remove-the-defender',
          'p3-block-the-file',
          'p4-seal-the-diagonal',
          'b1-the-martyr',
        };
        expect(EpisodeLibrary.firstNonCompleteFor(ids), EpisodeLibrary.ep4);
      },
    );
  });
}
