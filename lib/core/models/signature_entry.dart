/// A single entry in the player's Signature Rescues collection (PR 1
/// storage substrate for the Signatures system).
///
/// Identity is the canonical puzzle id — two entries with the same
/// canonical id are considered equal regardless of when or how they were
/// adopted. This enforces the canonical-dedupe rule at the type level:
/// a player cannot signature both a puzzle and its mirror variant.
///
/// PR 2 surfaces these entries in the SIGNATURES tab; PR 1 only collects
/// them.
class SignatureEntry {
  const SignatureEntry({
    required this.canonicalPuzzleId,
    required this.encounteredPuzzleId,
    required this.episodeId,
    required this.adoptedAt,
    this.endlessSeed,
    this.endlessMirrored,
  });

  /// The base id with any `#variation` suffix stripped. Identity + dedupe
  /// key.
  final String canonicalPuzzleId;

  /// The id as actually played — may include a `#mirror` suffix.
  /// Preserved so PR 2's detail page renders the version the player
  /// actually encountered.
  final String encounteredPuzzleId;

  final String episodeId;
  final DateTime adoptedAt;

  /// Endless-only context: the SessionComposer seed under which this
  /// rendered instance was generated. Null for canonical / master
  /// episodes. PR 2 will add texture/scenery seeds as forward-compatible
  /// optional fields without breaking the JSON shape PR 1 persists.
  final int? endlessSeed;

  /// Endless-only context: whether the encountered instance was the
  /// mirror variant. Null outside Endless. (Mirror variants in canonical
  /// episodes are encoded in [encounteredPuzzleId] via the `#mirror`
  /// suffix, not this flag.)
  final bool? endlessMirrored;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'canonicalPuzzleId': canonicalPuzzleId,
    'encounteredPuzzleId': encounteredPuzzleId,
    'episodeId': episodeId,
    'adoptedAt': adoptedAt.toUtc().toIso8601String(),
    'endlessSeed': endlessSeed,
    'endlessMirrored': endlessMirrored,
  };

  factory SignatureEntry.fromJson(Map<String, dynamic> json) => SignatureEntry(
    canonicalPuzzleId: json['canonicalPuzzleId'] as String,
    encounteredPuzzleId: json['encounteredPuzzleId'] as String,
    episodeId: json['episodeId'] as String,
    adoptedAt: DateTime.parse(json['adoptedAt'] as String),
    endlessSeed: json['endlessSeed'] as int?,
    endlessMirrored: json['endlessMirrored'] as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignatureEntry && other.canonicalPuzzleId == canonicalPuzzleId;

  @override
  int get hashCode => canonicalPuzzleId.hashCode;
}
