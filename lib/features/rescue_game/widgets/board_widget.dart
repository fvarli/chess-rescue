import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/piece.dart';
import '../../../core/models/square.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../game_state.dart';
import 'piece_widget.dart';

class BoardWidget extends StatefulWidget {
  const BoardWidget({
    super.key,
    required this.size,
    required this.pieces,
    required this.selected,
    required this.legalSquares,
    required this.state,
    required this.threatenedKing,
    required this.rescueTo,
    required this.commitInFlight,
    required this.resetInFlight,
    required this.onTapSquare,
    this.focusSquare,
    this.extendedSettle = false,
  });

  final double size;
  final List<Piece> pieces;
  final Piece? selected;
  final List<Square> legalSquares;
  final GameState state;
  final Square threatenedKing;
  final Square rescueTo;
  final bool commitInFlight;
  final bool resetInFlight;
  final void Function(int file, int rank) onTapSquare;

  // First-run only: a soft focus cue on this square during the opening danger
  // state (null disables it), and a slightly longer rescue settle.
  final Square? focusSquare;
  final bool extendedSettle;

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _dangerPulse;
  late final AnimationController _rescueBloom;
  late final AnimationController _rescueBreath;
  late final AnimationController _failedFlash;
  late final AnimationController _microShake;
  late final AnimationController _ambientBreath;

  late final Animation<double> _dangerPulseValue;

  // Sticky legal-move state so dots can fade out *after* the controller
  // has already cleared legalSquares.
  List<_StaggeredDot>? _stickyDots;

  Timer? _failedHoldTimer;

