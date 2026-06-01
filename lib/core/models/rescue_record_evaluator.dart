import 'package:flutter/foundation.dart';

import 'episode_library.dart';
import 'rescue_record.dart';
import 'rescue_record_library.dart';

/// Pure-function snapshot of every signal the R1 evaluator needs.
///
/// Built by the caller (GameController for in-play evaluation, Home for the
/// preview, the sheet for rendering) — the evaluator itself does no I/O and
/// reads nothing from the ProgressStore directly.
@immutable
class RescueRecordSnapshot {
  const RescueRecordSnapshot({
    required this.lifetimeSaved,
    required this.bestEndlessStreak,
    required this.currentEndlessStreakPeak,
    required this.completedIds,
    required this.unlockedRecords,
  });

  final int lifetimeSaved;
  final int bestEndlessStreak;

  /// In-memory peak of the current Ep5 streak. Lets the evaluator catch
  /// streak-tier crossings BEFORE the persisted `bestEndlessStreak` is
  /// updated (which happens only on streak-end or controller dispose).
  /// Pass 0 outside of Ep5.
  final int currentEndlessStreakPeak;

  /// Canonical-base puzzle ids ever completed. Used for episodeComplete
  /// records (Ep1-3 via EpisodeLibrary.progressFor).
  final Set<String> completedIds;

  /// Record ids the controller has already persisted as unlocked. Used as
  /// the truth-source for eventOnly records (Ep4, AtO, Unshaken). NOT used
  /// to decide isUnlocked for lifetime/endlessStreak/episodeComplete
  /// records — those are derived independently.
  final Set<String> unlockedRecords;
}

/// Pure evaluator. Returns one state-per-record in the library's book order.
List<RescueRecordState> evaluateRecords(RescueRecordSnapshot snapshot) {
  return [
    for (final record in RescueRecordLibrary.all) _evaluate(record, snapshot),
  ];
}

/// Convenience helper: returns the list of newly-unlocked record ids when
/// transitioning from one snapshot to another. Used by the controller's
/// post-rescue diff: snapshot the unlock set before, run the rescue, take a
/// new snapshot, diff. Preserves library order (so Recently Written reads
/// "last added" correctly).
List<String> newlyUnlocked(
  RescueRecordSnapshot before,
  RescueRecordSnapshot after,
) {
  final beforeStates = {
    for (final s in evaluateRecords(before)) s.record.id: s.isUnlocked,
  };
  final out = <String>[];
  for (final s in evaluateRecords(after)) {
    if (s.isUnlocked && (beforeStates[s.record.id] ?? false) == false) {
      out.add(s.record.id);
    }
  }
  return out;
}

RescueRecordState _evaluate(
  RescueRecord record,
  RescueRecordSnapshot snapshot,
) {
  final isUnlocked = _isUnlocked(record, snapshot);
  final progressTuple = _progressFor(record, snapshot);
  return RescueRecordState(
    record: record,
    isUnlocked: isUnlocked,
    isVisible: _isVisible(record, snapshot, isUnlocked),
    currentProgress: progressTuple.$1,
    targetProgress: progressTuple.$2,
  );
}

bool _isUnlocked(RescueRecord record, RescueRecordSnapshot s) {
  switch (record.source) {
    case RescueRecordSource.lifetime:
      return s.lifetimeSaved >= (record.targetInt ?? 0);
    case RescueRecordSource.endlessStreak:
      final peak = s.bestEndlessStreak > s.currentEndlessStreakPeak
          ? s.bestEndlessStreak
          : s.currentEndlessStreakPeak;
      return peak >= (record.targetInt ?? 0);
    case RescueRecordSource.episodeComplete:
      final episode = RescueRecordLibrary.episodeFor(record);
      if (episode == null) return false;
      return EpisodeLibrary.progressFor(episode, s.completedIds).isComplete;
    case RescueRecordSource.eventOnly:
      return s.unlockedRecords.contains(record.id);
  }
}

(int, int) _progressFor(RescueRecord record, RescueRecordSnapshot s) {
  switch (record.source) {
    case RescueRecordSource.lifetime:
      final target = record.targetInt ?? 0;
      final current = s.lifetimeSaved.clamp(0, target);
      return (current, target);
    case RescueRecordSource.endlessStreak:
      final target = record.targetInt ?? 0;
      final peak = s.bestEndlessStreak > s.currentEndlessStreakPeak
          ? s.bestEndlessStreak
          : s.currentEndlessStreakPeak;
      final current = peak.clamp(0, target);
      return (current, target);
    case RescueRecordSource.episodeComplete:
    case RescueRecordSource.eventOnly:
      return (0, 0); // not numerically progressed; UI shows description only
  }
}

bool _isVisible(RescueRecord record, RescueRecordSnapshot s, bool isUnlocked) {
  // Always show unlocked records (regardless of reveal mode — earning the
  // record makes its row visible permanently).
  if (isUnlocked) return true;

  switch (record.reveal) {
    case RescueRecordReveal.revealed:
      return true;
    case RescueRecordReveal.chained:
      final predId = record.predecessorId;
      if (predId == null) return true;
      // Visible only once the predecessor has been earned (which makes that
      // predecessor's own row unlocked and visible).
      final pred = RescueRecordLibrary.byId(predId);
      if (pred == null) return false;
      return _isUnlocked(pred, s);
    case RescueRecordReveal.hiddenCategory:
      // Entire category hidden until ANY record in that category is earned.
      for (final r in RescueRecordLibrary.byCategory(record.category)) {
        if (_isUnlocked(r, s)) return true;
      }
      return false;
  }
}
