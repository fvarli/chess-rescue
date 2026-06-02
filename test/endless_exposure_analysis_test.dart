import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/variation.dart';

// Sprint V1 Phase 3d — Endless Exposure Analysis. The lead-mandated
// observational measurement: do the two new positions (CC2, CAM1) actually
// surface to players who play Endless mode, and at what frequency relative to
// the existing expansion baselines?
//
// **This is observational, not gate-keeping.** Per the lead's directive, low
// exposure does NOT trigger a SessionComposer modification in this sprint —
// it is documented, quantified, and proposed as follow-up.
//
// Methodology: simulate the public Endless entry point — `PuzzleLibrary.session(seed)`
// — across seeds 1..1000 (seed 0 is the canonical onboarding session and is
// excluded). For every puzzle in every composed session, increment a
// canonical-id tally (mirror variants collapse to their base via
// `canonicalPuzzleId`). Then print a structured report and compare CC2 / CAM1
// frequencies to the four pre-existing expansion baselines (A4, B1, B3, B4).

void main() {
  test('Endless Exposure Analysis — CC2 and CAM1 frequency in seeds 1..1000', () {
    const sampleSize = 1000;
    final tally = <String, int>{};
    var totalPuzzles = 0;

    for (var seed = 1; seed <= sampleSize; seed++) {
      final session = PuzzleLibrary.session(seed);
      for (final puzzle in session) {
        final id = canonicalPuzzleId(puzzle.id);
        tally[id] = (tally[id] ?? 0) + 1;
        totalPuzzles++;
      }
    }

    String pct(int n) => (n / totalPuzzles * 100).toStringAsFixed(2);
    String ratio(int n, int d) => d > 0 ? (n / d).toStringAsFixed(2) : 'N/A';

    // ── Structured report (consumed by Phase 3e final report) ──
    // ignore: avoid_print
    print('===== Endless Exposure Analysis (Sprint V1 / Phase 3d) =====');
    // ignore: avoid_print
    print(
      'Sample size: $sampleSize seeds (seed 1..$sampleSize; seed 0 excluded)',
    );
    // ignore: avoid_print
    print('Total puzzles across all sessions: $totalPuzzles');
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('Per-puzzle frequency (descending):');
    final sorted = tally.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      // ignore: avoid_print
      print(
        '  ${e.key.padRight(40)} ${e.value.toString().padLeft(5)} '
        '(${pct(e.value)}%)',
      );
    }
    // ignore: avoid_print
    print('');

    final cc2 = tally['cc2-bishop-captures-shield'] ?? 0;
    final cam1 = tally['cam1-knight-takes-bishop'] ?? 0;
    const baselines = <String>[
      'a4-the-breakaway',
      'b1-the-martyr',
      'b3-remove-the-defender',
      'b4-the-cross-check',
    ];

    // ignore: avoid_print
    print('CC2 — count $cc2 (${pct(cc2)}% of all puzzles)');
    for (final ref in baselines) {
      final refCount = tally[ref] ?? 0;
      // ignore: avoid_print
      print(
        '  CC2 / ${ref.padRight(25)} = ${ratio(cc2, refCount)} '
        '(baseline $refCount)',
      );
    }
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('CAM1 — count $cam1 (${pct(cam1)}% of all puzzles)');
    for (final ref in baselines) {
      final refCount = tally[ref] ?? 0;
      // ignore: avoid_print
      print(
        '  CAM1 / ${ref.padRight(25)} = ${ratio(cam1, refCount)} '
        '(baseline $refCount)',
      );
    }
    // ignore: avoid_print
    print('');
    final baselineAvg =
        baselines.map((id) => tally[id] ?? 0).fold<int>(0, (a, b) => a + b) /
        baselines.length;
    // ignore: avoid_print
    print(
      'Expansion baseline mean (A4/B1/B3/B4): ${baselineAvg.toStringAsFixed(1)}',
    );
    // ignore: avoid_print
    print(
      'CC2 / baseline-mean  = '
      '${baselineAvg > 0 ? (cc2 / baselineAvg).toStringAsFixed(2) : 'N/A'}',
    );
    // ignore: avoid_print
    print(
      'CAM1 / baseline-mean = '
      '${baselineAvg > 0 ? (cam1 / baselineAvg).toStringAsFixed(2) : 'N/A'}',
    );
    // ignore: avoid_print
    print('===== End report =====');

    // Wiring assertion — the only HARD gate in this analysis. Both positions
    // must be present in `expansionTemplates`. Their actual appearance
    // frequency in composed sessions (including 0%) is an OBSERVATION, not a
    // gate, per the lead's directive:
    //
    //   "If the analysis shows that new positions are technically present but
    //    rarely encountered, do NOT modify SessionComposer in this sprint.
    //    Instead: document the observation, quantify it, propose follow-up
    //    investigation work."
    //
    // The frequency numbers printed above ARE the analysis output. The Phase
    // 3 final report (Phase 3e) interprets them against the lead's 5
    // reporting requirements. Zero-frequency is a real possible finding — see
    // SessionComposer.compose() opener-slot logic.
    final ids = {for (final t in PuzzleLibrary.expansionTemplates) t.puzzle.id};
    expect(
      ids,
      containsAll(<String>[
        'cc2-bishop-captures-shield',
        'cam1-knight-takes-bishop',
      ]),
      reason:
          'CC2 and CAM1 must be registered in PuzzleLibrary.expansionTemplates '
          'before composer exposure can be measured. If this fails, the Sprint '
          'V1 templates were not added — fix authoring before re-running.',
    );
  });
}
