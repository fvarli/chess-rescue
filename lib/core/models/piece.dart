import 'package:flutter/foundation.dart';

enum PieceType { king, queen, rook, bishop, knight, pawn }

enum PieceColor { light, dark }

@immutable
class Piece {
  const Piece({
    required this.type,
    required this.color,
    required this.file,
    required this.rank,
  });

  final PieceType type;
  final PieceColor color;
  final int file;
  final int rank;

  Piece copyWith({int? file, int? rank}) => Piece(
    type: type,
    color: color,
    file: file ?? this.file,
    rank: rank ?? this.rank,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece &&
          other.type == type &&
          other.color == color &&
          other.file == file &&
          other.rank == rank;

  @override
  int get hashCode => Object.hash(type, color, file, rank);
}
