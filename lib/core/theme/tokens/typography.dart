import 'package:flutter/material.dart';

import 'colors.dart';

/// Typography tokens — ten roles, single family, locked scale.
///
/// Every text style in v1.2.0 surfaces consumes [TextTokens]. The legacy
/// [AppText] namespace stays untouched for backward compatibility; future
/// PRs migrate widgets one at a time.
///
/// Family: Inter (bundled at weights 400/500/600/700). Display weights
/// declare 700; future PRs may swap to 800 (ExtraBold) once that face is
/// bundled — no token-API change required.
abstract final class TextTokens {
  static const String _displayFamily = 'Inter';
  static const String _monoFamily = 'monospace';

  /// DisplayLarge — hero copy on Home and major splash surfaces.
  /// 52 / Bold / tracking −0.02em / line-height 1.0.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 52,
    letterSpacing: -1.04,
    height: 1.0,
    color: ColorTokens.textPrimary,
  );

  /// DisplayMedium — success state "Rescued.", trilogy-finale headlines.
  /// 44 / Bold / tracking −0.02em / line-height 1.0.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 44,
    letterSpacing: -0.88,
    height: 1.0,
    color: ColorTokens.textPrimary,
  );

  /// Headline — card titles, journal section heads.
  /// 28 / Bold / tracking −0.01em / line-height 1.15.
  static const TextStyle headline = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    letterSpacing: -0.28,
    height: 1.15,
    color: ColorTokens.textPrimary,
  );

  /// Title — today's puzzle card title, in-game briefing first line.
  /// 20 / SemiBold / tracking −0.01em / line-height 1.15.
  static const TextStyle title = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: -0.20,
    height: 1.15,
    color: ColorTokens.textPrimary,
  );

  /// Body — standard reading copy, CTA labels.
  /// 16 / Regular / line-height 1.4.
  static const TextStyle body = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
    color: ColorTokens.textPrimary,
  );

  /// BodySmall — secondary copy, dense descriptive text.
  /// 14 / Regular / line-height 1.4.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    color: ColorTokens.textPrimary,
  );

  /// Caption — sub-text, descriptions, metadata.
  /// 12 / Regular / line-height 1.3.
  static const TextStyle caption = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: ColorTokens.textSecondary,
  );

  /// Mono — counts, streaks, technical labels. Tabular figures.
  /// 14 / Medium / tracking +0.10em / line-height 1.3.
  static const TextStyle mono = TextStyle(
    fontFamily: _monoFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 1.4,
    height: 1.3,
    color: ColorTokens.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Label — small-caps eyebrows (▮ THREAT, ▮ RESCUED, ▮ TODAY).
  /// 11 / SemiBold / tracking +0.15em / line-height 1.0.
  /// Pair with `.toUpperCase()` at the consumer for the small-caps register.
  static const TextStyle label = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 1.65,
    height: 1.0,
    color: ColorTokens.textPrimary,
  );

  /// Button — primary CTA labels, footer button text.
  /// 16 / Medium / line-height 1.0.
  static const TextStyle button = TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.0,
    color: ColorTokens.textPrimary,
  );
}
