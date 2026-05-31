import 'episode.dart';
import 'rescue_archetype.dart';

// Canonical puzzle id constants — matched against ProgressStore.completedIds
// entries, which GameController writes via canonicalPuzzleId(puzzle.id) from
// lib/core/models/variation.dart (the `#variation` suffix is stripped, the
// base id like "p1-knight-rescue" is preserved verbatim).
const String _idP1 = 'p1-knight-rescue';
const String _idP2 = 'p2-take-the-checker';
const String _idP3 = 'p3-block-the-file';
const String _idP4 = 'p4-seal-the-diagonal';
const String _idP5 = 'p5-win-the-queen';
const String _idA4 = 'a4-the-breakaway';
const String _idB1 = 'b1-the-martyr';
const String _idB3 = 'b3-remove-the-defender';
const String _idB4 = 'b4-the-cross-check';

class EpisodeLibrary {
  EpisodeLibrary._();

  static const Episode ep1 = Episode(
    id: 'ep1-strike-back',
    number: 1,
    titleKey: 'episodeEp1Title',
    taglineKey: 'episodeEp1Tagline',
    kind: EpisodeKind.canonical,
    archetypes: {RescueArchetype.counterCheck},
    canonicalPuzzleIds: [_idP1, _idA4, _idB4],
    unlockRequirementId: null,
  );

  static const Episode ep2 = Episode(
    id: 'ep2-end-the-threat',
    number: 2,
    titleKey: 'episodeEp2Title',
    taglineKey: 'episodeEp2Tagline',
    kind: EpisodeKind.canonical,
    archetypes: {
      RescueArchetype.captureAttackerMinor,
      RescueArchetype.captureAttackerHeavy,
      RescueArchetype.removeDefender,
    },
    canonicalPuzzleIds: [_idP2, _idP5, _idB3],
    unlockRequirementId: 'ep1-strike-back',
  );

  static const Episode ep3 = Episode(
    id: 'ep3-hold-the-line',
    number: 3,
    titleKey: 'episodeEp3Title',
    taglineKey: 'episodeEp3Tagline',
    kind: EpisodeKind.canonical,
    archetypes: {
      RescueArchetype.blockFile,
      RescueArchetype.sealDiagonal,
      RescueArchetype.forcedInterposition,
    },
    canonicalPuzzleIds: [_idP3, _idP4, _idB1],
    unlockRequirementId: 'ep2-end-the-threat',
  );

  // Master kind — one mirror drawn from each canonical episode's pool.
  // SessionComposer.composeEpisode reads canonicalPuzzleIds and mandates
  // mirror variants for every slot when kind == EpisodeKind.master.
  static const Episode ep4 = Episode(
    id: 'ep4-the-other-side',
    number: 4,
    titleKey: 'episodeEp4Title',
    taglineKey: 'episodeEp4Tagline',
    kind: EpisodeKind.master,
    archetypes: {},
    canonicalPuzzleIds: [_idP1, _idP5, _idB1],
    unlockRequirementId: 'ep3-hold-the-line',
  );

  // Endless kind — no canonical pool; composer draws from the full library.
  // Unlocks simultaneously with ep4 (both gate on ep3 completion).
  static const Episode ep5 = Episode(
    id: 'ep5-endless-rescue',
    number: 5,
    titleKey: 'episodeEp5Title',
    taglineKey: 'episodeEp5Tagline',
    kind: EpisodeKind.endless,
    archetypes: {},
    canonicalPuzzleIds: [],
    unlockRequirementId: 'ep3-hold-the-line',
  );

  static const List<Episode> all = [ep1, ep2, ep3, ep4, ep5];

  static Episode get first => ep1;

  static Episode? byId(String id) {
    for (final ep in all) {
      if (ep.id == id) return ep;
    }
    return null;
  }

  static Episode? nextAfter(Episode current) {
    final i = all.indexOf(current);
    if (i < 0 || i + 1 >= all.length) return null;
    return all[i + 1];
  }

  /// Returns `(completedCount, isComplete, isUnlocked)` for [episode] given the
  /// player's global `completedIds` set. Pure function — derives everything;
  /// nothing is persisted per-episode for master or endless.
  static EpisodeProgress progressFor(
    Episode episode,
    Set<String> completedIds,
  ) {
    final isUnlocked = _isUnlocked(episode, completedIds);
    switch (episode.kind) {
      case EpisodeKind.canonical:
        final done = episode.canonicalPuzzleIds
            .where(completedIds.contains)
            .length;
        return EpisodeProgress(
          completedCount: done,
          isComplete: done == episode.canonicalPuzzleIds.length,
          isUnlocked: isUnlocked,
        );
      case EpisodeKind.master:
      case EpisodeKind.endless:
        return EpisodeProgress(
          completedCount: 0,
          isComplete: false,
          isUnlocked: isUnlocked,
        );
    }
  }

  static bool _isUnlocked(Episode episode, Set<String> completedIds) {
    final reqId = episode.unlockRequirementId;
    if (reqId == null) return true;
    final req = byId(reqId);
    if (req == null) return false;
    return progressFor(req, completedIds).isComplete;
  }

  /// First episode in order that is unlocked but not complete. Falls back to
  /// `ep1` when no progress exists; falls back to `ep4` (first unlocked after
  /// ep3 in list order) for whales who've cleared ep1-ep3. Total — every
  /// possible `completedIds` set returns some live episode.
  static Episode firstNonCompleteFor(Set<String> completedIds) {
    for (final ep in all) {
      final p = progressFor(ep, completedIds);
      if (p.isUnlocked && !p.isComplete) return ep;
    }
    return ep1;
  }
}
