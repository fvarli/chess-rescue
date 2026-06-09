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

  // PR-10C — render at lifted scales (selected 1.025, rescued held 1.04) so
  // the new lift-aware shadow path is exercised. The TweenAnimationBuilder
  // animates over MotionTokens.pieceLift (180 ms); pump past it so the
  // painter receives non-1.0 liftedScale and the modulated alpha/blur path
  // runs without exception.
  group('PieceWidget — PR-10C lifted shadow paths', () {
    for (final lifted in const [1.025, 1.04]) {
      testWidgets('renders at liftedScale $lifted without exception', (
        tester,
      ) async {
        const piece = Piece(
          id: 'knight-light-lifted',
          type: PieceType.knight,
          color: PieceColor.light,
          file: 0,
          rank: 0,
        );
        await tester.pumpWidget(
          harness(PieceWidget(piece: piece, size: 48, liftedScale: lifted)),
        );
        await tester.pump();
        // Cross the lift tween + a frame for the lifted-shadow path.
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('settled lift transition does not throw', (tester) async {
      const piece = Piece(
        id: 'queen-dark-transition',
        type: PieceType.queen,
        color: PieceColor.dark,
        file: 0,
        rank: 0,
      );
      // Start at rest.
      await tester.pumpWidget(harness(PieceWidget(piece: piece, size: 48)));
      await tester.pump();
      // Lift.
      await tester.pumpWidget(
        harness(PieceWidget(piece: piece, size: 48, liftedScale: 1.025)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      // Back to rest.
      await tester.pumpWidget(harness(PieceWidget(piece: piece, size: 48)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });
}
