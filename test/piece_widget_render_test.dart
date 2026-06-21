import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  // PR-14 — 32 px added to the size matrix so the small-size legibility
  // path (optical-scale stroke + ear notch / jaw / 3-bead crown / 2-notch
  // rook / lengthened bishop slit) is exercised under paint.
  for (final type in PieceType.values) {
    for (final color in PieceColor.values) {
      for (final size in const [32.0, 36.0, 48.0, 64.0]) {
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

  // PR-16 — light + dark variants paint visually different pixels.
  // Without golden-file infrastructure this is the closest thing to a
  // visual regression sentinel: render a light and a dark king at
  // 64 px into separate RepaintBoundaries, capture the layer pixels,
  // and assert that the two encodings differ. Catches accidental
  // collapse of the light/dark branch (e.g. always-light gradient or
  // always-dark stroke).
  group('PR-16 — light vs dark visual sentinel', () {
    testWidgets('light king and dark king render different pixel data', (
      tester,
    ) async {
      const light = Piece(
        id: 'king-light',
        type: PieceType.king,
        color: PieceColor.light,
        file: 0,
        rank: 0,
      );
      const dark = Piece(
        id: 'king-dark',
        type: PieceType.king,
        color: PieceColor.dark,
        file: 0,
        rank: 0,
      );
      final lightKey = GlobalKey();
      final darkKey = GlobalKey();
      await tester.pumpWidget(
        harness(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: lightKey,
                child: const PieceWidget(piece: light, size: 64),
              ),
              RepaintBoundary(
                key: darkKey,
                child: const PieceWidget(piece: dark, size: 64),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      List<int>? lightBytes;
      List<int>? darkBytes;
      await tester.runAsync(() async {
        final lightRb =
            lightKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final darkRb =
            darkKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final lightImage = await lightRb.toImage(pixelRatio: 1.0);
        final darkImage = await darkRb.toImage(pixelRatio: 1.0);
        final lightData = await lightImage.toByteData(
          format: ImageByteFormat.rawRgba,
        );
        final darkData = await darkImage.toByteData(
          format: ImageByteFormat.rawRgba,
        );
        lightBytes = lightData!.buffer.asUint8List();
        darkBytes = darkData!.buffer.asUint8List();
      });
      expect(lightBytes, isNotNull);
      expect(darkBytes, isNotNull);
      expect(
        lightBytes!.length,
        darkBytes!.length,
        reason: 'both kings should rasterize at the same dimensions',
      );
      bool anyDiffer = false;
      for (var i = 0; i < lightBytes!.length; i++) {
        if (lightBytes![i] != darkBytes![i]) {
          anyDiffer = true;
          break;
        }
      }
      expect(
        anyDiffer,
        isTrue,
        reason:
            'light and dark king must rasterize to different pixel '
            'data — if this fails the color branch has collapsed',
      );
    });
  });

  // PR-14 — pin the optical-scale stroke curve. The numbers here define
  // the contract: 48 px and above match shipped main exactly (1.15 px),
  // below 48 px the stroke grows linearly so the silhouette outline
  // survives sub-pixel rendering.
  group('PR-14 — pieceBodyStrokeFor optical-scale curve', () {
    test('size >= 48 px returns the shipped 1.15 baseline exactly', () {
      expect(pieceBodyStrokeFor(48), closeTo(1.15, 1e-9));
      expect(pieceBodyStrokeFor(64), closeTo(1.15, 1e-9));
      expect(pieceBodyStrokeFor(96), closeTo(1.15, 1e-9));
      expect(pieceBodyStrokeFor(200), closeTo(1.15, 1e-9));
    });

    test('at 32 px the body stroke grows to ~1.27 px', () {
      // Boost = (48 - 32) / 48 * 0.35 = 16/48 * 0.35 ≈ 0.1167
      expect(pieceBodyStrokeFor(32), closeTo(1.15 + (16 / 48) * 0.35, 1e-9));
    });

    test('at 24 px the body stroke grows to ~1.325 px', () {
      expect(pieceBodyStrokeFor(24), closeTo(1.15 + (24 / 48) * 0.35, 1e-9));
    });

    test('curve is monotonically non-increasing as size grows', () {
      double last = double.infinity;
      for (final s in const [16.0, 20.0, 24.0, 32.0, 40.0, 48.0, 64.0]) {
        final v = pieceBodyStrokeFor(s);
        expect(
          v,
          lessThanOrEqualTo(last),
          reason: 'stroke must not grow as size grows; size=$s returned $v',
        );
        last = v;
      }
    });

    test('curve clamps gracefully at size 0 (no NaN, no negative)', () {
      final v = pieceBodyStrokeFor(0);
      expect(v.isFinite, isTrue);
      expect(v, lessThanOrEqualTo(1.15 + 0.35));
      expect(v, greaterThan(1.15));
    });
  });

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
