import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/rescue_record.dart';
import 'package:chess_rescue/core/models/rescue_record_library.dart';

void main() {
  group('RescueRecordLibrary — structure', () {
    test('exactly 14 records in book order', () {
      expect(RescueRecordLibrary.all, hasLength(14));
    });

    test('record ids are unique', () {
      final ids = RescueRecordLibrary.all.map((r) => r.id).toSet();
      expect(ids.length, 14);
    });

    test(
      'Rescue category contains 4 records with thresholds 1 / 10 / 25 / 100',
      () {
        final rescue = RescueRecordLibrary.byCategory(
          RescueRecordCategory.rescue,
        );
        expect(rescue, hasLength(4));
        expect(rescue.map((r) => r.targetInt).toList(), [1, 10, 25, 100]);
        for (final r in rescue) {
          expect(r.source, RescueRecordSource.lifetime);
        }
      },
    );

    test('Episodes category contains 6 records', () {
      final eps = RescueRecordLibrary.byCategory(RescueRecordCategory.episodes);
      expect(eps, hasLength(6));
      expect(eps.map((r) => r.id).toList(), [
        'ep1-strike-back',
        'ep2-end-the-threat',
        'ep3-hold-the-line',
        'ep6-pin-the-threat',
        'ep4-the-other-side',
        'against-the-odds',
      ]);
    });

    test('Endless category contains 3 records with thresholds 3 / 7 / 15', () {
      final endless = RescueRecordLibrary.byCategory(
        RescueRecordCategory.endless,
      );
      expect(endless, hasLength(3));
      expect(endless.map((r) => r.targetInt).toList(), [3, 7, 15]);
      for (final r in endless) {
        expect(r.source, RescueRecordSource.endlessStreak);
      }
    });

    test('Mastery category contains exactly one record in R1', () {
      final mastery = RescueRecordLibrary.byCategory(
        RescueRecordCategory.mastery,
      );
      expect(mastery, hasLength(1));
      expect(mastery.first.id, 'unshaken');
      expect(mastery.first.reveal, RescueRecordReveal.hiddenCategory);
    });
  });

  group('RescueRecordLibrary — chain integrity', () {
    test('every chained record has a predecessor in the same category', () {
      for (final r in RescueRecordLibrary.all) {
        if (r.reveal != RescueRecordReveal.chained) continue;
        expect(
          r.predecessorId,
          isNotNull,
          reason: '${r.id} is chained but has no predecessorId',
        );
        final pred = RescueRecordLibrary.byId(r.predecessorId!);
        expect(
          pred,
          isNotNull,
          reason: '${r.id} predecessor ${r.predecessorId} not in library',
        );
        expect(
          pred!.category,
          r.category,
          reason: '${r.id} predecessor is in a different category',
        );
      }
    });

    test(
      'revealed records are the entry-level of each category that has any',
      () {
        // First Rescue, Strike Back, Endless Spark — exactly three.
        final revealed = RescueRecordLibrary.all
            .where((r) => r.reveal == RescueRecordReveal.revealed)
            .toList();
        expect(revealed.map((r) => r.id).toSet(), {
          'first-rescue',
          'ep1-strike-back',
          'endless-spark',
        });
      },
    );

    test('Against the Odds is eventOnly and chained behind The Other Side', () {
      final atO = RescueRecordLibrary.byId('against-the-odds');
      expect(atO, isNotNull);
      expect(atO!.source, RescueRecordSource.eventOnly);
      expect(atO.reveal, RescueRecordReveal.chained);
      expect(atO.predecessorId, 'ep4-the-other-side');
    });

    test('The Other Side is eventOnly with episodeId ep4', () {
      final tos = RescueRecordLibrary.byId('ep4-the-other-side');
      expect(tos, isNotNull);
      expect(tos!.source, RescueRecordSource.eventOnly);
      expect(tos.episodeId, 'ep4-the-other-side');
    });
  });

  group('RescueRecordLibrary — l10n key well-formedness', () {
    test('every record references three distinct AppL10n keys', () {
      for (final r in RescueRecordLibrary.all) {
        expect(r.titleKey, startsWith('recordTitle_'));
        expect(r.descriptionLockedKey, startsWith('recordDescriptionLocked_'));
        expect(
          r.descriptionUnlockedKey,
          startsWith('recordDescriptionUnlocked_'),
        );
      }
    });
  });
}
