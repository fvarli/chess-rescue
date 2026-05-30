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
import 'dart:io' show Directory, File, exit;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart' show FontLoader;

import '../core/theme/app_theme.dart';
import '../features/rescue_game/game_controller.dart';
import '../features/rescue_game/rescue_screen.dart';
import '../l10n/gen/app_localizations.dart';

/// Flip to `false` for the clean capture. The verification chip also requires
/// `kDebugMode`, so it can never appear in a release build.
const bool _showShotOverlay = true;

/// The commit animation window (select → slide → outcome). Matches the test
/// helper's settle delay; generous so driven states are fully settled.
const Duration _settle = Duration(milliseconds: 520);

// ── Automated export mode (debug-only) ──────────────────────────────────────
// `flutter run -t lib/debug/screenshot_harness.dart -d linux --dart-define=SHOT_EXPORT=true`
// auto-renders each of the 6 states into a 1080×2400 PNG (with its headline band
// baked in), writes them to SHOT_OUT, prints SHOT_EXPORT_DONE, and exits. All of
// this lives in this separate entrypoint, so it is absent from the release build.
const bool _exportMode = bool.fromEnvironment('SHOT_EXPORT');

const String _exportDir = String.fromEnvironment(
  'SHOT_OUT',
  defaultValue:
      '/home/fvarli/Desktop/MobileProjects/chess-rescue/assets/store/screenshots/final',
);

/// Optional real-Inter font for fidelity (the app's `fontFamily: 'Inter'` is not
/// bundled). If this file is absent, the engine's system sans is used instead.
const String _interTtf = String.fromEnvironment(
  'INTER_TTF',
  defaultValue:
      '/media/fvarli/4C6C0EC86C0EACB0/wamp64/www/UpworkProjects/chatgpt/wp-content/themes/twentytwentytwo/assets/fonts/inter/Inter.ttf',
);

const _exportNames = [
  '01-hook.png',
  '02-danger.png',
  '03-one-move.png',
  '04-rescue.png',
  '05-completion.png',
  '06-everyday-comeback.png',
];

/// Logical canvas; captured at pixelRatio 3.0 → exactly 1080×2400.
const Size _canvas = Size(360, 800);

const TextStyle _bandHeadlineStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 27,
  fontWeight: FontWeight.w700,
  height: 1.12,
  letterSpacing: -0.5,
  color: AppColors.text,
);

const TextStyle _bandSubStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14.5,
  fontWeight: FontWeight.w500,
  height: 1.3,
  color: AppColors.textDim,
);

String _clean(String s) {
  var t = s.trim();
  if (t.startsWith('"')) t = t.substring(1);
  if (t.endsWith('"')) t = t.substring(0, t.length - 1);
  return t;
}

