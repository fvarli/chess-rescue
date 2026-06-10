import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recently_solved_entry.dart';
import '../models/recently_solved_ring.dart';
import '../models/signature_entry.dart';

// Tiny domain wrapper over SharedPreferences for offline, local-only progress.
// Persists just the current puzzle index and the set of completed puzzle ids.
// Values are read synchronously after the async create(), so the controller
// can restore state in its constructor. Persistence never leaks past this
// class and the controller.
class ProgressStore {
  ProgressStore._(this._prefs);

  final SharedPreferences _prefs;

  static const String _kSessionSeed = 'cr_session_seed';
  static const String _kIndex = 'cr_puzzle_index';
  static const String _kCompleted = 'cr_completed_ids';
  static const String _kOnboarding = 'cr_onboarding_seen';
  static const String _kIntroSeen = 'cr_intro_seen';
  static const String _kLanguageMode = 'cr_language_mode';
  static const String _kLifetimeSaved = 'cr_lifetime_saved';
  static const String _kCurrentEpisodeId = 'cr_current_episode_id';
  static const String _kEpisodeSeeds = 'cr_episode_seeds';
  static const String _kBestEndlessStreak = 'cr_best_endless_streak';
  static const String _kUnlockedRecords = 'cr_unlocked_records';
  // PR-12 — parallel date map for unlocked records, keyed by record id,
  // values are ISO 8601 UTC timestamps. Append-only; existing
  // [_kUnlockedRecords] remains the source of truth for "is this record
  // unlocked". Legacy unlocks (pre-PR-12) have no entry here — the
  // records sheet renders no date trailer for them.
  static const String _kUnlockedRecordDates = 'cr_unlocked_record_dates';
  // Signature Rescues PR 1 — silent storage substrate for PR 2's UI.
  static const String _kSignatures = 'cr_signatures';
  static const String _kRecentlySolved = 'cr_recently_solved';
  static const String _kSignaturesFirstBookmarkHintSeen =
      'cr_signatures_first_bookmark_hint_seen';
  static const String _kSignaturesTabPulseSeen = 'cr_signatures_tab_pulse_seen';
  // PR 3 Familiarity — single one-time flag for the first-recognition
  // hint. No other storage. The recognition signal itself derives from
  // the existing `completedIds` set (PR 1) and the controller's
  // in-memory `_completed`; nothing is persisted per-puzzle here.
  static const String _kFamiliarityFirstSeenHintSeen =
      'cr_familiarity_first_seen_hint_seen';

  static Future<ProgressStore> create() async =>
      ProgressStore._(await SharedPreferences.getInstance());

  // Current session seed (Phase 21). Absent on old saves → 0 (canonical session).
  int get sessionSeed => _prefs.getInt(_kSessionSeed) ?? 0;

  int get puzzleIndex => _prefs.getInt(_kIndex) ?? 0;

  // Canonical (base) ids completed in the current session.
  Set<String> get completedIds =>
      (_prefs.getStringList(_kCompleted) ?? const <String>[]).toSet();

  // First-run flag. False until the player survives their first rescue.
  bool get onboardingSeen => _prefs.getBool(_kOnboarding) ?? false;

  // First-run intro overlay flag. False until the player taps "Start rescue"
  // on the one-time intro. Kept separate from onboardingSeen (which flips on
  // the first rescue and drives the focus cue) so the cue survives the intro.
  bool get introSeen => _prefs.getBool(_kIntroSeen) ?? false;

  // Player-chosen language behaviour. 'system' (default) defers to the device
  // locale via the existing localeResolutionCallback; 'en'/'tr'/'es' forces
  // the app into that locale regardless of device. Parsed into
  // [AppLanguageMode] at the wiring layer (main.dart).
  String get languageMode => _prefs.getString(_kLanguageMode) ?? 'system';

  // Lifetime rescue count across every session. Independent of the per-session
  // completed-ids set (which clears when a session rotates). Drives the Home
  // screen's "Total rescues" line.
  int get lifetimeSaved => _prefs.getInt(_kLifetimeSaved) ?? 0;

