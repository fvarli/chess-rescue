// Debug-only screenshot harness — a SEPARATE entrypoint, never imported by
// lib/main.dart, so it is absent from the normal release artifact.
//
// Run:  flutter run -t lib/debug/screenshot_harness.dart -d <device>
//
// Drives the REAL screens into each of the 6 Play Store states
// deterministically (no manual play-through), so one person can capture all six
// 1080×2400 frames in a couple of minutes. See docs/play-store/SCREENSHOT_NOTES.md
// for the per-shot capture map and capture commands.
import 'dart:convert' show jsonEncode;
import 'dart:io' show Directory, File, exit;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart' show FontLoader;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/episode_library.dart';
import '../core/storage/progress_store.dart';
import '../core/theme/app_theme.dart';
import '../features/home/home_screen.dart';
import '../features/records/records_sheet.dart';
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

/// What a shot's builder returns: the live widget to render inside the poster
/// frame, plus optional ownership references that the harness disposes after
/// capture so per-shot state doesn't leak between pages.
class _ShotPrep {
  const _ShotPrep({required this.widget, this.controller});
  final Widget widget;
  final GameController? controller;
}

typedef _ShotBuilder = Future<_ShotPrep> Function();

class _Shot {
  const _Shot(
    this.n,
    this.fileName,
    this.beat,
    this.headline,
    this.sub,
    this.accent,
    this.build,
  );
  final int n;
  final String fileName;
  final String beat;
  final String headline;
  final String sub;
  final Color accent;
  final _ShotBuilder build;
}

// ── Shot definitions ────────────────────────────────────────────────────────
//
// Priority order (per the lead's 2026-06 brief):
//   1. Home / Episode Journey
//   2. Rescue In Danger     (post-onboarding — ambient focus cue visible)
//   3. Rescue Move Clarity
//   4. Rescue Success
//   5. Episode Progression  (Ep3 trilogy completion sheet)
//   6. Endless / Records    (RecordsSheet with several unlocked records)

const _shots = [
  _Shot(
    1,
    '01-home-journey.png',
    'Home',
    'A journey of rescues.',
    'Each episode is a chapter in your story.',
    AppColors.accent,
    _buildHomeShot,
  ),
  _Shot(
    2,
    '02-danger-ambient-cue.png',
    'Danger',
    '"Your king is in danger."',
    'The threat is named. The pressure is real.',
    AppColors.danger,
    _buildDangerShot,
  ),
  _Shot(
    3,
    '03-move-clarity.png',
    'One Move',
    '"One move can save it."',
    'Not deep calculation — just insight.',
    AppColors.accent,
    _buildMoveClarityShot,
  ),
  _Shot(
    4,
    '04-rescue-success.png',
    'Rescue',
    '"Rescued."',
    'A quiet breath of relief — not a fireworks show.',
    AppColors.rescue,
    _buildRescueShot,
  ),
  _Shot(
    5,
    '05-trilogy-finale.png',
    'Trilogy',
    '"The board is quiet now."',
    'A chapter complete. Master and Endless unlock.',
    AppColors.rescue,
    _buildTrilogyShot,
  ),
  _Shot(
    6,
    '06-rescue-records.png',
    'Records',
    'Your rescue records.',
    'A growing journal of every save.',
    AppColors.accent,
    _buildRecordsShot,
  ),
];

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

/// Pre-seeds SharedPreferences with the given map and returns a fresh
/// ProgressStore reading from it. Uses the public setters (not the
/// `@visibleForTesting` mock-init helper) so the harness compiles cleanly as
/// production-shaped code. Each call wipes prefs first so per-shot state
/// stays isolated.
Future<ProgressStore> _seededStore(Map<String, Object> entries) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  for (final e in entries.entries) {
    final value = e.value;
    if (value is bool) {
      await prefs.setBool(e.key, value);
    } else if (value is int) {
      await prefs.setInt(e.key, value);
    } else if (value is String) {
      await prefs.setString(e.key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(e.key, value);
    }
  }
  return ProgressStore.create();
}

// ── Shot 1 — Home / Episode Journey ─────────────────────────────────────────
//
// Mounts the real HomeScreen on top of a mid-journey store: Ep1 complete (3
// puzzles), Ep2 focused. The episode chip strip shows progression, the
// records preview is empty (clean composition), and the CTA reads
// "Continue rescue" because intro has been seen.
Future<_ShotPrep> _buildHomeShot() async {
  final store = await _seededStore({
    'cr_intro_seen': true,
    'cr_onboarding_seen': true,
    'cr_completed_ids': <String>[
      'p1-knight-rescue',
      'a4-the-breakaway',
      'b4-the-cross-check',
    ],
    'cr_lifetime_saved': 3,
    'cr_current_episode_id': 'ep2-end-the-threat',
  });
  return _ShotPrep(widget: HomeScreen(store: store));
}

// ── Shot 2 — Rescue In Danger (ambient focus cue) ───────────────────────────
//
// A fresh GameController with no store → isOnboarding=false → RescueScreen
// renders the DAMPED ambient focus cue (α 0.18–0.32) on the rescue piece in
// addition to the danger glow on the king. This is the visual centerpiece
// for the "we teach you which piece is yours, on the board, no copy" pitch.
Future<_ShotPrep> _buildDangerShot() async {
  final g = GameController();
  return _ShotPrep(
    widget: RescueScreen(store: null, controller: g),
    controller: g,
  );
}

