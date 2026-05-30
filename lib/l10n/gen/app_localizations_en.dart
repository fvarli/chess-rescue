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
}