class _Shot {
  const _Shot(
    this.n,
    this.beat,
    this.headline,
    this.sub,
    this.accent,
    this.drive,
  );
  final int n;
  final String beat;
  final String headline;
  final String sub;
  final Color accent;
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
  _Shot(
    1,
    'Hook',
    '"It looks lost. It isn\'t."',
    'One move turns it around — can you find it?',
    AppColors.danger,
    _driveHook,
  ),
  _Shot(
    2,
    'Danger',
    '"Your king is in danger."',
    'The threat is named. The pressure is real.',
    AppColors.danger,
    _driveNone,
  ),
  _Shot(
    3,
    'One Move',
    '"One move can save it."',
    'Not deep calculation — just insight.',
    AppColors.accent,
    _driveSelect,
  ),
  _Shot(
    4,
    'Rescue',
    '"Rescued."',
    'A quiet breath of relief — not a fireworks show.',
    AppColors.rescue,
    _driveRescue,
  ),
  _Shot(
    5,
    'Completion',
    '"The board is quiet now."',
    'A 90-second ritual, whenever the day gets loud.',
    AppColors.rescue,
    _driveComplete,
  ),
  _Shot(
    6,
    'Everyday comeback',
    '"Always one move from saved."',
    'Open it anytime — a fresh rescue, in about a minute.',
    AppColors.rescue,
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

void main() {
  if (_exportMode) {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const _ExportApp());
  } else {
    runApp(const _HarnessApp());
  }
}

class _HarnessApp extends StatelessWidget {
  const _HarnessApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue — Screenshot Harness (debug)',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // RescueScreen calls AppL10n.of(context)! since C2; without the
      // delegates here the harness would throw a null check on the inner
      // tree. Default test locale → English copy.
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
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

// ── Export composition + runner (debug-only) ────────────────────────────────

/// One Play-ready 1080×2400 frame: a headline band over the real RescueScreen.
class _StoreFrame extends StatelessWidget {
  const _StoreFrame({required this.shot, required this.controller});
  final _Shot shot;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _canvas.width,
      height: _canvas.height,
      child: ColoredBox(
        color: AppColors.bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: shot.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(_clean(shot.headline), style: _bandHeadlineStyle),
                  const SizedBox(height: 8),
                  Text(shot.sub, style: _bandSubStyle),
                ],
              ),
            ),
            Expanded(
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(360, 640),
                  devicePixelRatio: 3.0,
                ),
                // Unique key per shot so a fresh RescueScreen State binds to this
                // shot's controller (its State binds the controller in initState).
                child: RescueScreen(
                  key: ValueKey(shot.n),
                  store: null,
                  controller: controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportApp extends StatelessWidget {
  const _ExportApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue — Screenshot Export (debug)',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // RescueScreen calls AppL10n.of(context)! since C2; the delegates
      // resolve EN strings inside the embedded screen.
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: const _ExportRunner(),
    );
  }
}

class _ExportRunner extends StatefulWidget {
  const _ExportRunner();

  @override
  State<_ExportRunner> createState() => _ExportRunnerState();
}

class _ExportRunnerState extends State<_ExportRunner> {
  final GlobalKey _boundaryKey = GlobalKey();
  GameController? _ctrl;
  int _index = -1;
  String _status = 'starting export…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    await _maybeLoadInter();
    final dir = Directory(_exportDir)..createSync(recursive: true);
    for (var i = 0; i < _shots.length; i++) {
      final g = GameController();
      await _shots[i].drive(g);
      final previous = _ctrl;
      setState(() {
        _ctrl = g;
        _index = i;
        _status = 'rendering ${_exportNames[i]}…';
      });
      previous?.dispose();
      // Let it lay out, then let animations (mint bloom, ambient breath) settle
      // to a representative frame before capturing.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 950));
      await WidgetsBinding.instance.endOfFrame;
      debugPrint(
        'shot ${i + 1}: puzzle ${g.puzzleNumber}/${g.puzzleCount} '
        'saved=${g.completedCount} state=${g.state} '
        'sel=${g.selected != null} legal=${g.legalSquares.length}',
      );
      await _capture('${dir.path}/${_exportNames[i]}');
    }
    _ctrl?.dispose();
    debugPrint('SHOT_EXPORT_DONE count=${_shots.length} dir=${dir.path}');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    exit(0);
  }

  Future<void> _capture(String path) async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final w = image.width;
    final h = image.height;
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    File(path).writeAsBytesSync(data!.buffer.asUint8List());
    debugPrint('wrote $path ($w×$h)');
  }

  Future<void> _maybeLoadInter() async {
    try {
      final f = File(_interTtf);
      if (f.existsSync()) {
        final loader = FontLoader('Inter')
          ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
        await loader.load();
        debugPrint('export: loaded Inter from $_interTtf');
      } else {
        debugPrint('export: Inter ttf not found, using system sans fallback');
      }
    } catch (e) {
      debugPrint('export: Inter load failed ($e), using system sans fallback');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ctrl == null
            ? Text(
                _status,
                style: AppText.mono.copyWith(color: AppColors.textDim),
              )
            : OverflowBox(
                minWidth: _canvas.width,
                maxWidth: _canvas.width,
                minHeight: _canvas.height,
                maxHeight: _canvas.height,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: _StoreFrame(shot: _shots[_index], controller: ctrl),
                ),
              ),
      ),
    );
  }
}
