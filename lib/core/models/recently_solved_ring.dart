import 'recently_solved_entry.dart';

/// A fixed-capacity ring buffer of [RecentlySolvedEntry] ordered
/// newest-first.
///
/// Invariants enforced by [insert]:
///
/// 1. Capacity is [capacity] (7 in V1). Insertion beyond capacity drops
///    the oldest (tail) entry.
/// 2. The canonical puzzle id is unique inside the ring. Re-inserting
///    an already-present id is a *move-to-front* — the existing entry
///    is removed from its current position and the new entry inserted
///    at index 0.
/// 3. Order is recency: index 0 is most recent, index `length-1` is
///    oldest.
///
/// [visibleExcluding] is the render-time helper PR 2 will call to skip
/// rows whose canonical id is already saved as a Signature.
class RecentlySolvedRing {
  RecentlySolvedRing(List<RecentlySolvedEntry> entries)
    : _entries = List<RecentlySolvedEntry>.unmodifiable(entries);

  static const int capacity = 7;

  final List<RecentlySolvedEntry> _entries;

  List<RecentlySolvedEntry> get entries => _entries;

  /// Insert [entry] at the front. If [entry.canonicalPuzzleId] already
  /// exists in the ring, the existing entry is removed before the
  /// insert (move-to-front). After insertion, the ring is truncated to
  /// [capacity] from the tail (oldest dropped).
  RecentlySolvedRing insert(RecentlySolvedEntry entry) {
    final next = <RecentlySolvedEntry>[
      entry,
      for (final e in _entries)
        if (e.canonicalPuzzleId != entry.canonicalPuzzleId) e,
    ];
    if (next.length > capacity) {
      return RecentlySolvedRing(next.sublist(0, capacity));
    }
    return RecentlySolvedRing(next);
  }

  /// Returns entries whose canonical id is NOT in [savedCanonicalIds],
  /// preserving order. PR 2 calls this so the SIGNATURES tab's
  /// recently-solved section doesn't offer to re-bookmark a puzzle the
  /// player has already saved.
  List<RecentlySolvedEntry> visibleExcluding(Set<String> savedCanonicalIds) =>
      <RecentlySolvedEntry>[
        for (final e in _entries)
          if (!savedCanonicalIds.contains(e.canonicalPuzzleId)) e,
      ];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'entries': <Map<String, dynamic>>[for (final e in _entries) e.toJson()],
  };

  factory RecentlySolvedRing.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'];
    if (raw is! List) return RecentlySolvedRing.empty();
    final parsed = <RecentlySolvedEntry>[
      for (final item in raw)
        if (item is Map)
          RecentlySolvedEntry.fromJson(item.cast<String, dynamic>()),
    ];
    return RecentlySolvedRing(parsed);
  }

  factory RecentlySolvedRing.empty() =>
      RecentlySolvedRing(const <RecentlySolvedEntry>[]);
}
