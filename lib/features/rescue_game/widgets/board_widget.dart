import 'package:flutter/material.dart';

import '../../../core/models/piece.dart';
import '../../../core/models/square.dart';
import '../../../core/theme/app_theme.dart';
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
    required this.onTapSquare,
  });

  final double size;
  final List<Piece> pieces;
  final Piece? selected;
  final List<Square> legalSquares;
  final GameState state;
  final Square threatenedKing;
  final Square rescueTo;
  final void Function(int file, int rank) onTapSquare;

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _dangerPulse;
  late final AnimationController _rescuePop;
  late final AnimationController _failedFlash;

  @override
  void initState() {
    super.initState();
    _dangerPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _rescuePop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _failedFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _syncOneShotAnimations();
  }

  @override
  void didUpdateWidget(covariant BoardWidget old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncOneShotAnimations();
  }

  void _syncOneShotAnimations() {
    switch (widget.state) {
      case GameState.rescued:
        _rescuePop
          ..reset()
          ..forward();
        _failedFlash.value = 0;
        break;
      case GameState.failed:
        _failedFlash
          ..reset()
          ..forward();
        _rescuePop.value = 0;
        break;
      case GameState.danger:
      case GameState.selected:
        _rescuePop.value = 0;
        _failedFlash.value = 0;
        break;
    }
  }

  @override
  void dispose() {
    _dangerPulse.dispose();
    _rescuePop.dispose();
    _failedFlash.dispose();
    super.dispose();
  }

  double get _sq => widget.size / 8;

  Offset _squareOrigin(int file, int rank) =>
      Offset(file * _sq, (7 - rank) * _sq);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.boardDark,
            boxShadow: const [
              BoxShadow(
                color: Color(0x8C000000),
                offset: Offset(0, 30),
                blurRadius: 60,
              ),
            ],
            border: Border.all(color: AppColors.hairline, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              _buildSquares(),
              _buildGridLines(),
              _buildDangerGlow(),
              _buildFailedFlash(),
              _buildRescueGlow(),
              if (widget.selected != null) _buildSelectedRing(),
              ..._buildLegalDots(),
              ..._buildPieces(),
              _buildTapLayer(),
            ],
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
    final origin = _squareOrigin(
      widget.threatenedKing.file,
      widget.threatenedKing.rank,
    );
    return AnimatedBuilder(
      animation: _dangerPulse,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_dangerPulse.value);
        final blur = _sq * (0.6 + 0.4 * t);
        final alpha = 0.5 + 0.4 * t;
        return Positioned(
          left: origin.dx,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.20),
                border: Border.all(color: AppColors.danger, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: alpha),
                    blurRadius: blur,
                    spreadRadius: _sq * 0.05,
                  ),
                ],
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
    return AnimatedBuilder(
      animation: _failedFlash,
      builder: (context, _) {
        // First 180ms: solid flash. Then 300ms fade.
        final v = _failedFlash.value;
        final t = v < (180 / 480)
            ? 1.0
            : Curves.easeOut.transform(1 - ((v - 180 / 480) / (300 / 480)));
        return Positioned(
          left: origin.dx,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.45 * t),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: t),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: 0.6 * t),
                    blurRadius: _sq * 0.9,
                  ),
                ],
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
    return AnimatedBuilder(
      animation: _rescuePop,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_rescuePop.value);
        final scale = 1.0 + 0.06 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
        final alpha = 0.4 + 0.4 * t;
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
                  color: AppColors.rescue.withValues(alpha: 0.20),
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
        );
      },
    );
  }

  Widget _buildSelectedRing() {
    final origin = _squareOrigin(widget.selected!.file, widget.selected!.rank);
    return Positioned(
      left: origin.dx,
      top: origin.dy,
      width: _sq,
      height: _sq,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.accent, width: 2),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLegalDots() {
    if (widget.selected == null) return const [];
    final occupiedSquares = {
      for (final p in widget.pieces) Square(p.file, p.rank),
    };
    final dots = <Widget>[];
    for (final s in widget.legalSquares) {
      final origin = _squareOrigin(s.file, s.rank);
      final occupied = occupiedSquares.contains(s);
      dots.add(
        Positioned(
          left: origin.dx,
          top: origin.dy,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              builder: (context, t, _) {
                return Opacity(
                  opacity: t,
                  child: Center(
                    child: occupied
                        ? Container(
                            width: _sq * 0.86,
                            height: _sq * 0.86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.8),
                                width: 2,
                              ),
                            ),
                          )
                        : Container(
                            width: _sq * 0.28,
                            height: _sq * 0.28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    return dots;
  }

  List<Widget> _buildPieces() {
    return [
      for (final p in widget.pieces)
        Positioned(
          left: p.file * _sq,
          top: (7 - p.rank) * _sq,
          width: _sq,
          height: _sq,
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(_sq * 0.08),
              child: PieceWidget(piece: p, size: _sq * 0.84),
            ),
          ),
        ),
    ];
  }

  Widget _buildTapLayer() {
    // Tap layer is always responsive — it must accept taps in `danger` to
    // start a selection and in `selected` to commit. After resolution
    // (rescued/failed) the controller's handleSquare is a no-op.
    return Positioned.fill(
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
