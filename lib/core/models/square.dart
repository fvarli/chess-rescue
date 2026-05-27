import 'package:flutter/foundation.dart';

@immutable
class Square {
  const Square(this.file, this.rank);

  final int file;
  final int rank;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Square && other.file == file && other.rank == rank;

  @override
  int get hashCode => Object.hash(file, rank);

  @override
  String toString() => 'Square(${String.fromCharCode(97 + file)}${rank + 1})';
}
