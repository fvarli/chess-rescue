/// Spacing scale — eleven steps from `s2` to `s64`.
///
/// All padding, margin, and gap values in v1.2.0 surfaces consume
/// [SpacingTokens]. Hardcoded `EdgeInsets.all(N)` or `SizedBox(height: N)`
/// values in future PR diffs should be replaced with the closest token.
///
/// Naming: `s<pixels>` — the step value is the literal pixel count, so
/// reading `SpacingTokens.s16` makes its meaning self-evident at the
/// call site.
abstract final class SpacingTokens {
  /// 2 — hairline tightening (e.g., between an icon and its companion glyph).
  static const double s2 = 2.0;

  /// 4 — micro-spacing (chip internal gaps, dot constellations).
  static const double s4 = 4.0;

  /// 8 — standard small gap (between caption and title).
  static const double s8 = 8.0;

  /// 12 — comfortable small (between body lines in a stacked card).
  static const double s12 = 12.0;

  /// 16 — base unit. Default card padding, between adjacent cards.
  static const double s16 = 16.0;

  /// 20 — generous small.
  static const double s20 = 20.0;

  /// 24 — section breathing room.
  static const double s24 = 24.0;

  /// 32 — between hero and supporting content.
  static const double s32 = 32.0;

  /// 40 — major section divider.
  static const double s40 = 40.0;

  /// 48 — generous spacing (between Home zones).
  static const double s48 = 48.0;

  /// 64 — hero-level whitespace (between the headline lockup and the CTA).
  static const double s64 = 64.0;
}
