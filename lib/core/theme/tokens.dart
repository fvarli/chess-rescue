/// v1.2.0 "Threshold" foundation — barrel export for every design token.
///
/// Import this one file to bring in [ColorTokens], [TextTokens],
/// [SpacingTokens], [RadiusTokens], [ElevationTokens], [DurationTokens],
/// and [CurveTokens] together.
///
/// ```dart
/// import 'package:chess_rescue/core/theme/tokens.dart';
/// ```
///
/// Migration policy (PR-1 → later PRs): existing widgets continue to
/// consume the legacy `AppColors` / `AppText` / per-feature `MotionTokens`
/// namespaces in `app_theme.dart` and `motion.dart`. New widgets, and any
/// widget rewritten in a v1.2.0 PR, should consume the tokens in this
/// barrel exclusively.
library;

export 'tokens/colors.dart';
export 'tokens/elevation.dart';
export 'tokens/motion.dart';
export 'tokens/radius.dart';
export 'tokens/spacing.dart';
export 'tokens/typography.dart';
