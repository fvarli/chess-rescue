import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/models/piece.dart';
import '../../core/models/puzzle.dart';
import '../../core/models/square.dart';
import 'game_state.dart';

class GameController extends ChangeNotifier {
  GameController({Puzzle puzzle = Puzzle.knightRescue}) : _puzzle = puzzle {
    reset();
  }

  final Puzzle _puzzle;
  Puzzle get puzzle => _puzzle;

  late List<Piece> _pieces;
  Piece? _selected;
  GameState _state = GameState.danger;
  String _statusMsg = '';
  List<Square> _legalSquares = const [];
  bool _commitInFlight = false;

  List<Piece> get pieces => _pieces;
  Piece? get selected => _selected;
  GameState get state => _state;
  String get statusMsg => _statusMsg;
  List<Square> get legalSquares => _legalSquares;
  bool get commitInFlight => _commitInFlight;

  static const Duration _commitPause = Duration(milliseconds: 180);

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
    if (_commitInFlight) return;
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
      HapticFeedback.selectionClick();
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
      HapticFeedback.selectionClick();
      notifyListeners();
    }
  }

  Future<void> _commitMove(Square target) async {
    final from = _selected!;
    _commitInFlight = true;
    notifyListeners();

    // 180ms emotional pause before revealing outcome.
    await Future<void>.delayed(_commitPause);

    final isRescue =
        target == _puzzle.rescueTo &&
        from.type == PieceType.knight &&
        from.file == _puzzle.rescueFrom.file &&
        from.rank == _puzzle.rescueFrom.rank;

    // Apply the visual move regardless of outcome.
    final moved = from.copyWith(file: target.file, rank: target.rank);
    _pieces = [
      for (final p in _pieces)
        if (p != from && !(p.file == target.file && p.rank == target.rank)) p,
      moved,
    ];
    _selected = null;
    _legalSquares = const [];
    _commitInFlight = false;

    if (isRescue) {
      _state = GameState.rescued;
      _statusMsg = '◐ Attack broken · Nf6+';
      HapticFeedback.mediumImpact();
    } else {
      _state = GameState.failed;
      _statusMsg = '▮ Still trapped';
      HapticFeedback.heavyImpact();
    }
    notifyListeners();
  }

  void reset() {
    _pieces = List<Piece>.of(_puzzle.pieces);
    _selected = null;
    _legalSquares = const [];
    _state = GameState.danger;
    _statusMsg = '▮ Active threat · Qg2#';
    _commitInFlight = false;
    HapticFeedback.selectionClick();
    notifyListeners();
  }
}
