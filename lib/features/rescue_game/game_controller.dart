import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/haptics.dart';
import '../../core/models/piece.dart';
import '../../core/models/puzzle.dart';
import '../../core/models/puzzle_library.dart';
import '../../core/models/square.dart';
import '../../core/models/variation.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/motion.dart';
import 'game_state.dart';

class GameController extends ChangeNotifier {
  GameController({ProgressStore? store}) : _store = store {
    _seed = store?.sessionSeed ?? 0;
    _puzzles = PuzzleLibrary.session(_seed);
    if (store != null) {
      // _completed holds canonical (family) ids; every session's family set is
      // the base ids, so old saves (base ids) restore cleanly.
      final known = {for (final p in _puzzles) canonicalPuzzleId(p.id)};
      _completed.addAll(store.completedIds.where(known.contains));
    }
    _onboarding = (store != null) && !store.onboardingSeen;
    final restored = (store?.puzzleIndex ?? 0).clamp(0, _puzzles.length - 1);
    _loadPuzzle(restored);
  }

  final ProgressStore? _store;
  late int _seed;
  late List<Puzzle> _puzzles;
  int _index = 0;
  final Set<String> _completed = {};
  bool _onboarding = false;

  late List<Piece> _pieces;
  Piece? _selected;
  GameState _state = GameState.danger;
  String _statusMsg = '';
  List<Square> _legalSquares = const [];
  bool _commitInFlight = false;
  bool _resetInFlight = false;

  // — Puzzle sequencing
  Puzzle get currentPuzzle => _puzzles[_index];
  int get puzzleNumber => _index + 1;
  int get puzzleCount => _puzzles.length;
  bool get hasNext => _index < _puzzles.length - 1;
  int get completedCount => _completed.length;
  bool get allComplete => _completed.length == _puzzles.length;

  // Current session seed (Phase 21). 0 = canonical authored session.
  int get sessionSeed => _seed;

  // First-run only. Stays true through the first rescued screen, then ends
  // when the player advances off the first puzzle.
  bool get isOnboarding => _onboarding;

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

  // Whitelisted moves: only the puzzle's designated piece responds, and only
  // with that puzzle's curated destinations. No engine.
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

    // Re-select: tapping the rescuing piece again while one is selected.
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

    // Commit move attempt.
    if (_selected != null) {
      final target = Square(file, rank);
      if (!_legalSquares.contains(target)) {
        // Silent cancel.
        _selected = null;
        _legalSquares = const [];
        _state = GameState.danger;
        notifyListeners();
        return;
      }
      _commitMove(target);
      return;
    }

    // Initial selection — only the designated piece is tappable.
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

  // Commit flow (unchanged Phase 11 timing):
  // t=0: tap haptic + wind-up · t=80: apply move (slide) · t=300: outcome.
  Future<void> _commitMove(Square target) async {
    final from = _selected!;
    _commitInFlight = true;
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
      _completed.add(canonicalPuzzleId(puzzle.id));
      _state = GameState.rescued;
      _statusMsg = '◐ Attack broken';
      Haptics.rescue();
      // Mark the first rescue survived so the cold open never re-triggers,
      // but keep _onboarding true in memory through this rescued screen.
      if (_onboarding) unawaited(_store?.setOnboardingSeen());
      notifyListeners();
      _persist();
      return;
    } else {
      _state = GameState.failed;
      _statusMsg = '▮ Still trapped';
      Haptics.fail();
    }
    notifyListeners();
  }

  // Footer button routing.
  void onPrimaryAction() {
    switch (_state) {
      case GameState.rescued:
        _onboarding = false; // first run ends as the player moves on
        if (hasNext) {
          _loadPuzzle(_index + 1);
        } else {
          // Session complete → rotate to the next curated session (Phase 21).
          _seed += 1;
          _completed.clear();
          _puzzles = PuzzleLibrary.session(_seed);
          _loadPuzzle(0);
        }
        notifyListeners();
        _persist();
        break;
      case GameState.failed:
      case GameState.danger:
      case GameState.selected:
        reset();
        break;
    }
  }

  // Persist the durable progress (session seed + index + canonical completed
  // ids). Transient game state is never saved. Fire-and-forget; null store =
  // no persistence.
  void _persist() {
    unawaited(
      _store?.save(
        sessionSeed: _seed,
        puzzleIndex: _index,
        completedIds: _completed,
      ),
    );
  }

  // Hidden debug action — wipe local progress, return to the canonical first
  // session, and re-arm the cold open.
  Future<void> resetProgress() async {
    if (_commitInFlight || _resetInFlight) return;
    _seed = 0;
    _puzzles = PuzzleLibrary.session(0);
    _completed.clear();
    _onboarding =
        _store != null; // re-arm the cold open (cleared-storage parity)
    _loadPuzzle(0);
    Haptics.resetProgress();
    notifyListeners();
    await _store?.clear();
  }

  // Retry / restart the CURRENT puzzle with the Phase 11 settle animation.
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
