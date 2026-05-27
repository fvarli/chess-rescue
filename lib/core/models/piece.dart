import 'package:flutter/foundation.dart';

enum PieceType { king, queen, rook, bishop, knight, pawn }

enum PieceColor { light, dark }

@immutable
class Piece {
  const Piece({
    required this.id,
    required this.type,
    required this.color,
    required this.file,
    required this.rank,
  });

  // Stable identity for animation framework — survives moves so
  // AnimatedPositioned can interpolate the piece between squares.
  final String id;
  final PieceType type;
  final PieceColor color;
  final int file;
  final int rank;

  Piece copyWith({int? file, int? rank}) => Piece(
    id: id,
    type: type,
    color: color,
    file: file ?? this.file,
    rank: rank ?? this.rank,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece &&
          other.id == id &&
          other.type == type &&
          other.color == color &&
          other.file == file &&
          other.rank == rank;

  @override
  int get hashCode => Object.hash(id, type, color, file, rank);
}
