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

  @override
  String get puzzleP1StatusText => '▮ Amenaza activa';

  @override
  String get puzzleP1DangerHint =>
      'Toca una pieza blanca para ver sus movimientos.';

  @override
  String get puzzleP1FailureHint =>
      'Ese movimiento no rompe el ataque. Busca un jaque.';

  @override
  String get puzzleP1SuccessExplanation => 'EL CABALLO CONTRAATACA';

  @override
  String get puzzleP2StatusText => '▮ En jaque';

  @override
  String get puzzleP2DangerHint => 'El atacante está a un paso.';

  @override
  String get puzzleP2FailureHint => 'El caballo sigue dando jaque.';

  @override
  String get puzzleP2SuccessExplanation => 'EL JAQUE SE FUE';

  @override
  String get puzzleP3StatusText => '▮ Jaque en la columna';

  @override
  String get puzzleP3DangerHint => 'Jaque directo por la columna.';

  @override
  String get puzzleP3FailureHint => 'Eso no bloquea el jaque.';

  @override
  String get puzzleP3SuccessExplanation => 'LA COLUMNA QUEDA SELLADA';

  @override
  String get puzzleP4StatusText => '▮ Jaque en la diagonal';

  @override
  String get puzzleP4DangerHint => 'La diagonal larga está cargada.';

  @override
  String get puzzleP4FailureHint => 'La diagonal sigue abierta.';

  @override
  String get puzzleP4SuccessExplanation => 'LA DIAGONAL QUEDA CERRADA';

  @override
  String get puzzleP5StatusText => '▮ Jaque en la fila';

  @override
  String get puzzleP5DangerHint => 'La dama ha caído sobre la última fila.';

  @override
  String get puzzleP5FailureHint => 'La dama sigue dando jaque.';

  @override
  String get puzzleP5SuccessExplanation => 'LA DAMA CAE';

  @override
  String get puzzleA4StatusText => '▮ Acorralado en la entrada';

  @override
  String get puzzleA4DangerHint =>
      'Tu caballo está acorralado y la entrada está bajo fuego.';

  @override
  String get puzzleA4FailureHint =>
      'Eso escapa pero no golpea nada. Responde con un jaque.';

  @override
  String get puzzleA4SuccessExplanation => 'EL CABALLO SE LIBERA';

  @override
  String get puzzleB1StatusText => '▮ La línea está abierta';

  @override
  String get puzzleB1DangerHint =>
      'La diagonal está cargada y el rey queda expuesto.';

  @override
  String get puzzleB1FailureHint =>
      'Eso no se interpone. Sacrifica una pieza en la línea.';

  @override
  String get puzzleB1SuccessExplanation => 'UN CUERPO POR EL REY';

  @override
  String get puzzleB3StatusText => '▮ Sostenido por una sola pieza';

  @override
  String get puzzleB3DangerHint => 'Un defensor sostiene todo el ataque.';

  @override
  String get puzzleB3FailureHint => 'El ataque sigue en pie. Arranca su apoyo.';

  @override
  String get puzzleB3SuccessExplanation => 'EL APOYO CAYÓ';

  @override
  String get puzzleB4StatusText => '▮ En jaque';

  @override
  String get puzzleB4DangerHint =>
      'Estás en jaque — pero puedes responder con la misma moneda.';

  @override
  String get puzzleB4FailureHint =>
      'Eso no rompe el jaque. Responde con tu propio jaque.';

  @override
  String get puzzleB4SuccessExplanation => 'JAQUE CONTRA JAQUE';
}
