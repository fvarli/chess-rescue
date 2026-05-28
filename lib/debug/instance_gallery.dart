// Debug-only instance gallery — a SEPARATE entrypoint, never imported by
// lib/main.dart, so it is absent from the normal release artifact.
//
// Run:  flutter run -t lib/debug/instance_gallery.dart -d linux
//
// Renders base + mirror puzzle instances with their readability verdict so a
// developer can eyeball variant legibility. Reuses the real BoardWidget; does
// not touch the rescue loop or GameController.
import 'package:flutter/material.dart';

import '../core/models/puzzle.dart';
import '../core/models/puzzle_library.dart';
import '../core/models/readability.dart';
import '../core/models/square.dart';
import '../core/models/variation.dart';
import '../core/theme/app_theme.dart';
import '../features/rescue_game/game_state.dart';
import '../features/rescue_game/widgets/board_widget.dart';

void main() {
  runApp(const _GalleryApp());
}

class _GalleryApp extends StatelessWidget {
  const _GalleryApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue — Instance Gallery (debug)',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _GalleryScreen(),
    );
  }
}

class _Entry {
  const _Entry(this.label, this.puzzle, {this.showMoves = false});
  final String label;
  final Puzzle puzzle;
  final bool showMoves; // render the legal-move dots + list (decoy preview)
}

String _sq(Square s) => '${String.fromCharCode(97 + s.file)}${s.rank + 1}';

class _GalleryScreen extends StatelessWidget {
  const _GalleryScreen();

  @override
  Widget build(BuildContext context) {
    // Live composed sessions (Phase 22C — combined canonical + expansion pool).
    final session1 = PuzzleLibrary.session(1);
    final session2 = PuzzleLibrary.session(2);
    final entries = <_Entry>[
      for (final p in PuzzleLibrary.all) _Entry('base', p),
      for (final p in PuzzleLibrary.mirrorVariants) _Entry('mirror', p),
      // Phase 22B — Tier-1 expansion families (not wired into live sessions).
      for (final t in PuzzleLibrary.expansionTemplates)
        _Entry('expansion', t.toPuzzle()),
      for (final t in PuzzleLibrary.expansionTemplates)
        _Entry('expansion mirror', t.toPuzzle(Variation.mirror)),
      // Phase 23B — decoy texture preview (move-dots vary; rescue fixed).
      for (final t in [
        ...PuzzleLibrary.templates,
        ...PuzzleLibrary.expansionTemplates,
      ].where((t) => t.decoyPool.isNotEmpty)) ...[
        _Entry(
          'decoy s=0 · ${t.puzzle.id}',
          t.toTexturedPuzzle(),
          showMoves: true,
        ),
        _Entry(
          'decoy s=1',
          t.toTexturedPuzzle(textureSeed: 1),
          showMoves: true,
        ),
        _Entry(
          'decoy s=2',
          t.toTexturedPuzzle(textureSeed: 2),
          showMoves: true,
        ),
        _Entry(
          'decoy s=1 mirror',
          t.toTexturedPuzzle(variation: Variation.mirror, textureSeed: 1),
          showMoves: true,
        ),
      ],
      for (var i = 0; i < session1.length; i++)
        _Entry('session seed=1 · slot ${i + 1}', session1[i]),
      for (var i = 0; i < session2.length; i++)
        _Entry('session seed=2 · slot ${i + 1}', session2[i]),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, i) => _GalleryCard(entry: entries[i]),
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.entry});
  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final p = entry.puzzle;
    final score = readabilityScore(p);
    final ok = score.passed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.label}  ·  ${p.id}',
            style: AppText.mono.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 4),
          Text(
            ok ? 'READABLE ✓' : 'FAILED: ${score.notes.join(' · ')}',
            style: AppText.mono.copyWith(
              color: ok ? AppColors.rescue : AppColors.danger,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'danger: ${p.statusText}   ·   success: ${p.successExplanation}',
            style: AppText.mono.copyWith(color: AppColors.textDim),
          ),
          if (entry.showMoves) ...[
            const SizedBox(height: 4),
            Text(
              'moves: ${p.legalMoves.map(_sq).join(' ')}   (rescue ${_sq(p.rescueTo)})',
              style: AppText.mono.copyWith(color: AppColors.textDim),
            ),
          ],
          const SizedBox(height: 10),
          Center(
            child: BoardWidget(
              size: 300,
              pieces: p.pieces,
              selected: null,
              legalSquares: entry.showMoves ? p.legalMoves : const [],
              state: GameState.danger,
              threatenedKing: p.threatenedKing,
              rescueTo: p.rescueTo,
              commitInFlight: false,
              resetInFlight: false,
              onTapSquare: (_, _) {},
            ),
          ),
        ],
      ),
    );
  }
}
