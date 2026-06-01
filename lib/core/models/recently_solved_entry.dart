/// A single entry in the recently-solved ring buffer (PR 1 storage
/// substrate for PR 2's retroactive adoption section in the SIGNATURES
/// tab).
///
/// Shape mirrors [SignatureEntry] but with [solvedAt] in place of
/// `adoptedAt`. Kept intentionally separate from [SignatureEntry]
/// because the lifecycles differ — recently-solved rotates out of a
/// fixed-capacity ring; signatures persist until explicitly removed.
/// Conflating the two would couple PR 2's retroactive-adoption surface
/// to the signatures store in ways that would need to be unwound.
///
/// Identity is the canonical puzzle id (same dedupe contract as
/// [SignatureEntry]), which the [RecentlySolvedRing] uses for its
/// move-to-front insert rule.
class RecentlySolvedEntry {
  const RecentlySolvedEntry({
    required this.canonicalPuzzleId,
    required this.encounteredPuzzleId,
    required this.episodeId,
    required this.solvedAt,
    this.endlessSeed,
    this.endlessMirrored,
  });

  final String canonicalPuzzleId;
  final String encounteredPuzzleId;
  final String episodeId;
  final DateTime solvedAt;
  final int? endlessSeed;
  final bool? endlessMirrored;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'canonicalPuzzleId': canonicalPuzzleId,
    'encounteredPuzzleId': encounteredPuzzleId,
    'episodeId': episodeId,
    'solvedAt': solvedAt.toUtc().toIso8601String(),
    'endlessSeed': endlessSeed,
    'endlessMirrored': endlessMirrored,
  };

  factory RecentlySolvedEntry.fromJson(Map<String, dynamic> json) =>
      RecentlySolvedEntry(
        canonicalPuzzleId: json['canonicalPuzzleId'] as String,
        encounteredPuzzleId: json['encounteredPuzzleId'] as String,
        episodeId: json['episodeId'] as String,
        solvedAt: DateTime.parse(json['solvedAt'] as String),
        endlessSeed: json['endlessSeed'] as int?,
        endlessMirrored: json['endlessMirrored'] as bool?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentlySolvedEntry &&
          other.canonicalPuzzleId == canonicalPuzzleId;

  @override
  int get hashCode => canonicalPuzzleId.hashCode;
}
