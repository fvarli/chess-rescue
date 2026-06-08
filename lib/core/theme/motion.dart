import 'package:flutter/animation.dart';

// Centralized motion language for Chess Rescue.
// Single source of truth for every Duration and Curve in the prototype.
// Tune feel here, not in widgets.
class MotionTokens {
  MotionTokens._();

  // — Piece selection
  static const Duration ringIn = Duration(milliseconds: 140);
  static const Duration pieceLift = Duration(milliseconds: 180);
  static const double pieceLiftedScale = 1.05;
  static const double rescuedLiftedScale = 1.04;
  static const double ringStartScale = 0.94;
  static const double ringBorderWidth = 2.5;

  // — Legal-move dots (fan, don't pop)
  static const Duration dotBloom = Duration(milliseconds: 180);
  static const Duration dotStaggerStep = Duration(milliseconds: 24);
  static const double dotStartScale = 0.6;

  // — Move commit (split pause + slide)
  static const Duration commitWindUp = Duration(milliseconds: 80);
  static const Duration pieceSlide = Duration(milliseconds: 220);
  static const Duration commitDotFadeOut = Duration(milliseconds: 120);
  static const double ringContractScale = 0.96;
  static const double ringContractOpacity = 0.6;

  // — Danger pulse (breath, not alarm)
  static const Duration dangerPulse = Duration(milliseconds: 2400);
  static const double dangerInhaleWeight = 0.40; // 40% inhale / 60% exhale
  static const double dangerAlphaMin = 0.40;
  static const double dangerAlphaMax = 0.65;
  static const double dangerBlurMinFactor = 0.55; // × square size
  static const double dangerBlurMaxFactor = 0.90;
  static const double dangerScaleMin = 0.99;
  static const double dangerScaleMax = 1.01;

  // — Rescue glow (bloom → settle → breath)
  // V2 — bloom savor: 280 → 340 ms gives the rescue resolution a touch more
  // weight without exceeding the < 1 s total rescue-resolution budget.
  static const Duration rescueBloom = Duration(milliseconds: 340);
  static const Duration rescueSettle = Duration(milliseconds: 420);
  static const Duration rescueBreathPeriod = Duration(milliseconds: 3000);
  static const double rescueScalePeak = 1.08;
  static const double rescueScaleSettled = 1.02;
  static const double rescueGlowPeak = 0.85;
  static const double rescueGlowSettled = 0.55;
  static const double rescueGlowBreathMin = 0.45;
  static const double rescueGlowBreathMax = 0.60;

  // — Failed flash (sting, micro-shake)
  // G1.4 — amplitude bumped from 1.0 → 2.0 px and cycles from 2 → 3 per the
  // game-feel playtest finding that the prior register lacked emotional
  // weight. Still well under the typical "perceptible shake" threshold
  // (~4–6 dp) — restrained, not gimmicky.
  static const Duration failHold = Duration(milliseconds: 140);
  static const Duration failFade = Duration(milliseconds: 380);
  static const Duration microShake = Duration(milliseconds: 80);
  static const double microShakeAmplitudePx = 2.0;
  static const int microShakeCycles = 3;

  // G1.3 — king-piece rescue pulse. One-shot scale pulse on the threatened
  // king when state transitions to rescued. Paired with the existing
  // rescueBloom (which paints the square) — the pulse makes the figure
  // itself respond. Subtler than `rescueScalePeak` (1.08), which is reserved
  // for the rescuing piece; the rescued king gets a softer "exhale" so the
  // two don't compete.
  static const Duration kingRescuePulse = Duration(milliseconds: 280);
  static const double kingRescuePulseScalePeak = 1.06;

  // V2 — failure rim flash. Boardwide coral rim pulses once when a non-rescue
  // move commits. Quiet "that didn't work" — never shame, never punishment.
  // Total flash = failRimIn + failRimHold + failRimOut = 370 ms.
  static const Duration failRimIn = Duration(milliseconds: 80);
  static const Duration failRimHold = Duration(milliseconds: 90);
  static const Duration failRimOut = Duration(milliseconds: 200);
  static const double failRimAlphaPeak = 0.32;
  static const double failRimWidthPx = 2.0;

  // V2 — rescue expansion ring. Single concentric mint ring radiates outward
  // from the rescue square at commit, fading as it expands. Quiet pride.
  // `rescueRingEndScale` starts at the subtle end of the visually sensible
  // range; tune UP only on playtesting evidence (see memory:
  // feedback_prefer_subtlety_first.md).
  static const Duration rescueRingExpand = Duration(milliseconds: 520);
  static const double rescueRingStartScale = 1.0; // begin at the square radius
  static const double rescueRingEndScale = 2.1; // end at ~2.1× the square
  static const double rescueRingAlphaStart = 0.55;
  static const double rescueRingStrokeStart = 1.6;
  static const double rescueRingStrokeEnd = 0.4;