  // Which episode the Home chip-strip currently focuses on. Null until first
  // P3 boot, when GameController seeds it via EpisodeLibrary.firstNonCompleteFor.
  String? get currentEpisodeId => _prefs.getString(_kCurrentEpisodeId);

  // Per-episode rotation seed. Drives canonical-episode replays and Ep5's
  // endless loop. Defaults to an empty map; accessors return 0 for an
  // unseen episode id.
  Map<String, int> get episodeSeeds {
    final raw = _prefs.getString(_kEpisodeSeeds);
    if (raw == null || raw.isEmpty) return const <String, int>{};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        );
      }
    } catch (_) {}
    return const <String, int>{};
  }

  int seedFor(String episodeId) => episodeSeeds[episodeId] ?? 0;

  // Highest consecutive-rescue count ever reached in a single Ep5 visit.
  // Updated via [updateBestEndlessStreak] which takes max(stored, candidate).
  int get bestEndlessStreak => _prefs.getInt(_kBestEndlessStreak) ?? 0;

  // R1 Rescue Records — earned record ids in insertion order. The list is
  // treated as a set for `contains` lookups but preserves order so the
  // Home preview's open-page row can read the last entry. Append-only with
  // at-write dedup; never reordered.
  List<String> get unlockedRecords {
    final raw = _prefs.getString(_kUnlockedRecords);
    if (raw == null || raw.isEmpty) return const <String>[];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const <String>[];
  }

  // Convenience: same data, as a Set for `contains` lookups inside the
  // evaluator. Computed every read — the list is short (<= 13 entries in
  // R1) so the cost is negligible.
  Set<String> get unlockedRecordsSet => unlockedRecords.toSet();

  // PR-12 — per-record unlock timestamps. Sidecar to [unlockedRecords];
  // tolerates gaps (a legacy id present in the list with no entry here
  // simply has no date). Returns the empty map if the key was never
  // written.
  Map<String, DateTime> get unlockedRecordDates {
    final raw = _prefs.getString(_kUnlockedRecordDates);
    if (raw == null || raw.isEmpty) return const <String, DateTime>{};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        final out = <String, DateTime>{};
        for (final entry in decoded.entries) {
          final parsed = DateTime.tryParse(entry.value.toString());
          if (parsed != null) out[entry.key.toString()] = parsed;
        }
        return out;
      }
    } catch (_) {}
    return const <String, DateTime>{};
  }

  // — Signature Rescues PR 1: silent storage substrate. PR 2 surfaces
  // these values in the SIGNATURES tab and bookmark glyph; PR 1 only
  // collects and exposes them.

  // Saved Signature entries in insertion order. Identity is the canonical
  // puzzle id (a puzzle and its mirror share one entry). Same defensive
  // JSON-list pattern as [unlockedRecords].
  List<SignatureEntry> get signatures {
    final raw = _prefs.getString(_kSignatures);
    if (raw == null || raw.isEmpty) return const <SignatureEntry>[];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return <SignatureEntry>[
          for (final item in decoded)
            if (item is Map)
              SignatureEntry.fromJson(item.cast<String, dynamic>()),
        ];
      }
    } catch (_) {}
    return const <SignatureEntry>[];
  }

  // Canonical-id set view for O(1) `contains` lookups (mirrors
  // [unlockedRecordsSet]).
  Set<String> get signaturesCanonicalIds => <String>{
    for (final e in signatures) e.canonicalPuzzleId,
  };

  bool isSignatureSaved(String canonicalId) =>
      signaturesCanonicalIds.contains(canonicalId);

  // Recently-solved ring buffer (cap 7, move-to-front on dedupe). PR 2's
  // SIGNATURES tab renders this below the saved grid as a retroactive
  // adoption fallback.
  RecentlySolvedRing get recentlySolved {
    final raw = _prefs.getString(_kRecentlySolved);
    if (raw == null || raw.isEmpty) return RecentlySolvedRing.empty();
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        return RecentlySolvedRing.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {}
    return RecentlySolvedRing.empty();
  }

  // One-time discovery flags. PR 2 wires them to the inline hint that
  // surfaces after the player's first bookmark and the SIGNATURES tab
  // pulse on the next Records modal open.
  bool get hasSeenSignaturesFirstBookmarkHint =>
      _prefs.getBool(_kSignaturesFirstBookmarkHintSeen) ?? false;

  bool get hasSeenSignaturesTabPulse =>
      _prefs.getBool(_kSignaturesTabPulseSeen) ?? false;

  // PR 3 Familiarity — one-time first-recognition hint flag. False
  // until the player re-encounters their first previously-solved
  // puzzle and the inline overlay fires; permanently true thereafter.
  bool get hasSeenFirstFamiliarityHint =>
      _prefs.getBool(_kFamiliarityFirstSeenHintSeen) ?? false;

  Future<void> save({
    required int sessionSeed,
    required int puzzleIndex,
    required Set<String> completedIds,
  }) async {
    await _prefs.setInt(_kSessionSeed, sessionSeed);
    await _prefs.setInt(_kIndex, puzzleIndex);
    await _prefs.setStringList(_kCompleted, completedIds.toList());
  }

  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_kOnboarding, true);
  }

  Future<void> setIntroSeen() async {
    await _prefs.setBool(_kIntroSeen, true);
  }

  Future<void> setLanguageMode(String mode) async {
    await _prefs.setString(_kLanguageMode, mode);
  }

  Future<void> incrementLifetimeSaved() async {
    await _prefs.setInt(_kLifetimeSaved, lifetimeSaved + 1);
  }

  // Incremental, accumulating write to `cr_completed_ids`. Use this from
  // canonical episode controllers — `save()` writes the whole _completed set,
  // which would partially overwrite other episodes' completions.
  Future<void> addCompletedId(String canonicalId) async {
    final next = {...completedIds, canonicalId}.toList();
    await _prefs.setStringList(_kCompleted, next);
  }

  Future<void> setCurrentEpisodeId(String id) async {
    await _prefs.setString(_kCurrentEpisodeId, id);
  }

  Future<void> setEpisodeSeed(String episodeId, int seed) async {
    final next = Map<String, int>.from(episodeSeeds);
    next[episodeId] = seed;
    await _prefs.setString(_kEpisodeSeeds, json.encode(next));
  }

  // Persist `candidate` as the new best only if it exceeds the stored value.
  Future<void> updateBestEndlessStreak(int candidate) async {
    if (candidate <= bestEndlessStreak) return;
    await _prefs.setInt(_kBestEndlessStreak, candidate);
  }

  // R1 — append a record id to the unlocked-records list if not already
  // present. Insertion order is preserved (the list's last entry is the
  // page the Home preview is currently open at).
  //
  // PR-12 — on every NEW unlock, also write a parallel timestamp into
  // [_kUnlockedRecordDates]. Re-calls for an already-unlocked id are a
  // no-op on both surfaces (the date map preserves the original moment).
  // [now] is parameterised for test determinism (defaults to
  // `DateTime.now().toUtc()`).
  Future<void> addUnlockedRecord(String id, {DateTime? now}) async {
    final current = unlockedRecords;
    if (current.contains(id)) return;
    final next = [...current, id];
    await _prefs.setString(_kUnlockedRecords, json.encode(next));
    final dates = <String, String>{
      for (final e in unlockedRecordDates.entries)
        e.key: e.value.toIso8601String(),
    };
    dates[id] = (now ?? DateTime.now().toUtc()).toIso8601String();
    await _prefs.setString(_kUnlockedRecordDates, json.encode(dates));
  }

  // — Signature Rescues PR 1 writers.

  // Append a Signature with canonical-id dedupe. If a signature with the
  // same canonical id already exists, the call is a no-op (the
  // first-encountered rendered state wins).
  Future<void> addSignature(SignatureEntry entry) async {
    final current = signatures;
    if (current.any((e) => e.canonicalPuzzleId == entry.canonicalPuzzleId)) {
      return;
    }
    final next = <SignatureEntry>[...current, entry];
    await _prefs.setString(
      _kSignatures,
      json.encode(<Map<String, dynamic>>[for (final e in next) e.toJson()]),
    );
  }

  // Remove the Signature matching [canonicalPuzzleId]. No-op if absent.
  Future<void> removeSignature(String canonicalPuzzleId) async {
    final current = signatures;
    if (!current.any((e) => e.canonicalPuzzleId == canonicalPuzzleId)) {
      return;
    }
    final next = <SignatureEntry>[
      for (final e in current)
        if (e.canonicalPuzzleId != canonicalPuzzleId) e,
    ];
    await _prefs.setString(
      _kSignatures,
      json.encode(<Map<String, dynamic>>[for (final e in next) e.toJson()]),
    );
  }

  // Re-insert [entry] at [index] (clamped to the list's current length).
  // Used by PR 2's Undo snackbar to restore a just-removed entry at its
  // original position. PR 1 ships this method even though it has no
  // production caller — its presence is what makes the storage layer
  // undo-safe per the lead's directive.
  Future<void> restoreSignatureAt(int index, SignatureEntry entry) async {
    final current = signatures;
    // Don't reintroduce a duplicate canonical id — silently no-op.
    if (current.any((e) => e.canonicalPuzzleId == entry.canonicalPuzzleId)) {
      return;
    }
    final clampedIndex = index < 0
        ? 0
        : (index > current.length ? current.length : index);
    final next = <SignatureEntry>[...current];
    next.insert(clampedIndex, entry);
    await _prefs.setString(
      _kSignatures,
      json.encode(<Map<String, dynamic>>[for (final e in next) e.toJson()]),
    );
  }

  // Insert [entry] into the recently-solved ring (move-to-front, then
  // truncate to capacity).
  Future<void> recordRecentlySolved(RecentlySolvedEntry entry) async {
    final next = recentlySolved.insert(entry);
    await _prefs.setString(_kRecentlySolved, json.encode(next.toJson()));
  }

  Future<void> markSignaturesFirstBookmarkHintSeen() async {
    await _prefs.setBool(_kSignaturesFirstBookmarkHintSeen, true);
  }

  Future<void> markSignaturesTabPulseSeen() async {
    await _prefs.setBool(_kSignaturesTabPulseSeen, true);
  }

  // PR 3 Familiarity — mark the first-recognition hint as seen.
  // Called by the host (RescueScreen) at the moment it mounts the
  // one-time FamiliarityFirstSeenOverlay, so a mid-fade screen-close
  // does not re-fire the hint on the next rescued state.
  Future<void> markFirstFamiliarityHintSeen() async {
    await _prefs.setBool(_kFamiliarityFirstSeenHintSeen, true);
  }

  Future<void> clear() async {
    await _prefs.remove(_kSessionSeed);
    await _prefs.remove(_kIndex);
    await _prefs.remove(_kCompleted);
    await _prefs.remove(_kOnboarding);
    await _prefs.remove(_kIntroSeen);
    await _prefs.remove(_kLanguageMode);
    await _prefs.remove(_kLifetimeSaved);
    await _prefs.remove(_kCurrentEpisodeId);
    await _prefs.remove(_kEpisodeSeeds);
    await _prefs.remove(_kBestEndlessStreak);
    await _prefs.remove(_kUnlockedRecords);
    await _prefs.remove(_kUnlockedRecordDates);
    await _prefs.remove(_kSignatures);
    await _prefs.remove(_kRecentlySolved);
    await _prefs.remove(_kSignaturesFirstBookmarkHintSeen);
    await _prefs.remove(_kSignaturesTabPulseSeen);
    await _prefs.remove(_kFamiliarityFirstSeenHintSeen);
  }
}
