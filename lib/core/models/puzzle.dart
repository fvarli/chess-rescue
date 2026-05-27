import 'piece.dart';
import 'square.dart';

class Puzzle {
  const Puzzle({
    required this.pieces,
    required this.threatenedKing,
    required this.attackingPiece,
    required this.rescueFrom,
    required this.rescueTo,
  });

  final List<Piece> pieces;
  final Square threatenedKing;
  final Square attackingPiece;
  final Square rescueFrom;
  final Square rescueTo;

  // Canonical "Knight rescue" — transcribed verbatim from
  // docs/components/primitives.jsx:180-210.
  // White king on g1 is mate-threatened (Qg2#). White's knight on e4 plays
  // Nf6+ to break the attack.
  static const Puzzle knightRescue = Puzzle(
    pieces: [
      // Light
      Piece(
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
        rank: 0,
      ), // g1
      Piece(
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 5,
        rank: 1,
      ), // f2
      Piece(
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ), // g2
      Piece(
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ), // h2
      Piece(
        type: PieceType.knight,
        color: PieceColor.light,
        file: 4,
        rank: 3,
      ), // e4
      Piece(
        type: PieceType.bishop,
        color: PieceColor.light,
        file: 2,
        rank: 0,
      ), // c1
      Piece(
        type: PieceType.rook,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      ), // a1
      Piece(
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 0,
        rank: 1,
      ), // a2
      Piece(
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 1,
        rank: 1,
      ), // b2
      // Dark
      Piece(
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ), // g8
      Piece(
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ), // f7
      Piece(
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ), // h7
      Piece(
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 7,
        rank: 2,
      ), // h3
      Piece(
        type: PieceType.rook,
        color: PieceColor.dark,
        file: 4,
        rank: 6,
      ), // e7
      Piece(
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 0,
        rank: 6,
      ), // a7
      Piece(
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 1,
        rank: 6,
      ), // b7
      Piece(
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 2,
        rank: 5,
      ), // c6
      Piece(
        type: PieceType.bishop,
        color: PieceColor.dark,
        file: 5,
        rank: 4,
      ), // f5
    ],
    threatenedKing: Square(6, 0), // g1
    attackingPiece: Square(7, 2), // h3
    rescueFrom: Square(4, 3), // e4
    rescueTo: Square(5, 5), // f6
  );
}
