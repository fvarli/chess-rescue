import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// PR 3 — one-time inline hint shown on the rescued screen the first
/// ever time the player re-encounters a previously-solved puzzle.
/// Modeled directly on `FirstBookmarkHintOverlay` (PR 2): same
/// fade-in / hold / fade-out lifecycle, same non-interactive
/// `IgnorePointer` wrapping.
///
/// Two text lines:
///   L1: `familiarCueLabel` (FAMILIAR / AŞİNA / FAMILIAR), mono small-caps
///   L2: `familiarFirstSeenHintLine` ("You know this one.")
///
/// L2 is intentionally short and in the player's own internal voice —
/// per [[feedback-show-the-feeling-not-the-system]], the designer's
/// hand stays invisible. No "the game notices" framing.
class FamiliarityFirstSeenOverlay extends StatefulWidget {
  const FamiliarityFirstSeenOverlay({super.key, required this.onDismissed});

  final VoidCallback onDismissed;

  static const Duration fadeIn = Duration(milliseconds: 240);
  static const Duration hold = Duration(milliseconds: 2500);
  static const Duration fadeOut = Duration(milliseconds: 240);

  @override
  State<FamiliarityFirstSeenOverlay> createState() =>
      _FamiliarityFirstSeenOverlayState();
}

class _FamiliarityFirstSeenOverlayState
    extends State<FamiliarityFirstSeenOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alpha;
  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    final total =
        FamiliarityFirstSeenOverlay.fadeIn +
        FamiliarityFirstSeenOverlay.fadeOut;
    _ctrl = AnimationController(vsync: this, duration: total);
    final fadeInWeight =
        FamiliarityFirstSeenOverlay.fadeIn.inMilliseconds /
        total.inMilliseconds;
    _alpha = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: fadeInWeight * 100,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: (1 - fadeInWeight) * 100,
      ),
    ]).animate(_ctrl);
    _runLifecycle();
  }

  Future<void> _runLifecycle() async {
    _ctrl.duration = FamiliarityFirstSeenOverlay.fadeIn;
    await _ctrl.animateTo(
      FamiliarityFirstSeenOverlay.fadeIn.inMilliseconds /
          (FamiliarityFirstSeenOverlay.fadeIn +
                  FamiliarityFirstSeenOverlay.fadeOut)
              .inMilliseconds,
    );
    if (_dismissed || !mounted) return;
    _dismissTimer = Timer(FamiliarityFirstSeenOverlay.hold, () {
      if (_dismissed || !mounted) return;
      _fadeOutAndDismiss();
    });
  }

  Future<void> _fadeOutAndDismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    _dismissTimer?.cancel();
    _ctrl.duration = FamiliarityFirstSeenOverlay.fadeOut;
    await _ctrl.animateTo(1.0);
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _alpha,
        builder: (context, child) {
          final t = _alpha.value;
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - t)),
              child: child,
            ),
          );
        },
        child: Container(
          key: const ValueKey('familiarity-first-seen-overlay'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.familiarCueLabel,
                style: AppText.mono.copyWith(
                  fontSize: 10,
                  color: AppColors.textDim,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.familiarFirstSeenHintLine,
                style: AppText.body.copyWith(
                  fontSize: 12,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
