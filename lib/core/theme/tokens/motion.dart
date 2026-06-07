import 'package:flutter/animation.dart';

/// Motion tokens — durations + curves at the *foundation* layer.
///
/// Distinct from the per-feature `MotionTokens` in `lib/core/theme/motion.dart`
/// (which carries shipped animation specifics for rescue bloom, danger pulse,
/// failure flash, etc.). This file is the generic scale every new
/// implicit-animation widget in v1.2.0 surfaces should consume.
///
/// Use [DurationTokens] for durations; use [CurveTokens] for easings.

/// Generic duration scale — four steps.
abstract final class DurationTokens {
  /// Fast — touch feedback, button-press in-and-out, hover micro-states.
  static const Duration fast = Duration(milliseconds: 120);

  /// Normal — standard implicit animations (color, opacity, size).
  static const Duration normal = Duration(milliseconds: 240);

  /// Slow — page transitions, modal sheet enter/exit, card morphs.
  static const Duration slow = Duration(milliseconds: 320);

  /// VerySlow — cinematic reveals, success choreography, briefing intros.
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// Generic curve scale — six entries.
abstract final class CurveTokens {
  /// Standard — default easing. Most implicit animations.
  static const Curve standard = Curves.easeOutCubic;

  /// Emphasized — for cinematic reveals; more aggressive decelerate.
  /// Use sparingly — meant to feel like a held breath releasing.
  static const Curve emphasized = Curves.easeOutExpo;

  /// Entrance — incoming widgets (fade-in, slide-in, scale-in).
  static const Curve entrance = Curves.easeOutQuart;

  /// Exit — outgoing widgets (fade-out, slide-out, scale-out).
  static const Curve exit = Curves.easeInQuart;

  /// Overshoot — playful pops for affirmation moments. Use rarely.
  static const Curve overshoot = Curves.easeOutBack;

  /// Spring — elastic settle. Closest pre-built approximation to a physics
  /// spring. For true physics-based motion, future PRs can introduce
  /// `SpringSimulation` with bespoke `SpringDescription` values.
  static const Curve spring = Curves.elasticOut;
}
