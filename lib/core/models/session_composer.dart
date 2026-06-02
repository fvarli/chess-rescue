import 'dart:math';

import 'episode.dart';
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

  /// Kind-aware episode composition (Phase P3). Routes by `episode.kind`:
  ///
  /// - **canonical** — draws from `episode.canonicalPuzzleIds`. Seed 0 returns
  ///   the authored puzzles in canonical order with no variation; seed >= 1 may
  ///   apply mirror per slot (forced mix) plus optional decoy texture on the
  ///   middle slot.
  /// - **master** — every slot is the mirror variant of the episode's canonical
  ///   pool. Optional decoy texture on the middle slot. Session length matches
  ///   `episode.canonicalPuzzleIds.length` (3 for ep4).
  /// - **endless** — delegates to [compose] with the full templates + expansion
  ///   pool, producing the legacy 5-puzzle session with full canonical-anchor /
  ///   mirror-balance / texture-cap invariants.
  static List<Puzzle> composeEpisode({
    required Episode episode,
    required List<PuzzleTemplate> templates,
    List<PuzzleTemplate> expansion = const [],
    required int seed,
  }) {
    switch (episode.kind) {
      case EpisodeKind.canonical:
        return _composeCanonicalEpisode(episode, templates, expansion, seed);
      case EpisodeKind.master:
        return _composeMasterEpisode(episode, templates, expansion, seed);
      case EpisodeKind.endless:
        return compose(templates: templates, expansion: expansion, seed: seed);
    }
  }

  static List<Puzzle> _composeCanonicalEpisode(
    Episode episode,
    List<PuzzleTemplate> templates,
    List<PuzzleTemplate> expansion,
    int seed,
  ) {
    final all = [...templates, ...expansion];
    final pool = <PuzzleTemplate>[
      for (final id in episode.canonicalPuzzleIds) ?_templateForId(all, id),
    ];

    // Seed 0 → canonical authored order, no variation. The promise that
    // entering an episode for the first time shows the authored puzzles
    // verbatim.
    if (seed == 0) {
      return [for (final t in pool) t.toPuzzle()];
    }

    final rng = Random(seed);

    // Mirror per slot, forced to a mix (avoid all-base / all-mirror).
    final useMirror = [for (var i = 0; i < pool.length; i++) rng.nextBool()];
    if (pool.length > 1) {
      if (useMirror.every((m) => m)) useMirror[0] = false;
      if (useMirror.every((m) => !m)) useMirror[0] = true;
    }

    // Texture only the middle slot (canonical bookends stay clean).
    final textureSlot = pool.length > 2 ? 1 : -1;
    final textureSeed = (textureSlot >= 0 && rng.nextBool())
        ? 1 + rng.nextInt(64)
        : 0;

    return [
      for (var i = 0; i < pool.length; i++)
        _instance(pool[i], useMirror[i], i == textureSlot ? textureSeed : 0, 0),
    ];
  }

  static List<Puzzle> _composeMasterEpisode(
    Episode episode,
    List<PuzzleTemplate> templates,
    List<PuzzleTemplate> expansion,
    int seed,
  ) {
    final all = [...templates, ...expansion];
    final pool = <PuzzleTemplate>[
      for (final id in episode.canonicalPuzzleIds) ?_templateForId(all, id),
    ];

    final rng = Random(seed);

    // Master mode: every slot is mirrored. Optional decoy texture on the
    // middle slot only.
    final textureSlot = pool.length > 2 ? 1 : -1;
    final textureSeed = (textureSlot >= 0 && rng.nextBool())
        ? 1 + rng.nextInt(64)
        : 0;

    return [
      for (var i = 0; i < pool.length; i++)
        _instance(pool[i], true, i == textureSlot ? textureSeed : 0, 0),
    ];
  }

  static PuzzleTemplate? _templateForId(
    List<PuzzleTemplate> all,
    String puzzleId,
  ) {
    for (final t in all) {
      if (t.puzzle.id == puzzleId) return t;
    }
    return null;
  }

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
    // Seed-gated opener relief (§6.1 minimal fix): in ~25% of seeds, when an
    // expansion captureAttackerMinor candidate exists, the opener picks
    // expansion instead of the canonical anchor. Uses an independent
    // `Random(seed)` so the main `rng` stream is unchanged — every other slot's
    // draws stay bit-identical to the pre-relief baseline for any given seed.
    final reliefRng = Random(seed);
    final useExpansionOpener =
        openerCands.length > 1 && reliefRng.nextInt(4) == 0;
    final openerSlot = useExpansionOpener
        ? openerCands[1 + reliefRng.nextInt(openerCands.length - 1)]
        : openerCands.first;
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
      openerSlot, // opener — canonical-dominant; seed-gated expansion relief
      risingCands[risingIdx], // rising — counter-check / breakaway / cross-check
      middleCands[middleIdx], // middle — interpose (block / seal / martyr)
      peakCands[peakIdx], // peak — high-stakes resolution (queen / remove defender)
      finaleCands.first, // finale — canonical-locked, the other interpose
    ];

    // Base/mirror per slot, forced to a mix (avoid all-base / all-mirror).
    final useMirror = [for (var i = 0; i < chosen.length; i++) rng.nextBool()];
    if (useMirror.every((m) => m)) useMirror[0] = false;
    if (useMirror.every((m) => !m)) useMirror[0] = true;

    // Texture (Phase 23D): clean bookends (opener/finale never textured); at most
    // two of the three middle slots (rising/interpose/peak) get a light decoy
    // and/or scenery texture, preferring a single layer. A crafted album with
    // occasional freshness — not a remix. Drawn after the 22C draws so template +
    // mirror selection is unchanged; deterministic from the session seed.
    final textureSeeds = List<int>.filled(chosen.length, 0);
    final scenerySeeds = List<int>.filled(chosen.length, 0);
    final texturedCount = rng.nextInt(3); // 0, 1, or 2 middle slots
    final picked = ([1, 2, 3]..shuffle(rng)).take(texturedCount).toSet();
    for (var slot = 1; slot <= 3; slot++) {
      if (!picked.contains(slot)) continue;
      final t = chosen[slot];
      final canDecoy = t.decoyPool.isNotEmpty;
      final canScenery =
          t.sceneryPool.isNotEmpty || t.removableScenery.isNotEmpty;
      final modes = <String>[
        if (canDecoy) 'decoy',
        if (canScenery) 'scenery',
        if (canDecoy && canScenery) 'both',
      ];
      if (modes.isEmpty) continue;
      final mode = modes[rng.nextInt(modes.length)];
      if (mode == 'decoy' || mode == 'both') {
        textureSeeds[slot] = 1 + rng.nextInt(64);
      }
      if (mode == 'scenery' || mode == 'both') {
        scenerySeeds[slot] = 1 + rng.nextInt(64);
      }
    }

    return [
      for (var i = 0; i < chosen.length; i++)
        _instance(chosen[i], useMirror[i], textureSeeds[i], scenerySeeds[i]),
    ];
  }

  // Resolve a slot to a gate-clean instance, preferring the requested texture and
  // degrading gracefully so a session is always valid/readable and `sessionLength`
  // long: full texture → drop scenery → geometry only → canonical base.
  static Puzzle _instance(
    PuzzleTemplate t,
    bool mirror,
    int textureSeed,
    int scenerySeed,
  ) {
    final v = mirror ? Variation.mirror : Variation.identity;
    final attempts = <Puzzle Function()>[
      () => t.toTexturedPuzzle(
        variation: v,
        textureSeed: textureSeed,
        scenerySeed: scenerySeed,
      ),
      () => t.toTexturedPuzzle(variation: v, textureSeed: textureSeed),
      () => t.toTexturedPuzzle(variation: v),
      () => t.toPuzzle(),
    ];
    for (final make in attempts) {
      final p = make();
      if (_ok(p)) return p;
    }
    return t.toPuzzle();
  }

  static bool _ok(Puzzle p) =>
      validatePuzzle(p).isValid && readabilityScore(p).passed;
}
