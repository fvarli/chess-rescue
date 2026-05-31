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

  @override
  String get puzzleP1StatusText => '▮ Aktif tehdit';

  @override
  String get puzzleP1DangerHint =>
      'Hamlelerini görmek için beyaz bir taşa dokun.';

  @override
  String get puzzleP1FailureHint =>
      'Bu hamle saldırıyı kırmıyor. Bir şah çekişi ara.';

  @override
  String get puzzleP1SuccessExplanation => 'AT GERİ VURUR';

  @override
  String get puzzleP2StatusText => '▮ Şahta';

  @override
  String get puzzleP2DangerHint => 'Şah çeken bir adım ötede.';

  @override
  String get puzzleP2FailureHint => 'At hâlâ şah çekiyor.';

  @override
  String get puzzleP2SuccessExplanation => 'ŞAH KALKTI';

  @override
  String get puzzleP3StatusText => '▮ Dikeyde şah';

  @override
  String get puzzleP3DangerHint => 'Doğrudan dikey üzerinden şah.';

  @override
  String get puzzleP3FailureHint => 'Bu şahı kapatmıyor.';

  @override
  String get puzzleP3SuccessExplanation => 'DİKEY KAPANDI';

  @override
  String get puzzleP4StatusText => '▮ Çaprazda şah';

  @override
  String get puzzleP4DangerHint => 'Uzun çapraz tehdit altında.';

  @override
  String get puzzleP4FailureHint => 'Çapraz hâlâ açık.';

  @override
  String get puzzleP4SuccessExplanation => 'ÇAPRAZ KAPANDI';

  @override
  String get puzzleP5StatusText => '▮ Yatayda şah';

  @override
  String get puzzleP5DangerHint => 'Vezir arka sıraya daldı.';

  @override
  String get puzzleP5FailureHint => 'Vezir hâlâ şah çekiyor.';

  @override
  String get puzzleP5SuccessExplanation => 'VEZİR DÜŞER';

  @override
  String get puzzleA4StatusText => '▮ Kapıda kıstırıldı';

  @override
  String get puzzleA4DangerHint =>
      'Atın köşeye sıkıştı ve kapı tehdit altında.';

  @override
  String get puzzleA4FailureHint =>
      'Bu kaçar ama hiçbir şeye vurmaz. Bir şah çekişiyle karşılık ver.';

  @override
  String get puzzleA4SuccessExplanation => 'AT ÖZGÜRLEŞİR';

  @override
  String get puzzleB1StatusText => '▮ Hat açık';

  @override
  String get puzzleB1DangerHint => 'Çapraz dolu ve şah açıkta.';

  @override
  String get puzzleB1FailureHint => 'Bu yolu kesmiyor. Hatta bir taş feda et.';

  @override
  String get puzzleB1SuccessExplanation => 'ŞAH İÇİN BİR BEDEN';

  @override
  String get puzzleB3StatusText => '▮ Tek taşla ayakta';

  @override
  String get puzzleB3DangerHint => 'Bir savunucu tüm saldırıyı ayakta tutuyor.';

  @override
  String get puzzleB3FailureHint => 'Saldırı hâlâ ayakta. Desteğini söküp at.';

  @override
  String get puzzleB3SuccessExplanation => 'DESTEK GİTTİ';

  @override
  String get puzzleB4StatusText => '▮ Şahta';

  @override
  String get puzzleB4DangerHint =>
      'Şahtasın — ama aynı şekilde yanıt verebilirsin.';

  @override
  String get puzzleB4FailureHint =>
      'Bu şahı kırmıyor. Kendi şah çekişinle karşılık ver.';

  @override
  String get puzzleB4SuccessExplanation => 'ŞAHA ŞAH';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSystemDefault => 'Sistem dili';

  @override
  String get settingsLanguageEnglish => 'İngilizce';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsLanguageSpanish => 'İspanyolca';

  @override
  String get settingsDone => 'Bitti';

  @override
  String get homeTagline => 'Şahın tehlikede.\nKurtarışı bul.';

  @override
  String get homeRescueMission => 'KURTARMA GÖREVİ';

  @override
  String get homeCurrentRun => 'Mevcut seri';

  @override
  String homeRescueCounter(int current, int total) {
    return 'Kurtarış $current / $total';
  }

  @override
  String homeTotalRescues(int count) {
    return 'Toplam kurtarış: $count';
  }

  @override
  String get homeContinue => 'Kurtarışa devam et  ↦';

  @override
  String get homeStart => 'Kurtarışa başla  ↦';

  @override
  String episodeBadge(int number) {
    return 'BÖLÜM $number';
  }

  @override
  String get episodeEp1Title => 'KARŞI VUR';

  @override
  String get episodeEp1Tagline => 'Saldırıyı geri çevir.';

  @override
  String get episodeEp2Title => 'TEHDİDİ BİTİR';

  @override
  String get episodeEp2Tagline => 'Saldıranı tahtadan kaldır.';

  @override
  String get episodeEp3Title => 'HATTI TUT';

  @override
  String get episodeEp3Tagline => 'Şah için bir beden.';

  @override
  String get episodeEp4Title => 'DİĞER TARAF';

  @override
  String get episodeEp4Tagline =>
      'Bunları daha önce gördün. Kurtarışı diğer taraftan bul.';

  @override
  String get episodeEp5Title => 'SONSUZ KURTARIŞ';

  @override
  String get episodeEp5Tagline => 'Şahı kurtar. Tekrar. Ve tekrar.';

  @override
  String episodeBestRun(int count) {
    return 'En iyi tur: $count';
  }

  @override
  String get episodeLockedLabel => 'Açmak için önceki bölümü bitir.';

  @override
  String get episodeCompleteFooter => 'Bölüm tamamlandı  ↦';

  @override
  String get episodeCompleteToast =>
      'Bölüm tamamlandı. Sıradaki kurtarış açıldı.';

  @override
  String get episodeTrilogyCompleteToast =>
      'Üçleme tamamlandı. Master ve Sonsuz açıldı.';
}
