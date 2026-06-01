import 'package:flutter/foundation.dart';

/// R1 records — recognition layer ("Rescue Records").
///
/// A record describes a milestone that the player can earn from existing
/// gameplay signals (lifetime rescues, endless-streak peak, episode
/// completion, or a controller-detected event). Records carry no XP, no
/// currency, no rewards — only acknowledgement and chronology.
enum RescueRecordCategory { rescue, episodes, endless, mastery }

/// How a record's unlock condition is detected.
///
/// - [lifetime]: `store.lifetimeSaved >= record.targetInt`
/// - [endlessStreak]: `max(store.bestEndlessStreak, currentEndlessStreakPeak) >= record.targetInt`
/// - [episodeComplete]: the episode identified by [Episode.id] in
///   `record.episodeId` is complete (derived via EpisodeLibrary.progressFor
///   against the global `completedIds` set)
/// - [eventOnly]: never derived; only true when `record.id` is present in
///   `store.unlockedRecords`. The GameController is responsible for writing
///   the id at the unlock moment (used for The Other Side, Against the
///   Odds, and Unshaken)
enum RescueRecordSource { lifetime, endlessStreak, episodeComplete, eventOnly }

/// How a record appears in the sheet before it's earned.
///
/// - [revealed]: visible from boot with its title + locked description
/// - [chained]: hidden until the record named in [predecessorId] is
///   unlocked; then renders as a mystery row (`??? / Unknown Record.`)
///   until earned, then blooms open
/// - [hiddenCategory]: the entire category is absent from the sheet's
///   rendered tree until ANY record in that category is earned. Used for
///   Mastery in R1 — the player discovers the category whole
enum RescueRecordReveal { revealed, chained, hiddenCategory }

@immutable
class RescueRecord {
  const RescueRecord({
    required this.id,
    required this.titleKey,
    required this.descriptionLockedKey,
    required this.descriptionUnlockedKey,
    required this.category,
    required this.source,
    required this.reveal,
    this.targetInt,
    this.episodeId,
    this.predecessorId,
  });

  /// Stable id — used as the JSON entry in `cr_unlocked_records` and as the
  /// look-up key in the library.
  final String id;

  /// AppL10n key for the record's title (sentence case, no period).
  final String titleKey;

  /// AppL10n key for the imperative "Complete X." locked-state description.
  final String descriptionLockedKey;

  /// AppL10n key for the past-tense "Cleared X." unlocked-state description.
  /// The diary register.
  final String descriptionUnlockedKey;

  final RescueRecordCategory category;
  final RescueRecordSource source;
  final RescueRecordReveal reveal;

  /// Threshold for [lifetime] and [endlessStreak] sources. Null otherwise.
  final int? targetInt;

  /// Required Episode id for [episodeComplete] source. Null otherwise.
  final String? episodeId;

  /// Required predecessor id for [chained] reveal. Null for [revealed] and
  /// [hiddenCategory].
  final String? predecessorId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RescueRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Pure value type carrying a record's display + derivation result for one
/// snapshot of progress.
@immutable
class RescueRecordState {
  const RescueRecordState({
    required this.record,
    required this.isUnlocked,
    required this.isVisible,
    required this.currentProgress,
    required this.targetProgress,
  });

  final RescueRecord record;

  /// True if the player has earned this record.
  final bool isUnlocked;

  /// True if the record should be rendered in the sheet/preview at all.
  /// Combines [RescueRecord.reveal] rules + the unlock state of any
  /// predecessor / category gate.
  final bool isVisible;

  /// 0 when not applicable (e.g. eventOnly records, master/endless records).
  final int currentProgress;

  /// 0 when not applicable. For [lifetime] / [endlessStreak] this is the
  /// record's threshold; for [episodeComplete] it's 1 (complete or not).
  final int targetProgress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RescueRecordState &&
          other.record == record &&
          other.isUnlocked == isUnlocked &&
          other.isVisible == isVisible &&
          other.currentProgress == currentProgress &&
          other.targetProgress == targetProgress;

  @override
  int get hashCode => Object.hash(
    record,
    isUnlocked,
    isVisible,
    currentProgress,
    targetProgress,
  );
}
