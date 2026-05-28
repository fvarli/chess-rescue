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

  Future<void> clear() async {
    await _prefs.remove(_kSessionSeed);
    await _prefs.remove(_kIndex);
    await _prefs.remove(_kCompleted);
    await _prefs.remove(_kOnboarding);
  }
}
