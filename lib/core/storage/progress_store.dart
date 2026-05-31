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

  Future<void> clear() async {
    await _prefs.remove(_kSessionSeed);
    await _prefs.remove(_kIndex);
    await _prefs.remove(_kCompleted);
    await _prefs.remove(_kOnboarding);
    await _prefs.remove(_kIntroSeen);
    await _prefs.remove(_kLanguageMode);
    await _prefs.remove(_kLifetimeSaved);
  }
}
