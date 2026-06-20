import '../../core/storage/progress_store.dart';
import '../../core/util/relative_time.dart';

// PR-13 — derives "has the player rescued on the current calendar day?"
// from the existing 7-entry [RecentlySolvedRing]. No new storage; the
// signal is true while at least one entry in the ring carries a
// `solvedAt` that falls on today's local calendar day, false otherwise.
//
// Reliability of the proxy:
//   • Every rescue (canonical AND endless) writes to the ring at
//     commit time (game_controller.dart).
//   • The ring cap is 7; today's signal cannot be erased in practice
//     because today's entries are always the most recent.
//   • After midnight, the predicate flips false naturally on the next
//     read. No timer, no reset.
//
// [now] is parameterised for test determinism (mirrors `isToday`'s
// own pattern); production callers omit it.
bool solvedToday(ProgressStore? store, {DateTime? now}) =>
    store?.recentlySolved.entries.any((e) => isToday(e.solvedAt, now: now)) ??
    false;
