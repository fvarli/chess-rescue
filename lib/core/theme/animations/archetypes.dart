import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/motion.dart';

/// Animation archetype primitives — eight reusable widgets for v1.2.0.
///
/// Each archetype is a thin wrapper around Flutter's implicit-animation
/// machinery, parameterized by tokens from `lib/core/theme/tokens/motion.dart`
/// (overridable per call). The archetypes are **not used anywhere yet** —
/// they are deliberate primitives for later PRs to consume.
///
/// **Naming:** each widget is named for its action (`FadeInArchetype`,
/// `PulseArchetype`, etc.). The `Archetype` suffix avoids name collisions
/// with framework widgets and signals intent at call sites.
///
/// **One-shot vs looping:** `FadeIn`, `FadeOut`, `ScaleArchetype`,
/// `SlideArchetype`, `HeroArchetype`, `PulseArchetype` run once on first
/// build. `GlowPulseArchetype` and `AttentionArchetype` loop until they
/// are removed from the tree.

// ── One-shot archetypes ─────────────────────────────────────────────────

/// Fade in: opacity `0 → 1` over [duration] using [curve].
///
/// On first build, the child fades up from invisible. Re-builds of the
/// same widget do not re-trigger; if you need to replay, change the
/// widget's [Key].
class FadeInArchetype extends StatefulWidget {
  const FadeInArchetype({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final Duration delay;

  @override
  State<FadeInArchetype> createState() => _FadeInArchetypeState();
}

class _FadeInArchetypeState extends State<FadeInArchetype> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delay > Duration.zero) {
        await Future<void>.delayed(widget.delay);
      }
      if (mounted) setState(() => _opacity = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.duration ?? DurationTokens.normal,
      curve: widget.curve ?? CurveTokens.entrance,
      child: widget.child,
    );
  }
}

/// Fade out: opacity `1 → 0` over [duration] using [curve].
///
/// Triggered when [visible] flips false. While [visible] is true, the
/// child stays at full opacity.
class FadeOutArchetype extends StatelessWidget {
  const FadeOutArchetype({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
    this.curve,
  });

  final Widget child;
  final bool visible;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration ?? DurationTokens.normal,
      curve: curve ?? CurveTokens.exit,
      child: child,
    );
  }
}

/// Scale animation: `from → to` over [duration] using [curve].
///
/// Settles at [to] after duration. Re-renders with a new [to] re-animate
/// from the current scale.
class ScaleArchetype extends StatelessWidget {
  const ScaleArchetype({
    super.key,
    required this.child,
    this.from = 0.94,
    this.to = 1.0,
    this.duration,
    this.curve,
  });

  final Widget child;
  final double from;
  final double to;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from, end: to),
      duration: duration ?? DurationTokens.normal,
      curve: curve ?? CurveTokens.entrance,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: child,
    );
  }
}

/// Slide animation: `from → Offset.zero` over [duration] using [curve].
///
/// `from` is a fractional offset (`Offset(0, 0.1)` slides up from 10% of
/// the widget's own height). Aligns with `AnimatedSlide`'s convention.
class SlideArchetype extends StatelessWidget {
  const SlideArchetype({
    super.key,
    required this.child,
    this.from = const Offset(0, 0.1),
    this.duration,
    this.curve,
  });

  final Widget child;
  final Offset from;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: from, end: Offset.zero),
      duration: duration ?? DurationTokens.slow,
      curve: curve ?? CurveTokens.entrance,
      builder: (context, value, child) =>
          FractionalTranslation(translation: value, child: child),
      child: child,
    );
  }
}

/// Hero entrance: combined fade-in + scale-up.
///
/// Designed for cinematic surface intros (Daily Rescue briefing, Success
/// state headline). Opacity `0 → 1` and scale `0.92 → 1.0` over [duration],
/// with [curve] applied to both.
class HeroArchetype extends StatelessWidget {
  const HeroArchetype({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.fromScale = 0.92,
  });

  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final double fromScale;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration ?? DurationTokens.verySlow,
      curve: curve ?? CurveTokens.emphasized,
      builder: (context, t, child) {
        final scale = fromScale + (1.0 - fromScale) * t;
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }
}

/// Pulse: one-shot scale-up-then-down over [duration].
///
/// Useful for "look at me" affirmation on a single event (record unlock,
/// rescue confirmation chip). For ambient breathing, use
/// [GlowPulseArchetype] instead.
class PulseArchetype extends StatefulWidget {
  const PulseArchetype({
    super.key,
    required this.child,
    this.peak = 1.06,
    this.duration,
    this.curve,
  });

  final Widget child;
  final double peak;
  final Duration? duration;
  final Curve? curve;

  @override
  State<PulseArchetype> createState() => _PulseArchetypeState();
}

class _PulseArchetypeState extends State<PulseArchetype>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? DurationTokens.slow,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = widget.curve ?? CurveTokens.standard;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Pulse: 0 -> 1 over first half, 1 -> 0 over second half.
        final v = t < 0.5 ? (t * 2) : ((1 - t) * 2);
        final eased = curve.transform(v.clamp(0.0, 1.0));
        final scale = 1.0 + (widget.peak - 1.0) * eased;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

// ── Looping archetypes ──────────────────────────────────────────────────

/// Glow pulse: ambient looping breath of scale + opacity.
///
/// Loops until removed from the tree. Designed for "alive at rest" surfaces
/// (Today's puzzle card hover state, CTA-attract pulse). Uses sine easing
/// for an organic breathing feel, distinct from the per-feature
/// `MotionTokens.dangerPulse` (which uses a custom inhale/exhale weight).
class GlowPulseArchetype extends StatefulWidget {
  const GlowPulseArchetype({
    super.key,
    required this.child,
    this.scaleMin = 1.0,
    this.scaleMax = 1.012,
    this.period,
  });

  final Widget child;
  final double scaleMin;
  final double scaleMax;
  final Duration? period;

  @override
  State<GlowPulseArchetype> createState() => _GlowPulseArchetypeState();
}

class _GlowPulseArchetypeState extends State<GlowPulseArchetype>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period ?? const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Sine wave through full cycle: 0 → 1 → 0
        final t = _controller.value;
        final wave = 0.5 - 0.5 * (1 - 2 * (t - 0.5).abs());
        final scale =
            widget.scaleMin + (widget.scaleMax - widget.scaleMin) * wave;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// Attention: subtle one-shot horizontal oscillation. "Look here" nudge.
///
/// Plays once on first build, then settles. Re-trigger by changing the
/// widget's [Key]. Use sparingly; an over-shaken UI feels frantic, the
/// opposite of the Threshold register.
class AttentionArchetype extends StatefulWidget {
  const AttentionArchetype({
    super.key,
    required this.child,
    this.amplitudePx = 2.0,
    this.cycles = 3,
    this.duration,
  });

  final Widget child;
  final double amplitudePx;
  final int cycles;
  final Duration? duration;

  @override
  State<AttentionArchetype> createState() => _AttentionArchetypeState();
}

class _AttentionArchetypeState extends State<AttentionArchetype>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 240),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Damped sine: amplitude × sin(2π·cycles·t) × (1 - t)
        // (envelope decays from full to zero as t → 1)
        final omega = 2 * math.pi * widget.cycles;
        final wave = math.sin(omega * t);
        final envelope = 1.0 - t;
        final dx = widget.amplitudePx * wave * envelope;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
