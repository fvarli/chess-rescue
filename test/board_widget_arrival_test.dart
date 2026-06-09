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

  // A friendly rook arriving at rescueTo + the threatened light king + a
  // dark king. Enough pieces to exercise the release-settle wrap and the
  // arrival-memory layer together.
  const pieces = [
    Piece(
      id: 'wk',
      type: PieceType.king,
      color: PieceColor.light,
      file: 4,
      rank: 0,
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
    GameState state = GameState.danger,
    Square rescueTo = const Square(0, 0),
  }) => BoardWidget(
    size: 360,
    pieces: pieces,
    selected: null,
    legalSquares: const [],
    state: state,
    threatenedKing: const Square(4, 0),
    rescueTo: rescueTo,
    commitInFlight: false,
    resetInFlight: false,
    onTapSquare: (_, _) {},
  );

  group('BoardWidget — PR-10B.2 release settle + arrival memory', () {
    testWidgets('renders rescued state with arrival memory + release settle', (
      tester,
    ) async {
      await tester.pumpWidget(harness(makeBoard(state: GameState.rescued)));
      // First frame applies the state.
      await tester.pump();
      // Cross both windows: release settle (90 ms) + arrival memory (160 ms)
      // with a healthy margin so both controllers have ticked at least once.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(BoardWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('danger state does not fire the new layers', (tester) async {
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(BoardWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('danger → rescued transition does not throw', (tester) async {
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      // Transition to rescued mid-flight.
      await tester.pumpWidget(harness(makeBoard(state: GameState.rescued)));
      await tester.pump();
      // Pump through both new effect windows + a margin.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      // Then back to danger to exercise the reset path.
      await tester.pumpWidget(harness(makeBoard()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}
