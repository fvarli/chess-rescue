// Debug-only screenshot harness — a SEPARATE entrypoint, never imported by
// lib/main.dart, so it is absent from the normal release artifact.
//
// Run:  flutter run -t lib/debug/screenshot_harness.dart -d <device>
//
// Drives the REAL RescueScreen into each of the 6 Play Store states
// deterministically (no manual play-through), so one person can capture all six
// 1080×2400 frames in a couple of minutes. See docs/screenshot-capture.md for
// the exact capture commands and the marketing-headline mapping
// (store-assets-spec.md §27C).
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/rescue_game/game_controller.dart';
import '../features/rescue_game/rescue_screen.dart';

/// Flip to `false` for the clean capture. The verification chip also requires
/// `kDebugMode`, so it can never appear in a release build.
const bool _showShotOverlay = true;

/// The commit animation window (select → slide → outcome). Matches the test
/// helper's settle delay; generous so driven states are fully settled.
const Duration _settle = Duration(milliseconds: 520);

class _Shot {
  const _Shot(this.n, this.beat, this.headline, this.drive);
  final int n;
  final String beat;
  final String headline;
  final Future<void> Function(GameController g) drive;
}

Future<void> _solveCurrent(GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  final r = g.currentPuzzle.rescueTo;
  g.handleSquare(t.file, t.rank); // select the rescuer
  g.handleSquare(r.file, r.rank); // commit the rescue
  await Future<void>.delayed(_settle);
}

Future<void> _solveSession(GameController g) async {
  final count = g.puzzleCount;
  for (var i = 0; i < count; i++) {
    await _solveCurrent(g);
    if (g.hasNext) {
      g.onPrimaryAction(); // advance within the session
      await Future<void>.delayed(_settle);
    }
  }
}

const _shots = [
  _Shot(1, 'Hook', '"It looks lost. It isn\'t."', _driveHook),
  _Shot(2, 'Danger', '"Your king is in danger."', _driveNone),
  _Shot(3, 'One Move', '"One move can save it."', _driveSelect),
  _Shot(4, 'Rescue', '"Rescued."', _driveRescue),
  _Shot(5, 'Completion', '"The board is quiet now."', _driveComplete),
  _Shot(
    6,
    'Everyday comeback',
    '"Always one move from saved."',
    _driveComeback,
  ),
];

// Hook: solve P1–P4 + advance → land on P5 (`win-the-queen`) in danger, SAVED 4.
Future<void> _driveHook(GameController g) async {
  for (var i = 0; i < 4; i++) {
    await _solveCurrent(g);
    g.onPrimaryAction();
    await Future<void>.delayed(_settle);
  }
}

Future<void> _driveNone(GameController g) async {} // P1 danger (cold open)

Future<void> _driveSelect(GameController g) async {
  final t = g.currentPuzzle.tappableSquare;
  g.handleSquare(t.file, t.rank); // P1 selected → move dots fan out
}

Future<void> _driveRescue(GameController g) async =>
    _solveCurrent(g); // P1 rescued → mint bloom

Future<void> _driveComplete(GameController g) async =>
    _solveSession(g); // all 5 → "The board is quiet now." + SAVED 5

Future<void> _driveComeback(GameController g) async {
  await _solveSession(g);
  g.onPrimaryAction(); // "Again" → fresh seed-1 opener in danger
  await Future<void>.delayed(_settle);
}

void main() => runApp(const _HarnessApp());

class _HarnessApp extends StatelessWidget {
  const _HarnessApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue — Screenshot Harness (debug)',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Mirror main.dart's clamped text scaling so captures match the real app.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.35,
        child: child!,
      ),
      home: const _HarnessPager(),
    );
  }
}

class _HarnessPager extends StatelessWidget {
  const _HarnessPager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        children: [for (final shot in _shots) _ShotPage(shot: shot)],
      ),
    );
  }
}

class _ShotPage extends StatefulWidget {
  const _ShotPage({required this.shot});
  final _Shot shot;

  @override
  State<_ShotPage> createState() => _ShotPageState();
}

class _ShotPageState extends State<_ShotPage> {
  GameController? _ctrl;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final g = GameController();
    await widget.shot.drive(g);
    if (mounted) {
      setState(() => _ctrl = g);
    } else {
      g.dispose();
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose(); // we own it (RescueScreen does not dispose injected ones)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return Stack(
      children: [
        if (ctrl == null)
          Center(
            child: Text(
              'preparing [SHOT ${widget.shot.n}]…',
              style: AppText.mono.copyWith(color: AppColors.textDim),
            ),
          )
        else
          RescueScreen(store: null, controller: ctrl),
        if (kDebugMode && _showShotOverlay) _ShotOverlay(shot: widget.shot),
      ],
    );
  }
}

class _ShotOverlay extends StatelessWidget {
  const _ShotOverlay({required this.shot});
  final _Shot shot;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      top: MediaQuery.of(context).padding.top + 8,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '[SHOT ${shot.n}]  ${shot.beat}',
                style: AppText.mono.copyWith(color: AppColors.rescue),
              ),
              const SizedBox(height: 2),
              Text(
                shot.headline,
                style: AppText.mono.copyWith(color: AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
