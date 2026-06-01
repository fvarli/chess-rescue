/// Returns true if [when] falls on the same local calendar day as [now].
///
/// PR 2 V1 surfaces only one relative-time signal: *today*. Anything not
/// today is journal-flavored, rendered without a time fragment — the grid
/// order itself conveys recency. See the Signature Rescues plan §3 for the
/// rationale.
///
/// [now] is parameterised for test determinism (defaults to
/// `DateTime.now()`).
bool isToday(DateTime when, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final whenLocal = when.toLocal();
  final referenceLocal = reference.toLocal();
  return whenLocal.year == referenceLocal.year &&
      whenLocal.month == referenceLocal.month &&
      whenLocal.day == referenceLocal.day;
}
