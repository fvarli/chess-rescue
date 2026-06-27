import 'episode.dart';
import 'episode_library.dart';
import 'rescue_record.dart';

/// R1 — the 13-record Rescue Records library. Pure const data; the source
/// of truth for the recognition layer. Mid-tier rescue records (King's Hope
/// at 5, Steadfast at 50, etc.), additional endless tiers, and Phoenix are
/// deferred to R2 — all remain derivable from existing signals.
class RescueRecordLibrary {
  RescueRecordLibrary._();

  // — Rescue (lifetime ladder)
  static const RescueRecord firstRescue = RescueRecord(
    id: 'first-rescue',
    titleKey: 'recordTitle_firstRescue',
    descriptionLockedKey: 'recordDescriptionLocked_firstRescue',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_firstRescue',
    category: RescueRecordCategory.rescue,
    source: RescueRecordSource.lifetime,
    reveal: RescueRecordReveal.revealed,
    targetInt: 1,
  );
  static const RescueRecord familiarGround = RescueRecord(
    id: 'familiar-ground',
    titleKey: 'recordTitle_familiarGround',
    descriptionLockedKey: 'recordDescriptionLocked_familiarGround',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_familiarGround',
    category: RescueRecordCategory.rescue,
    source: RescueRecordSource.lifetime,
    reveal: RescueRecordReveal.chained,
    targetInt: 10,
    predecessorId: 'first-rescue',
  );
  static const RescueRecord theRescuer = RescueRecord(
    id: 'the-rescuer',
    titleKey: 'recordTitle_theRescuer',
    descriptionLockedKey: 'recordDescriptionLocked_theRescuer',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_theRescuer',
    category: RescueRecordCategory.rescue,
    source: RescueRecordSource.lifetime,
    reveal: RescueRecordReveal.chained,
    targetInt: 25,
    predecessorId: 'familiar-ground',
  );
  static const RescueRecord unbroken = RescueRecord(
    id: 'unbroken',
    titleKey: 'recordTitle_unbroken',
    descriptionLockedKey: 'recordDescriptionLocked_unbroken',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_unbroken',
    category: RescueRecordCategory.rescue,
    source: RescueRecordSource.lifetime,
    reveal: RescueRecordReveal.chained,
    targetInt: 100,
    predecessorId: 'the-rescuer',
  );

  // — Episodes
  static const RescueRecord ep1StrikeBack = RescueRecord(
    id: 'ep1-strike-back',
    titleKey: 'recordTitle_ep1StrikeBack',
    descriptionLockedKey: 'recordDescriptionLocked_ep1StrikeBack',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_ep1StrikeBack',
    category: RescueRecordCategory.episodes,
    source: RescueRecordSource.episodeComplete,
    reveal: RescueRecordReveal.revealed,
    episodeId: 'ep1-strike-back',
  );
  static const RescueRecord ep2EndTheThreat = RescueRecord(
    id: 'ep2-end-the-threat',
    titleKey: 'recordTitle_ep2EndTheThreat',
    descriptionLockedKey: 'recordDescriptionLocked_ep2EndTheThreat',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_ep2EndTheThreat',
    category: RescueRecordCategory.episodes,
    source: RescueRecordSource.episodeComplete,
    reveal: RescueRecordReveal.chained,
    episodeId: 'ep2-end-the-threat',
    predecessorId: 'ep1-strike-back',
  );
  static const RescueRecord ep3HoldTheLine = RescueRecord(
    id: 'ep3-hold-the-line',
    titleKey: 'recordTitle_ep3HoldTheLine',
    descriptionLockedKey: 'recordDescriptionLocked_ep3HoldTheLine',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_ep3HoldTheLine',
    category: RescueRecordCategory.episodes,
    source: RescueRecordSource.episodeComplete,
    reveal: RescueRecordReveal.chained,
    episodeId: 'ep3-hold-the-line',
    predecessorId: 'ep2-end-the-threat',
  );
  // PR-17 — Episode 6 episode-complete record. Chains off ep3.
  static const RescueRecord ep6PinTheThreat = RescueRecord(
    id: 'ep6-pin-the-threat',
    titleKey: 'recordTitle_ep6PinTheThreat',
    descriptionLockedKey: 'recordDescriptionLocked_ep6PinTheThreat',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_ep6PinTheThreat',
    category: RescueRecordCategory.episodes,
    source: RescueRecordSource.episodeComplete,
    reveal: RescueRecordReveal.chained,
    episodeId: 'ep6-pin-the-threat',
    predecessorId: 'ep3-hold-the-line',
  );
  // Ep4 + AtO are eventOnly because completedIds does not track master
  // episode completion. GameController writes both ids when Ep4 finale
  // / first-rescue-after-Ep4 fires.
  static const RescueRecord ep4TheOtherSide = RescueRecord(
    id: 'ep4-the-other-side',
    titleKey: 'recordTitle_ep4TheOtherSide',
    descriptionLockedKey: 'recordDescriptionLocked_ep4TheOtherSide',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_ep4TheOtherSide',
    category: RescueRecordCategory.episodes,
    source: RescueRecordSource.eventOnly,
    reveal: RescueRecordReveal.chained,
    episodeId: 'ep4-the-other-side',
    predecessorId: 'ep3-hold-the-line',
  );
  static const RescueRecord againstTheOdds = RescueRecord(
    id: 'against-the-odds',
    titleKey: 'recordTitle_againstTheOdds',
    descriptionLockedKey: 'recordDescriptionLocked_againstTheOdds',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_againstTheOdds',
    category: RescueRecordCategory.episodes,
    source: RescueRecordSource.eventOnly,
    reveal: RescueRecordReveal.chained,
    predecessorId: 'ep4-the-other-side',
  );

