import 'piece.dart';
import 'square.dart';

// A single curated rescue puzzle. Ships hardcoded — no engine. Each puzzle
// carries its own copy + a whitelisted move set with exactly one rescue.
class Puzzle {
  const Puzzle({
    required this.id,
    required this.title,
    required this.statusText,
    required this.pieces,
    required this.tappableSquare,
    required this.legalMoves,
    required this.rescueTo,
    required this.rescueNotation,
    required this.dangerHint,
    required this.failureHint,
    required this.successExplanation,
    required this.threatenedKing,
    this.isPrototype = false,
  });

  final String id;
  final String title;
  final String statusText; // danger-state status pill
  final List<Piece> pieces;
  final Square tappableSquare; // the only selectable piece
  final List<Square> legalMoves; // whitelist of destinations
  final Square rescueTo; // the one correct destination
  final String rescueNotation; // e.g. 'Nf6+'
  final String dangerHint;
  final String failureHint;
  final String successExplanation; // mono caps, shown when rescued
  final Square threatenedKing; // danger glow + failed flash position
  final bool isPrototype;
}
