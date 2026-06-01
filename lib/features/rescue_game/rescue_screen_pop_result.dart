import 'package:flutter/foundation.dart';

/// Result returned from `Navigator.maybePop` when leaving the RescueScreen.
///
/// Extends the P3.1 `bool` finale-signal: in addition to the
/// canonical/master episode finale flag, the player may also have unlocked
/// new Rescue Records during the session. R1B's HomeScreen reads
/// [newlyUnlockedRecordIds] to set the `_sessionJustUnlocked` flag that
/// drives the open-page row's mint glow pulse.
///
/// A `null` pop result still means "system back gesture" — the Home await
/// handler must guard against it.
@immutable
class RescueScreenPopResult {
  const RescueScreenPopResult({
    required this.finishedEpisode,
    required this.newlyUnlockedRecordIds,
  });

  /// True iff the player tapped the EpisodeCompletionSheet's Continue CTA on
  /// a canonical/master episode finale — drives Home's auto-focus-next P3.1
  /// behaviour.
  final bool finishedEpisode;

  /// Record ids unlocked during this RescueScreen session, in chronological
  /// order (earliest first). Empty when no records were earned. Includes
  /// both mid-rescue records (lifetime / endless / etc.) and finale records
  /// (Strike Back, Unshaken, The Other Side, Against the Odds).
  final List<String> newlyUnlockedRecordIds;
}