  @override
  void initState() {
    super.initState();
    _dangerPulse = AnimationController(
      vsync: this,
      duration: MotionTokens.dangerPulse,
    );
    _dangerPulseValue = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: MotionTokens.inhale)),
        weight: MotionTokens.dangerInhaleWeight * 100,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: MotionTokens.exhale)),
        weight: (1 - MotionTokens.dangerInhaleWeight) * 100,
      ),
    ]).animate(_dangerPulse);

    _rescueBloom = AnimationController(
      vsync: this,
      duration:
          MotionTokens.rescueBloom +
          MotionTokens.rescueSettle +
          (widget.extendedSettle
              ? MotionTokens.firstRescueSettleExtra
              : Duration.zero),
    );
    _rescueBreath = AnimationController(
      vsync: this,
      duration: MotionTokens.rescueBreathPeriod,
    );
    _failedFlash = AnimationController(
      vsync: this,
      duration: MotionTokens.failHold + MotionTokens.failFade,
    );
    _microShake = AnimationController(
      vsync: this,
      duration: MotionTokens.microShake,
    );
    _ambientBreath = AnimationController(
      vsync: this,
      duration: MotionTokens.ambientBreathDefault,
    );

    _dangerPulse.repeat();
    _retuneAmbientBreath();
    _syncStateAnimations(initial: true);
    _updateStickyDots();
  }

  @override
  void didUpdateWidget(covariant BoardWidget old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _syncStateAnimations(initial: false);
      _retuneAmbientBreath();
    }
    _updateStickyDots();
  }

  void _syncStateAnimations({required bool initial}) {
    switch (widget.state) {
      case GameState.rescued:
        _rescueBloom
          ..reset()
          ..forward().then((_) {
            if (mounted && widget.state == GameState.rescued) {
              _rescueBreath.repeat(reverse: true);
            }
          });
        _failedFlash.value = 0;
        _microShake.value = 0;
        break;
      case GameState.failed:
        _failedFlash
          ..reset()
          ..forward();
        _microShake
          ..reset()
          ..forward();
        _rescueBloom.value = 0;
        _rescueBreath.stop();
        break;
      case GameState.danger:
      case GameState.selected:
        _rescueBloom.value = 0;
        _rescueBreath.stop();
        _failedFlash.value = 0;
        _microShake.value = 0;
        break;
    }
  }

  void _retuneAmbientBreath() {
    _failedHoldTimer?.cancel();
    if (widget.state == GameState.failed) {
      _ambientBreath.stop();
      _ambientBreath.value = 0;
      _failedHoldTimer = Timer(MotionTokens.ambientHoldOnFail, () {
        if (mounted && widget.state == GameState.failed) {
          _ambientBreath
            ..duration = MotionTokens.ambientBreathDefault
            ..repeat(reverse: true);
        }
      });
      return;
    }
    final period = widget.state == GameState.rescued
        ? MotionTokens.ambientBreathCalm
        : MotionTokens.ambientBreathDefault;
    _ambientBreath
      ..stop()
      ..duration = period
      ..repeat(reverse: true);
  }

  void _updateStickyDots() {
    if (widget.selected != null && widget.legalSquares.isNotEmpty) {
      final origin = Square(widget.selected!.file, widget.selected!.rank);
      final sorted = _staggerSort(origin, widget.legalSquares);
      _stickyDots = [
        for (int i = 0; i < sorted.length; i++)
          _StaggeredDot(square: sorted[i], index: i),
      ];
    } else if (widget.state == GameState.danger &&
        !widget.commitInFlight &&
        !widget.resetInFlight &&
        widget.selected == null) {
      _stickyDots = null;
    }
  }

  List<Square> _staggerSort(Square origin, List<Square> squares) {
    int distance(Square s) =>
        (s.file - origin.file).abs() + (s.rank - origin.rank).abs();
    final list = [...squares]
      ..sort((a, b) {
        final da = distance(a);
        final db = distance(b);
        if (da != db) return da - db;
        if (a.file != b.file) return a.file - b.file;
        return a.rank - b.rank;
      });
    return list;
  }

  @override
  void dispose() {
    _failedHoldTimer?.cancel();
    _dangerPulse.dispose();
    _rescueBloom.dispose();
    _rescueBreath.dispose();
    _failedFlash.dispose();
    _microShake.dispose();
    _ambientBreath.dispose();
    super.dispose();
  }

  double get _sq => widget.size / 8;

  Offset _squareOrigin(int file, int rank) =>
      Offset(file * _sq, (7 - rank) * _sq);

  double _liftFor(Piece p) {
    if (widget.selected?.id == p.id) {
      return MotionTokens.pieceLiftedScale;
    }
    // Any rescuing piece (knight/pawn/bishop/rook) holds a lift on its
    // destination square once the rescue lands.
    if (widget.state == GameState.rescued &&
        p.color == PieceColor.light &&
        p.file == widget.rescueTo.file &&
        p.rank == widget.rescueTo.rank) {
      return MotionTokens.rescuedLiftedScale;
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.boardDark,
          boxShadow: const [
            BoxShadow(
              color: AppColors.boardShadow,
              offset: Offset(0, 30),
              blurRadius: 60,
            ),
          ],
          border: Border.all(color: AppColors.hairline, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedBuilder(
            animation: _ambientBreath,
            builder: (context, child) {
              final scale = _lerp(
                MotionTokens.ambientScaleMin,
                MotionTokens.ambientScaleMax,
                MotionTokens.breath.transform(_ambientBreath.value),
              );
              return Transform.scale(scale: scale, child: child);
            },
            child: Stack(
              children: [
                _buildSquares(),
                _buildGridLines(),
                _buildDangerGlow(),
                _buildFailedFlash(),
                _buildRescueGlow(),
                _buildFocusCue(),
                if (widget.selected != null) _buildSelectedRing(),
                ..._buildLegalDots(),
                ..._buildPieces(),
                _buildTapLayer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquares() {
    final cells = <Widget>[];
    for (int j = 0; j < 8; j++) {
      for (int i = 0; i < 8; i++) {
        final file = i;
        final rank = 7 - j;
        final isLight = (file + rank) % 2 == 1;
        cells.add(
          Positioned(
            left: i * _sq,
            top: j * _sq,
            width: _sq,
            height: _sq,
            child: ColoredBox(
              color: isLight ? AppColors.boardLight : AppColors.boardDark,
            ),
          ),
        );
      }
    }
    return Stack(children: cells);
  }

  Widget _buildGridLines() {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _GridPainter(squareSize: _sq),
      ),
    );
  }

  Widget _buildDangerGlow() {
    if (widget.state != GameState.danger &&
        widget.state != GameState.selected) {
      return const SizedBox.shrink();
    }
    if (widget.resetInFlight) return const SizedBox.shrink();
    final origin = _squareOrigin(
      widget.threatenedKing.file,
      widget.threatenedKing.rank,
    );
    return AnimatedBuilder(
      animation: _dangerPulseValue,
      builder: (context, _) {
        final t = _dangerPulseValue.value;
        final alpha = _lerp(
          MotionTokens.dangerAlphaMin,
          MotionTokens.dangerAlphaMax,
          t,
        );
        final blur =
            _lerp(
              MotionTokens.dangerBlurMinFactor,
              MotionTokens.dangerBlurMaxFactor,
              t,
            ) *
            _sq;
        final scale = _lerp(
          MotionTokens.dangerScaleMin,
          MotionTokens.dangerScaleMax,
          t,
        );
        return Positioned(
          left: origin.dx,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.danger, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: alpha),
                      blurRadius: blur,
                      spreadRadius: _sq * 0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFailedFlash() {
    if (widget.state != GameState.failed) return const SizedBox.shrink();
    final origin = _squareOrigin(
      widget.threatenedKing.file,
      widget.threatenedKing.rank,
    );
    final holdEnd =
        MotionTokens.failHold.inMilliseconds /
        (MotionTokens.failHold + MotionTokens.failFade).inMilliseconds;
    final overlayFade = widget.resetInFlight ? 0.0 : 1.0;
    return AnimatedBuilder(
      animation: Listenable.merge([_failedFlash, _microShake]),
      builder: (context, _) {
        final v = _failedFlash.value;
        final intensity = v < holdEnd
            ? 1.0
            : MotionTokens.standard.transform(
                1 - ((v - holdEnd) / (1 - holdEnd)).clamp(0.0, 1.0),
              );
        final shakeT = _microShake.value;
        final shakeOffset = shakeT > 0 && shakeT < 1
            ? math.sin(shakeT * math.pi * 2 * MotionTokens.microShakeCycles) *
                  MotionTokens.microShakeAmplitudePx
            : 0.0;
        return Positioned(
          left: origin.dx + shakeOffset,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: overlayFade),
              duration: MotionTokens.resetOverlayFade,
              curve: MotionTokens.standard,
              builder: (context, mask, child) =>
                  Opacity(opacity: mask * intensity, child: child),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.45),
                  border: Border.all(color: AppColors.danger, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.6),
                      blurRadius: _sq * 0.9,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRescueGlow() {
    if (widget.state != GameState.rescued) return const SizedBox.shrink();
    final origin = _squareOrigin(widget.rescueTo.file, widget.rescueTo.rank);

    // Use the live controller duration so the bloom stays fixed at
    // rescueBloom ms and only the settle phase stretches on first run.
    final bloomTotal =
        (_rescueBloom.duration ??
                (MotionTokens.rescueBloom + MotionTokens.rescueSettle))
            .inMilliseconds
            .toDouble();
    final bloomEnd = MotionTokens.rescueBloom.inMilliseconds / bloomTotal;
    final overlayFade = widget.resetInFlight ? 0.0 : 1.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_rescueBloom, _rescueBreath]),
      builder: (context, _) {
        // Phase 1+2 (bloom→settle) drives scale & alpha until rescueBloom done.
        // Phase 3 (breath) takes over on completion.
        final bloomDone = _rescueBloom.isCompleted;
        late double scale;
        late double alpha;
        if (!bloomDone) {
          final v = _rescueBloom.value;
          if (v <= bloomEnd) {
            // Bloom phase
            final n = (v / bloomEnd).clamp(0.0, 1.0);
            final t = MotionTokens.standard.transform(n);
            scale = _lerp(1.0, MotionTokens.rescueScalePeak, t);
            alpha = _lerp(0.0, MotionTokens.rescueGlowPeak, t);
          } else {
            // Settle phase
            final n = ((v - bloomEnd) / (1 - bloomEnd)).clamp(0.0, 1.0);
            final t = MotionTokens.standard.transform(n);
            scale = _lerp(
              MotionTokens.rescueScalePeak,
              MotionTokens.rescueScaleSettled,
              t,
            );
            alpha = _lerp(
              MotionTokens.rescueGlowPeak,
              MotionTokens.rescueGlowSettled,
              t,
            );
          }
        } else {
          final b = MotionTokens.breath.transform(_rescueBreath.value);
          scale = _lerp(1.0, MotionTokens.rescueScaleSettled, b);
          alpha = _lerp(
            MotionTokens.rescueGlowBreathMin,
            MotionTokens.rescueGlowBreathMax,
            b,
          );
        }
        return Positioned(
          left: origin.dx,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: overlayFade),
              duration: MotionTokens.resetOverlayFade,
              curve: MotionTokens.standard,
              builder: (context, mask, child) =>
                  Opacity(opacity: mask, child: child),
              child: Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.rescue.withValues(alpha: 0.18),
                    border: Border.all(color: AppColors.rescue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rescue.withValues(alpha: alpha),
                        blurRadius: _sq,
                        spreadRadius: _sq * 0.06,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // First-run only: a soft breathing accent glow drawing the eye to the
  // rescuing piece. Fades out gently the moment a piece is selected.
  Widget _buildFocusCue() {
    final fs = widget.focusSquare;
    if (fs == null) return const SizedBox.shrink();
    final visible = widget.state == GameState.danger && widget.selected == null;
    final origin = _squareOrigin(fs.file, fs.rank);
    return Positioned(
      left: origin.dx,
      top: origin.dy,
      width: _sq,
      height: _sq,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: MotionTokens.focusCueFade,
          curve: MotionTokens.standard,
          child: AnimatedBuilder(
            animation: _dangerPulseValue,
            builder: (context, _) {
              final t = _dangerPulseValue.value;
              final glow = _lerp(
                MotionTokens.focusCueAlphaMin,
                MotionTokens.focusCueAlphaMax,
                t,
              );
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(
                    alpha: MotionTokens.focusCueFillAlpha,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: glow),
                      blurRadius: _sq * 0.6,
                      spreadRadius: _sq * 0.02,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedRing() {
    final sel = widget.selected!;
    final origin = _squareOrigin(sel.file, sel.rank);
    // During commit, contract the ring (scale 0.96, opacity 0.6) — the wind-up.
    final contracted = widget.commitInFlight;
    final targetScale = contracted ? MotionTokens.ringContractScale : 1.0;
    final targetOpacity = contracted ? MotionTokens.ringContractOpacity : 1.0;
    return Positioned(
      left: origin.dx,
      top: origin.dy,
      width: _sq,
      height: _sq,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          // begin seeds the first build only — the ring scales in 0.94→1.0 on
          // appearance; the contract-on-commit animates from the live value.
          tween: Tween<double>(
            begin: MotionTokens.ringStartScale,
            end: targetScale,
          ),
          duration: contracted
              ? MotionTokens.commitWindUp
              : MotionTokens.ringIn,
          curve: MotionTokens.standard,
          builder: (context, scale, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: targetOpacity),
              duration: contracted
                  ? MotionTokens.commitWindUp
                  : MotionTokens.ringIn,
              curve: MotionTokens.standard,
              builder: (context, opacity, _) {
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.accent,
                          width: MotionTokens.ringBorderWidth,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildLegalDots() {
    final dots = _stickyDots;
    if (dots == null) return const [];
    final visible =
        widget.legalSquares.isNotEmpty &&
        !widget.commitInFlight &&
        !widget.resetInFlight &&
        widget.selected != null;

    final occupiedSquares = {
      for (final p in widget.pieces) Square(p.file, p.rank),
    };
    final totalDotIn =
        MotionTokens.dotStaggerStep * (dots.length - 1) + MotionTokens.dotBloom;

    return [
      for (final d in dots)
        _LegalDot(
          key: ValueKey('dot-${d.square.file}-${d.square.rank}'),
          square: d.square,
          origin: _squareOrigin(d.square.file, d.square.rank),
          sq: _sq,
          occupied: occupiedSquares.contains(d.square),
          visible: visible,
          staggerDelay: MotionTokens.dotStaggerStep * d.index,
          totalInDuration: totalDotIn,
        ),
    ];
  }

  List<Widget> _buildPieces() {
    final centerPad = _sq * 0.08;
    final pieceSize = _sq * 0.84;
    return [
      for (final p in widget.pieces)
        AnimatedPositioned(
          key: ValueKey('piece-${p.id}'),
          left: p.file * _sq,
          top: (7 - p.rank) * _sq,
          width: _sq,
          height: _sq,
          duration: MotionTokens.pieceSlide,
          curve: MotionTokens.slide,
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(centerPad),
              child: PieceWidget(
                piece: p,
                size: pieceSize,
                liftedScale: _liftFor(p),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildTapLayer() {
    final locked = widget.commitInFlight || widget.resetInFlight;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: locked,
        child: GridView.count(
          crossAxisCount: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int j = 0; j < 8; j++)
              for (int i = 0; i < 8; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTapSquare(i, 7 - j),
                  child: const SizedBox.expand(),
                ),
          ],
        ),
      ),
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

class _StaggeredDot {
  const _StaggeredDot({required this.square, required this.index});
  final Square square;
  final int index;
}

class _LegalDot extends StatelessWidget {
  const _LegalDot({
    super.key,
    required this.square,
    required this.origin,
    required this.sq,
    required this.occupied,
    required this.visible,
    required this.staggerDelay,
    required this.totalInDuration,
  });

  final Square square;
  final Offset origin;
  final double sq;
  final bool occupied;
  final bool visible;
  final Duration staggerDelay;
  final Duration totalInDuration;

  @override
  Widget build(BuildContext context) {
    final inFraction =
        staggerDelay.inMilliseconds /
        totalInDuration.inMilliseconds.clamp(1, double.maxFinite).toInt();
    final inCurve = Interval(
      inFraction.clamp(0.0, 0.999),
      1.0,
      curve: MotionTokens.standard,
    );
    return Positioned(
      left: origin.dx,
      top: origin.dy,
      width: sq,
      height: sq,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          // begin seeds the first build so dots fan in (0→1) with the staggered
          // inCurve + 0.6→1.0 bloom; the commit fade-out animates from 1→0.
          tween: Tween<double>(begin: 0.0, end: visible ? 1.0 : 0.0),
          duration: visible ? totalInDuration : MotionTokens.commitDotFadeOut,
          curve: visible ? inCurve : Curves.easeOut,
          builder: (context, t, _) {
            final scale = _lerp(MotionTokens.dotStartScale, 1.0, t);
            return Opacity(
              opacity: t,
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: occupied
                      ? Container(
                          width: sq * 0.86,
                          height: sq * 0.86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.8),
                              width: 2,
                            ),
                          ),
                        )
                      : Container(
                          width: sq * 0.28,
                          height: sq * 0.28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.squareSize});

  final double squareSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 0.5;
    for (int k = 1; k < 8; k++) {
      final x = k * squareSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      final y = k * squareSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.squareSize != squareSize;
}
