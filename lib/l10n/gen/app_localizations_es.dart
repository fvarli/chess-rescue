// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chess Rescue';

  @override
  String get introTitle => 'Un movimiento salva al rey.';

  @override
  String get introBody =>
      'Cada tablero comienza en peligro.\nEncuentra el rescate. Siente el alivio.';

  @override
  String get introSecondary =>
      'Sin cronómetros. Sin lecciones. Solo la salida.';

  @override
  String get introCta => 'Comenzar rescate';

  @override
  String get headlineSaveTheKing => 'Salva al rey.';

  @override
  String get headlineWhereWillItGo => '¿Adónde irá?';

  @override
  String get headlineRescued => 'Rescatado.';

  @override
  String get headlineNotTheMove => 'No es el movimiento.';

  @override
  String get hintOnboardingOneMoveSaves => 'Un movimiento salva la partida.';

  @override
  String get hintOnboardingFindRescue => 'Encuentra el rescate.';

  @override
  String get hintOnboardingStillTrapped => 'El rey sigue atrapado.';

  @override
  String get hintTapHighlightedSquare =>
      'Toca una casilla resaltada para mover.';

  @override
  String get completionFootnote => 'El tablero está tranquilo ahora.';

  @override
  String get footerNextPuzzle => 'Siguiente puzle  ↦';

  @override
  String get footerAgain => 'Otra vez  ↻';

  @override
  String get footerTryAgain => 'Intenta de nuevo  ↺';

  @override
  String get footerReset => 'Reiniciar';

  @override
  String puzzleCounter(int current, int total) {
    return 'PUZLE $current/$total';
  }
}
