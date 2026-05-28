import 'dart:math';

import 'puzzle.dart';
import 'puzzle_template.dart';
import 'readability.dart';
import 'rescue_archetype.dart';
import 'puzzle_validation.dart';
import 'variation.dart';

/// Builds a deterministic, emotionally-paced 5-puzzle session (Phase 19A
/// "session composition"). Curated, never random chaos.
///
/// Phase 22C — multi-template aware. An archetype may hold several templates
/// (the canonical backbone plus expansion families); the seed picks one per
/// slot. The opener and finale stay **canonical-locked**, and at most two of the
/// three middle slots (rising / interpose / peak) may be an expansion family —
/// so every session is **>= 3/5 canonical**. A crafted album with occasional
/// surprises, not a remix machine. Seed 0 never reaches here (PuzzleLibrary
/// returns the canonical `all` for onboarding).
class SessionComposer {
  SessionComposer._();

  static const int sessionLength = 5;

  static List<Puzzle> compose({
    required List<PuzzleTemplate> templates,
    List<PuzzleTemplate> expansion = const [],
    required int seed,
  }) {
    final rng = Random(seed);

    // Archetype -> templates, canonical first so index 0 of any list is the
    // canonical anchor every slot can fall back to.
    final byArchetype = <RescueArchetype, List<PuzzleTemplate>>{};
    for (final t in [...templates, ...expansion]) {
      byArchetype.putIfAbsent(t.archetype, () => []).add(t);
    }
    List<PuzzleTemplate> candidates(List<RescueArchetype> archs) => [
      for (final a in archs) ...?byArchetype[a],
    ];

    // The two canonical interposes split across middle + finale; the seed picks
    // which lands where. The middle also accepts the Martyr (forcedInterposition).
    final interposeSwap = rng.nextBool();
    final middleInterpose = interposeSwap
        ? RescueArchetype.blockFile
        : RescueArchetype.sealDiagonal;
    final finaleInterpose = interposeSwap
        ? RescueArchetype.sealDiagonal
        : RescueArchetype.blockFile;

    final openerCands = candidates([RescueArchetype.captureAttackerMinor]);
    final risingCands = candidates([RescueArchetype.counterCheck]);
    final middleCands = candidates([
      middleInterpose,
      RescueArchetype.forcedInterposition,
    ]);
    final peakCands = candidates([
      RescueArchetype.captureAttackerHeavy,
      RescueArchetype.removeDefender,
    ]);
    final finaleCands = candidates([finaleInterpose]);

    // Choose one candidate per middle slot (index 0 = canonical anchor).
    var risingIdx = rng.nextInt(risingCands.length);
    var middleIdx = rng.nextInt(middleCands.length);
    var peakIdx = rng.nextInt(peakCands.length);

    // Canonical-anchored cap: at most two of the three middle slots may be an
    // expansion family (index != 0). If all three are expansion, revert one
    // (seed-chosen) to its canonical anchor so >= 1 middle stays canonical and
    // the session is always >= 3/5 canonical (with the locked opener + finale).
    if (risingIdx != 0 && middleIdx != 0 && peakIdx != 0) {
      switch (rng.nextInt(3)) {
        case 0:
          risingIdx = 0;
        case 1:
          middleIdx = 0;
        default:
          peakIdx = 0;
      }
    }

    final chosen = <PuzzleTemplate>[
      openerCands.first, // opener — canonical-locked, simple/readable
      risingCands[risingIdx], // rising — counter-check / breakaway / cross-check
      middleCands[middleIdx], // middle — interpose (block / seal / martyr)
      peakCands[peakIdx], // peak — high-stakes resolution (queen / remove defender)
      finaleCands.first, // finale — canonical-locked, the other interpose
    ];

    // Base/mirror per slot, forced to a mix (avoid all-base / all-mirror).
    final useMirror = [for (var i = 0; i < chosen.length; i++) rng.nextBool()];
    if (useMirror.every((m) => m)) useMirror[0] = false;
    if (useMirror.every((m) => !m)) useMirror[0] = true;

    return [
      for (var i = 0; i < chosen.length; i++)
        _instance(chosen[i], useMirror[i]),
    ];
  }

  // Resolve a slot to a gate-clean instance: prefer the chosen orientation,
  // then the other orientation, then the template's base (always gate-clean).
  // Guarantees every slot yields a valid, readable puzzle so a session is always
  // `sessionLength` long — even if a future template's mirror were to fail.
  static Puzzle _instance(PuzzleTemplate t, bool mirror) {
    final first = mirror ? t.toPuzzle(Variation.mirror) : t.toPuzzle();
    if (_ok(first)) return first;
    final other = mirror ? t.toPuzzle() : t.toPuzzle(Variation.mirror);
    if (_ok(other)) return other;
    return t.toPuzzle();
  }

  static bool _ok(Puzzle p) =>
      validatePuzzle(p).isValid && readabilityScore(p).passed;
}
