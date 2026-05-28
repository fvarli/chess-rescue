import 'dart:math';

import 'puzzle.dart';
import 'puzzle_template.dart';
import 'readability.dart';
import 'rescue_archetype.dart';
import 'puzzle_validation.dart';
import 'variation.dart';

/// Builds a deterministic, emotionally-paced 5-puzzle session from base + mirror
/// instances (Phase 19A "session composition"). Curated, never random chaos.
///
/// Preview-only in 19E: the output may contain mirror variants whose
/// square-specific copy is geometrically stale, so it is NOT wired into the
/// runtime (`PuzzleLibrary.all`/`GameController` are unchanged). See
/// docs/replayability-architecture.md.
class SessionComposer {
  SessionComposer._();

  static const int sessionLength = 5;

  static List<Puzzle> compose({
    required List<PuzzleTemplate> templates,
    required int seed,
  }) {
    final rng = Random(seed);
    final byArchetype = {for (final t in templates) t.archetype: t};

    // Album-style pacing arc. Each of the current archetypes appears once, so
    // no archetype repeats and none sit back-to-back. The two interposes fill
    // the middle + finale slots; the seed picks their order.
    final interposes = rng.nextBool()
        ? [RescueArchetype.blockFile, RescueArchetype.sealDiagonal]
        : [RescueArchetype.sealDiagonal, RescueArchetype.blockFile];
    final arc = <RescueArchetype>[
      RescueArchetype.captureAttackerMinor, // opener — simple, readable
      RescueArchetype.counterCheck, // rising
      interposes[0], // middle — interpose
      RescueArchetype.captureAttackerHeavy, // peak — heavy/queen pressure
      interposes[1], // finale — calm interpose
    ];

    // Base/mirror per slot, forced to a mix (avoid all-base / all-mirror).
    final useMirror = [for (var i = 0; i < arc.length; i++) rng.nextBool()];
    if (useMirror.every((m) => m)) useMirror[0] = false;
    if (useMirror.every((m) => !m)) useMirror[0] = true;

    final session = <Puzzle>[];
    for (var i = 0; i < arc.length; i++) {
      final template = byArchetype[arc[i]];
      if (template == null) continue; // robustness: archetype not in pool
      final puzzle = useMirror[i]
          ? template.toPuzzle(Variation.mirror)
          : template.toPuzzle();
      // Defensive gate — only readable, valid instances enter a session.
      if (validatePuzzle(puzzle).isValid && readabilityScore(puzzle).passed) {
        session.add(puzzle);
      }
    }
    return session;
  }
}
