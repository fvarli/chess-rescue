import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/features/rescue_game/widgets/piece_widget.dart';

// Render-smoke coverage for every (PieceType × PieceColor × size) combo.
// The painter has no golden coverage; these tests catch the easy regression
// — a typo in the new floor-shadow / sheen / rim code that makes one
// (type, color) combo throw under paint.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget harness(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  for (final type in PieceType.values) {
    for (final color in PieceColor.values) {
      for (final size in const [36.0, 48.0, 64.0]) {
        testWidgets(
          'PieceWidget(${type.name}, ${color.name}) renders at ${size.toInt()}px',
          (tester) async {
            final piece = Piece(
              id: '${type.name}-${color.name}',
              type: type,
              color: color,
              file: 0,
              rank: 0,
            );
            await tester.pumpWidget(
              harness(PieceWidget(piece: piece, size: size)),
            );
            await tester.pump();
            expect(find.byType(CustomPaint), findsWidgets);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
