import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../game_state.dart';

class HeadlineText extends StatelessWidget {
  const HeadlineText({
    super.key,
    required this.state,
    required this.hasSelection,
    this.rescuedSettled = true,
  });

  final GameState state;
  final bool hasSelection;
  // PR-7 — gate the rescued headline behind a brief settle delay. While
  // false, the AnimatedSwitcher renders an empty placeholder; when it
  // flips true the existing rescueHeadlineFade carries the "Rescued."
  // text in. Other states ignore this flag entirely.
  final bool rescuedSettled;

  String _textFor(AppL10n t) => switch (state) {
    GameState.rescued => t.headlineRescued,
    GameState.failed => t.headlineNotTheMove,
    GameState.selected => t.headlineWhereWillItGo,
    GameState.danger =>
      hasSelection ? t.headlineWhereWillItGo : t.headlineSaveTheKing,
  };

  Color get _color =>
      state == GameState.rescued ? AppColors.rescue : AppColors.text;

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final text = _textFor(t);
    final duration = state == GameState.rescued
        ? MotionTokens.rescueHeadlineFade
        : MotionTokens.headlineFade;
    final isPending = state == GameState.rescued && !rescuedSettled;
    return AnimatedSwitcher(
      duration: duration,
      // PR-9A — easeOutQuart on the victory headline gives a non-linear
      // 0 / 15 / 40 / 72 / 100 opacity shape. Editorial typography settles
      // into place rather than appearing. Other states keep the original
      // easeOutCubic register.
      switchInCurve: state == GameState.rescued
          ? CurveTokens.entrance
          : MotionTokens.standard,
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
      // ValueKey(text) preserves the "no animation when state changes but text
      // is identical" behaviour (e.g. selected ↔ danger+selection both say
      // "Where will it go?"). The pending placeholder uses its own key so
      // the switcher fades the empty → text transition naturally.
      child: isPending
          ? const SizedBox.shrink(key: ValueKey('rescued-pending'))
          : Text(
              text,
              key: ValueKey(text),
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
    this.complete = false,
    this.rescuedSettled = true,
  });

  final GameState state;
  final bool hasSelection;
  final String dangerHint;
  final String failureHint;
  final String successExplanation;

  // First-run only: evocative, non-instructional copy for the cold open.
  // Rescued falls through to the normal explanation.
  final bool onboarding;

  // True only on the final puzzle's rescued screen once all five are saved.
  // Adds a quiet completion footnote beneath the success explanation.
  final bool complete;

  // PR-7 — rides the same settle delay as HeadlineText so the success
  // explanation lands with the headline rather than ahead of it.
  final bool rescuedSettled;

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final (text, style) = onboarding
        ? switch (state) {
            GameState.rescued => (
              successExplanation,
              AppText.mono.copyWith(
                color: AppColors.rescue,
                letterSpacing: 2.1,
              ),
            ),
            GameState.failed => (t.hintOnboardingStillTrapped, AppText.body),
            GameState.selected => (t.hintOnboardingFindRescue, AppText.body),
            GameState.danger => (
              hasSelection
                  ? t.hintOnboardingFindRescue
                  : t.hintOnboardingOneMoveSaves,
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
            GameState.selected => (t.hintTapHighlightedSquare, AppText.body),
            GameState.danger => (
              hasSelection ? t.hintTapHighlightedSquare : dangerHint,
              AppText.body,
            ),
          };
    final isPending = state == GameState.rescued && !rescuedSettled;
    // On the final completion, a quiet footnote sits beneath the success line.
    final Widget child = isPending
        ? const SizedBox.shrink(key: ValueKey('rescued-pending'))
        : complete
        ? Column(
            key: const ValueKey('complete'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, style: style, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                t.completionFootnote,
                style: AppText.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Text(
            text,
            key: ValueKey(text),
            style: style,
            textAlign: TextAlign.center,
          );
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
      child: child,
    );
  }
}
