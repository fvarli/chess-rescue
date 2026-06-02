import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/piece.dart';
import 'package:chess_rescue/core/models/puzzle_l10n.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/core/models/puzzle_template.dart';
import 'package:chess_rescue/core/models/puzzle_validation.dart';
import 'package:chess_rescue/core/models/readability.dart';
import 'package:chess_rescue/core/models/rescue_archetype.dart';
import 'package:chess_rescue/core/models/square.dart';
import 'package:chess_rescue/core/models/variation.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

// Sprint V1 — structural assertions for the two Phase-2.5-validated positions
// added to `expansionTemplates`. These tests intentionally pin every load-
// bearing field (rescue square, mover location, archetype, threatened king,
// localized copy resolution) so a future drift away from the validated board
// can't ship silently.

PuzzleTemplate _expansionTemplate(String id) =>
    PuzzleLibrary.expansionTemplates.firstWhere((t) => t.puzzle.id == id);

void main() {
  group('CC2 — Bishop captures the shield (counterCheck)', () {
    final template = _expansionTemplate('cc2-bishop-captures-shield');
    final puzzle = template.puzzle;

    test('archetype is counterCheck', () {
      expect(template.archetype, RescueArchetype.counterCheck);
    });

    test('mover is wB on c4', () {
      expect(puzzle.tappableSquare, const Square(2, 3));
      final atTap = puzzle.pieces.firstWhere((p) => p.file == 2 && p.rank == 3);
      expect(atTap.type, PieceType.bishop);
      expect(atTap.color, PieceColor.light);
      expect(atTap.id, 'wB');
    });

    test('rescue is Bxf7+ and rescue square is in legalMoves', () {
      expect(puzzle.rescueTo, const Square(5, 6));
      expect(puzzle.rescueNotation, 'Bxf7+');
      expect(puzzle.legalMoves, contains(puzzle.rescueTo));
    });

    test('rescue captures a black pawn on f7', () {
      final captured = puzzle.pieces.firstWhere(
        (p) => p.file == 5 && p.rank == 6,
      );
      expect(captured.color, PieceColor.dark);
      expect(captured.type, PieceType.pawn);
    });

    test('threatened king is the light king on g1', () {
      expect(puzzle.threatenedKing, const Square(6, 0));
      final atKing = puzzle.pieces.firstWhere(
        (p) => p.file == 6 && p.rank == 0,
      );
      expect(atKing.type, PieceType.king);
      expect(atKing.color, PieceColor.light);
    });

    test('threat is the black queen on h3', () {
      final queens = puzzle.pieces.where(
        (p) => p.color == PieceColor.dark && p.type == PieceType.queen,
      );
      expect(queens.length, 1);
      final q = queens.first;
      expect(q.file, 7);
      expect(q.rank, 2);
    });

    test('structurally valid + readable (base + mirror)', () {
      expect(validatePuzzle(puzzle).isValid, isTrue);
      expect(readabilityScore(puzzle).passed, isTrue);
      final mirror = template.toPuzzle(Variation.mirror);
      expect(validatePuzzle(mirror).isValid, isTrue);
      expect(readabilityScore(mirror).passed, isTrue);
    });

    test('isPrototype is true (Sprint V1 ships as prototype)', () {
      expect(puzzle.isPrototype, isTrue);
    });
  });

  group('CAM1 — Knight takes the bishop (captureAttackerMinor)', () {
    final template = _expansionTemplate('cam1-knight-takes-bishop');
    final puzzle = template.puzzle;

    test('archetype is captureAttackerMinor', () {
      expect(template.archetype, RescueArchetype.captureAttackerMinor);
    });

    test('mover is wN on g4', () {
      expect(puzzle.tappableSquare, const Square(6, 3));
      final atTap = puzzle.pieces.firstWhere((p) => p.file == 6 && p.rank == 3);
      expect(atTap.type, PieceType.knight);
      expect(atTap.color, PieceColor.light);
      expect(atTap.id, 'wN');
    });

    test('rescue is Nxh2 and rescue square is in legalMoves', () {
      expect(puzzle.rescueTo, const Square(7, 1));
      expect(puzzle.rescueNotation, 'Nxh2');
      expect(puzzle.legalMoves, contains(puzzle.rescueTo));
    });

    test('rescue captures the checking black bishop on h2', () {
      final captured = puzzle.pieces.firstWhere(
        (p) => p.file == 7 && p.rank == 1,
      );
      expect(captured.color, PieceColor.dark);
      expect(captured.type, PieceType.bishop);
    });

    test('threatened king is the light king on g1', () {
      expect(puzzle.threatenedKing, const Square(6, 0));
      final atKing = puzzle.pieces.firstWhere(
        (p) => p.file == 6 && p.rank == 0,
      );
      expect(atKing.type, PieceType.king);
      expect(atKing.color, PieceColor.light);
    });

    test('h-pawn is absent (the bishop occupies h2 instead)', () {
      final atH2 = puzzle.pieces.where((p) => p.file == 7 && p.rank == 1);
      expect(atH2.length, 1);
      expect(atH2.first.type, PieceType.bishop);
      // And there is no wP-h2.
      expect(
        puzzle.pieces.any((p) => p.id == 'wP-h2'),
        isFalse,
        reason:
            'CAM1 cannot have wP-h2 — the dark bishop occupies that square.',
      );
    });

    test('structurally valid + readable (base + mirror)', () {
      expect(validatePuzzle(puzzle).isValid, isTrue);
      expect(readabilityScore(puzzle).passed, isTrue);
      final mirror = template.toPuzzle(Variation.mirror);
      expect(validatePuzzle(mirror).isValid, isTrue);
      expect(readabilityScore(mirror).passed, isTrue);
    });

    test('isPrototype is true (Sprint V1 ships as prototype)', () {
      expect(puzzle.isPrototype, isTrue);
    });
  });

  group('Sprint V1 — l10n switch wires both ids in every locale', () {
    Future<void> assertCopyResolves(Locale locale) async {
      WidgetsFlutterBinding.ensureInitialized();
      final t = await AppL10n.delegate.load(locale);
      for (final id in const [
        'cc2-bishop-captures-shield',
        'cam1-knight-takes-bishop',
      ]) {
        final template = _expansionTemplate(id);
        final base = template.puzzle;
        final copyBase = puzzleCopyFor(base, t);
        // Real wire-up (NOT the fallback) — every field is non-empty and the
        // authored EN string is NOT what the resolver returns for TR/ES.
        expect(copyBase.statusText, isNotEmpty, reason: '$id $locale status');
        expect(copyBase.dangerHint, isNotEmpty, reason: '$id $locale danger');
        expect(copyBase.failureHint, isNotEmpty, reason: '$id $locale failure');
        expect(
          copyBase.successExplanation,
          isNotEmpty,
          reason: '$id $locale success',
        );
        if (locale.languageCode != 'en') {
          // Sanity: at least one localized line differs from the EN fallback.
          final divergent =
              copyBase.statusText != base.statusText ||
              copyBase.dangerHint != base.dangerHint ||
              copyBase.failureHint != base.failureHint ||
              copyBase.successExplanation != base.successExplanation;
          expect(
            divergent,
            isTrue,
            reason:
                '$id ${locale.languageCode} appears to be falling back to EN '
                '(every field matches the authored EN) — l10n switch case '
                'likely not wired.',
          );
        }
        // Mirror id collapses to the same canonical copy.
        final mirror = template.toPuzzle(Variation.mirror);
        final copyMirror = puzzleCopyFor(mirror, t);
        expect(copyMirror.statusText, copyBase.statusText);
        expect(copyMirror.dangerHint, copyBase.dangerHint);
        expect(copyMirror.failureHint, copyBase.failureHint);
        expect(copyMirror.successExplanation, copyBase.successExplanation);
      }
    }

    test('en wires copy', () async {
      await assertCopyResolves(const Locale('en'));
    });
    test('tr wires copy and diverges from EN', () async {
      await assertCopyResolves(const Locale('tr'));
    });
    test('es wires copy and diverges from EN', () async {
      await assertCopyResolves(const Locale('es'));
    });
  });
}
