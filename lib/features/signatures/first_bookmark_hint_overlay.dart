import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// PR 2 — one-time inline hint shown on the rescued screen the first
/// ever time the player bookmarks a rescue. Articulates signature-
/// worthiness through *relationship copy* (per
/// [[feedback-name-the-relationship-not-the-criteria]]):
///   L1: "Saved."
///   L2: "Keep the rescues that stay with you."
///
/// Lifecycle modeled on [RecordUnlockOverlay]: fade-in / hold /
/// fade-out, ~3 seconds total. Non-interactive — tapping the rest of
/// the screen still works; the banner does not block input.
class FirstBookmarkHintOverlay extends StatefulWidget {
  const FirstBookmarkHintOverlay({super.key, required this.onDismissed});

  final VoidCallback onDismissed;

  static const Duration fadeIn = Duration(milliseconds: 240);
  static const Duration hold = Duration(milliseconds: 2500);
  static const Duration fadeOut = Duration(milliseconds: 240);

  @override
  State<FirstBookmarkHintOverlay> createState() =>
      _FirstBookmarkHintOverlayState();
}

class _FirstBookmarkHintOverlayState extends State<FirstBookmarkHintOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alpha;
  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    final total =
        FirstBookmarkHintOverlay.fadeIn + FirstBookmarkHintOverlay.fadeOut;
    _ctrl = AnimationController(vsync: this, duration: total);
    final fadeInWeight =
        FirstBookmarkHintOverlay.fadeIn.inMilliseconds / total.inMilliseconds;
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
    _ctrl.duration = FirstBookmarkHintOverlay.fadeIn;
    await _ctrl.animateTo(
      FirstBookmarkHintOverlay.fadeIn.inMilliseconds /
          (FirstBookmarkHintOverlay.fadeIn + FirstBookmarkHintOverlay.fadeOut)
              .inMilliseconds,
    );
    if (_dismissed || !mounted) return;
    _dismissTimer = Timer(FirstBookmarkHintOverlay.hold, () {
      if (_dismissed || !mounted) return;
      _fadeOutAndDismiss();
    });
  }

  Future<void> _fadeOutAndDismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    _dismissTimer?.cancel();
    _ctrl.duration = FirstBookmarkHintOverlay.fadeOut;
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
          key: const ValueKey('first-bookmark-hint-overlay'),
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
                l.signaturesFirstBookmarkHintLine1,
                style: AppText.mono.copyWith(
                  fontSize: 10,
                  color: AppColors.textDim,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.signaturesFirstBookmarkHintLine2,
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
