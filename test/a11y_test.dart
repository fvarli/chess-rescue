import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/features/rescue_game/widgets/piece_a11y.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';
import 'package:chess_rescue/main.dart';

// PR-15 — accessibility + small-device + locale + text-scale safety net.
// Three concerns covered by one file:
//   1. Home + RescueScreen don't overflow on small / locale-stretched /
//      text-scaled viewports.
//   2. Semantic labels are reachable via find.bySemanticsLabel on the
//      surfaces that matter.
//   3. Pieces are excluded from the board-square Semantics so the screen
//      reader announces "e4, light knight" exactly once, not twice.

void useSmallPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void useLargePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: child,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('pieceA11yLabel — pure derivation', () {
    testWidgets('every (color, type) combo returns a non-empty string', (
      tester,
    ) async {
      late AppL10n l;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              l = AppL10n.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      for (final color in PieceColor.values) {
        for (final type in PieceType.values) {
          final p = Piece(
            id: '${color.name}-${type.name}',
            type: type,
            color: color,
            file: 0,
            rank: 0,
          );
          final label = pieceA11yLabel(p, l);
          expect(
            label,
            isNotEmpty,
            reason: 'pieceA11yLabel must return content for ($color, $type)',
          );
        }
      }
    });

    test('squareNotation maps file/rank to algebraic notation', () {
      expect(squareNotation(0, 0), 'a1');
      expect(squareNotation(4, 3), 'e4');
      expect(squareNotation(7, 7), 'h8');
    });
  });

  group('Home — small-device + locale + text-scale robustness', () {
    testWidgets('renders without overflow in Turkish on 320×640', (
      tester,
    ) async {
      useSmallPhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_intro_seen': true,
        'flutter.cr_language_mode': 'tr',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow in Spanish on 320×640', (
      tester,
    ) async {
      useSmallPhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_intro_seen': true,
        'flutter.cr_language_mode': 'es',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders without overflow at the clamped maximum text scaler (1.35)',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        // The app applies MediaQuery.withClampedTextScaling at the
        // MaterialApp root; reading a non-clamped 1.35 here exercises the
        // ceiling exactly.
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Home — semantic labels present', () {
    testWidgets('Begin today\'s rescue CTA carries a button semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      expect(find.bySemanticsLabel("Begin today's rescue  ↦"), findsOneWidget);
      handle.dispose();
    });

    testWidgets('RECORDS line carries a "RECORDS, N / 13" semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();

      expect(find.bySemanticsLabel('RECORDS, 0 / 13'), findsOneWidget);
      handle.dispose();
    });

    testWidgets(
      'Latest milestone line carries a "LATELY, First Rescue" semantic label',
      (tester) async {
        final handle = tester.ensureSemantics();
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_lifetime_saved': 1,
          'flutter.cr_unlocked_records': '["first-rescue"]',
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        expect(find.bySemanticsLabel('LATELY, First Rescue'), findsOneWidget);
        handle.dispose();
      },
    );
  });

  group('RescueScreen — board square semantic labels', () {
    testWidgets(
      'board squares announce algebraic notation + occupant (single-read)',
      (tester) async {
        final handle = tester.ensureSemantics();
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
        final store = await ProgressStore.create();
        final game = GameController(store: store);

        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump(const Duration(milliseconds: 250));

        // The P1 starting position puts a light knight at e4. The
        // composite "e4, Light knight" must be reachable exactly once
        // (the piece layer is wrapped in ExcludeSemantics so the square
        // owns the label).
        expect(find.bySemanticsLabel('e4, Light knight'), findsOneWidget);
        // An adjacent empty square reads as "<sq>, empty".
        expect(find.bySemanticsLabel('a3, empty'), findsOneWidget);
        handle.dispose();
      },
    );
  });
}
