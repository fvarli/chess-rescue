import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/rescue_record.dart';
import 'package:chess_rescue/core/models/rescue_record_evaluator.dart';

RescueRecordSnapshot _snap({
  int lifetime = 0,
  int bestEndlessStreak = 0,
  int currentEndlessStreakPeak = 0,
  Set<String> completedIds = const <String>{},
  Set<String> unlockedRecords = const <String>{},
}) {
  return RescueRecordSnapshot(
    lifetimeSaved: lifetime,
    bestEndlessStreak: bestEndlessStreak,
    currentEndlessStreakPeak: currentEndlessStreakPeak,
    completedIds: completedIds,
    unlockedRecords: unlockedRecords,
  );
}

const _ep1Puzzles = {
  'p1-knight-rescue',
  'a4-the-breakaway',
  'b4-the-cross-check',
};
const _ep2Puzzles = {
  'p2-take-the-checker',
  'p5-win-the-queen',
  'b3-remove-the-defender',
};
const _ep3Puzzles = {
  'p3-block-the-file',
  'p4-seal-the-diagonal',
  'b1-the-martyr',
};

bool _idUnlocked(List<RescueRecordState> states, String id) =>
    states.firstWhere((s) => s.record.id == id).isUnlocked;

bool _idVisible(List<RescueRecordState> states, String id) =>
    states.firstWhere((s) => s.record.id == id).isVisible;

int _currentOf(List<RescueRecordState> states, String id) =>
    states.firstWhere((s) => s.record.id == id).currentProgress;

