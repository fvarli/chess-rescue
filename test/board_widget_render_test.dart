import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/features/rescue_game/game_state.dart';
import 'package:chess_rescue/features/rescue_game/widgets/board_widget.dart';

// Render-smoke + label-visibility tests for the premium board. No goldens
// — visual verification is by device playtest per v1.2.0 policy.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget harness(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  BoardWidget makeBoard({
    required double size,
    List<Piece> pieces = const [],
    GameState state = GameState.danger,
    Square threatenedKing = const Square(4, 0),
    Square rescueTo = const Square(0, 0),
  }) => BoardWidget(
    size: size,
    pieces: pieces,
    selected: null,
    legalSquares: const [],
    state: state,
    threatenedKing: threatenedKing,
    rescueTo: rescueTo,
    commitInFlight: false,
    resetInFlight: false,
    onTapSquare: (_, _) {},
  );

  group('BoardWidget — render smoke', () {
    for (final size in const [280.0, 360.0, 480.0]) {
      testWidgets('renders at ${size.toInt()}px in danger state', (
        tester,
      ) async {
        await tester.pumpWidget(harness(makeBoard(size: size)));
        await tester.pump();
        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('renders in rescued state', (tester) async {
      await tester.pumpWidget(
        harness(makeBoard(size: 360, state: GameState.rescued)),
      );
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with a light king + a dark king on adjacent squares', (
      tester,
    ) async {
      const pieces = [
        Piece(
          id: 'wk',
          type: PieceType.king,
          color: PieceColor.light,
          file: 4,
          rank: 0,
        ),
        Piece(
          id: 'bk',
          type: PieceType.king,
          color: PieceColor.dark,
          file: 4,
          rank: 2,
        ),
      ];
      await tester.pumpWidget(harness(makeBoard(size: 360, pieces: pieces)));
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('BoardWidget — coordinate labels', () {
    testWidgets('all file letters a–h render at 360px', (tester) async {
      await tester.pumpWidget(harness(makeBoard(size: 360)));
      await tester.pump();
      for (final letter in const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        expect(
          find.text(letter),
          findsOneWidget,
          reason: 'file letter "$letter" should be rendered',
        );
      }
    });

    testWidgets('all rank numbers 1–8 render at 360px', (tester) async {
      await tester.pumpWidget(harness(makeBoard(size: 360)));
      await tester.pump();
      for (final n in const ['1', '2', '3', '4', '5', '6', '7', '8']) {
        expect(
          find.text(n),
          findsOneWidget,
          reason: 'rank number "$n" should be rendered',
        );
      }
    });

    testWidgets('coordinate labels are NOT rendered at 240px (gated)', (
      tester,
    ) async {
      await tester.pumpWidget(harness(makeBoard(size: 240)));
      await tester.pump();
      // At sub-280 sizes, labels are suppressed to avoid noise.
      expect(find.text('a'), findsNothing);
      expect(find.text('1'), findsNothing);
    });
  });
}
