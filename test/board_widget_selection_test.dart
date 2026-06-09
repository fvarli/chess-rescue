import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/features/rescue_game/game_state.dart';
import 'package:chess_rescue/features/rescue_game/widgets/board_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget harness(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  // Friendly light king + two non-king friendlies + one opponent king. Enough
  // pieces to exercise the attention-hierarchy dimming logic.
  const pieces = [
    Piece(
      id: 'wk',
      type: PieceType.king,
      color: PieceColor.light,
      file: 4,
      rank: 0,
    ),
    Piece(
      id: 'wn',
      type: PieceType.knight,
      color: PieceColor.light,
      file: 5,
      rank: 2,
    ),
    Piece(
      id: 'wr',
      type: PieceType.rook,
      color: PieceColor.light,
      file: 0,
      rank: 0,
    ),
    Piece(
      id: 'bk',
      type: PieceType.king,
      color: PieceColor.dark,
      file: 4,
      rank: 4,
    ),
  ];

  BoardWidget makeBoard({
    Piece? selected,
    GameState state = GameState.danger,
    bool commitInFlight = false,
  }) => BoardWidget(
    size: 360,
    pieces: pieces,
    selected: selected,
    legalSquares: const [],
    state: state,
    threatenedKing: const Square(4, 0),
    rescueTo: const Square(0, 0),
    commitInFlight: commitInFlight,
    resetInFlight: false,
    onTapSquare: (_, _) {},
  );

  group('BoardWidget — PR-10B.1 selection halo + attention', () {
    testWidgets('renders without a selection (no breath, no dim)', (
      tester,
    ) async {
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoardWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders with a selection — breath ticks + dim fades in without exception',
      (tester) async {
        await tester.pumpWidget(
          harness(
            makeBoard(
              selected: pieces[1], // the knight
              state: GameState.selected,
            ),
          ),
        );
        // First frame applies the selection.
        await tester.pump();
        // Cross the attention-dim fade window (180 ms) + at least one
        // breath frame so the AnimatedBuilder for the halo has ticked.
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(BoardWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('toggling selection on/off/elsewhere never throws', (
      tester,
    ) async {
      // Start with selection.
      await tester.pumpWidget(
        harness(makeBoard(selected: pieces[1], state: GameState.selected)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Clear selection.
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Select a different piece.
      await tester.pumpWidget(
        harness(makeBoard(selected: pieces[2], state: GameState.selected)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'selected → commitInFlight transition suppresses breath without exception',
      (tester) async {
        await tester.pumpWidget(
          harness(makeBoard(selected: pieces[1], state: GameState.selected)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        // Commit begins — breath should stop, ring contracts via its own
        // existing TweenAnimationBuilder.
        await tester.pumpWidget(
          harness(
            makeBoard(
              selected: pieces[1],
              state: GameState.selected,
              commitInFlight: true,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
