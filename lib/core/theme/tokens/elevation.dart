import 'package:flutter/widgets.dart';

import 'colors.dart';

/// Elevation tokens — `BoxShadow` lists for six depth tiers.
///
/// The base shadows (low / medium / high / floating) layer subtle dark
/// drop-shadows; the glow shadows (`glowDanger` / `glowRelief`) replace
/// the drop-shadow with the emotional accent color for ambient-pulse
/// surfaces.
abstract final class ElevationTokens {
  /// Low — barely-perceptible separation. Inline chips, secondary cards.
  static const List<BoxShadow> low = [
    BoxShadow(color: ColorTokens.shadow, blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Medium — standard card depth. Briefing cards, list rows.
  static const List<BoxShadow> medium = [
    BoxShadow(color: ColorTokens.shadow, blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// High — raised hero surfaces. Today's puzzle card, prominent CTAs.
  static const List<BoxShadow> high = [
    BoxShadow(color: ColorTokens.shadow, blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// Floating — modal sheets, snackbars, anything that visually detaches.
  static const List<BoxShadow> floating = [
    BoxShadow(color: ColorTokens.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Glow — danger. Ambient coral halo around threatened-king surfaces.
  /// No offset; uniform radial bloom.
  static const List<BoxShadow> glowDanger = [
    BoxShadow(color: ColorTokens.dangerGlow, blurRadius: 32),
  ];

  /// Glow — relief. Ambient mint halo around rescued / success surfaces.
  /// No offset; uniform radial bloom.
  static const List<BoxShadow> glowRelief = [
    BoxShadow(color: ColorTokens.reliefGlow, blurRadius: 32),
  ];
}
