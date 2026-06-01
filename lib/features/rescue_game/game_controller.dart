import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/haptics.dart';
import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/piece.dart';
import '../../core/models/puzzle.dart';
import '../../core/models/puzzle_library.dart';
import '../../core/models/rescue_record_evaluator.dart';
import '../../core/models/rescue_record_library.dart';
import '../../core/models/session_composer.dart';
import '../../core/models/square.dart';
import '../../core/models/variation.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/motion.dart';
import 'game_state.dart';

class GameController extends ChangeNotifier {
  GameController({ProgressStore? store, Episode? episode})
    : _store = store,
      _episode = episode ?? EpisodeLibrary.first {
    _seed = store?.seedFor(_episode.id) ?? 0;
    _puzzles = SessionComposer.composeEpisode(
      episode: _episode,
      templates: PuzzleLibrary.templates,
      expansion: PuzzleLibrary.expansionTemplates,
      seed: _seed,
    );

    // Restore in-episode progress only for canonical episodes; master/endless
    // start fresh on every entry (their completions don't accumulate in the
    // global set).
    int restored = 0;
    if (store != null && _episode.kind == EpisodeKind.canonical) {
      final known = {for (final p in _puzzles) canonicalPuzzleId(p.id)};
      _completed.addAll(store.completedIds.where(known.contains));
      restored = _puzzles.indexWhere(
        (p) => !_completed.contains(canonicalPuzzleId(p.id)),
      );
      if (restored < 0) restored = _puzzles.length - 1;
    }

    _onboarding = (store != null) && !store.onboardingSeen;
    _introSeen = store?.introSeen ?? true;
    _loadPuzzle(restored);
  }

  final ProgressStore? _store;
  final Episode _episode;
  late int _seed;
  late List<Puzzle> _puzzles;
  int _index = 0;
  final Set<String> _completed = {};
  bool _onboarding = false;
  late bool _introSeen;
  int _currentEndlessStreak = 0;
  // R1 — per-episode failure counter, reset on every `_loadPuzzle`. Used by
  // the Unshaken record (clear an episode with zero wrong moves). Pure
  // in-memory; never persisted.
  int _failureCount = 0;
  // R1B — record ids unlocked on the MOST RECENT _commitMove rescue commit.
  // Cleared at the start of every _commitMove; populated by
  // _persistNewlyUnlockedRecords with the diff result. RescueScreen reads
  // this on each notifyListeners cycle to dispatch records to either the
  // completion-sheet inline section (if isEpisodeFinale) or the mid-rescue
  // overlay queue. Empty in steady state.
  final List<String> _recordsJustUnlocked = <String>[];

  late List<Piece> _pieces;
  Piece? _selected;
  GameState _state = GameState.danger;
  String _statusMsg = '';
  List<Square> _legalSquares = const [];
  bool _commitInFlight = false;
  bool _resetInFlight = false;

  // — Episode + puzzle sequencing
  Episode get episode => _episode;
  Puzzle get currentPuzzle => _puzzles[_index];
  int get puzzleNumber => _index + 1;
  int get puzzleCount => _puzzles.length;
  bool get hasNext => _index < _puzzles.length - 1;
  int get completedCount => _completed.length;
  bool get allComplete => _completed.length == _puzzles.length;
  int get currentEndlessStreak => _currentEndlessStreak;

  /// R1B — record ids unlocked on the most recent rescue commit
  /// (chronological order, library order within the commit). Unmodifiable
  /// view; consumed by RescueScreen.
  List<String> get recordsJustUnlocked =>
      List<String>.unmodifiable(_recordsJustUnlocked);

  int get sessionSeed => _seed;

  bool get isOnboarding => _onboarding;
  bool get showIntro => !_introSeen;

  void dismissIntro() {
    if (_introSeen) return;
    _introSeen = true;
    notifyListeners();
    unawaited(_store?.setIntroSeen());
  }

  // — Game state
  List<Piece> get pieces => _pieces;
  Piece? get selected => _selected;
  GameState get state => _state;
  String get statusMsg => _statusMsg;
  List<Square> get legalSquares => _legalSquares;
  bool get commitInFlight => _commitInFlight;
  bool get resetInFlight => _resetInFlight;

  void _loadPuzzle(int i) {
    _index = i;
    final p = _puzzles[i];
    _pieces = List<Piece>.of(p.pieces);
    _selected = null;
    _legalSquares = const [];
    _state = GameState.danger;
    _statusMsg = p.statusText;
    _commitInFlight = false;
  }

  List<Square> _legalMovesFor(Piece p) {
    final puzzle = currentPuzzle;
    if (p.file == puzzle.tappableSquare.file &&
        p.rank == puzzle.tappableSquare.rank) {
      return puzzle.legalMoves;
    }
    return const [];
  }

