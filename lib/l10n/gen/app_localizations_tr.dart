// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppL10nTr extends AppL10n {
  AppL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Chess Rescue';

  @override
  String get introTitle => 'Tek hamle şahı kurtarır.';

  @override
  String get introBody =>
      'Her tahta tehlikeyle başlar.\nKurtarışı bul. Rahatlamayı hisset.';

  @override
  String get introSecondary => 'Süre yok. Ders yok. Yalnızca çıkış yolu.';

  @override
  String get introCta => 'Kurtarışa başla';

  @override
  String get headlineSaveTheKing => 'Şahı kurtar.';

  @override
  String get headlineWhereWillItGo => 'Nereye gidecek?';

  @override
  String get headlineRescued => 'Kurtarıldı.';

  @override
  String get headlineNotTheMove => 'Bu hamle değil.';

  @override
  String get hintOnboardingOneMoveSaves => 'Tek hamle oyunu kurtarır.';

  @override
  String get hintOnboardingFindRescue => 'Kurtarışı bul.';

  @override
  String get hintOnboardingStillTrapped => 'Şah hâlâ tuzakta.';

  @override
  String get hintTapHighlightedSquare => 'Hamle için vurgulanan kareye dokun.';

  @override
  String get completionFootnote => 'Tahta artık sakin.';

  @override
  String get footerNextPuzzle => 'Sıradaki bulmaca  ↦';

  @override
  String get footerAgain => 'Tekrar  ↻';

  @override
  String get footerTryAgain => 'Tekrar dene  ↺';

  @override
  String get footerReset => 'Sıfırla';

  @override
  String puzzleCounter(int current, int total) {
    return 'BULMACA $current/$total';
  }
}
