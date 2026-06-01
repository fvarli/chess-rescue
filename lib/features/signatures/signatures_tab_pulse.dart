import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';

/// PR 2 — generic decorator that wraps a target child and animates a
/// one-time mint border-glow around it when the player FIRST opens the
/// Records modal after their first bookmark. Pulse is gated on:
///
/// 1. The first-bookmark inline hint has fired (
///    `hasSeenSignaturesFirstBookmarkHint == true` — meaning the
///    player has actually saved something before)
/// 2. The tab pulse itself has not been seen yet (
///    `hasSeenSignaturesTabPulse == false`)
///
/// When both conditions hold, the pulse animates 2s (one full
/// breathing cycle) and the seen-flag is marked on first animation
/// frame so a mid-cycle modal-close doesn't re-fire the pulse on the
/// next open.
///
/// Per [[feedback-prefer-subtlety-first]], the pulse stays at the
/// subtle end of the design range: alpha 0 → 0.6 → 0, 1px border.
///
/// Extractability: the widget wraps an arbitrary [child] and decorates
/// it. It does NOT assume the child is part of any specific segmented
/// control — a future home-screen tile could wrap itself the same way.
class SignaturesTabPulse extends StatefulWidget {
  const SignaturesTabPulse({
    super.key,
    required this.store,
    required this.child,
  });

  final ProgressStore? store;
  final Widget child;

  static const Duration period = Duration(seconds: 2);

  @override
  State<SignaturesTabPulse> createState() => _SignaturesTabPulseState();
}

class _SignaturesTabPulseState extends State<SignaturesTabPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alpha;
  bool _shouldPulse = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: SignaturesTabPulse.period,
    );
    // 0 → 0.6 → 0 in one cycle.
    _alpha = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.6,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_ctrl);

    final store = widget.store;
    if (store != null &&
        store.hasSeenSignaturesFirstBookmarkHint &&
        !store.hasSeenSignaturesTabPulse) {
      _shouldPulse = true;
      // Mark seen BEFORE the animation starts so a mid-cycle close
      // doesn't re-fire on the next open.
      unawaited(store.markSignaturesTabPulseSeen());
      // Schedule the animation to fire on the next frame so the
      // wrapped child is mounted before the border starts breathing.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldPulse) return widget.child;
    return AnimatedBuilder(
      animation: _alpha,
      builder: (context, child) {
        final t = _alpha.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.rescue.withValues(alpha: t),
              width: 1,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
