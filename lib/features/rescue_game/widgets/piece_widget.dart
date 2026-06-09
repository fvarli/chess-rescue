import 'package:flutter/material.dart';

import '../../../core/models/piece.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/tokens.dart';

class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    this.liftedScale = 1.0,
  });

  final Piece piece;
  final double size;

  // Animated target scale, applied via Transform.scale wrapping the painter.
  // 1.0 = at rest, 1.05 = selected (lifted), 1.04 = rescued (held lift).
  final double liftedScale;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: liftedScale),
        duration: MotionTokens.pieceLift,
        curve: MotionTokens.standard,
        // PR-10C — thread the live animated scale into the painter so the
        // floor shadow softens in lockstep with the piece lift, not in a
        // separate snap. Repaint per tween frame is cheap (simple ovals +
        // paths in a 100×100 viewBox).
        builder: (context, scale, _) => Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: Size.square(size),
            painter: _PiecePainter(
              type: piece.type,
              color: piece.color,
              liftedScale: scale,
            ),
          ),
        ),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  _PiecePainter({
    required this.type,
    required this.color,
    this.liftedScale = 1.0,
  });

  final PieceType type;
  final PieceColor color;
  // PR-10C — current live scale (1.0 at rest, approaches 1.025 when
  // selected). Used by _paintFloorShadow to interpolate shadow geometry
  // and alpha/blur. Has no effect at rest.
  final double liftedScale;

  // Lift t: 0 at rest, 1 at the selected-lift ceiling of 1.025. The
  // rescued held-lift of 1.04 clamps to 1.0 so the shadow doesn't grow
  // further than the selected state.
  double get _liftT => ((liftedScale - 1.0) / 0.025).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    // Geometry is authored in a 100x100 viewBox per primitives.jsx.
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final isLight = color == PieceColor.light;
    final fillColor = isLight ? ColorTokens.pieceLight : ColorTokens.pieceDark;
    final strokeColor = isLight
        ? ColorTokens.pieceLightStroke
        : ColorTokens.pieceDarkStroke;

    // Asymmetric gradient: light pieces darken at the bottom (carved cue);
    // dark pieces lift at the top (separation from the deep charcoal board).
    final topColor = isLight
        ? Color.lerp(fillColor, Colors.white, 0.08)!
        : Color.lerp(fillColor, Colors.white, 0.18)!;
    final bottomColor = isLight
        ? Color.lerp(fillColor, Colors.black, 0.16)!
        : Color.lerp(fillColor, Colors.black, 0.06)!;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(const Rect.fromLTRB(0, 0, 100, 100));

    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Must paint before the silhouette so the body overpaints any overlap.
    _paintFloorShadow(canvas);

    switch (type) {
      case PieceType.king:
        _paintKing(canvas, fill, stroke, isLight);
        break;
      case PieceType.queen:
        _paintQueen(canvas, fill, stroke, isLight);
        break;
      case PieceType.rook:
        _paintRook(canvas, fill, stroke, isLight);
        break;
      case PieceType.bishop:
        _paintBishop(canvas, fill, stroke, strokeColor, isLight);
        break;
      case PieceType.knight:
        _paintKnight(canvas, fill, stroke, strokeColor, isLight);
        break;
      case PieceType.pawn:
        _paintPawn(canvas, fill, stroke, isLight);
        break;
    }

    canvas.restore();
  }

  void _drawPath(Canvas canvas, Path path, Paint fill, Paint stroke) {
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  Path _basePath() {
    // M24 75 H76 L82 87 H18 Z — wider trapezoidal base used by most pieces.
    return Path()
      ..moveTo(24, 75)
      ..lineTo(76, 75)
      ..lineTo(82, 87)
      ..lineTo(18, 87)
      ..close();
  }

  Path _wideBasePath() {
    // M22 75 H78 L82 87 H18 Z — slightly wider base for rook/knight.
    return Path()
      ..moveTo(22, 75)
      ..lineTo(78, 75)
      ..lineTo(82, 87)
      ..lineTo(18, 87)
      ..close();
  }

  Path _footEllipse() {
    return Path()..addOval(
      Rect.fromCenter(center: const Offset(50, 87), width: 64, height: 6),
    );
  }

  Path _collarPath({double left = 31, double right = 69}) {
    // M{left} 68 H{right} V75 H{left} Z
    return Path()
      ..moveTo(left, 68)
      ..lineTo(right, 68)
      ..lineTo(right, 75)
      ..lineTo(left, 75)
      ..close();
  }

  // Width 56 (narrower than the 64-wide foot ellipse) keeps the blurred
  // edge inside the inner 84%-padded square in board_widget.dart, so the
  // shadow can never bleed into an adjacent square.
  void _paintFloorShadow(Canvas canvas) {
    // PR-10C — selected lift softens the shadow. At rest (t = 0) the
    // values match the shipped PR-2 baseline exactly: width 56, height 7,
    // blur 3.5, full pieceFloorShadow alpha. At full lift (t = 1):
    // geometry scales by pieceLiftShadowScale, blur grows by
    // pieceLiftShadowBlurDelta, alpha multiplies by
    // pieceLiftShadowAlphaMultiplier. Subtle — visible only side-by-side.
    final t = _liftT;
    final geomScale = 1.0 + (MotionTokens.pieceLiftShadowScale - 1.0) * t;
    final blur = 3.5 + MotionTokens.pieceLiftShadowBlurDelta * t;
    final alphaMultiplier =
        1.0 - (1.0 - MotionTokens.pieceLiftShadowAlphaMultiplier) * t;
    final shadow = Paint()
      ..color = ColorTokens.pieceFloorShadow.withValues(
        alpha: ColorTokens.pieceFloorShadow.a * alphaMultiplier,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
      ..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(50, 92),
        width: 56 * geomScale,
        height: 7 * geomScale,
      ),
      shadow,
    );
  }

  // No clip path: the 8/12% alpha forgives any silhouette overflow, and
  // skipping clipPath keeps the rasterizer cheap for 16–32 pieces on screen.
  void _paintTopSheen(Canvas canvas, Offset center, bool isLight) {
    final sheen = Paint()
      ..color = isLight
          ? ColorTokens.pieceLightHighlight
          : ColorTokens.pieceDarkHighlight
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 28, height: 10),
      sheen,
    );
  }

  // Uses ColorTokens.shadow + 0.8px stroke so the rim accents the contact
  // without competing with the body stroke.
  void _paintFootRim(Canvas canvas) {
    final rim = Paint()
      ..color = ColorTokens.shadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    // Upper-half arc of the foot ellipse at y≈84, width 64.
    final arc = Path()
      ..addArc(
        Rect.fromCenter(center: const Offset(50, 87), width: 64, height: 6),
        3.14159, // π — start at left side
        3.14159, // sweep π — top half only
      );
    canvas.drawPath(arc, rim);
  }

  void _paintKing(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    // Cross: M47 4 H53 V12 H60 V18 H53 V26 H47 V18 H40 V12 H47 Z
    final cross = Path()
      ..moveTo(47, 4)
      ..lineTo(53, 4)
      ..lineTo(53, 12)
      ..lineTo(60, 12)
      ..lineTo(60, 18)
      ..lineTo(53, 18)
      ..lineTo(53, 26)
      ..lineTo(47, 26)
      ..lineTo(47, 18)
      ..lineTo(40, 18)
      ..lineTo(40, 12)
      ..lineTo(47, 12)
      ..close();
    _drawPath(canvas, cross, fill, stroke);

    // Finial bead: ellipse cx=50 cy=30 rx=5.5 ry=4
    final bead = Path()
      ..addOval(
        Rect.fromCenter(center: const Offset(50, 30), width: 11, height: 8),
      );
    _drawPath(canvas, bead, fill, stroke);

    // Body: M38 34 Q33 46 36 60 Q34 64 32 68 H68 Q66 64 64 60 Q67 46 62 34
    //       Q56 38 50 38 Q44 38 38 34 Z
    final body = Path()
      ..moveTo(38, 34)
      ..quadraticBezierTo(33, 46, 36, 60)
      ..quadraticBezierTo(34, 64, 32, 68)
      ..lineTo(68, 68)
      ..quadraticBezierTo(66, 64, 64, 60)
      ..quadraticBezierTo(67, 46, 62, 34)
      ..quadraticBezierTo(56, 38, 50, 38)
      ..quadraticBezierTo(44, 38, 38, 34)
      ..close();
    _drawPath(canvas, body, fill, stroke);

    _paintTopSheen(canvas, const Offset(50, 42), isLight);
    _drawPath(canvas, _collarPath(), fill, stroke);
    _drawPath(canvas, _basePath(), fill, stroke);
    _drawPath(canvas, _footEllipse(), fill, stroke);
    _paintFootRim(canvas);
  }

  void _paintQueen(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    // Five crown beads.
    const beads = [
      [28.0, 16.0, 3.6],
      [39.0, 11.0, 3.6],
      [50.0, 8.0, 4.0],
      [61.0, 11.0, 3.6],
      [72.0, 16.0, 3.6],
    ];
    for (final b in beads) {
      final bead = Path()
        ..addOval(Rect.fromCircle(center: Offset(b[0], b[1]), radius: b[2]));
      _drawPath(canvas, bead, fill, stroke);
    }

    // Crown band: M26 18 H74 L70 26 H30 Z
    final crownBand = Path()
      ..moveTo(26, 18)
      ..lineTo(74, 18)
      ..lineTo(70, 26)
      ..lineTo(30, 26)
      ..close();
    _drawPath(canvas, crownBand, fill, stroke);

    // Neck: M33 26 H67 V32 H33 Z
    final neck = Path()
      ..moveTo(33, 26)
      ..lineTo(67, 26)
      ..lineTo(67, 32)
      ..lineTo(33, 32)
      ..close();
    _drawPath(canvas, neck, fill, stroke);

    // Body: M37 32 Q31 46 34 60 Q32 64 30 68 H70 Q68 64 66 60 Q69 46 63 32 Z
    final body = Path()
      ..moveTo(37, 32)
      ..quadraticBezierTo(31, 46, 34, 60)
      ..quadraticBezierTo(32, 64, 30, 68)
      ..lineTo(70, 68)
      ..quadraticBezierTo(68, 64, 66, 60)
      ..quadraticBezierTo(69, 46, 63, 32)
      ..close();
    _drawPath(canvas, body, fill, stroke);

    _paintTopSheen(canvas, const Offset(50, 40), isLight);
    _drawPath(canvas, _collarPath(), fill, stroke);
    _drawPath(canvas, _basePath(), fill, stroke);
    _drawPath(canvas, _footEllipse(), fill, stroke);
    _paintFootRim(canvas);
  }

  void _paintRook(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    // Battlements: M24 6 H34 V14 H40 V6 H47 V14 H53 V6 H60 V14 H66 V6 H76 V24 H24 Z
    final battlements = Path()
      ..moveTo(24, 6)
      ..lineTo(34, 6)
      ..lineTo(34, 14)
      ..lineTo(40, 14)
      ..lineTo(40, 6)
      ..lineTo(47, 6)
      ..lineTo(47, 14)
      ..lineTo(53, 14)
      ..lineTo(53, 6)
      ..lineTo(60, 6)
      ..lineTo(60, 14)
      ..lineTo(66, 14)
      ..lineTo(66, 6)
      ..lineTo(76, 6)
      ..lineTo(76, 24)
      ..lineTo(24, 24)
      ..close();
    _drawPath(canvas, battlements, fill, stroke);

    // Upper collar: M28 24 H72 V32 H28 Z
    final upperCollar = Path()
      ..moveTo(28, 24)
      ..lineTo(72, 24)
      ..lineTo(72, 32)
      ..lineTo(28, 32)
      ..close();
    _drawPath(canvas, upperCollar, fill, stroke);

    // Body: M32 32 H68 L70 42 V58 L68 68 H32 L30 58 V42 Z
    final body = Path()
      ..moveTo(32, 32)
      ..lineTo(68, 32)
      ..lineTo(70, 42)
      ..lineTo(70, 58)
      ..lineTo(68, 68)
      ..lineTo(32, 68)
      ..lineTo(30, 58)
      ..lineTo(30, 42)
      ..close();
    _drawPath(canvas, body, fill, stroke);

    _paintTopSheen(canvas, const Offset(50, 38), isLight);
    _drawPath(canvas, _collarPath(left: 28, right: 72), fill, stroke);
    _drawPath(canvas, _wideBasePath(), fill, stroke);
    _drawPath(canvas, _footEllipse(), fill, stroke);
    _paintFootRim(canvas);
  }

  void _paintBishop(
    Canvas canvas,
    Paint fill,
    Paint stroke,
    Color strokeColor,
    bool isLight,
  ) {
    // Head: M50 5 Q40 14 38 28 Q40 34 50 35 Q60 34 62 28 Q60 14 50 5 Z
    final head = Path()
      ..moveTo(50, 5)
      ..quadraticBezierTo(40, 14, 38, 28)
      ..quadraticBezierTo(40, 34, 50, 35)
      ..quadraticBezierTo(60, 34, 62, 28)
      ..quadraticBezierTo(60, 14, 50, 5)
      ..close();
    _drawPath(canvas, head, fill, stroke);

    // Mitre slit: M52 8 L57 13 (stroke only, slightly thicker).
    final slit = Path()
      ..moveTo(52, 8)
      ..lineTo(57, 13);
    final slitStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15 * 1.4
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(slit, slitStroke);

    // Collar bead: ellipse cx=50 cy=37 rx=11 ry=3.
    final collarBead = Path()
      ..addOval(
        Rect.fromCenter(center: const Offset(50, 37), width: 22, height: 6),
      );
    _drawPath(canvas, collarBead, fill, stroke);

    // Body: M40 38 Q33 52 36 64 Q34 66 32 68 H68 Q66 66 64 64 Q67 52 60 38
    //       Q55 40 50 40 Q45 40 40 38 Z
    final body = Path()
      ..moveTo(40, 38)
      ..quadraticBezierTo(33, 52, 36, 64)
      ..quadraticBezierTo(34, 66, 32, 68)
      ..lineTo(68, 68)
      ..quadraticBezierTo(66, 66, 64, 64)
      ..quadraticBezierTo(67, 52, 60, 38)
      ..quadraticBezierTo(55, 40, 50, 40)
      ..quadraticBezierTo(45, 40, 40, 38)
      ..close();
    _drawPath(canvas, body, fill, stroke);

    _paintTopSheen(canvas, const Offset(50, 44), isLight);
    _drawPath(canvas, _collarPath(), fill, stroke);
    _drawPath(canvas, _basePath(), fill, stroke);
    _drawPath(canvas, _footEllipse(), fill, stroke);
    _paintFootRim(canvas);
  }

  void _paintKnight(
    Canvas canvas,
    Paint fill,
    Paint stroke,
    Color strokeColor,
    bool isLight,
  ) {
    // Horse head silhouette — verbatim from primitives.jsx:98-117.
    final head = Path()
      ..moveTo(30, 24)
      ..quadraticBezierTo(36, 14, 48, 12)
      ..quadraticBezierTo(60, 10, 68, 16)
      ..quadraticBezierTo(76, 24, 76, 36)
      ..lineTo(76, 46)
      ..quadraticBezierTo(78, 54, 76, 62)
      ..lineTo(79, 68)
      ..lineTo(30, 68)
      ..lineTo(30, 62)
      ..quadraticBezierTo(27, 60, 26, 56)
      ..lineTo(18, 54)
      ..lineTo(14, 48)
      ..lineTo(18, 44)
      ..lineTo(22, 38)
      ..lineTo(14, 36)
      ..lineTo(18, 30)
      ..lineTo(28, 30)
      ..close();
    _drawPath(canvas, head, fill, stroke);

    // Mane crease: M58 18 Q66 30 70 50 — stroke only, 0.4 opacity.
    final mane = Path()
      ..moveTo(58, 18)
      ..quadraticBezierTo(66, 30, 70, 50);
    final maneStroke = Paint()
      ..color = strokeColor.withValues(alpha: strokeColor.a * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(mane, maneStroke);

    // Eye: ellipse cx=38 cy=28 rx=1.6 ry=2, filled with stroke color.
    final eye = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 28), width: 3.2, height: 4.0),
      eye,
    );

    // Nostril: ellipse cx=20 cy=40 rx=1.2 ry=1.6, opacity 0.6.
    final nostril = Paint()
      ..color = strokeColor.withValues(alpha: strokeColor.a * 0.6)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(20, 40), width: 2.4, height: 3.2),
      nostril,
    );

    _paintTopSheen(canvas, const Offset(52, 28), isLight);
    _drawPath(canvas, _collarPath(left: 28, right: 72), fill, stroke);
    _drawPath(canvas, _wideBasePath(), fill, stroke);
    _drawPath(canvas, _footEllipse(), fill, stroke);
    _paintFootRim(canvas);
  }

  void _paintPawn(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    // Head: circle cx=50 cy=22 r=10.
    final head = Path()
      ..addOval(Rect.fromCircle(center: const Offset(50, 22), radius: 10));
    _drawPath(canvas, head, fill, stroke);

    // Neck: M44 31 H56 L58 38 H42 Z
    final neck = Path()
      ..moveTo(44, 31)
      ..lineTo(56, 31)
      ..lineTo(58, 38)
      ..lineTo(42, 38)
      ..close();
    _drawPath(canvas, neck, fill, stroke);

    // Body: M40 40 Q34 52 38 64 Q36 66 34 68 H66 Q64 66 62 64 Q66 52 60 40
    //       Q55 43 50 43 Q45 43 40 40 Z
    final body = Path()
      ..moveTo(40, 40)
      ..quadraticBezierTo(34, 52, 38, 64)
      ..quadraticBezierTo(36, 66, 34, 68)
      ..lineTo(66, 68)
      ..quadraticBezierTo(64, 66, 62, 64)
      ..quadraticBezierTo(66, 52, 60, 40)
      ..quadraticBezierTo(55, 43, 50, 43)
      ..quadraticBezierTo(45, 43, 40, 40)
      ..close();
    _drawPath(canvas, body, fill, stroke);

    _paintTopSheen(canvas, const Offset(50, 24), isLight);
    _drawPath(canvas, _collarPath(left: 32, right: 68), fill, stroke);
    _drawPath(canvas, _basePath(), fill, stroke);
    _drawPath(canvas, _footEllipse(), fill, stroke);
    _paintFootRim(canvas);
  }

  @override
  bool shouldRepaint(covariant _PiecePainter old) =>
      old.type != type || old.color != color || old.liftedScale != liftedScale;
}
