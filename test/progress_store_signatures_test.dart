import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';
import 'package:chess_rescue/core/models/signature_entry.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';

SignatureEntry _sig(
  String canonicalId, {
  String? encountered,
  String episode = 'ep1-strike-back',
  DateTime? at,
}) => SignatureEntry(
  canonicalPuzzleId: canonicalId,
  encounteredPuzzleId: encountered ?? canonicalId,
  episodeId: episode,
  adoptedAt: at ?? DateTime.utc(2026, 6, 1),
);

RecentlySolvedEntry _recent(
  String canonicalId, {
  String? encountered,
  String episode = 'ep1-strike-back',
  DateTime? at,
}) => RecentlySolvedEntry(
  canonicalPuzzleId: canonicalId,
  encounteredPuzzleId: encountered ?? canonicalId,
  episodeId: episode,
  solvedAt: at ?? DateTime.utc(2026, 6, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressStore — Signatures storage (PR 1)', () {
    test(
      'fresh install: empty signatures, empty ring, both flags false',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        expect(s.signatures, isEmpty);
        expect(s.signaturesCanonicalIds, isEmpty);
        expect(s.recentlySolved.entries, isEmpty);
        expect(s.hasSeenSignaturesFirstBookmarkHint, isFalse);
        expect(s.hasSeenSignaturesTabPulse, isFalse);
      },
    );

    test('addSignature persists and round-trips across reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addSignature(_sig('p1-knight-rescue'));
      await s.addSignature(_sig('p2-take-the-checker'));

      final fresh = await ProgressStore.create();
      expect(fresh.signatures.map((e) => e.canonicalPuzzleId).toList(), [
        'p1-knight-rescue',
        'p2-take-the-checker',
      ]);
      expect(fresh.signaturesCanonicalIds, {
        'p1-knight-rescue',
        'p2-take-the-checker',
      });
      expect(fresh.isSignatureSaved('p1-knight-rescue'), isTrue);
      expect(fresh.isSignatureSaved('b1-the-martyr'), isFalse);
    });

    test('addSignature is a no-op when canonical id already present', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addSignature(_sig('p1-knight-rescue'));
      // Try to re-add with different encountered id — should still no-op.
      await s.addSignature(
        _sig(
          'p1-knight-rescue',
          encountered: 'p1-knight-rescue#mirror',
          episode: 'ep4-the-other-side',
        ),
      );
      final fresh = await ProgressStore.create();
      expect(fresh.signatures.length, 1);
      expect(fresh.signatures.first.episodeId, 'ep1-strike-back');
      expect(
        fresh.signatures.first.encounteredPuzzleId,
        'p1-knight-rescue',
      ); // first-write wins
    });

    test('addSignature with the canonical of an already-saved mirror is '
        'also a no-op (cross-mirror dedupe)', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      // First save the mirror encounter (canonical id is still stripped
      // — the caller is responsible for passing the canonical id).
      await s.addSignature(
        _sig('p1-knight-rescue', encountered: 'p1-knight-rescue#mirror'),
      );
      // Now attempt to add the canonical version of the same puzzle.
      await s.addSignature(_sig('p1-knight-rescue'));
      final fresh = await ProgressStore.create();
      expect(fresh.signatures.length, 1);
      // The first-saved (mirror) entry's encountered id wins.
      expect(
        fresh.signatures.first.encounteredPuzzleId,
        'p1-knight-rescue#mirror',
      );
    });

    test(
      'removeSignature removes the matching entry, preserves order',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        await s.addSignature(_sig('a'));
        await s.addSignature(_sig('b'));
        await s.addSignature(_sig('c'));
        await s.removeSignature('b');
        final fresh = await ProgressStore.create();
        expect(fresh.signatures.map((e) => e.canonicalPuzzleId).toList(), [
          'a',
          'c',
        ]);
      },
    );

    test('removeSignature with unknown id is a no-op', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addSignature(_sig('a'));
      await s.removeSignature('nope');
      final fresh = await ProgressStore.create();
      expect(fresh.signatures.length, 1);
    });

    test('restoreSignatureAt re-inserts at the given index, shifting later '
        'entries right', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addSignature(_sig('a'));
      await s.addSignature(_sig('b'));
      await s.addSignature(_sig('c'));
      // Remove b, then restore at original position 1.
      await s.removeSignature('b');
      await s.restoreSignatureAt(1, _sig('b'));
      final fresh = await ProgressStore.create();
      expect(fresh.signatures.map((e) => e.canonicalPuzzleId).toList(), [
        'a',
        'b',
        'c',
      ]);
    });

    test(
      'restoreSignatureAt with index beyond current length appends at end',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        await s.addSignature(_sig('a'));
        await s.restoreSignatureAt(99, _sig('b'));
        final fresh = await ProgressStore.create();
        expect(fresh.signatures.map((e) => e.canonicalPuzzleId).toList(), [
          'a',
          'b',
        ]);
      },
    );

    test(
      'restoreSignatureAt does not duplicate an existing canonical id',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        await s.addSignature(_sig('a'));
        // Restoring an id that's already present is a no-op.
        await s.restoreSignatureAt(0, _sig('a'));
        final fresh = await ProgressStore.create();
        expect(fresh.signatures.length, 1);
      },
    );

    test('recordRecentlySolved writes into the ring and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.recordRecentlySolved(_recent('p1-knight-rescue'));
      await s.recordRecentlySolved(_recent('p2-take-the-checker'));
      final fresh = await ProgressStore.create();
      expect(
        fresh.recentlySolved.entries.map((e) => e.canonicalPuzzleId).toList(),
        ['p2-take-the-checker', 'p1-knight-rescue'],
      );
    });

    test(
      'recording 8 distinct canonical ids drops the oldest (cap 7)',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        for (var i = 0; i < 8; i++) {
          await s.recordRecentlySolved(_recent('id-$i'));
        }
        final fresh = await ProgressStore.create();
        expect(fresh.recentlySolved.entries.length, 7);
        expect(fresh.recentlySolved.entries.first.canonicalPuzzleId, 'id-7');
        expect(
          fresh.recentlySolved.entries
              .map((e) => e.canonicalPuzzleId)
              .contains('id-0'),
          isFalse,
        );
      },
    );

    test(
      're-recording an existing canonical id moves to front, no duplicate',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = await ProgressStore.create();
        await s.recordRecentlySolved(_recent('a'));
        await s.recordRecentlySolved(_recent('b'));
        await s.recordRecentlySolved(_recent('c'));
        await s.recordRecentlySolved(_recent('a'));
        final fresh = await ProgressStore.create();
        expect(
          fresh.recentlySolved.entries.map((e) => e.canonicalPuzzleId).toList(),
          ['a', 'c', 'b'],
        );
      },
    );

    test('markSignaturesFirstBookmarkHintSeen persists the flag', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.hasSeenSignaturesFirstBookmarkHint, isFalse);
      await s.markSignaturesFirstBookmarkHintSeen();
      final fresh = await ProgressStore.create();
      expect(fresh.hasSeenSignaturesFirstBookmarkHint, isTrue);
    });

    test('markSignaturesTabPulseSeen persists the flag', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.hasSeenSignaturesTabPulse, isFalse);
      await s.markSignaturesTabPulseSeen();
      final fresh = await ProgressStore.create();
      expect(fresh.hasSeenSignaturesTabPulse, isTrue);
    });

    test('clear() removes all four new Signatures keys', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      await s.addSignature(_sig('a'));
      await s.recordRecentlySolved(_recent('b'));
      await s.markSignaturesFirstBookmarkHintSeen();
      await s.markSignaturesTabPulseSeen();
      await s.clear();
      final fresh = await ProgressStore.create();
      expect(fresh.signatures, isEmpty);
      expect(fresh.recentlySolved.entries, isEmpty);
      expect(fresh.hasSeenSignaturesFirstBookmarkHint, isFalse);
      expect(fresh.hasSeenSignaturesTabPulse, isFalse);
    });

    test('malformed signatures JSON falls back to empty list', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_signatures': '{not valid json',
      });
      final s = await ProgressStore.create();
      expect(s.signatures, isEmpty);
    });

    test('non-list signatures JSON falls back to empty list', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_signatures': '{"oops": true}',
      });
      final s = await ProgressStore.create();
      expect(s.signatures, isEmpty);
    });

    test('malformed recently-solved JSON falls back to empty ring', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_recently_solved': '{not valid json',
      });
      final s = await ProgressStore.create();
      expect(s.recentlySolved.entries, isEmpty);
    });
  });
}
