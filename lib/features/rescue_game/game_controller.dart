import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/haptics.dart';
import '../../core/models/piece.dart';
import '../../core/models/puzzle.dart';
import '../../core/models/square.dart';
import '../../core/theme/motion.dart';
import 'game_state.dart';

class GameController extends ChangeNotifier {
  GameController({Puzzle puzzle = Puzzle.knightRescue}) : _puzzle = puzzle {
    _pieces = List<Piece>.of(_puzzle.pieces);
    _statusMsg = '▮ Active threat · Qg2#';
  }

  final Puzzle _puzzle;
  Puzzle get puzzle => _puzzle;

  late List<Piece> _pieces;
  Piece? _selected;
  GameState _state = GameState.danger;
  String _statusMsg = '';
  List<Square> _legalSquares = const [];
  bool _commitInFlight = false;
  bool _resetInFlight = false;

  List<Piece> get pieces => _pieces;
  Piece? get selected => _selected;
  GameState get state => _state;
  String get statusMsg => _statusMsg;
  List<Square> get legalSquares => _legalSquares;
  bool get commitInFlight => _commitInFlight;
  bool get resetInFlight => _resetInFlight;

  // For the vertical slice only the rescuing knight (e4) responds to taps.
  // The 8 destinations mirror playable.jsx:14-25 — f6 is the rescue,
  // the rest are decoys that resolve to `failed`.
  List<Square> _legalMovesFor(Piece p) {
    if (p.type == PieceType.knight &&
        p.color == PieceColor.light &&
        p.file == 4 &&
        p.rank == 3) {
      return const [
        Square(5, 5), // f6 — RESCUE
        Square(3, 5), // d6
        Square(2, 4), // c5
        Square(2, 2), // c3
        Square(3, 1), // d2 (own pawn, decoy)
        Square(5, 1), // f2 (own pawn, decoy)
        Square(6, 2), // g3
        Square(6, 4), // g5
      ];
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

    // Re-select case: tapping a different (rescuing) light piece while one is selected.
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
      final isLegal = _legalSquares.contains(target);
      if (!isLegal) {
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

    // Initial selection — only pieces with legal moves are tappable.
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

  // Phase 11 commit flow:
  // t=0:    tap haptic + windUp (ring contracts, dots fade out)
  // t=80:   apply move; AnimatedPositioned slides the piece
  // t=300:  outcome state + outcome haptic + glow ignition
  Future<void> _commitMove(Square target) async {
    final from = _selected!;
    _commitInFlight = true;
    Haptics.commitTap();
    // Clear legal squares immediately so dots fade out.
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
    // Keep _selected set during the slide so the ring stays visible —
    // BoardWidget reads commitInFlight to know to contract+fade the ring.
    notifyListeners();

    await Future<void>.delayed(MotionTokens.pieceSlide);

    final isRescue =
        target == _puzzle.rescueTo &&
        from.type == PieceType.knight &&
        from.file == _puzzle.rescueFrom.file &&
        from.rank == _puzzle.rescueFrom.rank;

    _selected = null;
    _commitInFlight = false;
    if (isRescue) {
      _state = GameState.rescued;
      _statusMsg = '◐ Attack broken · Nf6+';
      Haptics.rescue();
    } else {
      _state = GameState.failed;
      _statusMsg = '▮ Still trapped';
      Haptics.fail();
    }
    notifyListeners();
  }

  // Phase 11 reset flow (no snap):
  // t=0:    resetInFlight=true → BoardWidget fades the rescue/fail overlay
  // t=200:  pieces + state snap back to canonical; AnimatedPositioned
  //         slides anything that moved (knight back to e4) + state crossfade
  // t=520:  resetInFlight clears, full interactivity restored
  // The button itself plays its haptic — controller does not fire haptic.
  Future<void> reset() async {
    if (_resetInFlight) return;
    _resetInFlight = true;
    notifyListeners();

    await Future<void>.delayed(MotionTokens.resetOverlayFade);

    _pieces = List<Piece>.of(_puzzle.pieces);
    _selected = null;
    _legalSquares = const [];
    _state = GameState.danger;
    _statusMsg = '▮ Active threat · Qg2#';
    _commitInFlight = false;
    notifyListeners();

    await Future<void>.delayed(MotionTokens.resetSettle);
    _resetInFlight = false;
    notifyListeners();
  }
}
