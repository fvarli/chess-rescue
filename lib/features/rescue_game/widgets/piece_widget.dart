import 'package:flutter/material.dart';

import '../../../core/models/piece.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/tokens.dart';

/// PR-14 — optical-scale body stroke width.
///
/// At rendered sizes ≥ 48 px returns the shipped 1.15 px baseline exactly,
/// so 48 / 64 px piece renders match the baseline. Below 48 px the stroke
/// grows linearly so the silhouette outline survives sub-pixel rendering
/// at 32 px and below. At 32 px the result is ≈ 1.27 px.
///
/// Pure function — exposed at file scope so tests can pin the curve
/// without depending on the private `_PiecePainter`.
double pieceBodyStrokeFor(double sizePx) {
  if (sizePx >= 48) return 1.15;
  final boost = ((48 - sizePx) / 48).clamp(0.0, 1.0) * 0.35;
  return 1.15 + boost;
}

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
        // separate snap. Repaint per tween frame is cheap.
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

  // PR-14 — current paint's body stroke width, set in [paint] before
  // dispatching to per-piece methods. Used by helpers (bishop slit,
  // knight mane / jaw) that derive related strokes from the body width.
  double _bodyStroke = 1.15;

  // PR-16 — every piece resolves to ONE primary silhouette path (fill +
  // stroke once) plus a small number of INTERNAL detail strokes. The
  // base / foot / rim trio from PR-2..14 collapses into one beveled
  // platform that every piece's silhouette traverses on the way down.
  // The platform top sits at y=70 (shoulders) and the bottom at y=88,
  // so the shipped floor-shadow at y=92 still anchors below.
  static const _platTopRightX = 72.0;
  static const _platTopLeftX = 28.0;
  static const _platTopY = 70.0;
  static const _platBottomRightX = 80.0;
  static const _platBottomLeftX = 20.0;
  static const _platBottomY = 88.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Geometry is authored in a 100×100 viewBox.
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final isLight = color == PieceColor.light;
    final fillColor = isLight ? ColorTokens.pieceLight : ColorTokens.pieceDark;
    final strokeColor = isLight
        ? ColorTokens.pieceLightStroke
        : ColorTokens.pieceDarkStroke;

    // PR-16 — gradient halved from the PR-2 baseline. Reads as carved
    // matte material instead of glazed ceramic. Asymmetry preserved:
    // light pieces darken at the bottom (carved cue); dark pieces lift
    // at the top (separation from the deep charcoal board).
    final topColor = isLight
        ? Color.lerp(fillColor, Colors.white, 0.04)!
        : Color.lerp(fillColor, Colors.white, 0.09)!;
    final bottomColor = isLight
        ? Color.lerp(fillColor, Colors.black, 0.08)!
        : Color.lerp(fillColor, Colors.black, 0.03)!;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(const Rect.fromLTRB(0, 0, 100, 100));

    _bodyStroke = pieceBodyStrokeFor(size.width);
    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bodyStroke
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

  void _drawSilhouette(Canvas canvas, Path path, Paint fill, Paint stroke) {
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  // PR-10C — selected lift softens the shadow. Geometry / blur / alpha
  // interpolate with the live tween. Unchanged from shipped main.
  void _paintFloorShadow(Canvas canvas) {
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

  // PR-16 — top sheen shrunk + dimmed. Reads as a soft material edge
  // instead of a plastic highlight. Width 28→22, height 10→6, alpha
  // halved at the call site.
  void _paintTopSheen(Canvas canvas, Offset center, bool isLight) {
    final base = isLight
        ? ColorTokens.pieceLightHighlight
        : ColorTokens.pieceDarkHighlight;
    final sheen = Paint()
      ..color = base.withValues(alpha: base.a * 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 22, height: 6),
      sheen,
    );
  }

  // ───────────────────────── PR-16 KING (topY = 4) ─────────────────────
  // One silhouette: bold cross + slim columnar body + integrated platform.
  // Cross enlarged ~30% from PR-14 so it dominates at every render size.
  void _paintKing(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    final path = Path()
      // Cross — vertical arm top-right corner.
      ..moveTo(56, 4)
      ..lineTo(56, 12)
      ..lineTo(66, 12) // step out to horizontal arm
      ..lineTo(66, 20)
      ..lineTo(56, 20) // step back in
      ..lineTo(56, 24) // bottom of vertical arm right
      // Right shoulder of body, narrow upper neck.
      ..quadraticBezierTo(58, 28, 58, 32)
      // Right body — slim columnar with a gentle taper.
      ..quadraticBezierTo(60, 46, 60, 60)
      ..quadraticBezierTo(60, 64, 60, 68)
      // Platform.
      ..lineTo(_platTopRightX, _platTopY)
      ..lineTo(_platBottomRightX, _platBottomY)
      ..lineTo(_platBottomLeftX, _platBottomY)
      ..lineTo(_platTopLeftX, _platTopY)
      // Body left mirror.
      ..lineTo(40, 68)
      ..quadraticBezierTo(40, 64, 40, 60)
      ..quadraticBezierTo(40, 46, 42, 32)
      ..quadraticBezierTo(42, 28, 44, 24)
      // Cross — vertical arm bottom-left.
      ..lineTo(44, 24)
      ..lineTo(44, 20)
      ..lineTo(34, 20) // step out to horizontal arm left
      ..lineTo(34, 12)
      ..lineTo(44, 12) // step back in
      ..lineTo(44, 4) // top of vertical arm left
      ..close();
    _drawSilhouette(canvas, path, fill, stroke);
    _paintTopSheen(canvas, const Offset(50, 38), isLight);
  }

  // ───────────────────────── PR-16 QUEEN (topY = 9) ────────────────────
  // One silhouette: 3-point coronet integrated, body slim-but-flaring
  // through a wide tiara band that spreads beyond the body's shoulders.
  // King-vs-queen distinction lives in the crown spread, not body width.
  void _paintQueen(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    final path = Path()
      // Start at right band corner top.
      ..moveTo(76, 18)
      // Right bead apex — short peak.
      ..lineTo(72, 13)
      // Down into right dip.
      ..lineTo(66, 22)
      // Centre bead apex — tallest peak (queen apex).
      ..lineTo(50, 9)
      // Down into left dip.
      ..lineTo(34, 22)
      // Left bead apex — matches right.
      ..lineTo(28, 13)
      // Left band corner top.
      ..lineTo(24, 18)
      // Down to band bottom-left (slight inward taper).
      ..lineTo(26, 26)
      // Shoulder taper inward — queen body is slim, similar to king.
      ..lineTo(38, 30)
      // Body left curve.
      ..quadraticBezierTo(36, 46, 36, 60)
      ..quadraticBezierTo(36, 64, 36, 68)
      // Platform left side.
      ..lineTo(_platTopLeftX, _platTopY)
      ..lineTo(_platBottomLeftX, _platBottomY)
      ..lineTo(_platBottomRightX, _platBottomY)
      ..lineTo(_platTopRightX, _platTopY)
      // Body right.
      ..lineTo(64, 68)
      ..quadraticBezierTo(64, 64, 64, 60)
      ..quadraticBezierTo(64, 46, 62, 30)
      // Shoulder right back up to band.
      ..lineTo(74, 26)
      ..close();
    _drawSilhouette(canvas, path, fill, stroke);
    _paintTopSheen(canvas, const Offset(50, 38), isLight);
  }

  // ───────────────────────── PR-16 ROOK (topY = 18) ────────────────────
  // One silhouette: 3-tower top with 2 deep notches integrated, body
  // tapers slightly outward at the platform shoulders. Crenellations
  // are part of the path, not a separate battlement shape.
  void _paintRook(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    final path = Path()
      // Left tower top-left.
      ..moveTo(22, 18)
      // Left tower top-right.
      ..lineTo(36, 18)
      // Drop into left notch.
      ..lineTo(36, 30)
      ..lineTo(42, 30)
      // Up centre tower left.
      ..lineTo(42, 18)
      // Centre tower top-right.
      ..lineTo(58, 18)
      // Drop into right notch.
      ..lineTo(58, 30)
      ..lineTo(64, 30)
      // Up right tower left.
      ..lineTo(64, 18)
      // Right tower top-right.
      ..lineTo(78, 18)
      // Right side of body — slight outward taper to platform shoulder.
      ..lineTo(78, 60)
      ..lineTo(74, 68)
      // Platform.
      ..lineTo(_platTopRightX, _platTopY)
      ..lineTo(_platBottomRightX, _platBottomY)
      ..lineTo(_platBottomLeftX, _platBottomY)
      ..lineTo(_platTopLeftX, _platTopY)
      // Body left mirror.
      ..lineTo(26, 68)
      ..lineTo(22, 60)
      ..close();
    _drawSilhouette(canvas, path, fill, stroke);
    _paintTopSheen(canvas, const Offset(50, 42), isLight);
  }

  // ───────────────────────── PR-16 BISHOP (topY = 12) ──────────────────
  // One silhouette: pointed mitre + slim monastic body. The mitre slit
  // remains an internal diagonal stroke (the slit-as-silhouette-notch
  // option fragments the apex at 32 px; the diagonal stroke survives
  // PR-14's optical-scale boost at every size).
  void _paintBishop(
    Canvas canvas,
    Paint fill,
    Paint stroke,
    Color strokeColor,
    bool isLight,
  ) {
    final path = Path()
      // Mitre apex.
      ..moveTo(50, 12)
      // Right side of mitre curving down.
      ..quadraticBezierTo(58, 18, 62, 28)
      // Mitre base shoulder right.
      ..lineTo(64, 30)
      // Body shoulder taper.
      ..lineTo(62, 36)
      // Body right curve — slim.
      ..quadraticBezierTo(64, 50, 66, 64)
      ..lineTo(66, 68)
      // Platform.
      ..lineTo(_platTopRightX, _platTopY)
      ..lineTo(_platBottomRightX, _platBottomY)
      ..lineTo(_platBottomLeftX, _platBottomY)
      ..lineTo(_platTopLeftX, _platTopY)
      // Body left mirror.
      ..lineTo(34, 68)
      ..lineTo(34, 64)
      ..quadraticBezierTo(36, 50, 38, 36)
      ..lineTo(36, 30)
      ..lineTo(38, 28)
      ..quadraticBezierTo(42, 18, 50, 12)
      ..close();
    _drawSilhouette(canvas, path, fill, stroke);

    // PR-16 — mitre slit as a diagonal internal stroke (PR-14 idiom
    // preserved, slightly lengthened so it stays legible at 32 px).
    final slit = Path()
      ..moveTo(51, 16)
      ..lineTo(58, 23);
    final slitStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bodyStroke * 1.6
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(slit, slitStroke);

    _paintTopSheen(canvas, const Offset(50, 44), isLight);
  }

  // ───────────────────────── PR-16 KNIGHT (topY = 14) ──────────────────
  // One silhouette: equine head with the ear notch embedded in the
  // outline (no separate triangle path), neck flowing into body and
  // platform. Internal strokes: mane crease + short jaw line. Eye +
  // nostril dropped — sub-pixel below 32 px anyway, and the silhouette
  // now carries the identity.
  void _paintKnight(
    Canvas canvas,
    Paint fill,
    Paint stroke,
    Color strokeColor,
    bool isLight,
  ) {
    final path = Path()
      // Ear tip — load-bearing horse cue at every size.
      ..moveTo(64, 14)
      // Down the back of the ear to the main head.
      ..quadraticBezierTo(68, 20, 70, 24)
      // Top-back of head curving down.
      ..quadraticBezierTo(76, 30, 78, 38)
      // Straight neck-back.
      ..lineTo(78, 50)
      // Slight rounding into the body.
      ..quadraticBezierTo(78, 60, 76, 66)
      ..lineTo(76, 68)
      // Platform.
      ..lineTo(_platTopRightX, _platTopY)
      ..lineTo(_platBottomRightX, _platBottomY)
      ..lineTo(_platBottomLeftX, _platBottomY)
      ..lineTo(_platTopLeftX, _platTopY)
      // Body left bottom.
      ..lineTo(24, 68)
      ..lineTo(24, 64)
      // Under-chin curve.
      ..quadraticBezierTo(22, 60, 22, 56)
      // Tuck under the muzzle.
      ..lineTo(16, 54)
      // Down to the muzzle underside.
      ..lineTo(14, 48)
      // Muzzle tip protruding to the left.
      ..lineTo(18, 44)
      ..lineTo(22, 40)
      // Back along the muzzle top.
      ..lineTo(14, 38)
      // Up the bridge of the nose.
      ..lineTo(20, 32)
      // Forehead crest.
      ..lineTo(28, 30)
      // Forehead curve up to the crown.
      ..quadraticBezierTo(38, 22, 50, 22)
      // Crown to the inner side of the ear.
      ..quadraticBezierTo(58, 22, 62, 20)
      ..close();
    _drawSilhouette(canvas, path, fill, stroke);

    // PR-16 — mane crease (PR-14 alpha 0.55 preserved).
    final mane = Path()
      ..moveTo(58, 22)
      ..quadraticBezierTo(66, 32, 70, 50);
    final maneStroke = Paint()
      ..color = strokeColor.withValues(alpha: strokeColor.a * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bodyStroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(mane, maneStroke);

    // PR-16 — short jaw line, slightly lifted from PR-14 to track the
    // new under-chin curve.
    final jaw = Path()
      ..moveTo(22, 52)
      ..lineTo(32, 54);
    final jawStroke = Paint()
      ..color = strokeColor.withValues(alpha: strokeColor.a * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bodyStroke * 0.85
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(jaw, jawStroke);

    _paintTopSheen(canvas, const Offset(52, 30), isLight);
  }

  // ───────────────────────── PR-16 PAWN (topY = 30) ────────────────────
  // One silhouette: round head merging into a slim neck and gently
  // flaring body, blending into the platform. Smallest piece.
  void _paintPawn(Canvas canvas, Paint fill, Paint stroke, bool isLight) {
    final path = Path()
      // Top of head.
      ..moveTo(50, 30)
      // Right side of head down to neck.
      ..quadraticBezierTo(58, 30, 58, 38)
      // Neck right.
      ..lineTo(56, 44)
      // Body shoulder right.
      ..quadraticBezierTo(60, 52, 60, 60)
      ..quadraticBezierTo(60, 64, 60, 68)
      // Platform.
      ..lineTo(_platTopRightX, _platTopY)
      ..lineTo(_platBottomRightX, _platBottomY)
      ..lineTo(_platBottomLeftX, _platBottomY)
      ..lineTo(_platTopLeftX, _platTopY)
      // Body left mirror.
      ..lineTo(40, 68)
      ..quadraticBezierTo(40, 64, 40, 60)
      ..quadraticBezierTo(40, 52, 44, 44)
      ..lineTo(42, 38)
      ..quadraticBezierTo(42, 30, 50, 30)
      ..close();
    _drawSilhouette(canvas, path, fill, stroke);
    _paintTopSheen(canvas, const Offset(50, 36), isLight);
  }

  @override
  bool shouldRepaint(covariant _PiecePainter old) =>
      old.type != type || old.color != color || old.liftedScale != liftedScale;
}
