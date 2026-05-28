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
import '../core/models/session_composer.dart';
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
  const _Entry(this.label, this.puzzle);
  final String label;
  final Puzzle puzzle;
}

class _GalleryScreen extends StatelessWidget {
  const _GalleryScreen();

  @override
  Widget build(BuildContext context) {
    final session1 = SessionComposer.compose(
      templates: PuzzleLibrary.templates,
      seed: 1,
    );
    final session2 = SessionComposer.compose(
      templates: PuzzleLibrary.templates,
      seed: 2,
    );
    final entries = <_Entry>[
      for (final p in PuzzleLibrary.all) _Entry('base', p),
      for (final p in PuzzleLibrary.mirrorVariants) _Entry('mirror', p),
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
          const SizedBox(height: 10),
          Center(
            child: BoardWidget(
              size: 300,
              pieces: p.pieces,
              selected: null,
              legalSquares: const [],
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
