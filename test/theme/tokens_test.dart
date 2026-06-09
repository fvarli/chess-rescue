import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/theme/motion.dart';
import 'package:chess_rescue/core/theme/tokens.dart';

// v1.2.0 "Threshold" foundation — token-value regression net.
//
// These tests pin the public surface of the token system. If a value here
// changes, a later PR that consumes it visibly changes too — so every
// modification to a token should also touch this file deliberately.

void main() {
  group('ColorTokens — semantic palette', () {
    test('danger family matches the shipped 1.1.1 coral', () {
      expect(ColorTokens.dangerPrimary, const Color(0xFFFF5A4C));
      // Glow is the same coral at 60% alpha.
      expect(ColorTokens.dangerGlow.r, ColorTokens.dangerPrimary.r);
      expect(ColorTokens.dangerGlow.g, ColorTokens.dangerPrimary.g);
      expect(ColorTokens.dangerGlow.b, ColorTokens.dangerPrimary.b);
      expect(ColorTokens.dangerGlow.a, closeTo(0.60, 0.01));
      // Background is the same coral at 10% alpha.
      expect(ColorTokens.dangerBackground.a, closeTo(0.10, 0.01));
    });

    test('relief family matches the shipped 1.1.1 mint', () {
      expect(ColorTokens.reliefPrimary, const Color(0xFF5EE2C0));
      expect(ColorTokens.reliefGlow.a, closeTo(0.60, 0.01));
      expect(ColorTokens.reliefBackground.a, closeTo(0.10, 0.01));
    });

    test('surface stack is three distinct depth values', () {
      expect(ColorTokens.surfacePrimary, const Color(0xFF0D0E12));
      expect(ColorTokens.surfaceSecondary, const Color(0xFF161821));
      expect(ColorTokens.surfaceElevated, const Color(0xFF1D2030));
      expect(ColorTokens.surfacePrimary, isNot(ColorTokens.surfaceSecondary));
      expect(ColorTokens.surfaceSecondary, isNot(ColorTokens.surfaceElevated));
    });

    test('text tokens carry expected alphas', () {
      expect(ColorTokens.textPrimary.a, closeTo(1.0, 0.001));
      expect(ColorTokens.textSecondary.a, closeTo(0.55, 0.01));
    });

    test('board materials are the warm-slate / charcoal pair', () {
      expect(ColorTokens.boardLight, const Color(0xFF3E4250));
      // boardDark carries a slight L lift over the shipped 1.1.1 value so
      // dark-piece silhouettes separate against it.
      expect(ColorTokens.boardDark, const Color(0xFF181B26));
    });

    test('boardGridLine whispers at ~2.5% white', () {
      expect(ColorTokens.boardGridLine.a, closeTo(0.024, 0.005));
    });

    test('boardShadow is the dedicated 55% drop-shadow tint', () {
      expect(ColorTokens.boardShadow.a, closeTo(0.55, 0.01));
    });
  });

  group('TextTokens — typography scale', () {
    test('display sizes are 52 / 44 with Bold weight', () {
      expect(TextTokens.displayLarge.fontSize, 52);
      expect(TextTokens.displayLarge.fontWeight, FontWeight.w700);
      expect(TextTokens.displayMedium.fontSize, 44);
      expect(TextTokens.displayMedium.fontWeight, FontWeight.w700);
    });

    test('display letter-spacing is -0.02em (tightened headlines)', () {
      // 52 px × -0.02 = -1.04 px
      expect(TextTokens.displayLarge.letterSpacing, closeTo(-1.04, 0.001));
      // 44 px × -0.02 = -0.88 px
      expect(TextTokens.displayMedium.letterSpacing, closeTo(-0.88, 0.001));
    });

    test('body / bodySmall / caption sizes are 16 / 14 / 12', () {
      expect(TextTokens.body.fontSize, 16);
      expect(TextTokens.bodySmall.fontSize, 14);
      expect(TextTokens.caption.fontSize, 12);
    });

    test('label is small-caps eyebrow style (11px, +1.65 tracking)', () {
      expect(TextTokens.label.fontSize, 11);
      expect(TextTokens.label.fontWeight, FontWeight.w600);
      expect(TextTokens.label.letterSpacing, closeTo(1.65, 0.001));
    });

    test('mono carries tabular-figure font feature for stable counters', () {
      expect(TextTokens.mono.fontFamily, 'monospace');
      expect(
        TextTokens.mono.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });

    test('each style has an explicit color (no inherited defaults)', () {
      final styles = <TextStyle>[
        TextTokens.displayLarge,
        TextTokens.displayMedium,
        TextTokens.headline,
        TextTokens.title,
        TextTokens.body,
        TextTokens.bodySmall,
        TextTokens.caption,
        TextTokens.mono,
        TextTokens.label,
        TextTokens.button,
      ];
      for (final s in styles) {
        expect(s.color, isNotNull, reason: 'all token styles ship a color');
      }
    });
  });

  group('SpacingTokens — eleven-step scale', () {
    test('values are exactly the documented integers', () {
      expect(SpacingTokens.s2, 2.0);
      expect(SpacingTokens.s4, 4.0);
      expect(SpacingTokens.s8, 8.0);
      expect(SpacingTokens.s12, 12.0);
      expect(SpacingTokens.s16, 16.0);
      expect(SpacingTokens.s20, 20.0);
      expect(SpacingTokens.s24, 24.0);
      expect(SpacingTokens.s32, 32.0);
      expect(SpacingTokens.s40, 40.0);
      expect(SpacingTokens.s48, 48.0);
      expect(SpacingTokens.s64, 64.0);
    });

    test('scale is strictly increasing', () {
      final scale = [
        SpacingTokens.s2,
        SpacingTokens.s4,
        SpacingTokens.s8,
        SpacingTokens.s12,
        SpacingTokens.s16,
        SpacingTokens.s20,
        SpacingTokens.s24,
        SpacingTokens.s32,
        SpacingTokens.s40,
        SpacingTokens.s48,
        SpacingTokens.s64,
      ];
      for (var i = 1; i < scale.length; i++) {
        expect(scale[i], greaterThan(scale[i - 1]));
      }
    });
  });

  group('RadiusTokens — six steps + BorderRadius convenience', () {
    test('Radius values increase monotonically through the named steps', () {
      expect(RadiusTokens.small.x, 6);
      expect(RadiusTokens.medium.x, 12);
      expect(RadiusTokens.large.x, 20);
      expect(RadiusTokens.xl.x, 28);
      expect(RadiusTokens.pill.x, 999);
      expect(RadiusTokens.circle.x, 9999);
    });

    test('BorderRadius helpers point at the matching Radius', () {
      expect(RadiusTokens.brSmall.topLeft, RadiusTokens.small);
      expect(RadiusTokens.brMedium.topLeft, RadiusTokens.medium);
      expect(RadiusTokens.brLarge.topLeft, RadiusTokens.large);
      expect(RadiusTokens.brXl.topLeft, RadiusTokens.xl);
      expect(RadiusTokens.brPill.topLeft, RadiusTokens.pill);
      expect(RadiusTokens.brCircle.topLeft, RadiusTokens.circle);
    });
  });

  group('ElevationTokens — six shadow tiers', () {
    test('base tiers carry increasing blur radius (low < medium < high)', () {
      expect(
        ElevationTokens.low.first.blurRadius,
        lessThan(ElevationTokens.medium.first.blurRadius),
      );
      expect(
        ElevationTokens.medium.first.blurRadius,
        lessThan(ElevationTokens.high.first.blurRadius),
      );
      expect(
        ElevationTokens.high.first.blurRadius,
        lessThan(ElevationTokens.floating.first.blurRadius),
      );
    });

    test('glow tiers use the accent colors, not the dark shadow', () {
      expect(ElevationTokens.glowDanger.first.color, ColorTokens.dangerGlow);
      expect(ElevationTokens.glowRelief.first.color, ColorTokens.reliefGlow);
    });

    test('glow tiers have zero offset (uniform radial bloom)', () {
      expect(ElevationTokens.glowDanger.first.offset, Offset.zero);
      expect(ElevationTokens.glowRelief.first.offset, Offset.zero);
    });
  });

  group('DurationTokens + CurveTokens — motion foundation', () {
    test('duration scale is 120 / 240 / 320 / 800 ms', () {
      expect(DurationTokens.fast, const Duration(milliseconds: 120));
      expect(DurationTokens.normal, const Duration(milliseconds: 240));
      expect(DurationTokens.slow, const Duration(milliseconds: 320));
      expect(DurationTokens.verySlow, const Duration(milliseconds: 800));
    });

    test('duration scale is strictly increasing', () {
      expect(DurationTokens.fast < DurationTokens.normal, isTrue);
      expect(DurationTokens.normal < DurationTokens.slow, isTrue);
      expect(DurationTokens.slow < DurationTokens.verySlow, isTrue);
    });

    test('curve scale exposes six named entries', () {
      // Sanity-check by name; values are framework-provided enums and
      // their identity is the contract.
      expect(CurveTokens.standard, isNotNull);
      expect(CurveTokens.emphasized, isNotNull);
      expect(CurveTokens.entrance, isNotNull);
      expect(CurveTokens.exit, isNotNull);
      expect(CurveTokens.overshoot, isNotNull);
      expect(CurveTokens.spring, isNotNull);
    });
  });

  group('MotionTokens — ambient board presence', () {
    test('long-period durations land at 7s / 28s / 250ms', () {
      expect(
        MotionTokens.ambientBrightnessPeriod,
        const Duration(milliseconds: 7000),
      );
      expect(
        MotionTokens.ambientLightDriftPeriod,
        const Duration(milliseconds: 28000),
      );
      expect(
        MotionTokens.ambientRescueExhale,
        const Duration(milliseconds: 250),
      );
    });

    test('amplitudes + rescued multiplier stay subtle', () {
      expect(MotionTokens.ambientBrightnessAmplitude, closeTo(0.015, 0.001));
      expect(MotionTokens.ambientLightDriftPeakAlpha, closeTo(0.025, 0.001));
      expect(MotionTokens.ambientGrainAmplitude, closeTo(0.02, 0.001));
      expect(MotionTokens.ambientRescuedAmplitudeMul, closeTo(0.6, 0.001));
      // Light drift must stay under the brief's 3% cap.
      expect(MotionTokens.ambientLightDriftPeakAlpha, lessThan(0.03));
    });
  });

  group('MotionTokens — PR-10B.2 release settle + arrival memory', () {
    test('release settle is 90 ms with min scale 0.985 (subtle compress)', () {
      expect(
        MotionTokens.releaseSettleDuration,
        const Duration(milliseconds: 90),
      );
      expect(MotionTokens.releaseSettleMinScale, closeTo(0.985, 0.0001));
      // Must compress (< 1.0), never overshoot.
      expect(MotionTokens.releaseSettleMinScale, lessThan(1.0));
    });

    test('arrival memory is 160 ms with peak alpha 0.12 (subliminal)', () {
      expect(
        MotionTokens.arrivalMemoryDuration,
        const Duration(milliseconds: 160),
      );
      expect(MotionTokens.arrivalMemoryPeakAlpha, closeTo(0.12, 0.0001));
      // Must stay below the subliminal threshold; rescue glow peaks
      // at 0.85 (PR-2 era), so the memory must remain a trace.
      expect(MotionTokens.arrivalMemoryPeakAlpha, lessThan(0.15));
    });
  });

  group('MotionTokens — PR-10B.1 selection halo + attention', () {
    test('selection halo breath cycle is 2800 ms (full period)', () {
      expect(
        MotionTokens.selectedHaloBreathPeriod,
        const Duration(milliseconds: 2800),
      );
    });

    test('halo breath alphas straddle the prior static 0.15 fill', () {
      expect(MotionTokens.selectedHaloMinAlpha, closeTo(0.12, 0.0001));
      expect(MotionTokens.selectedHaloMaxAlpha, closeTo(0.18, 0.0001));
      // Midpoint must equal the legacy fill so the change reads as
      // "breathing around" not as a brightness shift.
      final midpoint =
          (MotionTokens.selectedHaloMinAlpha +
              MotionTokens.selectedHaloMaxAlpha) /
          2;
      expect(midpoint, closeTo(0.15, 0.001));
    });

    test('non-selected friendly opacity is 0.94 (subtle 6% recede)', () {
      expect(MotionTokens.nonSelectedFriendlyOpacity, closeTo(0.94, 0.0001));
    });

    test('attention fade duration is 180 ms', () {
      expect(
        MotionTokens.attentionFadeDuration,
        const Duration(milliseconds: 180),
      );
    });
  });

  group('MotionTokens — PR-10A touch feel polish', () {
    test('selected piece lift is capped at 1.025 (was 1.05)', () {
      expect(MotionTokens.pieceLiftedScale, closeTo(1.025, 0.0001));
    });

    test('rescuedLiftedScale unchanged (different semantic state)', () {
      expect(MotionTokens.rescuedLiftedScale, closeTo(1.04, 0.0001));
    });

    test('legal dot tokens land at the documented values', () {
      expect(MotionTokens.legalDotEmptyScale, closeTo(0.22, 0.0001));
      expect(MotionTokens.legalDotEmptyAlpha, closeTo(0.75, 0.0001));
      expect(MotionTokens.legalDotOccupiedAlpha, closeTo(0.65, 0.0001));
    });
  });

  group('MotionTokens — PR-9A rescue motion polish', () {
    test('ring opacity-vs-radius ratio is the conservative 1.4', () {
      expect(MotionTokens.rescueRingOpacityVsRadiusRatio, closeTo(1.4, 0.001));
    });

    test('status pill transition is 180 ms', () {
      expect(
        MotionTokens.statusPillTransitionDuration,
        const Duration(milliseconds: 180),
      );
    });
  });

  group('MotionTokens — rescue ceremony', () {
    test('headline settle delay is the conservative 280 ms', () {
      expect(
        MotionTokens.rescueHeadlineSettleDelay,
        const Duration(milliseconds: 280),
      );
    });
  });

  group('MotionTokens — move arrow', () {
    test('three-phase durations land at 220 / 240 / 320 ms', () {
      expect(MotionTokens.moveArrowDraw, const Duration(milliseconds: 220));
      expect(MotionTokens.moveArrowHold, const Duration(milliseconds: 240));
      expect(MotionTokens.moveArrowFade, const Duration(milliseconds: 320));
    });

    test('alpha + head-start ratios reflect subtlety directive', () {
      expect(MotionTokens.moveArrowHeadStart, closeTo(0.80, 0.001));
      expect(MotionTokens.moveArrowPeakAlpha, closeTo(0.88, 0.001));
      expect(MotionTokens.moveArrowSettledAlpha, closeTo(0.50, 0.001));
    });
  });
}
