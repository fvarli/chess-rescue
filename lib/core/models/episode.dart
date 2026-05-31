import 'package:flutter/foundation.dart';

import 'rescue_archetype.dart';

enum EpisodeKind { canonical, master, endless }

@immutable
class Episode {
  const Episode({
    required this.id,
    required this.number,
    required this.titleKey,
    required this.taglineKey,
    required this.kind,
    required this.archetypes,
    required this.canonicalPuzzleIds,
    required this.unlockRequirementId,
  });

  final String id;
  final int number;
  final String titleKey;
  final String taglineKey;
  final EpisodeKind kind;
  final Set<RescueArchetype> archetypes;
  final List<String> canonicalPuzzleIds;
  final String? unlockRequirementId;

  int get puzzleCount =>
      kind == EpisodeKind.endless ? 5 : canonicalPuzzleIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Episode && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class EpisodeProgress {
  const EpisodeProgress({
    required this.completedCount,
    required this.isComplete,
    required this.isUnlocked,
  });

  final int completedCount;
  final bool isComplete;
  final bool isUnlocked;

  static const empty = EpisodeProgress(
    completedCount: 0,
    isComplete: false,
    isUnlocked: false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeProgress &&
          other.completedCount == completedCount &&
          other.isComplete == isComplete &&
          other.isUnlocked == isUnlocked;

  @override
  int get hashCode => Object.hash(completedCount, isComplete, isUnlocked);
}
