import '../../../core/models/piece.dart';
import '../../../l10n/gen/app_localizations.dart';

// PR-15 — pure derivations for screen-reader labels. No state, no
// allocations beyond the returned String. All composition happens in
// the helper so the ARB can ship one atomic localized string per
// (color, type) combination — translators control natural word order
// across locales (e.g. Spanish noun-first: "Caballo claro" instead of
// the English "Light knight").

/// Algebraic-notation string for a board square (`'a1'` … `'h8'`).
String squareNotation(int file, int rank) =>
    '${String.fromCharCode(97 + file)}${rank + 1}';

/// Localized screen-reader label for a chess piece, e.g. `'Light knight'`,
/// `'Açık at'`, `'Caballo claro'`.
String pieceA11yLabel(Piece p, AppL10n l) {
  switch (p.color) {
    case PieceColor.light:
      switch (p.type) {
        case PieceType.king:
          return l.a11yPieceLightKing;
        case PieceType.queen:
          return l.a11yPieceLightQueen;
        case PieceType.rook:
          return l.a11yPieceLightRook;
        case PieceType.bishop:
          return l.a11yPieceLightBishop;
        case PieceType.knight:
          return l.a11yPieceLightKnight;
        case PieceType.pawn:
          return l.a11yPieceLightPawn;
      }
    case PieceColor.dark:
      switch (p.type) {
        case PieceType.king:
          return l.a11yPieceDarkKing;
        case PieceType.queen:
          return l.a11yPieceDarkQueen;
        case PieceType.rook:
          return l.a11yPieceDarkRook;
        case PieceType.bishop:
          return l.a11yPieceDarkBishop;
        case PieceType.knight:
          return l.a11yPieceDarkKnight;
        case PieceType.pawn:
          return l.a11yPieceDarkPawn;
      }
  }
}

/// Localized screen-reader label for a board square plus its occupant.
/// Example: `'e4, light knight'` or `'a1, empty'`.
String squareA11yLabel(int file, int rank, Piece? occupant, AppL10n l) {
  final sq = squareNotation(file, rank);
  final occ = occupant == null
      ? l.a11ySquareEmpty
      : pieceA11yLabel(occupant, l);
  return l.a11ySquareLabel(sq, occ);
}
