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

  @override
  String get puzzleCC2StatusText => '▮ Llega el mate';

  @override
  String get puzzleCC2DangerHint =>
      'La dama está a un paso de encerrar al rey.';

  @override
  String get puzzleCC2FailureHint =>
      'Ese movimiento no rompe la amenaza. Golpea al otro rey.';

  @override
  String get puzzleCC2SuccessExplanation => 'EL ALFIL IRRUMPE';

  @override
  String get puzzleCAM1StatusText => '▮ En jaque';

  @override
  String get puzzleCAM1DangerHint => 'Un alfil muerde. Devuelve el golpe.';

  @override
  String get puzzleCAM1FailureHint => 'El alfil sigue ahí. Cómelo.';

  @override
  String get puzzleCAM1SuccessExplanation => 'EL CABALLO COME AL ALFIL';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Idioma del sistema';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageTurkish => 'Turco';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsDone => 'Listo';

  @override
  String get homeTagline => 'Tu rey está en peligro.\nEncuentra el rescate.';

  @override
  String get homeRescueMission => 'MISIÓN DE RESCATE';

  @override
  String get homeCurrentRun => 'Racha actual';

  @override
  String homeRescueCounter(int current, int total) {
    return 'Rescate $current / $total';
  }

  @override
  String homeTotalRescues(int count) {
    return 'Rescates totales: $count';
  }

  @override
  String get homeContinue => 'Continuar rescate  ↦';

  @override
  String get homeStart => 'Comenzar rescate  ↦';

  @override
  String episodeBadge(int number) {
    return 'EPISODIO $number';
  }

  @override
  String get episodeEp1Title => 'CONTRAATAQUE';

  @override
  String get episodeEp1Tagline => 'Devuelve el ataque.';

  @override
  String get episodeEp2Title => 'ACABA CON LA AMENAZA';

  @override
  String get episodeEp2Tagline => 'Saca al atacante del tablero.';

  @override
  String get episodeEp3Title => 'MANTÉN LA LÍNEA';

  @override
  String get episodeEp3Tagline => 'Un cuerpo por el rey.';

  @override
  String get episodeEp4Title => 'EL OTRO LADO';

  @override
  String get episodeEp4Tagline =>
      'Ya los has visto. Encuentra el rescate desde el otro lado.';

  @override
  String get episodeEp5Title => 'RESCATE INFINITO';

  @override
  String get episodeEp5Tagline => 'Salva al rey. Otra vez. Y otra.';

  @override
  String episodeBestRun(int count) {
    return 'Mejor racha: $count';
  }

  @override
  String get episodeLockedLabel =>
      'Termina el episodio anterior para desbloquear.';

  @override
  String get episodeCompleteFooter => 'Episodio completado  ↦';

  @override
  String get episodeCompleteToast =>
      'Episodio completado. Siguiente rescate desbloqueado.';

  @override
  String get episodeTrilogyCompleteToast =>
      'Trilogía completada. Master y Endless desbloqueados.';

  @override
  String get episodeSheetCompleteEyebrow => '✓ EPISODIO COMPLETADO';

  @override
  String get episodeSheetTrilogyEyebrow => '✓ TRILOGÍA COMPLETADA';

  @override
  String episodeSheetEpisodeLabel(int number) {
    return 'Episodio $number';
  }

  @override
  String episodeSheetRescuesCount(int count) {
    return '$count rescates completados';
  }

  @override
  String get episodeSheetTrilogyUnlock => 'Master y Endless desbloqueados';

  @override
  String get episodeSheetContinue => 'Continuar';

  @override
  String get recordTitle_firstRescue => 'Primer Rescate';

  @override
  String get recordTitle_familiarGround => 'Terreno Familiar';

  @override
  String get recordTitle_theRescuer => 'El Rescatador';

  @override
  String get recordTitle_unbroken => 'Inquebrantable';

  @override
  String get recordTitle_ep1StrikeBack => 'Contraataque';

  @override
  String get recordTitle_ep2EndTheThreat => 'Acaba con la amenaza';

  @override
  String get recordTitle_ep3HoldTheLine => 'Mantén la línea';

  @override
  String get recordTitle_ep4TheOtherSide => 'El otro lado';

  @override
  String get recordTitle_againstTheOdds => 'Contra Todo Pronóstico';

  @override
  String get recordTitle_endlessSpark => 'Chispa Infinita';

  @override
  String get recordTitle_endlessFocus => 'Foco Infinito';

  @override
  String get recordTitle_endlessMaster => 'Maestro Infinito';

  @override
  String get recordTitle_unshaken => 'Inquebrantable';

  @override
  String get recordDescriptionLocked_firstRescue =>
      'Completa tu primer rescate.';

  @override
  String get recordDescriptionLocked_familiarGround => 'Completa 10 rescates.';

  @override
  String get recordDescriptionLocked_theRescuer => 'Completa 25 rescates.';

  @override
  String get recordDescriptionLocked_unbroken => 'Completa 100 rescates.';

  @override
  String get recordDescriptionLocked_ep1StrikeBack => 'Termina el Episodio 1.';

  @override
  String get recordDescriptionLocked_ep2EndTheThreat =>
      'Termina el Episodio 2.';

  @override
  String get recordDescriptionLocked_ep3HoldTheLine => 'Termina el Episodio 3.';

  @override
  String get recordDescriptionLocked_ep4TheOtherSide =>
      'Termina el Episodio 4.';

  @override
  String get recordDescriptionLocked_againstTheOdds =>
      'Termina cada episodio canónico y atraviesa el espejo.';

  @override
  String get recordDescriptionLocked_endlessSpark =>
      'Alcanza una racha de 3 rescates en Infinito.';

  @override
  String get recordDescriptionLocked_endlessFocus =>
      'Alcanza una racha de 7 rescates en Infinito.';

  @override
  String get recordDescriptionLocked_endlessMaster =>
      'Alcanza una racha de 15 rescates en Infinito.';

  @override
  String get recordDescriptionLocked_unshaken =>
      'Termina un episodio sin movimientos erróneos.';

  @override
  String get recordDescriptionUnlocked_firstRescue => 'Tu primer rescate.';

  @override
  String get recordDescriptionUnlocked_familiarGround =>
      'El tablero se ha vuelto familiar.';

  @override
  String get recordDescriptionUnlocked_theRescuer =>
      'Veinticinco vidas salvadas.';

  @override
  String get recordDescriptionUnlocked_unbroken => 'Cien, sin quiebres.';

  @override
  String get recordDescriptionUnlocked_ep1StrikeBack => 'Episodio 1 terminado.';

  @override
  String get recordDescriptionUnlocked_ep2EndTheThreat =>
      'Episodio 2 terminado.';

  @override
  String get recordDescriptionUnlocked_ep3HoldTheLine =>
      'Episodio 3 terminado.';

  @override
  String get recordDescriptionUnlocked_ep4TheOtherSide =>
      'Recorrió el otro lado.';

  @override
  String get recordDescriptionUnlocked_againstTheOdds =>
      'Contra todo pronóstico — cada página del canon.';

  @override
  String get recordDescriptionUnlocked_endlessSpark =>
      'Una chispa atrapada en Infinito.';

  @override
  String get recordDescriptionUnlocked_endlessFocus =>
      'Siete sostenidos en foco.';

  @override
  String get recordDescriptionUnlocked_endlessMaster => 'Quince con maestría.';

  @override
  String get recordDescriptionUnlocked_unshaken =>
      'Inquebrantable de principio a fin.';

  @override
  String get recordCategoryRescue => 'Rescate';

  @override
  String get recordCategoryEpisodes => 'Episodios';

  @override
  String get recordCategoryEndless => 'Infinito';

  @override
  String get recordCategoryMastery => 'Maestría';

  @override
  String get recordsSheetEyebrow => 'REGISTROS DE RESCATE';

  @override
  String recordsCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String get recordsMysteryTitle => '???';

  @override
  String get recordsMysteryDescription => 'Registro Desconocido.';

  @override
  String get recordsSheetIntro => 'Estas páginas se llenarán solas.';

  @override
  String get recordUnlockEyebrow => '✓ REGISTRO DESBLOQUEADO';

  @override
  String get recordUnlockEyebrowFirstEver => 'Se ha escrito una página.';

  @override
  String get recordsAllPagesWritten => 'Cada página ha sido escrita.';

  @override
  String get recordUnlockOverlayCta => 'Página pasada.';

  @override
  String get signaturesTabLabel => 'FIRMAS';

  @override
  String get signaturesEmptyStateLine1 => 'Algunos rescates se quedan contigo.';

  @override
  String get signaturesEmptyStateLine2 => 'Aquí es donde los guardas.';

  @override
  String get signaturesRecentlySolvedHeader => 'RESUELTOS RECIENTEMENTE';

  @override
  String get signaturesMenuRemove => 'Quitar de Firmas';

  @override
  String get signaturesRemoveDialogTitle => '¿Quitar de Firmas?';

  @override
  String get signaturesRemoveDialogBody =>
      'Este rescate ya no estará en tu colección.';

  @override
  String get signaturesRemoveDialogCancel => 'Cancelar';

  @override
  String get signaturesRemoveDialogConfirm => 'Quitar';

  @override
  String signaturesJournalLineCanonical(int episodeNumber) {
    return 'Del Episodio $episodeNumber';
  }

  @override
  String signaturesJournalLineCanonicalToday(int episodeNumber) {
    return 'Del Episodio $episodeNumber · hoy';
  }

  @override
  String get signaturesJournalLineEndless => 'Del Infinito';

  @override
  String get signaturesJournalLineEndlessToday => 'Del Infinito · hoy';

  @override
  String signaturesJournalCanonicalDetail(int episodeNumber) {
    return 'Del Episodio $episodeNumber.';
  }

  @override
  String get signaturesJournalEndlessDetail => 'Del Infinito.';

  @override
  String get signaturesJournalRememberedDetail => 'Aún recordado.';

  @override
  String get signaturesFirstBookmarkHintLine1 => 'Guardado.';

  @override
  String get signaturesFirstBookmarkHintLine2 =>
      'Guarda los rescates que se quedan contigo.';

  @override
  String get relativeTimeToday => 'hoy';

  @override
  String get familiarCueLabel => 'FAMILIAR';

  @override
  String get familiarFirstSeenHintLine => 'Lo conoces.';
}