void main() {
  group('evaluateRecords — empty state', () {
    test(
      'only the three revealed entry-level records are visible; all locked',
      () {
        final states = evaluateRecords(_snap());
        for (final s in states) {
          expect(
            s.isUnlocked,
            isFalse,
            reason: '${s.record.id} should be locked',
          );
        }
        // Visible: first-rescue, ep1-strike-back, endless-spark.
        expect(_idVisible(states, 'first-rescue'), isTrue);
        expect(_idVisible(states, 'ep1-strike-back'), isTrue);
        expect(_idVisible(states, 'endless-spark'), isTrue);
        // Hidden chained / hiddenCategory entries.
        expect(_idVisible(states, 'familiar-ground'), isFalse);
        expect(_idVisible(states, 'the-rescuer'), isFalse);
        expect(_idVisible(states, 'unbroken'), isFalse);
        expect(_idVisible(states, 'ep2-end-the-threat'), isFalse);
        expect(_idVisible(states, 'unshaken'), isFalse);
      },
    );
  });

  group('evaluateRecords — Rescue lifetime ladder', () {
    test(
      'lifetimeSaved=1 unlocks First Rescue; Familiar Ground in progress',
      () {
        final states = evaluateRecords(_snap(lifetime: 1));
        expect(_idUnlocked(states, 'first-rescue'), isTrue);
        expect(_idUnlocked(states, 'familiar-ground'), isFalse);
        // Familiar Ground is now visible because First Rescue is unlocked.
        expect(_idVisible(states, 'familiar-ground'), isTrue);
        expect(_currentOf(states, 'familiar-ground'), 1);
      },
    );

    test('lifetimeSaved=10 unlocks First Rescue + Familiar Ground', () {
      final states = evaluateRecords(_snap(lifetime: 10));
      expect(_idUnlocked(states, 'first-rescue'), isTrue);
      expect(_idUnlocked(states, 'familiar-ground'), isTrue);
      expect(_idUnlocked(states, 'the-rescuer'), isFalse);
      expect(_idVisible(states, 'the-rescuer'), isTrue);
      expect(_currentOf(states, 'the-rescuer'), 10);
    });

    test('lifetimeSaved=100 unlocks the whole Rescue ladder', () {
      final states = evaluateRecords(_snap(lifetime: 100));
      for (final id in [
        'first-rescue',
        'familiar-ground',
        'the-rescuer',
        'unbroken',
      ]) {
        expect(_idUnlocked(states, id), isTrue, reason: id);
      }
    });
  });

  group('evaluateRecords — Endless streak ladder', () {
    test('bestEndlessStreak=3 unlocks Endless Spark only', () {
      final states = evaluateRecords(_snap(bestEndlessStreak: 3));
      expect(_idUnlocked(states, 'endless-spark'), isTrue);
      expect(_idUnlocked(states, 'endless-focus'), isFalse);
      expect(_idVisible(states, 'endless-focus'), isTrue);
    });

    test('bestEndlessStreak=7 unlocks Spark + Focus', () {
      final states = evaluateRecords(_snap(bestEndlessStreak: 7));
      expect(_idUnlocked(states, 'endless-spark'), isTrue);
      expect(_idUnlocked(states, 'endless-focus'), isTrue);
      expect(_idUnlocked(states, 'endless-master'), isFalse);
    });

    test('bestEndlessStreak=15 unlocks all three Endless records', () {
      final states = evaluateRecords(_snap(bestEndlessStreak: 15));
      expect(_idUnlocked(states, 'endless-spark'), isTrue);
      expect(_idUnlocked(states, 'endless-focus'), isTrue);
      expect(_idUnlocked(states, 'endless-master'), isTrue);
    });

    test(
      'currentEndlessStreakPeak overrides bestEndlessStreak when higher (mid-run unlock)',
      () {
        final states = evaluateRecords(
          _snap(bestEndlessStreak: 0, currentEndlessStreakPeak: 3),
        );
        expect(_idUnlocked(states, 'endless-spark'), isTrue);
      },
    );
  });

  group('evaluateRecords — Episodes', () {
    test('ep1 puzzles complete unlocks Strike Back', () {
      final states = evaluateRecords(_snap(completedIds: _ep1Puzzles));
      expect(_idUnlocked(states, 'ep1-strike-back'), isTrue);
      expect(_idVisible(states, 'ep2-end-the-threat'), isTrue);
      expect(_idUnlocked(states, 'ep2-end-the-threat'), isFalse);
    });

    test('ep1+ep2 puzzles complete unlocks Strike Back + End the Threat', () {
      final states = evaluateRecords(
        _snap(completedIds: {..._ep1Puzzles, ..._ep2Puzzles}),
      );
      expect(_idUnlocked(states, 'ep1-strike-back'), isTrue);
      expect(_idUnlocked(states, 'ep2-end-the-threat'), isTrue);
      expect(_idUnlocked(states, 'ep3-hold-the-line'), isFalse);
    });

    test('all canonical puzzles complete unlocks the canonical trilogy', () {
      final states = evaluateRecords(
        _snap(completedIds: {..._ep1Puzzles, ..._ep2Puzzles, ..._ep3Puzzles}),
      );
      expect(_idUnlocked(states, 'ep1-strike-back'), isTrue);
      expect(_idUnlocked(states, 'ep2-end-the-threat'), isTrue);
      expect(_idUnlocked(states, 'ep3-hold-the-line'), isTrue);
      // The Other Side is eventOnly — still locked without an explicit write.
      expect(_idUnlocked(states, 'ep4-the-other-side'), isFalse);
    });
  });

  group('evaluateRecords — eventOnly records', () {
    test(
      "The Other Side requires its id in unlockedRecords; not derivable from completedIds",
      () {
        final completed = {..._ep1Puzzles, ..._ep2Puzzles, ..._ep3Puzzles};
        final s1 = evaluateRecords(_snap(completedIds: completed));
        expect(_idUnlocked(s1, 'ep4-the-other-side'), isFalse);
        final s2 = evaluateRecords(
          _snap(
            completedIds: completed,
            unlockedRecords: {'ep4-the-other-side'},
          ),
        );
        expect(_idUnlocked(s2, 'ep4-the-other-side'), isTrue);
      },
    );

    test('Against the Odds unlocks via its id in unlockedRecords', () {
      final states = evaluateRecords(
        _snap(unlockedRecords: {'ep4-the-other-side', 'against-the-odds'}),
      );
      expect(_idUnlocked(states, 'against-the-odds'), isTrue);
    });

    test('Mastery (Unshaken) — eventOnly + hiddenCategory', () {
      // Unshaken not earned → category invisible.
      final s1 = evaluateRecords(_snap(lifetime: 100));
      expect(_idVisible(s1, 'unshaken'), isFalse);
      // Unshaken earned → row visible + unlocked.
      final s2 = evaluateRecords(_snap(unlockedRecords: {'unshaken'}));
      expect(_idVisible(s2, 'unshaken'), isTrue);
      expect(_idUnlocked(s2, 'unshaken'), isTrue);
    });
  });

  group('newlyUnlocked — diff helper', () {
    test('empty before → empty after produces no new ids', () {
      final diff = newlyUnlocked(_snap(), _snap());
      expect(diff, isEmpty);
    });

    test('lifetime 0 → 1 yields First Rescue', () {
      final diff = newlyUnlocked(_snap(), _snap(lifetime: 1));
      expect(diff, ['first-rescue']);
    });

    test(
      'lifetime 9 → 10 yields Familiar Ground only (First Rescue already)',
      () {
        final diff = newlyUnlocked(_snap(lifetime: 9), _snap(lifetime: 10));
        expect(diff, ['familiar-ground']);
      },
    );

    test('completing ep3 from ep1+ep2 done yields Hold the Line only', () {
      final before = _snap(completedIds: {..._ep1Puzzles, ..._ep2Puzzles});
      final after = _snap(
        completedIds: {..._ep1Puzzles, ..._ep2Puzzles, ..._ep3Puzzles},
      );
      final diff = newlyUnlocked(before, after);
      expect(diff, ['ep3-hold-the-line']);
    });

    test('two thresholds crossed in one rescue yield ids in library order', () {
      // From lifetimeSaved=24 + bestStreak=6 to 25/7 crosses The Rescuer
      // and Endless Focus simultaneously. The Rescuer is earlier in the
      // library list, should come first.
      final before = _snap(lifetime: 24, bestEndlessStreak: 6);
      final after = _snap(lifetime: 25, bestEndlessStreak: 7);
      final diff = newlyUnlocked(before, after);
      expect(diff, ['the-rescuer', 'endless-focus']);
    });
  });
}
