import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/episode.dart';
import 'package:chess_rescue/core/models/episode_library.dart';
import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/puzzle.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/rescue_archetype.dart';

// PR-17 — Episode 6 ("Pin the Threat") canonical puzzle invariants.
// Each puzzle is hand-authored with the pin-defense motif: white moves a
// long-range friendly piece onto a line connecting the enemy attacker to
// a more valuable enemy piece behind it. These tests pin the structural
// + motif-consistency contract.

void main() {
  // The five canonical e6 puzzle ids in their authored order.
  const e6Ids = <String>[
    'e6p1-first-pin',
    'e6p2-diagonal-pin',
    'e6p3-pin-via-rank',
    'e6p4-cross-pin',
    'e6p5-pin-and-threat',
  ];

  // Resolve every e6 puzzle from the combined templates + expansionTemplates
  // pool. The composer uses the same union to look up canonicalPuzzleIds.
  final allTemplates = [
    ...PuzzleLibrary.templates,
    ...PuzzleLibrary.expansionTemplates,
  ];
  final puzzlesById = <String, Puzzle>{
    for (final t in allTemplates)
      if (e6Ids.contains(t.puzzle.id)) t.puzzle.id: t.puzzle,
  };
  final templatesById = <String, dynamic>{
    for (final t in allTemplates)
      if (e6Ids.contains(t.puzzle.id)) t.puzzle.id: t,
  };

  group('Episode 6 — structural validation', () {
    for (final id in e6Ids) {
      test('$id passes structural validation', () {
        final p = puzzlesById[id]!;
        final v = validatePuzzle(p);
        expect(
          v.isValid,
          isTrue,
          reason: '$id should be structurally valid — errors: ${v.errors}',
        );
      });
    }
  });

  group('Episode 6 — tappable / rescue / decoy invariants', () {
    for (final id in e6Ids) {
      test('$id has exactly one light piece on tappableSquare', () {
        final p = puzzlesById[id]!;
        final occupants = p.pieces.where(
          (q) =>
              q.file == p.tappableSquare.file &&
              q.rank == p.tappableSquare.rank,
        );
        expect(occupants.length, 1, reason: '$id tappableSquare overlaps');
        expect(
          occupants.single.color,
          PieceColor.light,
          reason: '$id tappableSquare must hold a light piece',
        );
      });

      test('$id has rescueTo in legalMoves', () {
        final p = puzzlesById[id]!;
        expect(p.legalMoves, contains(p.rescueTo));
      });

      test('$id has at least one decoy in legalMoves', () {
        final p = puzzlesById[id]!;
        final decoys = p.legalMoves.where((s) => s != p.rescueTo);
        expect(
          decoys.length,
          greaterThanOrEqualTo(1),
          reason:
              '$id should have at least one decoy so the player has a '
              'failure path to teach from',
        );
      });

      test('$id has exactly one light king on threatenedKing', () {
        final p = puzzlesById[id]!;
        final occupants = p.pieces.where(
          (q) =>
              q.file == p.threatenedKing.file &&
              q.rank == p.threatenedKing.rank,
        );
        expect(occupants.length, 1, reason: '$id threatenedKing overlaps');
        final tk = occupants.single;
        expect(tk.color, PieceColor.light);
        expect(tk.type, PieceType.king);
      });

      test('$id rescue piece is long-range (R, B, or Q) per pin motif', () {
        final p = puzzlesById[id]!;
        final mover = p.pieces.firstWhere(
          (q) =>
              q.file == p.tappableSquare.file &&
              q.rank == p.tappableSquare.rank,
        );
        const longRange = {PieceType.rook, PieceType.bishop, PieceType.queen};
        expect(
          longRange.contains(mover.type),
          isTrue,
          reason:
              '$id rescue piece type ${mover.type.name} is not a long-range '
              'piece; pin defense requires the rescue mover to be R / B / Q',
        );
      });
    }
  });

  group('Episode 6 — archetype tagging', () {
    for (final id in e6Ids) {
      test('$id template archetype is pinDefense', () {
        final t = templatesById[id];
        expect(t, isNotNull, reason: '$id template not found in pool');
        expect(t.archetype, RescueArchetype.pinDefense);
      });
    }
  });

  group('Episode 6 — episode wiring', () {
    test('ep6 exists in EpisodeLibrary.all', () {
      expect(
        EpisodeLibrary.all.map((e) => e.id),
        contains('ep6-pin-the-threat'),
      );
    });

    test('ep6 lists exactly the five authored canonical puzzle ids', () {
      final ep6 = EpisodeLibrary.byId('ep6-pin-the-threat')!;
      expect(ep6.canonicalPuzzleIds, e6Ids);
    });

    test('ep6 is canonical kind and unlocks after ep3', () {
      final ep6 = EpisodeLibrary.byId('ep6-pin-the-threat')!;
      expect(ep6.kind, EpisodeKind.canonical);
      expect(ep6.unlockRequirementId, 'ep3-hold-the-line');
    });

    test('ep6 archetypes contain pinDefense', () {
      final ep6 = EpisodeLibrary.byId('ep6-pin-the-threat')!;
      expect(ep6.archetypes, contains(RescueArchetype.pinDefense));
    });
  });
}
