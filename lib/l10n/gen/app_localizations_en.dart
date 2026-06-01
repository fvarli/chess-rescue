// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chess Rescue';

  @override
  String get introTitle => 'One move saves the king.';

  @override
  String get introBody =>
      'Every board begins in danger.\nFind the rescue. Feel the relief.';

  @override
  String get introSecondary => 'No timers. No lessons. Just the way out.';

  @override
  String get introCta => 'Start rescue';

  @override
  String get headlineSaveTheKing => 'Save the king.';

  @override
  String get headlineWhereWillItGo => 'Where will it go?';

  @override
  String get headlineRescued => 'Rescued.';

  @override
  String get headlineNotTheMove => 'Not the move.';

  @override
  String get hintOnboardingOneMoveSaves => 'One move saves the game.';

  @override
  String get hintOnboardingFindRescue => 'Find the rescue.';

  @override
  String get hintOnboardingStillTrapped => 'The king is still trapped.';

  @override
  String get hintTapHighlightedSquare => 'Tap a highlighted square to move.';

  @override
  String get completionFootnote => 'The board is quiet now.';

  @override
  String get footerNextPuzzle => 'Next puzzle  ↦';

  @override
  String get footerAgain => 'Again  ↻';

  @override
  String get footerTryAgain => 'Try again  ↺';

  @override
  String get footerReset => 'Reset';

  @override
  String puzzleCounter(int current, int total) {
    return 'PUZZLE $current/$total';
  }

  @override
  String get puzzleP1StatusText => '▮ Active threat';

  @override
  String get puzzleP1DangerHint => 'Tap a white piece to see its moves.';

  @override
  String get puzzleP1FailureHint =>
      'That move doesn\'t break the attack. Look for a check.';

  @override
  String get puzzleP1SuccessExplanation => 'THE KNIGHT STRIKES BACK';

  @override
  String get puzzleP2StatusText => '▮ In check';

  @override
  String get puzzleP2DangerHint => 'The checker sits one step away.';

  @override
  String get puzzleP2FailureHint => 'The knight still gives check.';

  @override
  String get puzzleP2SuccessExplanation => 'THE CHECKER IS GONE';

  @override
  String get puzzleP3StatusText => '▮ Checked on the file';

  @override
  String get puzzleP3DangerHint => 'Checked straight down the file.';

  @override
  String get puzzleP3FailureHint => 'That doesn\'t block the check.';

  @override
  String get puzzleP3SuccessExplanation => 'THE FILE IS SEALED';

  @override
  String get puzzleP4StatusText => '▮ Checked on the diagonal';

  @override
  String get puzzleP4DangerHint => 'The long diagonal is loaded.';

  @override
  String get puzzleP4FailureHint => 'The diagonal is still open.';

  @override
  String get puzzleP4SuccessExplanation => 'THE DIAGONAL IS CLOSED';

  @override
  String get puzzleP5StatusText => '▮ Checked on the rank';

  @override
  String get puzzleP5DangerHint => 'The queen has crashed the back rank.';

  @override
  String get puzzleP5FailureHint => 'The queen still gives check.';

  @override
  String get puzzleP5SuccessExplanation => 'THE QUEEN FALLS';

  @override
  String get puzzleA4StatusText => '▮ Hunted at the gate';

  @override
  String get puzzleA4DangerHint =>
      'Your knight is cornered and the gate is under fire.';

  @override
  String get puzzleA4FailureHint =>
      'That slips away but strikes nothing. Hit back with a check.';

  @override
  String get puzzleA4SuccessExplanation => 'THE KNIGHT BREAKS FREE';

  @override
  String get puzzleB1StatusText => '▮ The line is open';

  @override
  String get puzzleB1DangerHint =>
      'The diagonal is loaded and the king stands bare.';

  @override
  String get puzzleB1FailureHint =>
      'That doesn\'t stand in the way. Throw a body on the line.';

  @override
  String get puzzleB1SuccessExplanation => 'A BODY FOR THE KING';

  @override
  String get puzzleB3StatusText => '▮ Held up by one piece';

  @override
  String get puzzleB3DangerHint =>
      'One defender is propping up the whole attack.';

  @override
  String get puzzleB3FailureHint =>
      'The attack still stands. Tear out its support.';

  @override
  String get puzzleB3SuccessExplanation => 'THE PROP IS GONE';

  @override
  String get puzzleB4StatusText => '▮ In check';

  @override
  String get puzzleB4DangerHint =>
      'You\'re in check — but you can answer in kind.';

  @override
  String get puzzleB4FailureHint =>
      'That doesn\'t break the check. Answer with a check of your own.';

  @override
  String get puzzleB4SuccessExplanation => 'CHECK MEETS CHECK';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystemDefault => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageTurkish => 'Turkish';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsDone => 'Done';

  @override
  String get homeTagline => 'Your king is in danger.\nFind the rescue.';

  @override
  String get homeRescueMission => 'RESCUE MISSION';

  @override
  String get homeCurrentRun => 'Current run';

  @override
  String homeRescueCounter(int current, int total) {
    return 'Rescue $current / $total';
  }

  @override
  String homeTotalRescues(int count) {
    return 'Total rescues: $count';
  }

  @override
  String get homeContinue => 'Continue rescue  ↦';

  @override
  String get homeStart => 'Start rescue  ↦';

  @override
  String episodeBadge(int number) {
    return 'EPISODE $number';
  }

  @override
  String get episodeEp1Title => 'STRIKE BACK';

  @override
  String get episodeEp1Tagline => 'Turn the attack back.';

  @override
  String get episodeEp2Title => 'END THE THREAT';

  @override
  String get episodeEp2Tagline => 'Take the attacker off the board.';

  @override
  String get episodeEp3Title => 'HOLD THE LINE';

  @override
  String get episodeEp3Tagline => 'A body for the king.';

  @override
  String get episodeEp4Title => 'THE OTHER SIDE';

  @override
  String get episodeEp4Tagline =>
      'You\'ve seen these before. Find the rescue from the other side.';

  @override
  String get episodeEp5Title => 'ENDLESS RESCUE';

  @override
  String get episodeEp5Tagline => 'Save the king. Again. And again.';

  @override
  String episodeBestRun(int count) {
    return 'Best run: $count';
  }

  @override
  String get episodeLockedLabel => 'Finish the previous episode to unlock.';

  @override
  String get episodeCompleteFooter => 'Episode complete  ↦';

  @override
  String get episodeCompleteToast => 'Episode complete. Next rescue unlocked.';

  @override
  String get episodeTrilogyCompleteToast =>
      'Trilogy complete. Master and Endless unlocked.';

  @override
  String get episodeSheetCompleteEyebrow => '✓ EPISODE COMPLETE';

  @override
  String get episodeSheetTrilogyEyebrow => '✓ TRILOGY COMPLETE';

  @override
  String episodeSheetEpisodeLabel(int number) {
    return 'Episode $number';
  }

  @override
  String episodeSheetRescuesCount(int count) {
    return '$count rescues completed';
  }

  @override
  String get episodeSheetTrilogyUnlock => 'Master and Endless unlocked';

  @override
  String get episodeSheetContinue => 'Continue';

  @override
  String get recordTitle_firstRescue => 'First Rescue';

  @override
  String get recordTitle_familiarGround => 'Familiar Ground';

  @override
  String get recordTitle_theRescuer => 'The Rescuer';

  @override
  String get recordTitle_unbroken => 'Unbroken';

  @override
  String get recordTitle_ep1StrikeBack => 'Strike Back';

  @override
  String get recordTitle_ep2EndTheThreat => 'End the Threat';

  @override
  String get recordTitle_ep3HoldTheLine => 'Hold the Line';

  @override
  String get recordTitle_ep4TheOtherSide => 'The Other Side';

  @override
  String get recordTitle_againstTheOdds => 'Against the Odds';

  @override
  String get recordTitle_endlessSpark => 'Endless Spark';

  @override
  String get recordTitle_endlessFocus => 'Endless Focus';

  @override
  String get recordTitle_endlessMaster => 'Endless Master';

  @override
  String get recordTitle_unshaken => 'Unshaken';

  @override
  String get recordDescriptionLocked_firstRescue =>
      'Complete your first rescue.';

  @override
  String get recordDescriptionLocked_familiarGround => 'Complete 10 rescues.';

  @override
  String get recordDescriptionLocked_theRescuer => 'Complete 25 rescues.';

  @override
  String get recordDescriptionLocked_unbroken => 'Complete 100 rescues.';

  @override
  String get recordDescriptionLocked_ep1StrikeBack => 'Clear Episode 1.';

  @override
  String get recordDescriptionLocked_ep2EndTheThreat => 'Clear Episode 2.';

  @override
  String get recordDescriptionLocked_ep3HoldTheLine => 'Clear Episode 3.';

  @override
  String get recordDescriptionLocked_ep4TheOtherSide => 'Clear Episode 4.';

  @override
  String get recordDescriptionLocked_againstTheOdds =>
      'Clear every canonical episode and walk the mirror.';

  @override
  String get recordDescriptionLocked_endlessSpark =>
      'Reach a 3-rescue streak in Endless.';

  @override
  String get recordDescriptionLocked_endlessFocus =>
      'Reach a 7-rescue streak in Endless.';

  @override
  String get recordDescriptionLocked_endlessMaster =>
      'Reach a 15-rescue streak in Endless.';

  @override
  String get recordDescriptionLocked_unshaken =>
      'Clear an episode without a wrong move.';

  @override
  String get recordDescriptionUnlocked_firstRescue => 'Your first rescue.';

  @override
  String get recordDescriptionUnlocked_familiarGround =>
      'The board has become familiar.';

  @override
  String get recordDescriptionUnlocked_theRescuer => 'Twenty-five lives saved.';

  @override
  String get recordDescriptionUnlocked_unbroken => 'One hundred unbroken.';

  @override
  String get recordDescriptionUnlocked_ep1StrikeBack => 'Cleared Episode 1.';

  @override
  String get recordDescriptionUnlocked_ep2EndTheThreat => 'Cleared Episode 2.';

  @override
  String get recordDescriptionUnlocked_ep3HoldTheLine => 'Cleared Episode 3.';

  @override
  String get recordDescriptionUnlocked_ep4TheOtherSide =>
      'Walked the other side.';

  @override
  String get recordDescriptionUnlocked_againstTheOdds =>
      'Against the odds — every page of the canon.';

  @override
  String get recordDescriptionUnlocked_endlessSpark =>
      'A spark caught in Endless.';

  @override
  String get recordDescriptionUnlocked_endlessFocus => 'Seven held in focus.';

  @override
  String get recordDescriptionUnlocked_endlessMaster => 'Fifteen in mastery.';

  @override
  String get recordDescriptionUnlocked_unshaken => 'Unshaken throughout.';

  @override
  String get recordCategoryRescue => 'Rescue';

  @override
  String get recordCategoryEpisodes => 'Episodes';

  @override
  String get recordCategoryEndless => 'Endless';

  @override
  String get recordCategoryMastery => 'Mastery';

  @override
  String get recordsSheetEyebrow => 'RESCUE RECORDS';

  @override
  String recordsCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String get recordsMysteryTitle => '???';

  @override
  String get recordsMysteryDescription => 'Unknown Record.';

  @override
  String get recordsSheetIntro => 'These pages will fill themselves.';

  @override
  String get recordUnlockEyebrow => '✓ RECORD UNLOCKED';

  @override
  String get recordUnlockEyebrowFirstEver => 'A page has been written.';

  @override
  String get recordsAllPagesWritten => 'Every page has been written.';

  @override
  String get recordUnlockOverlayCta => 'Page turned.';
}
