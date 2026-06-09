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
    Square? lastMoveFrom,
    Square rescueTo = const Square(0, 0),
    bool commitInFlight = false,
  }) => BoardWidget(
    size: 360,
    pieces: pieces,
    selected: selected,
    legalSquares: const [],
    state: state,
    threatenedKing: const Square(4, 0),
    rescueTo: rescueTo,
    commitInFlight: commitInFlight,
    resetInFlight: false,
    onTapSquare: (_, _) {},
    lastMoveFrom: lastMoveFrom,
  );

  group('BoardWidget — PR-10D selection continuity', () {
    testWidgets('selection → null triggers sticky fade, no exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(makeBoard(selected: pieces[1], state: GameState.selected)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Clear selection — sticky fade should now run for 140 ms.
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'selection → different piece glides via AnimatedPositioned without exception',
      (tester) async {
        await tester.pumpWidget(
          harness(makeBoard(selected: pieces[1], state: GameState.selected)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        // Switch to a different selected piece — ring should glide rather
        // than teleport.
        await tester.pumpWidget(
          harness(makeBoard(selected: pieces[2], state: GameState.selected)),
        );
        await tester.pump();
        // Cross the relocation window.
        await tester.pump(const Duration(milliseconds: 80));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('selection → failed state uses sticky fade path', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(makeBoard(selected: pieces[1], state: GameState.selected)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // State transitions to failed; controller would clear selection.
      await tester.pumpWidget(harness(makeBoard(state: GameState.failed)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('BoardWidget — PR-10D arrow dissolve', () {
    testWidgets('rescued → danger dissolves arrow over 120 ms', (tester) async {
      // Establish the rescued state with an active arrow.
      await tester.pumpWidget(
        harness(
          makeBoard(
            state: GameState.rescued,
            rescueTo: const Square(4, 4),
            lastMoveFrom: const Square(4, 0),
          ),
        ),
      );
      await tester.pump();
      // Cross the move-arrow sequence so its value is non-zero.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      // Transition to danger — dissolve should run rather than the arrow
      // teleporting away.
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      // Mid-dissolve frame.
      await tester.pump(const Duration(milliseconds: 60));
      // Past dissolve window + clear timer.
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rescued → rescued (re-mount) does not require dissolve', (
      tester,
    ) async {
      // Mount already-rescued — initial branch should not fire effects.
      await tester.pumpWidget(
        harness(
          makeBoard(
            state: GameState.rescued,
            rescueTo: const Square(4, 4),
            lastMoveFrom: const Square(4, 0),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });
}
