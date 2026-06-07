import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/theme/animations/archetypes.dart';

// v1.2.0 "Threshold" foundation — animation archetype primitives test net.
//
// Each archetype is a thin wrapper around Flutter implicit-animation
// machinery. The tests below verify:
//   1. The widget mounts without error.
//   2. The animated property reaches its target after the documented
//      duration window.
//   3. Looping archetypes keep ticking (their controller is `isAnimating`).

Widget _wrap(Widget child) => MediaQuery(
  data: const MediaQueryData(),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FadeInArchetype', () {
    testWidgets('opacity reaches 1.0 after duration', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FadeInArchetype(
            duration: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      // Initial post-frame schedules the opacity flip.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 1.0);
    });
  });

  group('FadeOutArchetype', () {
    testWidgets('opacity drops to 0 when visible flips false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FadeOutArchetype(
            visible: true,
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1.0,
      );

      await tester.pumpWidget(
        _wrap(
          const FadeOutArchetype(
            visible: false,
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0.0,
      );
    });
  });

  group('ScaleArchetype', () {
    testWidgets('scale settles at `to` after the animation completes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ScaleArchetype(
            from: 0.5,
            to: 1.0,
            duration: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      // Settle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Find the transform applied to the SizedBox.
      final transform = tester.widget<Transform>(find.byType(Transform).first);
      // Final transform should be approximately identity scale.
      // We check via the matrix's diagonal x component.
      final scale = transform.transform.getRow(0).x;
      expect(scale, closeTo(1.0, 0.001));
    });
  });

  group('SlideArchetype', () {
    testWidgets('child mounts and settles to zero translation', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SlideArchetype(
            from: Offset(0, 0.5),
            duration: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      final translation = tester.widget<FractionalTranslation>(
        find.byType(FractionalTranslation),
      );
      expect(translation.translation.dx, closeTo(0.0, 0.001));
      expect(translation.translation.dy, closeTo(0.0, 0.001));
    });
  });

  group('HeroArchetype', () {
    testWidgets('mounts, runs through, lands at full opacity + 1.0 scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const HeroArchetype(
            duration: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Settled: opacity should be 1.0 (last Opacity in the tree).
      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .toList();
      expect(opacities, isNotEmpty);
      expect(opacities.last.opacity, closeTo(1.0, 0.001));
    });
  });

  group('PulseArchetype', () {
    testWidgets('completes one cycle and returns toward original scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PulseArchetype(
            peak: 1.10,
            duration: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      // Mid-pulse: scale should be near peak.
      await tester.pump(const Duration(milliseconds: 100));
      // End: scale should be near 1.0.
      await tester.pump(const Duration(milliseconds: 120));

      final transform = tester.widget<Transform>(find.byType(Transform).first);
      final scale = transform.transform.getRow(0).x;
      expect(scale, closeTo(1.0, 0.05));
    });
  });

  group('GlowPulseArchetype', () {
    testWidgets('keeps animating while mounted (does not settle)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const GlowPulseArchetype(
            period: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final scale1 = tester
          .widget<Transform>(find.byType(Transform).first)
          .transform
          .getRow(0)
          .x;
      await tester.pump(const Duration(milliseconds: 100));
      final scale2 = tester
          .widget<Transform>(find.byType(Transform).first)
          .transform
          .getRow(0)
          .x;
      // Two samples 100ms apart should differ — the loop is ticking.
      expect(scale1, isNot(closeTo(scale2, 0.0001)));
      // Cleanup so the controller doesn't leak past the test.
      await tester.pumpWidget(_wrap(const SizedBox()));
    });
  });

  group('AttentionArchetype', () {
    testWidgets('plays a damped oscillation and settles', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AttentionArchetype(
            amplitudePx: 4,
            cycles: 2,
            duration: Duration(milliseconds: 200),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      await tester.pump();
      // Mid-attention: there should be a non-zero horizontal offset.
      await tester.pump(const Duration(milliseconds: 50));
      final midTransform = tester.widget<Transform>(
        find.byType(Transform).first,
      );
      final midOffsetX = midTransform.transform.getTranslation().x;
      // We don't pin a specific value (envelope + sine = variable);
      // we only assert that motion actually happened.
      expect(midOffsetX.abs(), greaterThan(0));

      // End: dampens back to ~0.
      await tester.pump(const Duration(milliseconds: 200));
      final endTransform = tester.widget<Transform>(
        find.byType(Transform).first,
      );
      final endOffsetX = endTransform.transform.getTranslation().x;
      expect(endOffsetX.abs(), lessThan(0.5));
    });
  });
}
