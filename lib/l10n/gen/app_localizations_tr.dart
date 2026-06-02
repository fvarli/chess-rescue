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
  String get puzzleCC2StatusText => '▮ Mat geliyor';

  @override
  String get puzzleCC2DangerHint =>
      'Vezir şahı bir adımda köşeye sıkıştırmak üzere.';

  @override
  String get puzzleCC2FailureHint =>
      'Bu hamle tehdidi kırmıyor. Diğer şaha vur.';

  @override
  String get puzzleCC2SuccessExplanation => 'FİL İÇERİ DALAR';

  @override
  String get puzzleCAM1StatusText => '▮ Şahta';

  @override
  String get puzzleCAM1DangerHint => 'Bir fil ısırıyor. Geri vur.';

  @override
  String get puzzleCAM1FailureHint => 'Fil hâlâ orada. Al onu.';

  @override
  String get puzzleCAM1SuccessExplanation => 'AT FİLİ ALIR';

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

  @override
  String get episodeSheetCompleteEyebrow => '✓ BÖLÜM TAMAMLANDI';

  @override
  String get episodeSheetTrilogyEyebrow => '✓ ÜÇLEME TAMAMLANDI';

  @override
  String episodeSheetEpisodeLabel(int number) {
    return 'Bölüm $number';
  }

  @override
  String episodeSheetRescuesCount(int count) {
    return '$count kurtarış tamamlandı';
  }

  @override
  String get episodeSheetTrilogyUnlock => 'Master ve Sonsuz açıldı';

  @override
  String get episodeSheetContinue => 'Devam et';

  @override
  String get recordTitle_firstRescue => 'İlk Kurtarış';

  @override
  String get recordTitle_familiarGround => 'Tanıdık Zemin';

  @override
  String get recordTitle_theRescuer => 'Kurtarıcı';

  @override
  String get recordTitle_unbroken => 'Yenilmez';

  @override
  String get recordTitle_ep1StrikeBack => 'Karşı Vur';

  @override
  String get recordTitle_ep2EndTheThreat => 'Tehdidi Bitir';

  @override
  String get recordTitle_ep3HoldTheLine => 'Hattı Tut';

  @override
  String get recordTitle_ep4TheOtherSide => 'Diğer Taraf';

  @override
  String get recordTitle_againstTheOdds => 'Tüm Olasılıklara Karşı';

  @override
  String get recordTitle_endlessSpark => 'Sonsuz Kıvılcım';

  @override
  String get recordTitle_endlessFocus => 'Sonsuz Odak';

  @override
  String get recordTitle_endlessMaster => 'Sonsuz Usta';

  @override
  String get recordTitle_unshaken => 'Sarsılmaz';

  @override
  String get recordDescriptionLocked_firstRescue => 'İlk kurtarışını tamamla.';

  @override
  String get recordDescriptionLocked_familiarGround => '10 kurtarış tamamla.';

  @override
  String get recordDescriptionLocked_theRescuer => '25 kurtarış tamamla.';

  @override
  String get recordDescriptionLocked_unbroken => '100 kurtarış tamamla.';

  @override
  String get recordDescriptionLocked_ep1StrikeBack => 'Bölüm 1\'i bitir.';

  @override
  String get recordDescriptionLocked_ep2EndTheThreat => 'Bölüm 2\'yi bitir.';

  @override
  String get recordDescriptionLocked_ep3HoldTheLine => 'Bölüm 3\'ü bitir.';

  @override
  String get recordDescriptionLocked_ep4TheOtherSide => 'Bölüm 4\'ü bitir.';

  @override
  String get recordDescriptionLocked_againstTheOdds =>
      'Tüm bölümleri bitir ve aynayı yürü.';

  @override
  String get recordDescriptionLocked_endlessSpark =>
      'Sonsuz\'da 3 kurtarışlık seri yakala.';

  @override
  String get recordDescriptionLocked_endlessFocus =>
      'Sonsuz\'da 7 kurtarışlık seri yakala.';

  @override
  String get recordDescriptionLocked_endlessMaster =>
      'Sonsuz\'da 15 kurtarışlık seri yakala.';

  @override
  String get recordDescriptionLocked_unshaken => 'Bir bölümü hatasız bitir.';

  @override
  String get recordDescriptionUnlocked_firstRescue => 'İlk kurtarışın.';

  @override
  String get recordDescriptionUnlocked_familiarGround =>
      'Tahta tanıdık geliyor.';

  @override
  String get recordDescriptionUnlocked_theRescuer =>
      'Yirmi beş can kurtarıldı.';

  @override
  String get recordDescriptionUnlocked_unbroken => 'Yüz, hiç kırılmadan.';

  @override
  String get recordDescriptionUnlocked_ep1StrikeBack => 'Bölüm 1 bitti.';

  @override
  String get recordDescriptionUnlocked_ep2EndTheThreat => 'Bölüm 2 bitti.';

  @override
  String get recordDescriptionUnlocked_ep3HoldTheLine => 'Bölüm 3 bitti.';

  @override
  String get recordDescriptionUnlocked_ep4TheOtherSide => 'Diğer taraf yürüdü.';

  @override
  String get recordDescriptionUnlocked_againstTheOdds =>
      'Tüm olasılıklara karşı — kanonun her sayfası.';

  @override
  String get recordDescriptionUnlocked_endlessSpark =>
      'Sonsuz\'da bir kıvılcım yakaladı.';

  @override
  String get recordDescriptionUnlocked_endlessFocus => 'Yedi, odakta tutuldu.';

  @override
  String get recordDescriptionUnlocked_endlessMaster => 'On beş, ustalıkta.';

  @override
  String get recordDescriptionUnlocked_unshaken => 'Baştan sona sarsılmadan.';

  @override
  String get recordCategoryRescue => 'Kurtarış';

  @override
  String get recordCategoryEpisodes => 'Bölümler';

  @override
  String get recordCategoryEndless => 'Sonsuz';

  @override
  String get recordCategoryMastery => 'Ustalık';

  @override
  String get recordsSheetEyebrow => 'KURTARIŞ KAYITLARI';

  @override
  String recordsCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String get recordsMysteryTitle => '???';

  @override
  String get recordsMysteryDescription => 'Bilinmeyen Kayıt.';

  @override
  String get recordsSheetIntro => 'Bu sayfalar kendiliğinden dolacak.';

  @override
  String get recordUnlockEyebrow => '✓ KAYIT AÇILDI';

  @override
  String get recordUnlockEyebrowFirstEver => 'Bir sayfa yazıldı.';

  @override
  String get recordsAllPagesWritten => 'Her sayfa yazıldı.';

  @override
  String get recordUnlockOverlayCta => 'Sayfa çevrildi.';

  @override
  String get signaturesTabLabel => 'İMZALAR';

  @override
  String get signaturesEmptyStateLine1 => 'Bazı kurtarışlar seninle kalır.';

  @override
  String get signaturesEmptyStateLine2 => 'Onları burada saklarsın.';

  @override
  String get signaturesRecentlySolvedHeader => 'SON ÇÖZÜLENLER';

  @override
  String get signaturesMenuRemove => 'İmzalardan kaldır';

  @override
  String get signaturesRemoveDialogTitle => 'İmzalardan kaldırılsın mı?';

  @override
  String get signaturesRemoveDialogBody =>
      'Bu kurtarış artık koleksiyonunda olmayacak.';

  @override
  String get signaturesRemoveDialogCancel => 'İptal';

  @override
  String get signaturesRemoveDialogConfirm => 'Kaldır';

  @override
  String signaturesJournalLineCanonical(int episodeNumber) {
    return '$episodeNumber. Bölümden';
  }

  @override
  String signaturesJournalLineCanonicalToday(int episodeNumber) {
    return '$episodeNumber. Bölümden · bugün';
  }

  @override
  String get signaturesJournalLineEndless => 'Sonsuzdan';

  @override
  String get signaturesJournalLineEndlessToday => 'Sonsuzdan · bugün';

  @override
  String signaturesJournalCanonicalDetail(int episodeNumber) {
    return '$episodeNumber. Bölümden.';
  }

  @override
  String get signaturesJournalEndlessDetail => 'Sonsuzdan.';

  @override
  String get signaturesJournalRememberedDetail => 'Hâlâ hatırlanıyor.';

  @override
  String get signaturesFirstBookmarkHintLine1 => 'Kaydedildi.';

  @override
  String get signaturesFirstBookmarkHintLine2 =>
      'Seninle kalan kurtarışları sakla.';

  @override
  String get relativeTimeToday => 'bugün';

  @override
  String get familiarCueLabel => 'AŞİNA';

  @override
  String get familiarFirstSeenHintLine => 'Bunu biliyorsun.';
}