  Piece? _pieceAt(int file, int rank) {
    for (final p in _pieces) {
      if (p.file == file && p.rank == rank) return p;
    }
    return null;
  }

  void handleSquare(int file, int rank) {
    if (_commitInFlight || _resetInFlight) return;
    if (!_state.isPlayable) return;

    final tapped = _pieceAt(file, rank);

    if (_selected != null &&
        tapped != null &&
        tapped.color == PieceColor.light &&
        _legalMovesFor(tapped).isNotEmpty) {
      _selected = tapped;
      _legalSquares = _legalMovesFor(tapped);
      _state = GameState.selected;
      Haptics.select();
      notifyListeners();
      return;
    }

    if (_selected != null) {
      final target = Square(file, rank);
      if (!_legalSquares.contains(target)) {
        _selected = null;
        _legalSquares = const [];
        _state = GameState.danger;
        notifyListeners();
        return;
      }
      _commitMove(target);
      return;
    }

    if (tapped != null &&
        tapped.color == PieceColor.light &&
        _legalMovesFor(tapped).isNotEmpty) {
      _selected = tapped;
      _legalSquares = _legalMovesFor(tapped);
      _state = GameState.selected;
      Haptics.select();
      notifyListeners();
    }
  }

  Future<void> _commitMove(Square target) async {
    final from = _selected!;
    _commitInFlight = true;
    _recordsJustUnlocked.clear(); // R1B — reset per-commit record buffer
    Haptics.commitTap();
    _legalSquares = const [];
    notifyListeners();

    await Future<void>.delayed(MotionTokens.commitWindUp);

    final moved = from.copyWith(file: target.file, rank: target.rank);
    _pieces = [
      for (final p in _pieces)
        if (p.id != from.id &&
            !(p.file == target.file && p.rank == target.rank))
          p,
      moved,
    ];
    notifyListeners();

    await Future<void>.delayed(MotionTokens.pieceSlide);

    final puzzle = currentPuzzle;
    final isRescue = target == puzzle.rescueTo;

    _selected = null;
    _commitInFlight = false;
    if (isRescue) {
      // R1 — snapshot pre-rescue state BEFORE any side-effects, so the
      // evaluator diff sees a clean "before" vs the derived "after".
      final preLifetime = _store?.lifetimeSaved ?? 0;
      final preStreak = _currentEndlessStreak;
      final preCompleted = _store?.completedIds ?? const <String>{};
      final preUnlocked = _store?.unlockedRecordsSet ?? const <String>{};

      final base = canonicalPuzzleId(puzzle.id);
      _completed.add(base);
      _state = GameState.rescued;
      _statusMsg = '◐ Attack broken';
      Haptics.rescue();
      if (_onboarding) unawaited(_store?.setOnboardingSeen());
      // Lifetime counter fires for every rescue across every episode kind.
      unawaited(_store?.incrementLifetimeSaved());
      // Canonical episodes accumulate canonical-base completions into the
      // global set; master and endless leave no per-puzzle footprint.
      if (_episode.kind == EpisodeKind.canonical) {
        unawaited(_store?.addCompletedId(base));
      }
      // Endless streak: increment on each rescue; persist on streak-end only.
      if (_episode.kind == EpisodeKind.endless) {
        _currentEndlessStreak += 1;
      }
      // R1 — derive post-rescue state, apply event-only writes (Unshaken /
      // Ep4 / Against the Odds), run the evaluator diff against the pre
      // snapshot, persist each newly unlocked id.
      _persistNewlyUnlockedRecords(
        preLifetime: preLifetime,
        preStreak: preStreak,
        preCompleted: preCompleted,
        preUnlocked: preUnlocked,
        rescuedBase: base,
      );
      notifyListeners();
      return;
    } else {
      _state = GameState.failed;
      _statusMsg = '▮ Still trapped';
      Haptics.fail();
      _failureCount += 1; // R1 — drives the Unshaken / Mastery test
      // A failed move ends an in-progress endless streak.
      if (_episode.kind == EpisodeKind.endless) {
        _endEndlessStreak();
      }
    }
    notifyListeners();
  }

