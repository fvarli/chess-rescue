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
  static const Duration rescueBloom = Duration(milliseconds: 280);
  static const Duration rescueSettle = Duration(milliseconds: 420);
  static const Duration rescueBreathPeriod = Duration(milliseconds: 3000);
  static const double rescueScalePeak = 1.08;
  static const double rescueScaleSettled = 1.02;
  static const double rescueGlowPeak = 0.85;
  static const double rescueGlowSettled = 0.55;
  static const double rescueGlowBreathMin = 0.45;
  static const double rescueGlowBreathMax = 0.60;

  // — Failed flash (sting, micro-shake)
  static const Duration failHold = Duration(milliseconds: 140);
  static const Duration failFade = Duration(milliseconds: 380);
  static const Duration microShake = Duration(milliseconds: 80);
  static const double microShakeAmplitudePx = 1.0;
  static const int microShakeCycles = 2;

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
  static const double focusCueAlphaMin = 0.22;
  static const double focusCueAlphaMax = 0.46;
  static const double focusCueFillAlpha = 0.08;

  // — Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve slide = Curves.easeInOutCubic;
  static const Curve breath = Curves.easeInOutSine;
  static const Curve inhale = Curves.easeOutSine;
  static const Curve exhale = Curves.easeInSine;
  static const Curve press = Curves.easeOut;
}
