import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/puzzle_l10n.dart';
import 'package:chess_rescue/core/models/puzzle_library.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppL10n locale loading', () {
    test(
      'English (en) loads with the expected representative strings',
      () async {
        final t = await AppL10n.delegate.load(const Locale('en'));
        expect(t.introTitle, 'One move saves the king.');
        expect(t.headlineRescued, 'Rescued.');
        expect(t.footerNextPuzzle, 'Next puzzle  ↦');
        expect(t.puzzleCounter(2, 5), 'PUZZLE 2/5');
      },
    );

    test(
      'Turkish (tr) loads with the expected representative strings',
      () async {
        final t = await AppL10n.delegate.load(const Locale('tr'));
        expect(t.introTitle, 'Tek hamle şahı kurtarır.');
        expect(t.headlineRescued, 'Kurtarıldı.');
        expect(t.footerNextPuzzle, 'Sıradaki bulmaca  ↦');
        expect(t.puzzleCounter(2, 5), 'BULMACA 2/5');
      },
    );

    test(
      'Spanish (es) loads with the expected representative strings',
      () async {
        final t = await AppL10n.delegate.load(const Locale('es'));
        expect(t.introTitle, 'Un movimiento salva al rey.');
        expect(t.headlineRescued, 'Rescatado.');
        expect(t.footerNextPuzzle, 'Siguiente puzle  ↦');
        expect(t.puzzleCounter(2, 5), 'PUZLE 2/5');
      },
    );
  });

  group('Per-puzzle copy resolves', () {
    test('English (en) — all 9 puzzles + puzzleCopyFor routing', () async {
      final t = await AppL10n.delegate.load(const Locale('en'));

      // Sentinel: statusText for every canonical puzzle id.
      expect(t.puzzleP1StatusText, '▮ Active threat');
      expect(t.puzzleP2StatusText, '▮ In check');
      expect(t.puzzleP3StatusText, '▮ Checked on the file');
      expect(t.puzzleP4StatusText, '▮ Checked on the diagonal');
      expect(t.puzzleP5StatusText, '▮ Checked on the rank');
      expect(t.puzzleA4StatusText, '▮ Hunted at the gate');
      expect(t.puzzleB1StatusText, '▮ The line is open');
      expect(t.puzzleB3StatusText, '▮ Held up by one piece');
      expect(t.puzzleB4StatusText, '▮ In check');

      // puzzleCopyFor routes P1 via canonicalPuzzleId.
      final p1 = PuzzleLibrary.all.first;
      final copy = puzzleCopyFor(p1, t);
      expect(copy.statusText, '▮ Active threat');
      expect(copy.dangerHint, 'One piece can answer this. Find it.');
      expect(
        copy.failureHint,
        "That move doesn't break the attack. Look for a check.",
      );
      expect(copy.successExplanation, 'THE KNIGHT STRIKES BACK');
    });

    test('Turkish (tr) — all 9 puzzles + puzzleCopyFor routing', () async {
      final t = await AppL10n.delegate.load(const Locale('tr'));

      expect(t.puzzleP1StatusText, '▮ Aktif tehdit');
      expect(t.puzzleP2StatusText, '▮ Şahta');
      expect(t.puzzleP3StatusText, '▮ Dikeyde şah');
      expect(t.puzzleP4StatusText, '▮ Çaprazda şah');
      expect(t.puzzleP5StatusText, '▮ Yatayda şah');
      expect(t.puzzleA4StatusText, '▮ Kapıda kıstırıldı');
      expect(t.puzzleB1StatusText, '▮ Hat açık');
      expect(t.puzzleB3StatusText, '▮ Tek taşla ayakta');
      expect(t.puzzleB4StatusText, '▮ Şahta');

      final p1 = PuzzleLibrary.all.first;
      final copy = puzzleCopyFor(p1, t);
      expect(copy.statusText, '▮ Aktif tehdit');
      expect(copy.successExplanation, 'AT GERİ VURUR');
    });

    test('Spanish (es) — all 9 puzzles + puzzleCopyFor routing', () async {
      final t = await AppL10n.delegate.load(const Locale('es'));

      expect(t.puzzleP1StatusText, '▮ Amenaza activa');
      expect(t.puzzleP2StatusText, '▮ En jaque');
      expect(t.puzzleP3StatusText, '▮ Jaque en la columna');
      expect(t.puzzleP4StatusText, '▮ Jaque en la diagonal');
      expect(t.puzzleP5StatusText, '▮ Jaque en la fila');
      expect(t.puzzleA4StatusText, '▮ Acorralado en la entrada');
      expect(t.puzzleB1StatusText, '▮ La línea está abierta');
      expect(t.puzzleB3StatusText, '▮ Sostenido por una sola pieza');
      expect(t.puzzleB4StatusText, '▮ En jaque');

      final p1 = PuzzleLibrary.all.first;
      final copy = puzzleCopyFor(p1, t);
      expect(copy.statusText, '▮ Amenaza activa');
      expect(copy.successExplanation, 'EL CABALLO CONTRAATACA');
    });
  });
}