  // R1 — derive the post-rescue snapshot (incl. event-only Unshaken / Ep4 /
  // Against the Odds writes), diff against the pre snapshot, and persist
  // every newly unlocked record id via the store's addUnlockedRecord. Order
  // of insertion is preserved (library order via the evaluator).
  void _persistNewlyUnlockedRecords({
    required int preLifetime,
    required int preStreak,
    required Set<String> preCompleted,
    required Set<String> preUnlocked,
    required String rescuedBase,
  }) {
    final before = RescueRecordSnapshot(
      lifetimeSaved: preLifetime,
      bestEndlessStreak: _store?.bestEndlessStreak ?? 0,
      currentEndlessStreakPeak: preStreak,
      completedIds: preCompleted,
      unlockedRecords: preUnlocked,
    );

    final completedAfter = _episode.kind == EpisodeKind.canonical
        ? {...preCompleted, rescuedBase}
        : preCompleted;
    final unlockedAfter = {...preUnlocked};

    // Event-only finale writes (canonical or master episodes — endless
    // never reaches a finale).
    final isCanonicalOrMasterFinale =
        _completed.length == _puzzles.length &&
        _episode.kind != EpisodeKind.endless;
    if (isCanonicalOrMasterFinale && _failureCount == 0) {
      unlockedAfter.add(RescueRecordLibrary.unshaken.id);
    }
    if (isCanonicalOrMasterFinale && _episode.kind == EpisodeKind.master) {
      unlockedAfter.add(RescueRecordLibrary.ep4TheOtherSide.id);
    }
    // Against the Odds: the first rescue after Ep4 has ever been earned.
    if (preUnlocked.contains(RescueRecordLibrary.ep4TheOtherSide.id) &&
        !unlockedAfter.contains(RescueRecordLibrary.againstTheOdds.id)) {
      unlockedAfter.add(RescueRecordLibrary.againstTheOdds.id);
    }

    final after = RescueRecordSnapshot(
      lifetimeSaved: preLifetime + 1,
      bestEndlessStreak: _store?.bestEndlessStreak ?? 0,
      currentEndlessStreakPeak: _currentEndlessStreak,
      completedIds: completedAfter,
      unlockedRecords: unlockedAfter,
    );

    final newIds = newlyUnlocked(before, after);
    for (final id in newIds) {
      unawaited(_store?.addUnlockedRecord(id));
    }
    // R1B — also surface to the per-commit buffer for RescueScreen.
    _recordsJustUnlocked.addAll(newIds);
  }

  // True when the player has just rescued the last puzzle of a canonical or
  // master episode. RescueScreen reads this to render the "Back to Home"
  // footer; the tap pops the navigator rather than routing through this
  // controller. (Endless episodes never reach this state — they rotate seeds
  // on the final rescue and keep playing.)
  bool get isEpisodeFinale =>
      _state == GameState.rescued &&
      allComplete &&
      _episode.kind != EpisodeKind.endless;

  void onPrimaryAction() {
    switch (_state) {
      case GameState.rescued:
        _onboarding = false;
        if (allComplete) {
          if (_episode.kind == EpisodeKind.endless) {
            // Rotate seed inline; streak continues across rotations.
            _seed += 1;
            _completed.clear();
            _puzzles = SessionComposer.composeEpisode(
              episode: _episode,
              templates: PuzzleLibrary.templates,
              expansion: PuzzleLibrary.expansionTemplates,
              seed: _seed,
            );
            unawaited(_store?.setEpisodeSeed(_episode.id, _seed));
            _loadPuzzle(0);
            notifyListeners();
          }
          // canonical / master finale: RescueScreen handles the pop on its
          // own footer tap — this controller does nothing further.
          return;
        }
        _loadPuzzle(_index + 1);
        notifyListeners();
        break;
      case GameState.failed:
      case GameState.danger:
      case GameState.selected:
        reset();
        break;
    }
  }

  void _endEndlessStreak() {
    if (_currentEndlessStreak <= 0) return;
    unawaited(_store?.updateBestEndlessStreak(_currentEndlessStreak));
    _currentEndlessStreak = 0;
  }

  @override
  void dispose() {
    // Leaving an endless episode (controller disposed) ends the current streak.
    if (_episode.kind == EpisodeKind.endless) {
      _endEndlessStreak();
    }
    super.dispose();
  }

  Future<void> resetProgress() async {
    if (_commitInFlight || _resetInFlight) return;
    _seed = 0;
    _puzzles = SessionComposer.composeEpisode(
      episode: _episode,
      templates: PuzzleLibrary.templates,
      expansion: PuzzleLibrary.expansionTemplates,
      seed: 0,
    );
    _completed.clear();
    _currentEndlessStreak = 0;
    _failureCount = 0; // R1 — debug-reset also clears the Mastery counter
    _onboarding = _store != null;
    _introSeen = _store == null;
    _loadPuzzle(0);
    Haptics.resetProgress();
    notifyListeners();
    await _store?.clear();
  }

  Future<void> reset() async {
    if (_resetInFlight) return;
    _resetInFlight = true;
    notifyListeners();

    await Future<void>.delayed(MotionTokens.resetOverlayFade);

    final p = currentPuzzle;
    _pieces = List<Piece>.of(p.pieces);
    _selected = null;
    _legalSquares = const [];
    _state = GameState.danger;
    _statusMsg = p.statusText;
    _commitInFlight = false;
    notifyListeners();

    await Future<void>.delayed(MotionTokens.resetSettle);
    _resetInFlight = false;
    notifyListeners();
  }
}
