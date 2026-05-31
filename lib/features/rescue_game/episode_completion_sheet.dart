import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// G1.1 — Episode Completion Sheet.
///
/// In-context modal sheet that appears ON the RescueScreen *before* the
/// navigator pop, anchored over a dimmed board. Renders "✓ EPISODE COMPLETE"
/// (or "✓ TRILOGY COMPLETE" for Ep3), the episode number, the pre-uppercased
/// title, the rescue count, and a mint Continue CTA that fires [onContinue]
/// — which should call `Navigator.maybePop<bool>(true)` to preserve the P3.1
/// completion-signal protocol.
///
/// Fade-in + tiny slide-up (~280 ms) — "relief, not victory royale".
class EpisodeCompletionSheet extends StatefulWidget {
  const EpisodeCompletionSheet({
    super.key,
    required this.eyebrow,
    required this.episodeLabel,
    required this.title,
    required this.rescuesCount,
    required this.continueLabel,
    required this.onContinue,
    this.trilogyUnlockLabel,
  });

  final String eyebrow;
  final String episodeLabel;
  final String title;
  final String rescuesCount;
  final String continueLabel;
  final String? trilogyUnlockLabel;
  final VoidCallback onContinue;

  @override
  State<EpisodeCompletionSheet> createState() => _EpisodeCompletionSheetState();
}

class _EpisodeCompletionSheetState extends State<EpisodeCompletionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTrilogy = widget.trilogyUnlockLabel != null;
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black.withValues(alpha: 0.55 * t)),
            Center(
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - t)),
                child: Opacity(opacity: t, child: child),
              ),
            ),
          ],
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          key: const ValueKey('episode-completion-sheet'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.hairline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.eyebrow,
                textAlign: TextAlign.center,
                style: AppText.mono.copyWith(
                  color: AppColors.danger,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.episodeLabel,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textDim,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppText.headline.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.rescuesCount,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  fontSize: 15,
                  color: AppColors.textDim,
                ),
              ),
              if (hasTrilogy) ...[
                const SizedBox(height: 10),
                Text(
                  widget.trilogyUnlockLabel!,
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(
                    fontSize: 14,
                    color: AppColors.rescue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _ContinueButton(
                label: widget.continueLabel,
                onTap: widget.onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.rescue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.rescue.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppText.button.copyWith(color: AppColors.onRescue),
          ),
        ),
      ),
    );
  }
}
