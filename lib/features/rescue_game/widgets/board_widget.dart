import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/piece.dart';
import '../../../core/models/square.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/tokens.dart';
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
    this.focusCueIsAmbient = false,
    this.extendedSettle = false,
    this.lastMoveFrom,
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

  // A soft focus cue on this square during the danger state (null disables
  // it). Intensity is controlled by [focusCueIsAmbient]: false uses the
  // louder onboarding range; true uses the damped post-onboarding range.
  final Square? focusSquare;
  // When true, the focus cue uses the quieter ambient alpha range
  // (post-onboarding). When false, the louder onboarding range is used.
  final bool focusCueIsAmbient;
  // First-run only: a slightly longer rescue settle so the first survival
  // lingers.
  final bool extendedSettle;

  // Origin square of the rescuer piece for the just-committed move. Drives
  // the cinematic move-arrow that draws from origin → rescueTo during the
  // rescued state. Null suppresses the arrow.
  final Square? lastMoveFrom;

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
  // V2 — transient effects layered on top of the existing rescue/failure
  // animations. Each ticks only during its ≤520 ms forward run.
  late final AnimationController _rescueRing;
  late final AnimationController _failRim;
  // G1.3 — one-shot scale pulse on the threatened king piece itself when
  // state transitions to rescued. Paired with the existing rescueBloom (which
  // paints the square); together the figure and its ground respond.
  late final AnimationController _kingPulse;
  // Post-rescue cinematic confirmation arrow. Three-phase sequence: draw-in,
  // strong hold, fade to a calmer presence. Driven by a single controller;
  // the painter derives shaft-progress + alpha per frame.
  late final AnimationController _moveArrow;
  // PR-5 ambient layers. Long-period repeating controllers that drive a
  // ±1.5% brightness sine on the board material and a slow elliptical
  // light drift. The grain overlay shares the brightness controller.
  late final AnimationController _ambientBrightness;
  late final AnimationController _ambientLightDrift;
  // Brief pause on rescue transition before the brightness resumes at a
  // softer amplitude — the board's "exhale."
  Timer? _ambientExhaleTimer;
  // PR-10B.1 — selection halo breath. Runs only while a piece is selected
  // and not committing; stopped + reset otherwise so reads land on a
  // stable baseline.
  late final AnimationController _selectionBreath;
  // PR-10B.2 — tactile closure on successful rescue.
  // _releaseSettle: 90 ms sine bell on the rescuer piece's scale.
  // _arrivalMemory: 160 ms faint mint trace on the destination square.
  // Both fire on the danger → rescued transition, gated by !initial.
  late final AnimationController _releaseSettle;
  late final AnimationController _arrivalMemory;

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
    _rescueRing = AnimationController(
      vsync: this,
      duration: MotionTokens.rescueRingExpand,
    );
    _failRim = AnimationController(
      vsync: this,
      duration:
          MotionTokens.failRimIn +
          MotionTokens.failRimHold +
          MotionTokens.failRimOut,
    );
    _kingPulse = AnimationController(
      vsync: this,
      duration: MotionTokens.kingRescuePulse,
    );
    _moveArrow = AnimationController(
      vsync: this,
      duration:
          MotionTokens.moveArrowDraw +
          MotionTokens.moveArrowHold +
          MotionTokens.moveArrowFade,
    );
    _ambientBrightness = AnimationController(
      vsync: this,
      duration: MotionTokens.ambientBrightnessPeriod,
    )..repeat();
    _ambientLightDrift = AnimationController(
      vsync: this,
      duration: MotionTokens.ambientLightDriftPeriod,
    )..repeat();
    _selectionBreath = AnimationController(
      vsync: this,
      // Period / 2 with repeat(reverse: true) gives a time-symmetric
      // breath whose full cycle equals selectedHaloBreathPeriod.
      duration: Duration(
        milliseconds: MotionTokens.selectedHaloBreathPeriod.inMilliseconds ~/ 2,
      ),
    );
    _releaseSettle = AnimationController(
      vsync: this,
      duration: MotionTokens.releaseSettleDuration,
    );
    _arrivalMemory = AnimationController(
      vsync: this,
      duration: MotionTokens.arrivalMemoryDuration,
    );

    _dangerPulse.repeat();
    _retuneAmbientBreath();
    _syncStateAnimations(initial: true);
    _syncSelectionBreath();
    _updateStickyDots();
  }

  @override
  void didUpdateWidget(covariant BoardWidget old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _syncStateAnimations(initial: false);
      _retuneAmbientBreath();
    }
    _syncSelectionBreath();
    _updateStickyDots();
  }

  // PR-10B.1 — gate the selection halo breath on the current selection.
  // Runs only when a piece is selected and no commit is in flight.
  void _syncSelectionBreath() {
    final shouldBreathe = widget.selected != null && !widget.commitInFlight;
    if (shouldBreathe && !_selectionBreath.isAnimating) {
      _selectionBreath.repeat(reverse: true);
    } else if (!shouldBreathe && _selectionBreath.isAnimating) {
      _selectionBreath.stop();
      _selectionBreath.value = 0;
    }
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
        // V2 — fire the expansion ring once on transition. Skip on initial
        // build so re-mounting a settled "rescued" state doesn't re-animate.
        if (!initial) {
          _rescueRing
            ..reset()
            ..forward();
          // G1.3 — same gating; the king-piece scale pulse only fires on
          // genuine danger → rescued transitions, never on first mount of an
          // already-rescued screen.
          _kingPulse
            ..reset()
            ..forward();
          // Same gating for the cinematic move arrow.
          _moveArrow
            ..reset()
            ..forward();
          // PR-10B.2 — release settle on the rescuer piece, arrival
          // memory trace on the destination square. Same gating: real
          // commit transitions only.
          _releaseSettle
            ..reset()
            ..forward();
          _arrivalMemory
            ..reset()
            ..forward();
          // Ambient exhale: pause brightness for a brief emotional beat,
          // then resume at the softer rescued amplitude (handled in the
          // painter). The light drift is never paused.
          _ambientBrightness.stop();
          _ambientExhaleTimer?.cancel();
          _ambientExhaleTimer = Timer(MotionTokens.ambientRescueExhale, () {
            if (mounted && widget.state == GameState.rescued) {
              _ambientBrightness.repeat();
            }
          });
        }
        _failedFlash.value = 0;
        _microShake.value = 0;
        _failRim.value = 0;
        break;
      case GameState.failed:
        _failedFlash
          ..reset()
          ..forward();
        _microShake
          ..reset()
          ..forward();
        // V2 — fire the rim flash once on transition.
        if (!initial) {
          _failRim
            ..reset()
            ..forward();
        }
        _rescueBloom.value = 0;
        _rescueBreath.stop();
        _rescueRing.value = 0;
        _kingPulse.value = 0;
        _moveArrow.value = 0;
        _releaseSettle.value = 0;
        _arrivalMemory.value = 0;
        _ensureAmbientBrightnessRunning();
        break;
      case GameState.danger:
      case GameState.selected:
        _rescueBloom.value = 0;
        _rescueBreath.stop();
        _failedFlash.value = 0;
        _microShake.value = 0;
        _rescueRing.value = 0;
        _failRim.value = 0;
        _kingPulse.value = 0;
        _moveArrow.value = 0;
        _releaseSettle.value = 0;
        _arrivalMemory.value = 0;
        _ensureAmbientBrightnessRunning();
        break;
    }
  }

  // Resume the brightness controller from its current value if a prior
  // rescued-state pause left it stopped. Cancels any pending exhale timer.
  void _ensureAmbientBrightnessRunning() {
    _ambientExhaleTimer?.cancel();
    _ambientExhaleTimer = null;
    if (!_ambientBrightness.isAnimating) {
      _ambientBrightness.repeat();
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
    _rescueRing.dispose();
    _failRim.dispose();
    _kingPulse.dispose();
    _moveArrow.dispose();
    _ambientExhaleTimer?.cancel();
    _ambientBrightness.dispose();
    _ambientLightDrift.dispose();
    _selectionBreath.dispose();
    _releaseSettle.dispose();
    _arrivalMemory.dispose();
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
          color: ColorTokens.boardDark,
          boxShadow: const [
            BoxShadow(
              color: ColorTokens.boardShadow,
              offset: Offset(0, 22),
              blurRadius: 48,
              spreadRadius: -2,
            ),
          ],
          border: Border.all(color: AppColors.hairline, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
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
                // PR-5 ambient layer: brightness breath + slow light drift.
                // Tints the raw board material; grid / grain / vignette /
                // gameplay overlays all draw on top.
                _buildAmbient(),
                _buildGridLines(),
                // V1 surface polish: tiled grain → "made of something" read.
                _buildGrainOverlay(),
                // V1 depth polish: soft inner vignette deepens the edges
                // without dimming the centre (where the action lives).
                _buildInnerVignette(),
                _buildInnerBezel(),
                // PR-10B.2 — arrival memory: faint mint trace on the
                // rescue destination square. Bottom-most rescue layer; the
                // arrow, glow, ring, pieces, and dots all draw on top.
                _buildArrivalMemory(),
                // Cinematic move-arrow sits low — above the board surface,
                // below every gameplay-state overlay — so pieces, glows, and
                // rings overlay it cleanly. The arrow connects; it does not
                // crown.
                _buildMoveArrow(),
                _buildDangerGlow(),
                _buildFailedFlash(),
                // V2 — coral rim flashes once on failed commits. Sits above
                // the king's failure flash so it reads as a *boardwide*
                // signal, not a local one.
                _buildFailureRim(),
                _buildRescueGlow(),
                // V2 — mint ring radiates outward from the rescue square at
                // commit. Sits just above the glow so glow + ring read as
                // concentric.
                _buildRescueRing(),
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

  // V1 surface polish — a tiled, low-alpha grain that lifts the checker from
  // "flat colour blocks" to "made of something." Sits above the squares /
  // grid lines but beneath every gameplay overlay (danger glow, rescue glow,
  // focus cue, pieces) so it never competes with the action.
  Widget _buildGrainOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ambientBrightness,
          builder: (context, _) {
            final phase = math.sin(2 * math.pi * _ambientBrightness.value);
            final opacity = (0.45 + phase * MotionTokens.ambientGrainAmplitude)
                .clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/textures/board-grain.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // PR-5 ambient layer — two felt-but-not-seen overlays. Brightness
  // crossfade (white/black @ ±1.5%, ~7s period) + slow elliptical light
  // drift (~28s). Sits below grid/grain/vignette/gameplay so every
  // existing layer's contrast is preserved.
  Widget _buildAmbient() {
    return Positioned.fill(
      key: const ValueKey('ambient-layer'),
      child: IgnorePointer(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _ambientBrightness,
              builder: (context, _) {
                final phase = math.sin(2 * math.pi * _ambientBrightness.value);
                final effective =
                    MotionTokens.ambientBrightnessAmplitude *
                    (widget.state == GameState.rescued
                        ? MotionTokens.ambientRescuedAmplitudeMul
                        : 1.0);
                final whiteAlpha = phase > 0 ? phase * effective : 0.0;
                final blackAlpha = phase < 0 ? -phase * effective : 0.0;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: whiteAlpha),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: blackAlpha),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            AnimatedBuilder(
              animation: _ambientLightDrift,
              builder: (context, _) {
                final t = _ambientLightDrift.value;
                final cx = math.cos(2 * math.pi * t) * 0.4;
                final cy = math.sin(2 * math.pi * t * 0.7) * 0.3;
                return Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(cx, cy),
                        radius: 1.2,
                        colors: [
                          Colors.white.withValues(
                            alpha: MotionTokens.ambientLightDriftPeakAlpha,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // V1 depth polish — soft inner vignette that deepens the board edges at
  // ~6 % alpha and is fully transparent through the center 55 % of the
  // board, so danger glow / mint bloom continue to dominate.
  Widget _buildInnerVignette() {
    return const Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.95,
              colors: [Color(0x00000000), Color(0x1C000000)],
              stops: [0.62, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  // Hairline inset stroke that reads as the polished inner edge of the
  // board frame. ~6% white is barely visible; the eye registers the edge
  // as a felt bezel, not a drawn line.
  Widget _buildInnerBezel() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 0.5, color: const Color(0x0FEAEAF2)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquares() {
    // Gate coordinate labels on a minimum board size so they never read as
    // noise on tiny embedded previews. 280 covers every BoardWidget consumer
    // in the current screens.
    final showCoords = widget.size >= 280;
    final cells = <Widget>[];
    for (int j = 0; j < 8; j++) {
      for (int i = 0; i < 8; i++) {
        final file = i;
        final rank = 7 - j;
        final isLight = (file + rank) % 2 == 1;
        final baseColor = isLight
            ? ColorTokens.boardLight
            : ColorTokens.boardDark;
        // Asymmetric gradient: light squares symmetric ±3% (polished tile);
        // dark squares lift +6% at top, -2% at bottom (perceptual ground for
        // dark pieces without changing the body color identity).
        final topColor = isLight
            ? Color.lerp(baseColor, Colors.white, 0.03)!
            : Color.lerp(baseColor, Colors.white, 0.06)!;
        final bottomColor = isLight
            ? Color.lerp(baseColor, Colors.black, 0.03)!
            : Color.lerp(baseColor, Colors.black, 0.02)!;
        cells.add(
          Positioned(
            left: i * _sq,
            top: j * _sq,
            width: _sq,
            height: _sq,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor],
                ),
              ),
              child: showCoords ? _coordOverlay(file: file, rank: rank) : null,
            ),
          ),
        );
      }
    }
    return Stack(children: cells);
  }

  // Engraved coordinate labels — files (a–h) inside the bottom edge of
  // rank-0 squares; ranks (1–8) inside the top edge of file-0 squares.
  // Effective alpha ~19% (coordinateAccent 35% × Opacity 0.55) so they feel
  // engraved into the board rather than overlaid as labels.
  Widget? _coordOverlay({required int file, required int rank}) {
    final isBottomRow = rank == 0;
    final isLeftCol = file == 0;
    if (!isBottomRow && !isLeftCol) return null;
    final pad = _sq * 0.06;
    final children = <Widget>[];
    if (isBottomRow) {
      children.add(
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: pad, bottom: pad * 0.6),
            child: _coordLabel(_fileLetter(file)),
          ),
        ),
      );
    }
    if (isLeftCol) {
      children.add(
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left: pad, top: pad * 0.6),
            child: _coordLabel('${rank + 1}'),
          ),
        ),
      );
    }
    return IgnorePointer(child: Stack(children: children));
  }

  Widget _coordLabel(String text) => Opacity(
    opacity: 0.55,
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 9,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: ColorTokens.coordinateAccent,
        height: 1.0,
      ),
    ),
  );

  static String _fileLetter(int file) =>
      const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'][file];

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

  // V2 — coral rim flash on failed commits. Fires once via `_failRim`;
  // boardwide border at low alpha so the player reads it as "that didn't
  // rescue" without any shame register. IgnorePointer so the tap layer keeps
  // responding throughout the 370 ms.
  Widget _buildFailureRim() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _failRim,
          builder: (context, _) {
            final t = _failRim.value;
            if (t == 0) return const SizedBox.shrink();
            final total =
                MotionTokens.failRimIn.inMilliseconds +
                MotionTokens.failRimHold.inMilliseconds +
                MotionTokens.failRimOut.inMilliseconds;
            final inEnd = MotionTokens.failRimIn.inMilliseconds / total;
            final holdEnd =
                (MotionTokens.failRimIn.inMilliseconds +
                    MotionTokens.failRimHold.inMilliseconds) /
                total;
            // 3-segment ramp: ease in → hold → ease out.
            final double k = t <= inEnd
                ? Curves.easeOutCubic.transform(t / inEnd)
                : t <= holdEnd
                ? 1.0
                : 1.0 -
                      Curves.easeInCubic.transform(
                        (t - holdEnd) / (1.0 - holdEnd),
                      );
            final alpha = k * MotionTokens.failRimAlphaPeak;
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: alpha),
                  width: MotionTokens.failRimWidthPx,
                ),
              ),
            );
          },
        ),
      ),
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
            // Bloom phase — PR-9A: easeOutQuart for "grow / slow / linger".
            final n = (v / bloomEnd).clamp(0.0, 1.0);
            final t = CurveTokens.entrance.transform(n);
            scale = _lerp(1.0, MotionTokens.rescueScalePeak, t);
            alpha = _lerp(0.0, MotionTokens.rescueGlowPeak, t);
          } else {
            // Settle phase — PR-9A: easeOutQuart continues the exhale.
            final n = ((v - bloomEnd) / (1 - bloomEnd)).clamp(0.0, 1.0);
            final t = CurveTokens.entrance.transform(n);
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
  // V2 — single mint expansion ring radiating from the rescue square at
  // commit. Quiet pride; not a fireworks show. Drawn via CustomPaint backed
  // by the dedicated `_rescueRing` controller (520 ms forward run).
  Widget _buildRescueRing() {
    final centerOrigin = _squareOrigin(
      widget.rescueTo.file,
      widget.rescueTo.rank,
    );
    final center = Offset(centerOrigin.dx + _sq / 2, centerOrigin.dy + _sq / 2);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _rescueRing,
          builder: (context, _) => CustomPaint(
            painter: _RescueRingPainter(
              visible: widget.state == GameState.rescued,
              t: Curves.easeOutCubic.transform(_rescueRing.value),
              center: center,
              squareSize: _sq,
            ),
          ),
        ),
      ),
    );
  }

  // PR-10B.2 — faint mint trace on the rescue destination square that
  // decays linearly over arrivalMemoryDuration. Sits bottom-most in the
  // rescue-effect stack so the arrow, glow, ring, focus cue, selection
  // ring, legal dots, and pieces all draw on top. Subliminal closure —
  // the board remembers where the rescue landed for a breath.
  Widget _buildArrivalMemory() {
    return AnimatedBuilder(
      animation: _arrivalMemory,
      builder: (context, _) {
        final t = _arrivalMemory.value;
        if (t <= 0.0 || t >= 1.0) return const SizedBox.shrink();
        final alpha = MotionTokens.arrivalMemoryPeakAlpha * (1 - t);
        final origin = _squareOrigin(
          widget.rescueTo.file,
          widget.rescueTo.rank,
        );
        return Positioned(
          left: origin.dx,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ColorTokens.reliefPrimary.withValues(alpha: alpha),
                borderRadius: RadiusTokens.brSmall,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoveArrow() {
    final from = widget.lastMoveFrom;
    if (widget.state != GameState.rescued ||
        from == null ||
        (from.file == widget.rescueTo.file &&
            from.rank == widget.rescueTo.rank)) {
      return const SizedBox.shrink(key: ValueKey('move-arrow-hidden'));
    }
    final originOrigin = _squareOrigin(from.file, from.rank);
    final destOrigin = _squareOrigin(
      widget.rescueTo.file,
      widget.rescueTo.rank,
    );
    final originCenter = Offset(
      originOrigin.dx + _sq / 2,
      originOrigin.dy + _sq / 2,
    );
    final destCenter = Offset(destOrigin.dx + _sq / 2, destOrigin.dy + _sq / 2);
    final totalMs =
        (MotionTokens.moveArrowDraw +
                MotionTokens.moveArrowHold +
                MotionTokens.moveArrowFade)
            .inMilliseconds;
    final drawEnd = MotionTokens.moveArrowDraw.inMilliseconds / totalMs;
    final holdEnd =
        (MotionTokens.moveArrowDraw + MotionTokens.moveArrowHold)
            .inMilliseconds /
        totalMs;
    return Positioned.fill(
      key: const ValueKey('move-arrow'),
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _moveArrow,
          builder: (context, _) => CustomPaint(
            painter: _MoveArrowPainter(
              sequenceProgress: _moveArrow.value,
              originCenter: originCenter,
              destCenter: destCenter,
              squareSize: _sq,
              color: ColorTokens.reliefPrimary,
              drawEnd: drawEnd,
              holdEnd: holdEnd,
              peakAlpha: MotionTokens.moveArrowPeakAlpha,
              settledAlpha: MotionTokens.moveArrowSettledAlpha,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusCue() {
    final fs = widget.focusSquare;
    if (fs == null) return const SizedBox.shrink();
    final visible = widget.state == GameState.danger && widget.selected == null;
    final origin = _squareOrigin(fs.file, fs.rank);
    final alphaMin = widget.focusCueIsAmbient
        ? MotionTokens.focusCueAmbientAlphaMin
        : MotionTokens.focusCueAlphaMin;
    final alphaMax = widget.focusCueIsAmbient
        ? MotionTokens.focusCueAmbientAlphaMax
        : MotionTokens.focusCueAlphaMax;
    return Positioned(
      key: const ValueKey('focus-cue'),
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
              final glow = _lerp(alphaMin, alphaMax, t);
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
                // PR-10B.1 — gentle fill-alpha breath. Contract phase
                // suppresses the breath at midpoint; the contract is its
                // own statement and the breath shouldn't compete.
                return AnimatedBuilder(
                  animation: _selectionBreath,
                  builder: (context, _) {
                    final breathT = contracted
                        ? 0.5
                        : MotionTokens.breath.transform(_selectionBreath.value);
                    final fillAlpha = _lerp(
                      MotionTokens.selectedHaloMinAlpha,
                      MotionTokens.selectedHaloMaxAlpha,
                      breathT,
                    );
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(
                              alpha: fillAlpha,
                            ),
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
    final selected = widget.selected;
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
              child: AnimatedOpacity(
                // PR-10B.1 — non-selected friendly non-king pieces
                // gently recede to clarify the rescue piece. King never
                // dims (danger / rescue signaling preserved). Opponents
                // never dim.
                opacity:
                    (selected != null &&
                        p.color == PieceColor.light &&
                        p.type != PieceType.king &&
                        p.id != selected.id)
                    ? MotionTokens.nonSelectedFriendlyOpacity
                    : 1.0,
                duration: MotionTokens.attentionFadeDuration,
                curve: MotionTokens.standard,
                child: _kingPulseWrap(
                  p,
                  _releaseSettleWrap(
                    p,
                    PieceWidget(
                      piece: p,
                      size: pieceSize,
                      liftedScale: _liftFor(p),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  // G1.3 — wrap the threatened-king piece in a one-shot scale pulse driven by
  // [_kingPulse]. Non-king pieces pass through unchanged so the wrap is free.
  Widget _kingPulseWrap(Piece p, Widget child) {
    final isKing =
        p.type == PieceType.king &&
        p.file == widget.threatenedKing.file &&
        p.rank == widget.threatenedKing.rank;
    if (!isKing) return child;
    return AnimatedBuilder(
      animation: _kingPulse,
      builder: (context, c) {
        // sin(πv) traces 0 → 1 → 0 cleanly over the controller's 0 → 1 run.
        final v = math.sin(_kingPulse.value * math.pi);
        final extra = (MotionTokens.kingRescuePulseScalePeak - 1.0) * v;
        return Transform.scale(scale: 1.0 + extra, child: c);
      },
      child: child,
    );
  }

  // PR-10B.2 — release/settle compression on the rescuer piece (the one
  // at rescueTo in rescued state). Sine bell 1.0 → minScale → 1.0 over
  // releaseSettleDuration, no overshoot. Non-rescuer pieces pass through
  // unchanged so the wrap is free for them.
  Widget _releaseSettleWrap(Piece p, Widget child) {
    if (widget.state != GameState.rescued) return child;
    if (p.file != widget.rescueTo.file || p.rank != widget.rescueTo.rank) {
      return child;
    }
    return AnimatedBuilder(
      animation: _releaseSettle,
      builder: (context, c) {
        // sin(π·t): 0 at endpoints, 1 at t = 0.5 — clean down-and-up arc.
        final bell = math.sin(math.pi * _releaseSettle.value);
        final scale = 1.0 - (1.0 - MotionTokens.releaseSettleMinScale) * bell;
        return Transform.scale(scale: scale, child: c);
      },
      child: child,
    );
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
          // PR-10A — fade-out curve consolidated through the token system.
          // standard is easeOutCubic; perceptually adjacent to the prior
          // easeOut, but no raw Curves literal in interaction animations.
          curve: visible ? inCurve : MotionTokens.standard,
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
                              color: AppColors.accent.withValues(
                                alpha: MotionTokens.legalDotOccupiedAlpha,
                              ),
                              width: 2,
                            ),
                          ),
                        )
                      : Container(
                          width: sq * MotionTokens.legalDotEmptyScale,
                          height: sq * MotionTokens.legalDotEmptyScale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(
                              alpha: MotionTokens.legalDotEmptyAlpha,
                            ),
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
      ..color = ColorTokens.boardGridLine
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

// V2 — paints a single concentric mint ring around the rescue square.
// Radius lerps from `start*sq/2` to `end*sq/2`; alpha lerps from `start → 0`;
// stroke width tapers `strokeStart → strokeEnd`. One drawCircle per frame.
class _RescueRingPainter extends CustomPainter {
  _RescueRingPainter({
    required this.visible,
    required this.t,
    required this.center,
    required this.squareSize,
  });

  final bool visible;
  final double t; // 0..1 (already curved)
  final Offset center;
  final double squareSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || t <= 0.0 || t >= 1.0) return;
    // PR-9A — opacity decays 1.4× faster than radius; ring grows almost
    // to full radius before fully fading (ripple losing energy into water).
    final alphaT = (t * MotionTokens.rescueRingOpacityVsRadiusRatio).clamp(
      0.0,
      1.0,
    );
    if (alphaT >= 1.0) return; // ring fully transparent — skip the draw.
    final r0 = squareSize * MotionTokens.rescueRingStartScale / 2;
    final r1 = squareSize * MotionTokens.rescueRingEndScale / 2;
    final radius = r0 + (r1 - r0) * t;
    final alpha = MotionTokens.rescueRingAlphaStart * (1.0 - alphaT);
    final stroke =
        MotionTokens.rescueRingStrokeStart +
        (MotionTokens.rescueRingStrokeEnd -
                MotionTokens.rescueRingStrokeStart) *
            t;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true
      ..color = AppColors.rescue.withValues(alpha: alpha);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RescueRingPainter old) =>
      old.visible != visible ||
      old.t != t ||
      old.center != center ||
      old.squareSize != squareSize;
}

// Cinematic move-arrow painter. One-shot tapered shaft (5 → 9 px) capped by
// a wider-than-tall editorial head. Single controller; phase boundaries
// drive shaft progress and alpha from MotionTokens.moveArrow*.
class _MoveArrowPainter extends CustomPainter {
  _MoveArrowPainter({
    required this.sequenceProgress,
    required this.originCenter,
    required this.destCenter,
    required this.squareSize,
    required this.color,
    required this.drawEnd,
    required this.holdEnd,
    required this.peakAlpha,
    required this.settledAlpha,
  });

  final double sequenceProgress;
  final Offset originCenter;
  final Offset destCenter;
  final double squareSize;
  final Color color;
  final double drawEnd;
  final double holdEnd;
  final double peakAlpha;
  final double settledAlpha;

  // Tapered shaft widths and head geometry, in logical pixels.
  static const double _tailWidth = 5.0;
  static const double _neckWidth = 9.0;
  static const double _headWidth = 18.0;
  static const double _headLength = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Phase 1: derive shaft progress + alpha.
    double shaftProgress;
    double alpha;
    if (sequenceProgress <= 0.0) {
      return;
    } else if (sequenceProgress <= drawEnd) {
      shaftProgress = (sequenceProgress / drawEnd).clamp(0.0, 1.0);
      alpha = peakAlpha;
    } else if (sequenceProgress <= holdEnd) {
      shaftProgress = 1.0;
      alpha = peakAlpha;
    } else {
      shaftProgress = 1.0;
      final fadeT = ((sequenceProgress - holdEnd) / (1.0 - holdEnd)).clamp(
        0.0,
        1.0,
      );
      alpha = peakAlpha + (settledAlpha - peakAlpha) * fadeT;
    }
    if (shaftProgress <= 0.0) return;

    // Phase 2: trim 30% of square size inward at both endpoints so the
    // arrow sits between the origin and dest piece silhouettes.
    final delta = destCenter - originCenter;
    final totalDist = delta.distance;
    if (totalDist <= 0) return;
    final dirX = delta.dx / totalDist;
    final dirY = delta.dy / totalDist;
    final trim = squareSize * 0.30;
    final usableLength = totalDist - 2 * trim;
    if (usableLength <= 0) return; // origin/dest too close
    final start = Offset(
      originCenter.dx + dirX * trim,
      originCenter.dy + dirY * trim,
    );
    final end = Offset(
      destCenter.dx - dirX * trim,
      destCenter.dy - dirY * trim,
    );

    // Phase 3: head fade-in across the final 20% of the shaft draw.
    final headT =
        ((shaftProgress - MotionTokens.moveArrowHeadStart) /
                (1.0 - MotionTokens.moveArrowHeadStart))
            .clamp(0.0, 1.0);

    // Tip of the shaft at this progress (independent of head).
    final shaftTipX = start.dx + dirX * (usableLength * shaftProgress);
    final shaftTipY = start.dy + dirY * (usableLength * shaftProgress);
    final shaftTip = Offset(shaftTipX, shaftTipY);

    // Head is anchored at the trimmed end; its visible length scales by
    // headT during the final 20% of the draw, then stays at full length.
    final headLen = _headLength * headT;
    final headBase = Offset(end.dx - dirX * headLen, end.dy - dirY * headLen);

    // Where does the shaft visually stop? If the head is visible, the
    // shaft ends at the head base (not under the head). Otherwise the
    // shaft ends at shaftTip from progress alone.
    final shaftEnd = headT > 0
        ? (shaftTip - end).distance < headLen
              ? shaftTip
              : headBase
        : shaftTip;

    final shaftEndDist = (shaftEnd - start).distance;
    if (shaftEndDist > 0) {
      // Perpendicular for shaft width.
      final perpX = -dirY;
      final perpY = dirX;
      // Linear width interpolation along the shaft.
      final wStart = _tailWidth / 2;
      final wEndRatio = (shaftEndDist / usableLength).clamp(0.0, 1.0);
      final wEnd = (_tailWidth + (_neckWidth - _tailWidth) * wEndRatio) / 2;
      final shaftPath = Path()
        ..moveTo(start.dx + perpX * wStart, start.dy + perpY * wStart)
        ..lineTo(shaftEnd.dx + perpX * wEnd, shaftEnd.dy + perpY * wEnd)
        ..lineTo(shaftEnd.dx - perpX * wEnd, shaftEnd.dy - perpY * wEnd)
        ..lineTo(start.dx - perpX * wStart, start.dy - perpY * wStart)
        ..close();
      final shaftPaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..color = color.withValues(alpha: alpha);
      canvas.drawPath(shaftPath, shaftPaint);
    }

    if (headT > 0 && headLen > 0) {
      final perpX = -dirY;
      final perpY = dirX;
      final hw = _headWidth / 2;
      final headPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(headBase.dx + perpX * hw, headBase.dy + perpY * hw)
        ..lineTo(headBase.dx - perpX * hw, headBase.dy - perpY * hw)
        ..close();
      final headPaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..color = color.withValues(alpha: alpha * headT);
      canvas.drawPath(headPath, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoveArrowPainter old) =>
      old.sequenceProgress != sequenceProgress ||
      old.originCenter != originCenter ||
      old.destCenter != destCenter ||
      old.squareSize != squareSize ||
      old.color != color;
}
