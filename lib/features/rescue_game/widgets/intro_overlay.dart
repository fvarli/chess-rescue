import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../../../l10n/gen/app_localizations.dart';

// One-time, first-run intro. A calm, premium single screen that frames the
// emotional premise (danger → one move → relief) before the first puzzle, then
// is dismissed by its CTA. Not a tutorial: no menus, no chess lessons. Shown
// only when a real store reports introSeen == false.
class IntroOverlay extends StatelessWidget {
  const IntroOverlay({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    // Opaque background absorbs stray taps so the board behind stays inert.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.9,
            colors: [AppColors.backdropDanger, AppColors.bg],
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      t.introTitle,
                      textAlign: TextAlign.center,
                      style: AppText.headline.copyWith(
                        fontSize: 28,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.introBody,
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.introSecondary,
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 40),
                    _StartRescueButton(label: t.introCta, onTap: onStart),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Mint "way out" CTA, mirroring the rescued FooterButton's language
// (rounded pill, rescue fill, soft glow, immediate press-in).
class _StartRescueButton extends StatefulWidget {
  const _StartRescueButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_StartRescueButton> createState() => _StartRescueButtonState();
}

class _StartRescueButtonState extends State<_StartRescueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? MotionTokens.buttonPressedScale : 1.0,
          duration: _pressed
              ? MotionTokens.buttonPressIn
              : MotionTokens.buttonPressOut,
          curve: MotionTokens.press,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.rescue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rescue.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: AppText.button.copyWith(color: AppColors.onRescue),
            ),
          ),
        ),
      ),
    );
  }
}