  // — Endless (streak ladder)
  static const RescueRecord endlessSpark = RescueRecord(
    id: 'endless-spark',
    titleKey: 'recordTitle_endlessSpark',
    descriptionLockedKey: 'recordDescriptionLocked_endlessSpark',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_endlessSpark',
    category: RescueRecordCategory.endless,
    source: RescueRecordSource.endlessStreak,
    reveal: RescueRecordReveal.revealed,
    targetInt: 3,
  );
  static const RescueRecord endlessFocus = RescueRecord(
    id: 'endless-focus',
    titleKey: 'recordTitle_endlessFocus',
    descriptionLockedKey: 'recordDescriptionLocked_endlessFocus',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_endlessFocus',
    category: RescueRecordCategory.endless,
    source: RescueRecordSource.endlessStreak,
    reveal: RescueRecordReveal.chained,
    targetInt: 7,
    predecessorId: 'endless-spark',
  );
  static const RescueRecord endlessMaster = RescueRecord(
    id: 'endless-master',
    titleKey: 'recordTitle_endlessMaster',
    descriptionLockedKey: 'recordDescriptionLocked_endlessMaster',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_endlessMaster',
    category: RescueRecordCategory.endless,
    source: RescueRecordSource.endlessStreak,
    reveal: RescueRecordReveal.chained,
    targetInt: 15,
    predecessorId: 'endless-focus',
  );

  // — Mastery (hiddenCategory — the player discovers this category whole)
  static const RescueRecord unshaken = RescueRecord(
    id: 'unshaken',
    titleKey: 'recordTitle_unshaken',
    descriptionLockedKey: 'recordDescriptionLocked_unshaken',
    descriptionUnlockedKey: 'recordDescriptionUnlocked_unshaken',
    category: RescueRecordCategory.mastery,
    source: RescueRecordSource.eventOnly,
    reveal: RescueRecordReveal.hiddenCategory,
  );

  /// The full R1 record library in book order (Rescue → Episodes → Endless
  /// → Mastery).
  static const List<RescueRecord> all = [
    firstRescue,
    familiarGround,
    theRescuer,
    unbroken,
    ep1StrikeBack,
    ep2EndTheThreat,
    ep3HoldTheLine,
    ep6PinTheThreat,
    ep4TheOtherSide,
    againstTheOdds,
    endlessSpark,
    endlessFocus,
    endlessMaster,
    unshaken,
  ];

  static RescueRecord? byId(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<RescueRecord> byCategory(RescueRecordCategory category) => [
    for (final r in all)
      if (r.category == category) r,
  ];

  /// Helper used by the evaluator: which Episode does an episodeComplete
  /// record refer to.
  static Episode? episodeFor(RescueRecord record) {
    final id = record.episodeId;
    if (id == null) return null;
    return EpisodeLibrary.byId(id);
  }
}
