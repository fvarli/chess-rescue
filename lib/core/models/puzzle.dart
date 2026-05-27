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
  // Ids are <color><type>-<origin-square> so AnimatedPositioned can track
  // each piece across moves.
  static const Puzzle knightRescue = Puzzle(
    pieces: [
      // Light
      Piece(
        id: 'wK-g1',
        type: PieceType.king,
        color: PieceColor.light,
        file: 6,
        rank: 0,
      ),
      Piece(
        id: 'wP-f2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 5,
        rank: 1,
      ),
      Piece(
        id: 'wP-g2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 6,
        rank: 1,
      ),
      Piece(
        id: 'wP-h2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 7,
        rank: 1,
      ),
      Piece(
        id: 'wN-e4',
        type: PieceType.knight,
        color: PieceColor.light,
        file: 4,
        rank: 3,
      ),
      Piece(
        id: 'wB-c1',
        type: PieceType.bishop,
        color: PieceColor.light,
        file: 2,
        rank: 0,
      ),
      Piece(
        id: 'wR-a1',
        type: PieceType.rook,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      ),
      Piece(
        id: 'wP-a2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 0,
        rank: 1,
      ),
      Piece(
        id: 'wP-b2',
        type: PieceType.pawn,
        color: PieceColor.light,
        file: 1,
        rank: 1,
      ),

      // Dark
      Piece(
        id: 'bK-g8',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 6,
        rank: 7,
      ),
      Piece(
        id: 'bP-f7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 5,
        rank: 6,
      ),
      Piece(
        id: 'bP-h7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 7,
        rank: 6,
      ),
      Piece(
        id: 'bQ-h3',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 7,
        rank: 2,
      ),
      Piece(
        id: 'bR-e7',
        type: PieceType.rook,
        color: PieceColor.dark,
        file: 4,
        rank: 6,
      ),
      Piece(
        id: 'bP-a7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 0,
        rank: 6,
      ),
      Piece(
        id: 'bP-b7',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 1,
        rank: 6,
      ),
      Piece(
        id: 'bP-c6',
        type: PieceType.pawn,
        color: PieceColor.dark,
        file: 2,
        rank: 5,
      ),
      Piece(
        id: 'bB-f5',
        type: PieceType.bishop,
        color: PieceColor.dark,
        file: 5,
        rank: 4,
      ),
    ],
    threatenedKing: Square(6, 0), // g1
    attackingPiece: Square(7, 2), // h3
    rescueFrom: Square(4, 3), // e4
    rescueTo: Square(5, 5), // f6
  );
}
