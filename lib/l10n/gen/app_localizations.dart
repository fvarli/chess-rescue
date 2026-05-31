import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n? of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n);
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

  /// Application title shown in OS task-switcher chrome and accessibility surfaces.
  ///
  /// In en, this message translates to:
  /// **'Chess Rescue'**
  String get appTitle;

  /// Intro overlay headline.
  ///
  /// In en, this message translates to:
  /// **'One move saves the king.'**
  String get introTitle;

  /// Intro overlay body — two short sentences on separate lines.
  ///
  /// In en, this message translates to:
  /// **'Every board begins in danger.\nFind the rescue. Feel the relief.'**
  String get introBody;

  /// Intro overlay tertiary supporting line.
  ///
  /// In en, this message translates to:
  /// **'No timers. No lessons. Just the way out.'**
  String get introSecondary;

  /// Intro overlay mint CTA button label.
  ///
  /// In en, this message translates to:
  /// **'Start rescue'**
  String get introCta;

  /// Danger-state headline shown when no piece is selected.
  ///
  /// In en, this message translates to:
  /// **'Save the king.'**
  String get headlineSaveTheKing;

  /// Headline shown when a piece is selected (selected state, or danger with a selection).
  ///
  /// In en, this message translates to:
  /// **'Where will it go?'**
  String get headlineWhereWillItGo;

  /// Headline shown after a successful rescue.
  ///
  /// In en, this message translates to:
  /// **'Rescued.'**
  String get headlineRescued;

  /// Headline shown after a failed move.
  ///
  /// In en, this message translates to:
  /// **'Not the move.'**
  String get headlineNotTheMove;

  /// First-run danger hint shown when no piece is selected.
  ///
  /// In en, this message translates to:
  /// **'One move saves the game.'**
  String get hintOnboardingOneMoveSaves;

  /// First-run hint shown when a piece is selected (or selected state).
  ///
  /// In en, this message translates to:
  /// **'Find the rescue.'**
  String get hintOnboardingFindRescue;

  /// First-run hint shown after a failed attempt.
  ///
  /// In en, this message translates to:
  /// **'The king is still trapped.'**
  String get hintOnboardingStillTrapped;

  /// Post-onboarding hint shown when a piece is selected.
  ///
  /// In en, this message translates to:
  /// **'Tap a highlighted square to move.'**
  String get hintTapHighlightedSquare;

  /// Quiet footnote shown beneath the success line on session completion.
  ///
  /// In en, this message translates to:
  /// **'The board is quiet now.'**
  String get completionFootnote;

  /// Footer CTA after a rescue when the session has a next puzzle.
  ///
  /// In en, this message translates to:
  /// **'Next puzzle  ↦'**
  String get footerNextPuzzle;

  /// Footer CTA after a rescue when the session is complete (rotates to the next session).
  ///
  /// In en, this message translates to:
  /// **'Again  ↻'**
  String get footerAgain;

  /// Footer CTA shown after a failed move.
  ///
  /// In en, this message translates to:
  /// **'Try again  ↺'**
  String get footerTryAgain;

  /// Footer CTA shown in danger/selected states (resets the current puzzle).
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get footerReset;

  /// Status pill counter — current puzzle number and total in the session.
  ///
  /// In en, this message translates to:
  /// **'PUZZLE {current}/{total}'**
  String puzzleCounter(int current, int total);

  /// P1 knight rescue — danger-state status pill message.
  ///
  /// In en, this message translates to:
  /// **'▮ Active threat'**
  String get puzzleP1StatusText;

  /// P1 danger hint.
  ///
  /// In en, this message translates to:
  /// **'Tap a white piece to see its moves.'**
  String get puzzleP1DangerHint;

  /// P1 failure hint.
  ///
  /// In en, this message translates to:
  /// **'That move doesn\'t break the attack. Look for a check.'**
  String get puzzleP1FailureHint;

  /// P1 success explanation (mono caps).
  ///
  /// In en, this message translates to:
  /// **'THE KNIGHT STRIKES BACK'**
  String get puzzleP1SuccessExplanation;

  /// P2 take-the-checker — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ In check'**
  String get puzzleP2StatusText;

  /// P2 danger hint.
  ///
  /// In en, this message translates to:
  /// **'The checker sits one step away.'**
  String get puzzleP2DangerHint;

  /// P2 failure hint.
  ///
  /// In en, this message translates to:
  /// **'The knight still gives check.'**
  String get puzzleP2FailureHint;

  /// P2 success explanation.
  ///
  /// In en, this message translates to:
  /// **'THE CHECKER IS GONE'**
  String get puzzleP2SuccessExplanation;

  /// P3 block-the-file — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ Checked on the file'**
  String get puzzleP3StatusText;

  /// P3 danger hint.
  ///
  /// In en, this message translates to:
  /// **'Checked straight down the file.'**
  String get puzzleP3DangerHint;

  /// P3 failure hint.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t block the check.'**
  String get puzzleP3FailureHint;

  /// P3 success explanation.
  ///
  /// In en, this message translates to:
  /// **'THE FILE IS SEALED'**
  String get puzzleP3SuccessExplanation;

  /// P4 seal-the-diagonal — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ Checked on the diagonal'**
  String get puzzleP4StatusText;

  /// P4 danger hint.
  ///
  /// In en, this message translates to:
  /// **'The long diagonal is loaded.'**
  String get puzzleP4DangerHint;

  /// P4 failure hint.
  ///
  /// In en, this message translates to:
  /// **'The diagonal is still open.'**
  String get puzzleP4FailureHint;

  /// P4 success explanation.
  ///
  /// In en, this message translates to:
  /// **'THE DIAGONAL IS CLOSED'**
  String get puzzleP4SuccessExplanation;

  /// P5 win-the-queen — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ Checked on the rank'**
  String get puzzleP5StatusText;

  /// P5 danger hint.
  ///
  /// In en, this message translates to:
  /// **'The queen has crashed the back rank.'**
  String get puzzleP5DangerHint;

  /// P5 failure hint.
  ///
  /// In en, this message translates to:
  /// **'The queen still gives check.'**
  String get puzzleP5FailureHint;

  /// P5 success explanation.
  ///
  /// In en, this message translates to:
  /// **'THE QUEEN FALLS'**
  String get puzzleP5SuccessExplanation;

  /// A4 the-breakaway — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ Hunted at the gate'**
  String get puzzleA4StatusText;

  /// A4 danger hint.
  ///
  /// In en, this message translates to:
  /// **'Your knight is cornered and the gate is under fire.'**
  String get puzzleA4DangerHint;

  /// A4 failure hint.
  ///
  /// In en, this message translates to:
  /// **'That slips away but strikes nothing. Hit back with a check.'**
  String get puzzleA4FailureHint;

  /// A4 success explanation.
  ///
  /// In en, this message translates to:
  /// **'THE KNIGHT BREAKS FREE'**
  String get puzzleA4SuccessExplanation;

  /// B1 the-martyr — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ The line is open'**
  String get puzzleB1StatusText;

  /// B1 danger hint.
  ///
  /// In en, this message translates to:
  /// **'The diagonal is loaded and the king stands bare.'**
  String get puzzleB1DangerHint;

  /// B1 failure hint.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t stand in the way. Throw a body on the line.'**
  String get puzzleB1FailureHint;

  /// B1 success explanation.
  ///
  /// In en, this message translates to:
  /// **'A BODY FOR THE KING'**
  String get puzzleB1SuccessExplanation;

  /// B3 remove-the-defender — status pill.
  ///
  /// In en, this message translates to:
  /// **'▮ Held up by one piece'**
  String get puzzleB3StatusText;

  /// B3 danger hint.
  ///
  /// In en, this message translates to:
  /// **'One defender is propping up the whole attack.'**
  String get puzzleB3DangerHint;

  /// B3 failure hint.
  ///
  /// In en, this message translates to:
  /// **'The attack still stands. Tear out its support.'**
  String get puzzleB3FailureHint;

  /// B3 success explanation.
  ///
  /// In en, this message translates to:
  /// **'THE PROP IS GONE'**
  String get puzzleB3SuccessExplanation;

  /// B4 the-cross-check — status pill (independent of P2 to allow translator variation).
  ///
  /// In en, this message translates to:
  /// **'▮ In check'**
  String get puzzleB4StatusText;

  /// B4 danger hint.
  ///
  /// In en, this message translates to:
  /// **'You\'re in check — but you can answer in kind.'**
  String get puzzleB4DangerHint;

  /// B4 failure hint.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t break the check. Answer with a check of your own.'**
  String get puzzleB4FailureHint;

  /// B4 success explanation.
  ///
  /// In en, this message translates to:
  /// **'CHECK MEETS CHECK'**
  String get puzzleB4SuccessExplanation;

  /// Title of the language picker bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Picker option that defers to the device's language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystemDefault;

  /// Picker option that forces the app into English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Picker option that forces the app into Turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get settingsLanguageTurkish;

  /// Picker option that forces the app into Spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// Dismisses the language picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get settingsDone;

  /// Home tagline beneath the title. Two short sentences — names the danger, directs the action — replacing the reused intro headline.
  ///
  /// In en, this message translates to:
  /// **'Your king is in danger.\nFind the rescue.'**
  String get homeTagline;

  /// Mission-briefing panel title on the Home progress card, rendered in AppText.mono with a coral status dot prefix — mirrors the in-game status pill grammar. Stored pre-uppercased per locale because Dart's String.toUpperCase() is locale-insensitive and would mis-case Turkish (e.g. 'görevi' → 'GÖREVI' instead of 'GÖREVİ'). Widget does NOT call toUpperCase().
  ///
  /// In en, this message translates to:
  /// **'RESCUE MISSION'**
  String get homeRescueMission;

  /// Sub-label inside the progress card, between the panel title and the counter. Sentence case — preserves single-eyebrow hierarchy under the panel title.
  ///
  /// In en, this message translates to:
  /// **'Current run'**
  String get homeCurrentRun;

  /// Session-local rescue counter shown beneath the 'Current run' sub-label on Home.
  ///
  /// In en, this message translates to:
  /// **'Rescue {current} / {total}'**
  String homeRescueCounter(int current, int total);

  /// Lifetime rescue count on Home (independent of the current session).
  ///
  /// In en, this message translates to:
  /// **'Total rescues: {count}'**
  String homeTotalRescues(int count);

  /// Home CTA for returning players (introSeen=true).
  ///
  /// In en, this message translates to:
  /// **'Continue rescue  ↦'**
  String get homeContinue;

  /// Home CTA for first-time players (introSeen=false).
  ///
  /// In en, this message translates to:
  /// **'Start rescue  ↦'**
  String get homeStart;

  /// Pre-uppercased badge prefix for the episode panel title on Home (e.g. 'EPISODE 1'). Stored pre-uppercased because Dart's String.toUpperCase() is locale-insensitive — see homeRescueMission precedent.
  ///
  /// In en, this message translates to:
  /// **'EPISODE {number}'**
  String episodeBadge(int number);

  /// Episode 1 title — canonical counter-check chapter (P1, A4, B4). Pre-uppercased per locale (see homeRescueMission precedent) — Dart's String.toUpperCase() is locale-insensitive and mis-cases Turkish.
  ///
  /// In en, this message translates to:
  /// **'STRIKE BACK'**
  String get episodeEp1Title;

  /// Episode 1 tagline.
  ///
  /// In en, this message translates to:
  /// **'Turn the attack back.'**
  String get episodeEp1Tagline;

  /// Episode 2 title — canonical capture/remove-attacker chapter (P2, P5, B3).
  ///
  /// In en, this message translates to:
  /// **'END THE THREAT'**
  String get episodeEp2Title;

  /// Episode 2 tagline.
  ///
  /// In en, this message translates to:
  /// **'Take the attacker off the board.'**
  String get episodeEp2Tagline;

  /// Episode 3 title — canonical interpose/martyr chapter (P3, P4, B1).
  ///
  /// In en, this message translates to:
  /// **'HOLD THE LINE'**
  String get episodeEp3Title;

  /// Episode 3 tagline.
  ///
  /// In en, this message translates to:
  /// **'A body for the king.'**
  String get episodeEp3Tagline;

  /// Episode 4 title — master/mirror chapter (mirrors of P1, P5, B1).
  ///
  /// In en, this message translates to:
  /// **'THE OTHER SIDE'**
  String get episodeEp4Title;

  /// Episode 4 tagline — frames the mirror inversion honestly.
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen these before. Find the rescue from the other side.'**
  String get episodeEp4Tagline;

  /// Episode 5 title — endless seed-composed long-term retention mode.
  ///
  /// In en, this message translates to:
  /// **'ENDLESS RESCUE'**
  String get episodeEp5Title;

  /// Episode 5 tagline.
  ///
  /// In en, this message translates to:
  /// **'Save the king. Again. And again.'**
  String get episodeEp5Tagline;

  /// Ep5-only Home card line. Shown only when bestEndlessStreak > 0.
  ///
  /// In en, this message translates to:
  /// **'Best run: {count}'**
  String episodeBestRun(int count);

  /// Snackbar copy when the player taps a locked-by-progression chip on the Home episode strip.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous episode to unlock.'**
  String get episodeLockedLabel;

  /// RescueScreen footer on the last rescue of a canonical or master episode — CTA returns to Home.
  ///
  /// In en, this message translates to:
  /// **'Episode complete  ↦'**
  String get episodeCompleteFooter;

  /// Home snackbar shown once after returning from a completed canonical or master episode (except ep3 — see episodeTrilogyCompleteToast). Triggered by the navigator pop result; ephemeral, no persistence.
  ///
  /// In en, this message translates to:
  /// **'Episode complete. Next rescue unlocked.'**
  String get episodeCompleteToast;

  /// Home snackbar shown once after completing Ep3 (the canonical trilogy finale) — Ep4 (master) and Ep5 (endless) unlock simultaneously.
  ///
  /// In en, this message translates to:
  /// **'Trilogy complete. Master and Endless unlocked.'**
  String get episodeTrilogyCompleteToast;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
    case 'tr':
      return AppL10nTr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
