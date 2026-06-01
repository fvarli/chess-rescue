import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// R1B — non-blocking record-unlock banner shown at the bottom of
/// RescueScreen, above the FooterButton. Does NOT block board taps. Auto-
/// dismisses after [holdDuration]. Queued one at a time by the host
/// (RescueScreen) with a small gap; this widget owns only its own
/// fade-in / hold / fade-out lifecycle.
///
/// Variants:
/// - Standard: eyebrow uses `recordUnlockEyebrow` ("✓ RECORD UNLOCKED")
///   in mono uppercase
/// - First-record-ever: eyebrow uses italic sentence-case
///   `recordUnlockEyebrowFirstEver` ("A page has been written.")
///
/// Tap dismisses early.
class RecordUnlockOverlay extends StatefulWidget {
  const RecordUnlockOverlay({
    super.key,
    required this.eyebrow,
    required this.eyebrowIsFirstEver,
    required this.title,
    required this.description,
    required this.onDismissed,
  });

  /// Pre-resolved eyebrow text (the host picks the variant).
  final String eyebrow;

  /// True when [eyebrow] is the "A page has been written." italic sentence.
  /// Drives style (italic, sentence-case AppText.body) vs the standard mono
  /// uppercase eyebrow.
  final bool eyebrowIsFirstEver;
  final String title;
  final String description;
  final VoidCallback onDismissed;

  static const Duration fadeIn = Duration(milliseconds: 240);
  static const Duration hold = Duration(milliseconds: 2500);
  static const Duration fadeOut = Duration(milliseconds: 200);

  @override
  State<RecordUnlockOverlay> createState() => _RecordUnlockOverlayState();
}

class _RecordUnlockOverlayState extends State<RecordUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alpha;
  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    final total = RecordUnlockOverlay.fadeIn + RecordUnlockOverlay.fadeOut;
    _ctrl = AnimationController(vsync: this, duration: total);
    final fadeInWeight =
        RecordUnlockOverlay.fadeIn.inMilliseconds / total.inMilliseconds;
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
    // Fade-in.
    _ctrl.duration = RecordUnlockOverlay.fadeIn;
    await _ctrl.animateTo(
      RecordUnlockOverlay.fadeIn.inMilliseconds /
          (RecordUnlockOverlay.fadeIn + RecordUnlockOverlay.fadeOut)
              .inMilliseconds,
    );
    if (_dismissed || !mounted) return;
    // Hold.
    _dismissTimer = Timer(RecordUnlockOverlay.hold, () {
      if (_dismissed || !mounted) return;
      _fadeOutAndDismiss();
    });
  }

  Future<void> _fadeOutAndDismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    _dismissTimer?.cancel();
    _ctrl.duration = RecordUnlockOverlay.fadeOut;
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
    return AnimatedBuilder(
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
      child: GestureDetector(
        onTap: _fadeOutAndDismiss,
        child: Container(
          key: const ValueKey('record-unlock-overlay'),
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
              if (widget.eyebrowIsFirstEver)
                Text(
                  widget.eyebrow,
                  style: AppText.body.copyWith(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.text,
                  ),
                )
              else
                Text(
                  widget.eyebrow,
                  style: AppText.mono.copyWith(
                    fontSize: 10,
                    color: AppColors.rescue,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: AppText.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.description,
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