  // — Ambient board presence (felt, not seen)
  // Three desynchronized layers tint and breathe the board surface so it
  // feels like a physical object resting in a quiet room. If a tester
  // consciously notices any of these, the values get dropped one step.
  static const Duration ambientBrightnessPeriod = Duration(milliseconds: 7000);
  static const double ambientBrightnessAmplitude = 0.015; // ±1.5% alpha
  static const Duration ambientLightDriftPeriod = Duration(milliseconds: 28000);
  static const double ambientLightDriftPeakAlpha = 0.025; // ≤3% room light
  static const double ambientGrainAmplitude = 0.02; // ±2% around the 0.45 base
  // On rescued transition the brightness pauses for an emotional beat, then
  // resumes at a softer amplitude — the board exhales without freezing.
  static const Duration ambientRescueExhale = Duration(milliseconds: 250);
  static const double ambientRescuedAmplitudeMul = 0.6;

  // — Rescue animation polish (PR-9A: curve / timing only)
  // Ring alpha decays 1.4× faster than radius — ripple loses energy before
  // it loses size. Conservative initial value; raise to 1.6 only on
  // device-review evidence.
  static const double rescueRingOpacityVsRadiusRatio = 1.4;
  // Status pill accent color interpolates over 180 ms on state change;
  // no flash, no instant swap.
  static const Duration statusPillTransitionDuration = Duration(
    milliseconds: 180,
  );

  // — Rescue ceremony stagger
  // Delay between the rescued-state transition and the moment the "Rescued."
  // headline starts its 320 ms fade-in. Lets the board's bloom + arrow phase
  // land first so the headline reads as the relief beat, not a simultaneous
  // announcement. Conservative initial value; never raise above ~460 ms.
  static const Duration rescueHeadlineSettleDelay = Duration(milliseconds: 280);

  // — Move arrow (post-rescue cinematic confirmation)
  // Three-phase: draw-in → strong hold → fade to a calmer presence so the
  // rescued board doesn't feel cluttered. See feedback_cinematic_confirmation_fade.
  static const Duration moveArrowDraw = Duration(milliseconds: 220);
  static const Duration moveArrowHold = Duration(milliseconds: 240);
  static const Duration moveArrowFade = Duration(milliseconds: 320);
  // Inside the draw phase, the arrowhead fades in over the final 20% so it
  // arrives with the shaft rather than punctuating after it.
  static const double moveArrowHeadStart = 0.80;
  static const double moveArrowPeakAlpha = 0.88;
  static const double moveArrowSettledAlpha = 0.50;

  // — Background gradient transition
  static const Duration gradientTransition = Duration(milliseconds: 600);

  // — Headline + hint cross-fade (staggered)
  static const Duration headlineFade = Duration(milliseconds: 240);
  static const Duration rescueHeadlineFade = Duration(milliseconds: 320);
  static const Duration hintFade = Duration(milliseconds: 320);
  static const double hintDelayFraction =
      80 / 320; // 80ms delay within 320ms window
  static const double headlineEntryOffsetPx = 6.0;

  // — Footer button (immediate press, breath on fail)
  static const Duration buttonPressIn = Duration(milliseconds: 80);
  static const Duration buttonPressOut = Duration(milliseconds: 160);
  static const double buttonPressedScale = 0.97;
  static const Duration buttonInviteBreath = Duration(milliseconds: 2400);
  static const double buttonInviteScaleMax = 1.012;

  // — Board ambient breath (alive at rest)
  static const Duration ambientBreathDefault = Duration(milliseconds: 4800);
  static const Duration ambientBreathCalm = Duration(milliseconds: 6400);
  static const Duration ambientHoldOnFail = Duration(milliseconds: 600);
  static const double ambientScaleMin = 1.0;
  static const double ambientScaleMax = 1.006;

  // — Reset transition (settle, don't snap)
  static const Duration resetOverlayFade = Duration(milliseconds: 200);
  static const Duration resetSettle = Duration(milliseconds: 320);

  // — First-run (onboarding) only. Additive; existing motion unchanged.
  // A slightly longer rescue settle so the first survival lingers.
  static const Duration firstRescueSettleExtra = Duration(milliseconds: 400);
  // Soft focus cue on the rescuing piece during the opening danger state.
  static const Duration focusCueFade = Duration(milliseconds: 200);
  static const double focusCueAlphaMin = 0.30;
  static const double focusCueAlphaMax = 0.58;
  static const double focusCueFillAlpha = 0.10;

  // Ambient (post-onboarding) focus cue — quieter companion to the danger
  // glow, never a competitor. Roughly half the onboarding amplitude.
  static const double focusCueAmbientAlphaMin = 0.18;
  static const double focusCueAmbientAlphaMax = 0.32;

  // — Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve slide = Curves.easeInOutCubic;
  static const Curve breath = Curves.easeInOutSine;
  static const Curve inhale = Curves.easeOutSine;
  static const Curve exhale = Curves.easeInSine;
  static const Curve press = Curves.easeOut;
}