// ── Shot 3 — Rescue Move Clarity ────────────────────────────────────────────
//
// Same fresh controller as #2 with one tap on the rescue piece. Legal-move
// dots fan in (staggered), the mint selected ring + 1.05× piece lift land.
// The ambient cue's visibility gate (state==danger && selected==null) flips
// false on selection, so it gracefully fades; the selected-state affordances
// take over.
Future<_ShotPrep> _buildMoveClarityShot() async {
  final g = GameController();
  final t = g.currentPuzzle.tappableSquare;
  g.handleSquare(t.file, t.rank);
  return _ShotPrep(
    widget: RescueScreen(store: null, controller: g),
    controller: g,
  );
}

// ── Shot 4 — Rescue Success ─────────────────────────────────────────────────
//
// Same controller, driven through the rescue commit. Rescued state: success
// mono-caps line + mint bloom + king pulse. Settle past the bloom (~520 ms
// here; the export runner extends with ~950 ms more so the still frame lands
// on a fully-settled rescue, not mid-animation).
Future<_ShotPrep> _buildRescueShot() async {
  final g = GameController();
  await _solveCurrent(g);
  return _ShotPrep(
    widget: RescueScreen(store: null, controller: g),
    controller: g,
  );
}

// ── Shot 5 — Trilogy Finale ─────────────────────────────────────────────────
//
// GameController constructed against Ep3 (the canonical trilogy finale). All
// 3 puzzles solved → allComplete + isEpisodeFinale, RescueScreen mounts the
// EpisodeCompletionSheet overlay with the "TRILOGY COMPLETE" eyebrow + the
// "Master and Endless unlocked" copy.
Future<_ShotPrep> _buildTrilogyShot() async {
  final g = GameController(episode: EpisodeLibrary.ep3);
  await _solveSession(g);
  return _ShotPrep(
    widget: RescueScreen(store: null, controller: g),
    controller: g,
  );
}

// ── Shot 6 — Rescue Records ─────────────────────────────────────────────────
//
// Mounts the RecordsSheet (RECORDS tab default) over a pre-seeded store with
// 5 unlocked records spanning multiple categories — the journal reads as
// "alive" without claiming completion. The bottom-sheet shape is preserved
// via a Material host with a colored backdrop matching the in-app sheet
// presentation.
Future<_ShotPrep> _buildRecordsShot() async {
  final store = await _seededStore({
    'cr_intro_seen': true,
    'cr_onboarding_seen': true,
    // ProgressStore.unlockedRecords reads `cr_unlocked_records` as a JSON-
    // encoded string (not a StringList), so seed it that way.
    'cr_unlocked_records': jsonEncode(<String>[
      'firstRescue',
      'familiarGround',
      'ep1StrikeBack',
      'ep2EndTheThreat',
      'endlessSpark',
    ]),
    'cr_completed_ids': <String>[
      'p1-knight-rescue',
      'p2-take-the-checker',
      'p3-block-the-file',
      'p4-seal-the-diagonal',
      'p5-win-the-queen',
      'a4-the-breakaway',
      'b3-remove-the-defender',
      'b4-the-cross-check',
    ],
    'cr_lifetime_saved': 12,
  });
  return _ShotPrep(
    widget: ColoredBox(
      color: Colors.black.withValues(alpha: 0.55),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: RecordsSheet(store: store),
        ),
      ),
    ),
  );
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
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
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
  _ShotPrep? _prep;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final p = await widget.shot.build();
    if (mounted) {
      setState(() => _prep = p);
    } else {
      p.controller?.dispose();
    }
  }

  @override
  void dispose() {
    _prep?.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prep = _prep;
    return Stack(
      children: [
        if (prep == null)
          Center(
            child: Text(
              'preparing [SHOT ${widget.shot.n}]…',
              style: AppText.mono.copyWith(color: AppColors.textDim),
            ),
          )
        else
          prep.widget,
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

/// One Play-ready 1080×2400 frame: a headline band over whatever the shot
/// builder returned (RescueScreen, HomeScreen, RecordsSheet).
class _StoreFrame extends StatelessWidget {
  const _StoreFrame({required this.shot, required this.child});
  final _Shot shot;
  final Widget child;

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
              // Bottom padding trimmed from 18 → 12 so HomeScreen's mid-journey
              // layout (shot 1) lands the Records preview row inside the
              // canvas instead of triggering Flutter's debug overflow stripes.
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 12),
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
              // ClipRect suppresses Flutter's debug yellow-and-black overflow
              // stripes from bleeding into the captured PNG when a child
              // (e.g. HomeScreen) is a few px taller than the available canvas.
              child: ClipRect(
                child: MediaQuery(
                  data: const MediaQueryData(
                    size: Size(360, 640),
                    devicePixelRatio: 3.0,
                  ),
                  child: KeyedSubtree(key: ValueKey(shot.n), child: child),
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
  _ShotPrep? _prep;
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
      final prep = await _shots[i].build();
      final previous = _prep;
      setState(() {
        _prep = prep;
        _index = i;
        _status = 'rendering ${_shots[i].fileName}…';
      });
      previous?.controller?.dispose();
      // Let it lay out, then let animations (mint bloom, ambient breath) settle
      // to a representative frame before capturing.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 950));
      await WidgetsBinding.instance.endOfFrame;
      debugPrint('shot ${i + 1}/${_shots.length}: ${_shots[i].fileName}');
      await _capture('${dir.path}/${_shots[i].fileName}');
    }
    _prep?.controller?.dispose();
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
    final prep = _prep;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: prep == null
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
                  child: _StoreFrame(shot: _shots[_index], child: prep.widget),
                ),
              ),
      ),
    );
  }
}
