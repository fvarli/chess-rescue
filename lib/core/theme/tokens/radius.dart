import 'package:flutter/widgets.dart';

/// Corner-radius tokens — six steps.
///
/// `Radius` constants for one-off uses; `BorderRadius.all(token)` convenience
/// constants for the common case of rounding every corner equally.
abstract final class RadiusTokens {
  /// Small — chips, small badges (6 px).
  static const Radius small = Radius.circular(6);

  /// Medium — briefing cards, secondary surfaces (12 px).
  static const Radius medium = Radius.circular(12);

  /// Large — Today's puzzle card, hero surfaces (20 px).
  static const Radius large = Radius.circular(20);

  /// XL — modal sheets, full-screen card-overlays (28 px).
  static const Radius xl = Radius.circular(28);

  /// Pill — full-pill buttons, status pills (999 px).
  static const Radius pill = Radius.circular(999);

  /// Circle — circular avatars, dots, icons (9999 px).
  /// Use when the geometry guarantees equal width and height.
  static const Radius circle = Radius.circular(9999);

  // ── BorderRadius convenience (most common all-corner case) ──────────────
  /// `BorderRadius.all(small)` — equal small corners.
  static const BorderRadius brSmall = BorderRadius.all(small);

  /// `BorderRadius.all(medium)` — equal medium corners.
  static const BorderRadius brMedium = BorderRadius.all(medium);

  /// `BorderRadius.all(large)` — equal large corners.
  static const BorderRadius brLarge = BorderRadius.all(large);

  /// `BorderRadius.all(xl)` — equal XL corners.
  static const BorderRadius brXl = BorderRadius.all(xl);

  /// `BorderRadius.all(pill)` — pill shape.
  static const BorderRadius brPill = BorderRadius.all(pill);

  /// `BorderRadius.all(circle)` — circular.
  static const BorderRadius brCircle = BorderRadius.all(circle);
}
