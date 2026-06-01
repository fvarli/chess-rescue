import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> addUnlockedRecord(String id) async {
    final current = unlockedRecords;
    if (current.contains(id)) return;
    final next = [...current, id];
    await _prefs.setString(_kUnlockedRecords, json.encode(next));
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
  }
}
