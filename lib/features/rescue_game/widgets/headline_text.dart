import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../game_state.dart';

class HeadlineText extends StatelessWidget {
  const HeadlineText({
    super.key,
    required this.state,
    required this.hasSelection,
  });

  final GameState state;
  final bool hasSelection;

  String get _text => switch (state) {
    GameState.rescued => 'Rescued.',
    GameState.failed => 'Not the move.',
    GameState.selected => 'Where will it go?',
    GameState.danger => hasSelection ? 'Where will it go?' : 'Save the king.',
  };

  Color get _color =>
      state == GameState.rescued ? AppColors.rescue : AppColors.text;

  @override
  Widget build(BuildContext context) {
    final duration = state == GameState.rescued
        ? MotionTokens.rescueHeadlineFade
        : MotionTokens.headlineFade;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: MotionTokens.standard,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        final offset = Tween<Offset>(
          begin: Offset(0, MotionTokens.headlineEntryOffsetPx / 100),
          end: Offset.zero,
        ).chain(CurveTween(curve: MotionTokens.standard)).animate(anim);
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: Text(
        _text,
        key: ValueKey(_text),
        style: AppText.headline.copyWith(color: _color),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class HintText extends StatelessWidget {
  const HintText({
    super.key,
    required this.state,
    required this.hasSelection,
    required this.dangerHint,
    required this.failureHint,
    required this.successExplanation,
    this.onboarding = false,
  });

  final GameState state;
  final bool hasSelection;
  final String dangerHint;
  final String failureHint;
  final String successExplanation;

  // First-run only: evocative, non-instructional copy for the cold open.
  // Rescued falls through to the normal explanation.
  final bool onboarding;

  @override
  Widget build(BuildContext context) {
    final (text, style) = onboarding
        ? switch (state) {
            GameState.rescued => (
              successExplanation,
              AppText.mono.copyWith(
                color: AppColors.rescue,
                letterSpacing: 2.1,
              ),
            ),
            GameState.failed => ('The king is still trapped.', AppText.body),
            GameState.selected => ('Find the rescue.', AppText.body),
            GameState.danger => (
              hasSelection ? 'Find the rescue.' : 'One move saves the game.',
              AppText.body,
            ),
          }
        : switch (state) {
            GameState.rescued => (
              successExplanation,
              AppText.mono.copyWith(
                color: AppColors.rescue,
                letterSpacing: 2.1,
              ),
            ),
            GameState.failed => (failureHint, AppText.body),
            GameState.selected => (
              'Tap a highlighted square to move.',
              AppText.body,
            ),
            GameState.danger => (
              hasSelection ? 'Tap a highlighted square to move.' : dangerHint,
              AppText.body,
            ),
          };
    // Hint fades in *after* the headline settles. Implemented as an
    // AnimatedSwitcher whose switchInCurve waits, then eases.
    return AnimatedSwitcher(
      duration: MotionTokens.hintFade,
      switchInCurve: Interval(
        MotionTokens.hintDelayFraction,
        1.0,
        curve: MotionTokens.standard,
      ),
      switchOutCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      child: Text(
        text,
        key: ValueKey(text),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
