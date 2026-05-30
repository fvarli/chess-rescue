import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
