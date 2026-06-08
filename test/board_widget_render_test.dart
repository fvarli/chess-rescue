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
    Square? lastMoveFrom,
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
    lastMoveFrom: lastMoveFrom,
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

  group('BoardWidget — cinematic move arrow', () {
    const arrowKey = ValueKey('move-arrow');
    const arrowHiddenKey = ValueKey('move-arrow-hidden');

    testWidgets('arrow layer is visible in rescued state with origin set', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          makeBoard(
            size: 360,
            state: GameState.rescued,
            rescueTo: const Square(4, 4),
            lastMoveFrom: const Square(4, 0),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(arrowKey), findsOneWidget);
      expect(find.byKey(arrowHiddenKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrow is suppressed when lastMoveFrom is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          makeBoard(
            size: 360,
            state: GameState.rescued,
            rescueTo: const Square(4, 4),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(arrowKey), findsNothing);
      expect(find.byKey(arrowHiddenKey), findsOneWidget);
    });

    testWidgets(
      'arrow is suppressed in non-rescued states even with origin set',
      (tester) async {
        for (final state in const [
          GameState.danger,
          GameState.selected,
          GameState.failed,
        ]) {
          await tester.pumpWidget(
            harness(
              makeBoard(
                size: 360,
                state: state,
                rescueTo: const Square(4, 4),
                lastMoveFrom: const Square(4, 0),
              ),
            ),
          );
          await tester.pump();
          expect(
            find.byKey(arrowKey),
            findsNothing,
            reason: 'arrow must not show during $state',
          );
          expect(
            find.byKey(arrowHiddenKey),
            findsOneWidget,
            reason: 'arrow hidden marker must be present during $state',
          );
        }
      },
    );
  });

  group('BoardWidget — ambient presence', () {
    const ambientKey = ValueKey('ambient-layer');
    const arrowKey = ValueKey('move-arrow');

    testWidgets('ambient layer is present in danger state', (tester) async {
      await tester.pumpWidget(harness(makeBoard(size: 360)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(ambientKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ambient layer survives a danger → rescued transition', (
      tester,
    ) async {
      await tester.pumpWidget(harness(makeBoard(size: 360)));
      await tester.pump();
      expect(find.byKey(ambientKey), findsOneWidget);
      await tester.pumpWidget(
        harness(makeBoard(size: 360, state: GameState.rescued)),
      );
      // Cross the exhale pause + a frame on the other side.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(ambientKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PR-4 move arrow coexists with ambient layer', (tester) async {
      await tester.pumpWidget(
        harness(
          makeBoard(
            size: 360,
            state: GameState.rescued,
            rescueTo: const Square(4, 4),
            lastMoveFrom: const Square(4, 0),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(ambientKey), findsOneWidget);
      expect(find.byKey(arrowKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispose is clean after rescued transition', (tester) async {
      await tester.pumpWidget(
        harness(makeBoard(size: 360, state: GameState.rescued)),
      );
      await tester.pump();
      // Pump well past the exhale window so the timer has fired (or been
      // cancelled). Then unmount; no exceptions, no late callbacks firing
      // on a disposed controller.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpWidget(harness(const SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 100));
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
